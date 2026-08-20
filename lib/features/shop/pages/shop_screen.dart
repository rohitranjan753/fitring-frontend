import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/core/widgets/error_banner.dart';
import 'package:fitring_companion/features/shop/bloc/cart_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/products_cubit.dart';
import 'package:fitring_companion/features/shop/widgets/product_card.dart';
import 'package:fitring_companion/features/shop/pages/cart_screen.dart';
import 'package:fitring_companion/features/shop/pages/product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().load();
    context.read<CartCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.items.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        // Only banner-worthy when there's already cached data to keep
        // showing — an empty-list failure gets the plainer centered
        // message below instead, since there's nothing to overlay it on.
        listenWhen: (previous, current) => current.errorMessage != null && current.products.isNotEmpty,
        listener: (context, state) => showErrorBanner(context, state.errorMessage!),
        builder: (context, state) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.products.isEmpty) {
            return Center(child: Text(state.errorMessage!));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProductsCubit>().load(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
