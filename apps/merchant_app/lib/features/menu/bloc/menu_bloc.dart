import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:merchant_app/data/menu_datasource.dart';
import 'package:merchant_app/domain/models/menu_item_model.dart';

sealed class MenuEvent {}

class LoadMenu extends MenuEvent {
  final String restaurantId;
  LoadMenu(this.restaurantId);
}

class ToggleAvailability extends MenuEvent {
  final String itemId;
  ToggleAvailability(this.itemId);
}

class AddMenuItem extends MenuEvent {
  final String restaurantId;
  final MenuItemModel item;
  AddMenuItem(this.restaurantId, this.item);
}

class MenuState {
  final List<MenuItemModel> items;
  final bool isLoading;
  const MenuState({this.items = const [], this.isLoading = false});

  List<MenuItemModel> get lowStockItems => items.where((item) => item.isLowStock || item.isOutOfStock).toList();
}

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuDatasource _datasource;

  MenuBloc(this._datasource) : super(const MenuState()) {
    on<LoadMenu>(_onLoad);
    on<ToggleAvailability>(_onToggle);
    on<AddMenuItem>(_onAdd);
  }

  Future<void> _onLoad(LoadMenu event, Emitter<MenuState> emit) async {
    emit(const MenuState(isLoading: true));
    try {
      final json = await _datasource.getItems(event.restaurantId);
      emit(MenuState(items: json.map((e) => _fromJson(e as Map<String, dynamic>)).toList()));
    } catch (e) {
      AppLogger.error('Failed to load menu', error: e, tag: 'Menu');
      emit(const MenuState());
    }
  }

  Future<void> _onToggle(ToggleAvailability event, Emitter<MenuState> emit) async {
    final updatedItems = state.items.map((item) {
      if (item.id == event.itemId) {
        if (item.isOutOfStock && !item.isAvailable) return item;
        return item.copyWith(isAvailable: !item.isAvailable);
      }
      return item;
    }).toList();
    emit(MenuState(items: updatedItems));

    final item = updatedItems.firstWhere((i) => i.id == event.itemId);
    try {
      await _datasource.updateItem(event.itemId, {'is_active': item.isAvailable});
    } catch (e) {
      AppLogger.error('Failed to update item availability', error: e, tag: 'Menu');
    }
  }

  Future<void> _onAdd(AddMenuItem event, Emitter<MenuState> emit) async {
    try {
      final json = await _datasource.createItem(event.restaurantId, {
        'name': event.item.name,
        'description': event.item.description,
        'base_price': event.item.price,
      });
      emit(MenuState(items: [_fromJson(json), ...state.items]));
    } catch (e) {
      AppLogger.error('Failed to add menu item', error: e, tag: 'Menu');
      emit(MenuState(items: [event.item, ...state.items]));
    }
  }

  // NOTE: the backend has no stock/inventory field on menu items — `stockCount`
  // is a local-only placeholder (always defaults to available) until that
  // exists server-side.
  MenuItemModel _fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      category: json['category_id'] as String? ?? 'General',
      imageUrl: json['image_url'] as String? ?? '',
      isAvailable: json['is_active'] as bool? ?? true,
    );
  }
}
