import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/core/network/connectivity_cubit.dart';
import 'package:fitring_companion/core/theme/app_theme.dart';
import 'package:fitring_companion/features/dashboard/pages/dashboard_screen.dart';
import 'package:fitring_companion/features/history/pages/history_screen.dart';
import 'package:fitring_companion/features/shop/pages/shop_screen.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_bloc.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_event.dart';

/// The authenticated app: a bottom-nav shell over Dashboard/History/Shop.
/// Only ever shown once AuthGate confirms the user is logged in.
///
/// This is where we start the wearable connection — it's not owned by any
/// one tab, so it starts here rather than inside DashboardScreen, meaning
/// data keeps flowing (and getting saved locally) even while the user is
/// looking at History or Shop. Each individual screen is responsible for
/// loading its own data in its own initState.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<WearableBloc>().add(const WearableStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [DashboardScreen(), HistoryScreen(), ShopScreen()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}

/// App-wide, not tied to any one tab — this is about the connection
/// itself, separate from (and simpler than) the health-sync-specific
/// pending count already shown inside History.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppTheme.warn,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'No internet connection — showing cached data',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}
