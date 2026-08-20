import 'package:equatable/equatable.dart';
import 'package:fitring_companion/features/shop/models/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.id, required this.product, required this.quantity});

  final String id;
  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  @override
  List<Object?> get props => [id, product, quantity];
}
