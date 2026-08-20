import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/features/shop/models/order.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';

class OrdersState extends Equatable {
  const OrdersState({this.isLoading = false, this.orders = const [], this.errorMessage});

  final bool isLoading;
  final List<Order> orders;
  final String? errorMessage;

  OrdersState copyWith({bool? isLoading, List<Order>? orders, String? errorMessage}) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, orders, errorMessage];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());

  final ShopRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final orders = await _repository.fetchOrders();
      emit(state.copyWith(isLoading: false, orders: orders));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not load order history.'));
    }
  }
}
