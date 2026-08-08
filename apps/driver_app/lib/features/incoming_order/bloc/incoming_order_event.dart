sealed class IncomingOrderEvent {}

class StartCountdown extends IncomingOrderEvent {
  final Map<String, dynamic> orderData;
  StartCountdown(this.orderData);
}

class AcceptOrder extends IncomingOrderEvent {
  final String orderId;
  AcceptOrder(this.orderId);
}

class RejectOrder extends IncomingOrderEvent {
  final String orderId;
  RejectOrder(this.orderId);
}
