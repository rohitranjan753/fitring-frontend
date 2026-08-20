import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/features/shop/models/product.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';

class ProductsState extends Equatable {
  const ProductsState({this.isLoading = false, this.products = const [], this.errorMessage});

  final bool isLoading;
  final List<Product> products;
  final String? errorMessage;

  ProductsState copyWith({bool? isLoading, List<Product>? products, String? errorMessage}) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, products, errorMessage];
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repository) : super(const ProductsState());

  final ShopRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final products = await _repository.fetchProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not load products.'));
    }
  }
}
