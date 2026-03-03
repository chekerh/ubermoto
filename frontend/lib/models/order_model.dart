enum OrderStatus {
  pendingPayment,
  confirmed,
  assigned,
  inTransit,
  completed,
  cancelled,
}

enum OrderType { market, delivery, ride, parts }

enum PaymentMethod { cod, card, paypal, wallet }

class OrderItemModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final OrderStatus status;
  final OrderType type;
  final PaymentMethod paymentMethod;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final double surgeMultiplier;
  final String? address;
  final String? region;

  OrderModel({
    required this.id,
    required this.status,
    required this.type,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.surgeMultiplier,
    this.address,
    this.region,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus status = OrderStatus.confirmed;
    switch (json['status']) {
      case 'pending_payment':
        status = OrderStatus.pendingPayment;
        break;
      case 'confirmed':
        status = OrderStatus.confirmed;
        break;
      case 'assigned':
        status = OrderStatus.assigned;
        break;
      case 'in_transit':
        status = OrderStatus.inTransit;
        break;
      case 'completed':
        status = OrderStatus.completed;
        break;
      case 'cancelled':
        status = OrderStatus.cancelled;
        break;
    }

    OrderType type = OrderType.market;
    switch (json['type']) {
      case 'DELIVERY':
        type = OrderType.delivery;
        break;
      case 'RIDE':
        type = OrderType.ride;
        break;
      case 'PARTS':
        type = OrderType.parts;
        break;
      default:
        type = OrderType.market;
    }

    PaymentMethod pm = PaymentMethod.cod;
    switch (json['paymentMethod']) {
      case 'CARD':
        pm = PaymentMethod.card;
        break;
      case 'PAYPAL':
        pm = PaymentMethod.paypal;
        break;
      case 'WALLET':
        pm = PaymentMethod.wallet;
        break;
      default:
        pm = PaymentMethod.cod;
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: status,
      type: type,
      paymentMethod: pm,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] ?? 1).toDouble(),
      address: json['address'],
      region: json['region'],
    );
  }
}
