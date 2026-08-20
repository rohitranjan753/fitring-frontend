import 'package:bloc_test/bloc_test.dart';
import 'package:fitring_companion/features/shop/bloc/cart_cubit.dart';
import 'package:fitring_companion/features/shop/models/cart_item.dart';
import 'package:fitring_companion/features/shop/models/order.dart';
import 'package:fitring_companion/features/shop/models/product.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeShopRepository implements ShopRepository {
  List<CartItem> cart = [];
  bool failPlaceOrder = false;

  @override
  Future<List<CartItem>> fetchCart() async => cart;

  @override
  Future<Order> placeOrder() async {
    if (failPlaceOrder) throw Exception('backend unavailable');
    final order = Order(
      id: 'order-1',
      totalAmount: cart.fold(0, (sum, item) => sum + item.lineTotal),
      status: 'placed',
      createdAt: DateTime.utc(2026, 8, 20),
      items: const [],
    );
    cart = []; // mirrors the backend clearing the cart inside its own transaction
    return order;
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {}

  @override
  Future<List<Product>> fetchProducts() async => [];

  @override
  Future<Product> fetchProduct(String id) async => throw UnimplementedError();

  @override
  Future<List<Order>> fetchOrders() async => [];
}

Product _product({required double price}) {
  return Product(id: 'p1', name: 'FitRing Charging Dock', description: null, price: price, imageUrl: null);
}

void main() {
  group('CartState.total', () {
    test('sums quantity times price across every line item', () {
      final state = CartState(
        items: [
          CartItem(id: 'c1', product: _product(price: 10.00), quantity: 2),
          CartItem(id: 'c2', product: _product(price: 5.50), quantity: 1),
        ],
      );

      expect(state.total, 25.50);
    });

    test('is zero for an empty cart', () {
      const state = CartState();
      expect(state.total, 0);
    });
  });

  group('CartCubit.placeOrder', () {
    // `seed` sets the cubit's starting state directly, independent of the
    // fake repository's own `cart` field — placeOrder() only ever reads
    // cubit state to compute nothing itself; it delegates to the
    // repository and reacts to success/failure.
    blocTest<CartCubit, CartState>(
      'clears the cart and records the placed order on success',
      build: () => CartCubit(_FakeShopRepository()),
      seed: () => CartState(items: [CartItem(id: 'c1', product: _product(price: 10), quantity: 2)]),
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CartState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CartState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.lastPlacedOrder?.id, 'lastPlacedOrder.id', 'order-1'),
      ],
    );

    blocTest<CartCubit, CartState>(
      'surfaces an error and leaves the cart untouched on failure',
      build: () => CartCubit(_FakeShopRepository()..failPlaceOrder = true),
      seed: () => CartState(items: [CartItem(id: 'c1', product: _product(price: 10), quantity: 1)]),
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CartState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CartState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having((s) => s.items, 'items', hasLength(1)),
      ],
    );
  });
}
