import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/core/widgets/error_banner.dart';
import 'package:fitring_companion/features/shop/bloc/orders_cubit.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listenWhen: (previous, current) => current.errorMessage != null && current.orders.isNotEmpty,
        listener: (context, state) => showErrorBanner(context, state.errorMessage!),
        builder: (context, state) {
          if (state.isLoading && state.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null && state.orders.isEmpty) {
            return Center(child: Text(state.errorMessage!));
          }
          if (state.orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.items.length} item(s) · ${order.status}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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
