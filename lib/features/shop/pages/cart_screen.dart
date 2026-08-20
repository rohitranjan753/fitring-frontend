import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/core/widgets/error_banner.dart';
import 'package:fitring_companion/features/shop/bloc/cart_cubit.dart';
import 'package:fitring_companion/features/shop/pages/order_history_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Order history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            ),
          ),
        ],
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            current.lastPlacedOrder != previous.lastPlacedOrder ||
            (current.errorMessage != null && current.items.isNotEmpty),
        listener: (context, state) {
          if (state.lastPlacedOrder != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed!')),
            );
          }
          if (state.errorMessage != null && state.items.isNotEmpty) {
            showErrorBanner(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name),
                                Text(
                                  '\$${item.product.price.toStringAsFixed(2)} each',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // The backend's POST /cart is an upsert that sets
                          // quantity outright (see shop_repository.dart) and
                          // there's no delete-from-cart endpoint in the
                          // brief's minimum API list, so quantity is capped
                          // at a minimum of 1 rather than removing the item.
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: item.quantity > 1
                                ? () => context.read<CartCubit>().addToCart(item.product.id, item.quantity - 1)
                                : null,
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                context.read<CartCubit>().addToCart(item.product.id, item.quantity + 1),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '\$${item.lineTotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '\$${state.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: state.isLoading ? null : () => context.read<CartCubit>().placeOrder(),
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
