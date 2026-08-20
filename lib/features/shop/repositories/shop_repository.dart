import 'package:fitring_companion/features/shop/models/cart_item.dart';
import 'package:fitring_companion/features/shop/models/order.dart';
import 'package:fitring_companion/features/shop/models/product.dart';

/// Unlike health data, the shop isn't offline-first — it just calls the
/// backend directly. There's no local queue here on purpose: the brief
/// scopes offline support to health data specifically (see the PRD).
abstract class ShopRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProduct(String id);

  Future<List<CartItem>> fetchCart();
  Future<void> addToCart(String productId, int quantity);

  /// Cart -> order on the backend, in one transaction. Throws if the cart is empty.
  Future<Order> placeOrder();
  Future<List<Order>> fetchOrders();
}
