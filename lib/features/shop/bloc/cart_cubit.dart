import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/features/shop/models/cart_item.dart';
import 'package:fitring_companion/features/shop/models/order.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';

class CartState extends Equatable {
  const CartState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
    this.lastPlacedOrder,
  });

  final bool isLoading;
  final List<CartItem> items;
  final String? errorMessage;

  /// Set right after a successful checkout — screens watch for this to
  /// show a confirmation instead of just an emptied cart.
  final Order? lastPlacedOrder;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    bool? isLoading,
    List<CartItem>? items,
    String? errorMessage,
    Order? lastPlacedOrder,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
      lastPlacedOrder: lastPlacedOrder,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, errorMessage, lastPlacedOrder];
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(const CartState());

  final ShopRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await _repository.fetchCart();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not load your cart.'));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    await _repository.addToCart(productId, quantity);
    await load();
  }

  Future<void> placeOrder() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final order = await _repository.placeOrder();
      emit(state.copyWith(isLoading: false, items: const [], lastPlacedOrder: order));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not place the order. Try again.'));
    }
  }
}
