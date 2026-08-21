import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:fitring_companion/features/auth/services/auth_api.dart';
import 'package:fitring_companion/features/auth/repositories/auth_repository_impl.dart';
import 'package:fitring_companion/features/auth/repositories/auth_repository.dart';
import 'package:fitring_companion/features/auth/bloc/auth_bloc.dart';
import 'package:fitring_companion/features/devices/services/device_id_cache.dart';
import 'package:fitring_companion/features/devices/services/devices_api.dart';
import 'package:fitring_companion/features/health/services/app_database.dart';
import 'package:fitring_companion/features/health/repositories/health_repository_impl.dart';
import 'package:fitring_companion/features/health/repositories/health_repository.dart';
import 'package:fitring_companion/features/history/bloc/history_cubit.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository_impl.dart';
import 'package:fitring_companion/features/shop/repositories/shop_repository.dart';
import 'package:fitring_companion/features/shop/bloc/cart_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/orders_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/products_cubit.dart';
import 'package:fitring_companion/features/wearable/services/mock_wearable_service.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository_impl.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/wearable/services/wearable_service.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_bloc.dart';
import 'package:fitring_companion/core/network/api_client.dart';
import 'package:fitring_companion/core/network/connectivity_cubit.dart';
import 'package:fitring_companion/core/storage/session_storage.dart';

final sl = GetIt.instance;

void configureDependencies() {
  // --- Core ---
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SessionStorage(sl()));
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => ConnectivityCubit());

  // --- Auth ---
  sl.registerLazySingleton(() => AuthApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => AuthBloc(sl()));

  // --- Devices ---
  sl.registerLazySingleton(() => DevicesApi(sl<ApiClient>().dio));
  sl.registerLazySingleton(() => DeviceIdCache(sl()));

  // --- Wearable ---
  // Swapping the mock for a real vendor SDK later means changing exactly
  // this one line — nothing above WearableService is affected.
  sl.registerLazySingleton<WearableService>(() => MockWearableService());
  sl.registerLazySingleton<WearableRepository>(
    () => WearableRepositoryImpl(sl<WearableService>()),
  );
  sl.registerLazySingleton(() => WearableBloc(sl()));

  // --- Health data: local storage + offline sync ---
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(sl(), sl(), sl(), sl(), sl<WearableRepository>()),
  );
  sl.registerLazySingleton(() => HistoryCubit(sl()));

  // --- Shop ---
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ProductsCubit(sl()));
  sl.registerLazySingleton(() => CartCubit(sl()));
  sl.registerLazySingleton(() => OrdersCubit(sl()));
}
