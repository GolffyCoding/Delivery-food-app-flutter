sealed class IncomingOrderState {}

class IncomingOrderCountdown extends IncomingOrderState {
  final Map<String, dynamic> orderData;
  final int remainingSeconds;
  IncomingOrderCountdown({required this.orderData, required this.remainingSeconds});

  IncomingOrderCountdown copyWith({int? remainingSeconds}) =>
      IncomingOrderCountdown(orderData: orderData, remainingSeconds: remainingSeconds ?? this.remainingSeconds);
}

class IncomingOrderLoading extends IncomingOrderState {
  final Map<String, dynamic> orderData;
  IncomingOrderLoading({required this.orderData});
}

class IncomingOrderAccepted extends IncomingOrderState {
  final String orderId;
  IncomingOrderAccepted({required this.orderId});
}

class IncomingOrderRejected extends IncomingOrderState {}

class IncomingOrderError extends IncomingOrderState {
  final String message;
  IncomingOrderError({required this.message});
}
