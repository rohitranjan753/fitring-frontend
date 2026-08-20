import 'package:equatable/equatable.dart';
import 'package:fitring_companion/features/shop/models/product.dart';

class OrderItem extends Equatable {
  const OrderItem({required this.product, required this.quantity, required this.unitPrice});

  final Product product;
  final int quantity;
  final double unitPrice;

  @override
  List<Object?> get props => [product, quantity, unitPrice];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  @override
  List<Object?> get props => [id, totalAmount, status, createdAt, items];
}
