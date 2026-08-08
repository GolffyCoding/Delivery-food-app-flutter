import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_network/opendelivery_network.dart';
import 'package:opendelivery_state_machine/opendelivery_state_machine.dart';
import 'package:merchant_app/data/merchant_order_datasource.dart';

sealed class MerchantOrderEvent {}

class LoadOrders extends MerchantOrderEvent {
  final String restaurantId;
  LoadOrders(this.restaurantId);
}

class UpdateLocalOrderStatus extends MerchantOrderEvent {
  final String orderId;
  final OrderEvent event;
  final String backendStatus;
  UpdateLocalOrderStatus(this.orderId, this.event, this.backendStatus);
}

class OrderLineItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderLineItem({required this.name, required this.quantity, required this.unitPrice});

  double get subtotal => unitPrice * quantity;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        name: json['name'] as String? ?? 'Item',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Local UI model combining the strict [OrderState] with the display data a
/// kitchen display card needs.
class KanbanOrder {
  final String id;
  final String customerName;
  final String itemsSummary;
  final List<OrderLineItem> items;
  final double total;
  final OrderState state;
  final DateTime? acceptedAt;
  // Set the moment the kitchen marks the order "Ready" — distinct from
  // [acceptedAt] because a real complaint from delivery-app reviews is food
  // going cold while it sits waiting for a rider *after* it's ready, which
  // is a different (and more urgent) clock than "time since accepted".
  final DateTime? readyAt;
  final String? assignedDriverName;

  const KanbanOrder({
    required this.id,
    required this.customerName,
    required this.itemsSummary,
    this.items = const [],
    this.total = 0,
    required this.state,
    this.acceptedAt,
    this.readyAt,
    this.assignedDriverName,
  });

  Duration get timeInState {
    if (acceptedAt == null) return Duration.zero;
    return DateTime.now().difference(acceptedAt!);
  }

  /// How long this order has been sitting in [ReadyState] waiting for a
  /// driver to pick it up. Zero if it hasn't reached "ready" yet.
  Duration get waitingForPickupDuration {
    if (readyAt == null) return Duration.zero;
    return DateTime.now().difference(readyAt!);
  }

  KanbanOrder copyWith({OrderState? state, DateTime? acceptedAt, DateTime? readyAt, String? assignedDriverName}) {
    return KanbanOrder(
      id: id,
      customerName: customerName,
      itemsSummary: itemsSummary,
      items: items,
      total: total,
      state: state ?? this.state,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      readyAt: readyAt ?? this.readyAt,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
    );
  }
}

class MerchantOrderState {
  final bool isLoading;
  final List<KanbanOrder> newOrders;
  final List<KanbanOrder> preparingOrders;
  final List<KanbanOrder> readyOrders;
  // One-shot error surfaced to the UI when a status update is rejected by the
  // backend (e.g. a driver already picked up the order the merchant is trying
  // to cancel). Null means "nothing to show".
  final String? actionError;

  const MerchantOrderState({
    this.isLoading = false,
    this.newOrders = const [],
    this.preparingOrders = const [],
    this.readyOrders = const [],
    this.actionError,
  });
}

class MerchantOrderBloc extends Bloc<MerchantOrderEvent, MerchantOrderState> {
  final MerchantOrderDatasource _datasource;
  final Map<String, OrderStateMachine> _machines = {};
  final Map<String, KanbanOrder> _orderCache = {};
  String? _restaurantId;

  MerchantOrderBloc(this._datasource) : super(const MerchantOrderState()) {
    on<LoadOrders>(_onLoad);
    on<UpdateLocalOrderStatus>(_onUpdateLocal);
  }

  Future<void> _onLoad(LoadOrders event, Emitter<MerchantOrderState> emit) async {
    _restaurantId = event.restaurantId;
    emit(const MerchantOrderState(isLoading: true));
    try {
      final json = await _datasource.listOrders(event.restaurantId);
      _orderCache.clear();
      _machines.clear();
      for (final raw in json) {
        final order = raw as Map<String, dynamic>;
        final id = (order['id'] ?? '').toString();
        final status = order['status'] as String? ?? 'pending';
        final machine = OrderStateMachine();
        _fastForward(machine, status);
        _machines[id] = machine;
        final items = (order['items'] as List<dynamic>?)
                ?.map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [];
        _orderCache[id] = KanbanOrder(
          id: id,
          customerName: order['customer_name'] as String? ?? 'Customer',
          itemsSummary: _summarize(order['items'] as List<dynamic>?),
          items: items,
          total: (order['total'] as num?)?.toDouble() ?? items.fold(0.0, (sum, i) => sum + i.subtotal),
          state: machine.currentState,
          acceptedAt: order['accepted_at'] != null ? DateTime.tryParse(order['accepted_at'] as String) : null,
          readyAt: order['ready_at'] != null ? DateTime.tryParse(order['ready_at'] as String) : null,
          assignedDriverName: order['driver_name'] as String?,
        );
      }
      emit(_buildGroupedState());
    } catch (e) {
      AppLogger.error('Failed to load merchant orders', error: e, tag: 'MerchantOrder');
      emit(_buildGroupedState());
    }
  }

  // The backend is the source of truth for whether this transition is still
  // legal: a driver may have already picked up (or been assigned) the same
  // order between the merchant loading the board and tapping this button.
  // We therefore confirm with the server *before* mutating local state —
  // updating optimistically first (the previous behaviour) meant a rejected
  // write left the kitchen display showing a status the backend never
  // accepted, with no rollback and no indication to the merchant.
  Future<void> _onUpdateLocal(UpdateLocalOrderStatus event, Emitter<MerchantOrderState> emit) async {
    final machine = _machines.putIfAbsent(event.orderId, () => OrderStateMachine());
    if (!machine.canEmit(event.event)) {
      AppLogger.error('Merchant invalid transition for ${event.orderId}', tag: 'MerchantOrder');
      emit(_buildGroupedState(actionError: 'That order has already moved on. Refreshing…'));
      add(LoadOrders(_restaurantId ?? ''));
      return;
    }

    try {
      await _datasource.updateStatus(event.orderId, event.backendStatus);
    } on NetworkException catch (e) {
      if (e.type == NetworkExceptionType.conflict) {
        // Someone else (driver, another merchant device) moved this order
        // first. Don't apply the local transition — reload from the server
        // so the board reflects reality instead of a stale guess.
        AppLogger.error('Order status conflict for ${event.orderId}', error: e, tag: 'MerchantOrder');
        emit(_buildGroupedState(actionError: 'This order was already updated elsewhere. Refreshing…'));
        add(LoadOrders(_restaurantId ?? ''));
        return;
      }
      AppLogger.error('Failed to sync order status', error: e, tag: 'MerchantOrder');
      emit(_buildGroupedState(actionError: 'Could not update the order. Please try again.'));
      return;
    } catch (e) {
      AppLogger.error('Failed to sync order status', error: e, tag: 'MerchantOrder');
      emit(_buildGroupedState(actionError: 'Could not update the order. Please try again.'));
      return;
    }

    final newState = machine.emit(event.event);
    final cached = _orderCache[event.orderId];
    if (cached != null) {
      _orderCache[event.orderId] = cached.copyWith(
        state: newState,
        acceptedAt: newState is AcceptedState ? DateTime.now() : cached.acceptedAt,
        readyAt: newState is ReadyState ? DateTime.now() : cached.readyAt,
      );
    }
    emit(_buildGroupedState());
  }

  void _fastForward(OrderStateMachine machine, String status) {
    const order = ['accepted', 'preparing', 'ready', 'picked_up', 'delivering', 'delivered'];
    const events = [AcceptEvent(), StartPreparingEvent(), FinishPreparingEvent(), PickUpEvent(), StartDeliveringEvent(), DeliverEvent()];
    final targetIndex = order.indexOf(status);
    if (targetIndex == -1) return;
    for (var i = 0; i <= targetIndex; i++) {
      machine.emit(events[i]);
    }
  }

  String _summarize(List<dynamic>? items) {
    if (items == null || items.isEmpty) return 'No items';
    return items.map((e) => '${(e as Map)['quantity']}x ${e['name']}').join(', ');
  }

  MerchantOrderState _buildGroupedState({String? actionError}) {
    final newOrders = <KanbanOrder>[];
    final preparingOrders = <KanbanOrder>[];
    final readyOrders = <KanbanOrder>[];

    for (final order in _orderCache.values) {
      switch (order.state) {
        case PendingState():
        case AcceptedState():
          newOrders.add(order);
        case PreparingState():
          preparingOrders.add(order);
        case ReadyState():
          readyOrders.add(order);
        default:
          break;
      }
    }

    return MerchantOrderState(
      newOrders: newOrders,
      preparingOrders: preparingOrders,
      readyOrders: readyOrders,
      actionError: actionError,
    );
  }

  String? get restaurantId => _restaurantId;
}
