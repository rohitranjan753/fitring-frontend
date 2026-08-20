import 'package:fitring_companion/core/network/api_client.dart';
import 'package:fitring_companion/features/shop/models/cart_item.dart';
import 'package:fitring_companion/features/shop/models/order.dart';
import 'package:fitring_companion/features/shop/models/product.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  ShopRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> fetchProducts() async {
    final response = await _api.dio.get<List<dynamic>>('/products');
    return response.data!.map((json) => _productFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> fetchProduct(String id) async {
    final response = await _api.dio.get<Map<String, dynamic>>('/products/$id');
    return _productFromJson(response.data!);
  }

  @override
  Future<List<CartItem>> fetchCart() async {
    final response = await _api.dio.get<Map<String, dynamic>>('/cart');
    final items = response.data!['items'] as List<dynamic>;
    return items.map((json) => _cartItemFromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    await _api.dio.post<void>('/cart', data: {'productId': productId, 'quantity': quantity});
  }

  @override
  Future<Order> placeOrder() async {
    final response = await _api.dio.post<Map<String, dynamic>>('/orders');
    return _orderFromJson(response.data!);
  }

  @override
  Future<List<Order>> fetchOrders() async {
    final response = await _api.dio.get<List<dynamic>>('/orders');
    return response.data!.map((json) => _orderFromJson(json as Map<String, dynamic>)).toList();
  }

  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  CartItem _cartItemFromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: _productFromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Order _orderFromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>;
    return Order(
      id: json['id'] as String,
      totalAmount: double.parse(json['totalAmount'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: items.map((itemJson) {
        final m = itemJson as Map<String, dynamic>;
        return OrderItem(
          product: _productFromJson(m['product'] as Map<String, dynamic>),
          quantity: m['quantity'] as int,
          unitPrice: double.parse(m['unitPrice'] as String),
        );
      }).toList(),
    );
  }
}
