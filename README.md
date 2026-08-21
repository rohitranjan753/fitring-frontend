# FitRing Companion: Frontend

This is my Flutter app for the ERBrains wearable health and shopping take-home. Login, then a live dashboard fed by a simulated smart ring, then local-first health history with offline sync, then a small shopping flow. In this file I'm focusing on the four things the brief asks me to reason about on the mobile side: architecture/vendor-SDK swap, connection handling, local health data, and offline sync, plus setup and testing. For the backend and the full seven-section README, see [`../README.md`](../README.md) and [`../fitring-backend/README.md`](../fitring-backend/README.md).

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates the Drift database code
flutter run
```

I need the backend running (`cd ../fitring-backend && npm run start:dev`) and a device, emulator, or simulator target.

Android emulator can't reach the backend via `localhost`, since it has its own loopback. I've already pointed Android at `10.0.2.2:3000` in `lib/core/network/api_config.dart`, the emulator's alias for the host machine.

iOS simulator, web, and desktop share the host's network directly, so plain `localhost` works.

For a real device, I'd set `_physicalDeviceHostIp` in `api_config.dart` to my computer's LAN IP, since the phone and computer need to be on the same Wi-Fi network.

I run the tests with `flutter test`. 14 tests total: wearable reconnection, health duplicate-prevention, dashboard/reconnect widget behavior, cart logic.

## Architecture: the wearable abstraction, and swapping in a real SDK

There's no real ring or vendor SDK for this assignment, so I mocked the wearable behind an interface instead of hardcoding the mock into the app directly. Dashboard and History only ever talk to `WearableRepository`, which only talks to `WearableService` below. `MockWearableService` implements it today, a real SDK would implement it later, and I wouldn't need to change anything above this interface either way.

```dart
// lib/features/wearable/services/wearable_service.dart
abstract class WearableService {
  Stream<WearableConnectionState> get connectionState;
  Stream<HealthReading> get readings;
  Future<void> connect();
  Future<void> disconnect();
  Future<int> batteryLevel();
  Future<void> dispose();
}
```

Swapping the mock for a real SDK is one line for me in `lib/core/di/injector.dart`: a new class implementing `WearableService`.

I looked into how I'd actually build that real implementation, since it's the part the brief asks me to reason about. Two options came up.

`flutter_blue_plus` directly: works if the vendor publishes an open BLE protocol with documented GATT UUIDs and packet format I could parse myself in Dart.

Platform channels wrapping the vendor's own native SDK: what I'd need if the vendor only ships a compiled Kotlin/Swift SDK with no public protocol, which is the more typical case for closed smart-ring products, since a lot of the value in these devices, like sleep staging and HRV, is proprietary logic they don't want to expose as a documented protocol.

I assumed the second case here, a closed vendor SDK rather than an open protocol, and picked Pigeon over a hand-rolled `MethodChannel` to wrap it. A raw `MethodChannel` passes method names and arguments as untyped strings across the bridge, so a typo only shows up at runtime as a `MissingPluginException`. Pigeon generates matching typed Dart, Kotlin, and Swift code from one schema file, so I'd catch that same mistake at compile time instead.

## Connection handling

I put the reconnection policy in `WearableRepositoryImpl`, one layer above the raw `WearableService`. That's deliberate, so the policy stays identical regardless of whether the mock or a real SDK is underneath.

States I handle: connected, connecting, disconnected, reconnecting with an attempt number, connection failed, and the user manually retrying. See `WearableConnectionState` and its subtypes in `lib/features/wearable/models/`.

The policy itself lives in `lib/features/wearable/repositories/wearable_repository_impl.dart`:

Automatic reconnect happens only on an unprompted disconnect. It backs off exponentially, 1 second, then 2, 4, 8, 16, capping at 30 seconds, and gives up after 6 attempts, surfacing `WearableConnectionFailed` with a manual retry still available from the Dashboard.

A user-initiated disconnect, from logout or an automatic logout on a 401 from the backend, is tracked separately with `_userInitiatedDisconnect`, so it's never mistaken for a dropped connection. No reconnect attempt follows a deliberate disconnect.

Manual reconnect always resets the attempt counter to zero rather than inheriting whatever backoff the automatic retry was mid-way through, since I didn't want a user tapping reconnect to get stuck waiting out a stale cooldown.

I covered this with 5 unit tests in `test/features/wearable/wearable_repository_impl_test.dart`, using `fake_async` to run the full backoff curve, including the 30 second cap and the 6 attempt cutoff, without actually waiting in real time.

## Local health data: the History screen

I write every reading to a local SQLite database, via Drift, before the app ever tries the network. More on that below. On the History screen (`lib/features/history/`) I show daily history as a raw, timestamped list of recent readings, a weekly summary as a 7-day daily-bucketed aggregate of average heart rate, average SpO2, and max steps per day, a heart-rate chart and SpO2 chart using `fl_chart` fed by that same weekly-summary data rather than raw rows, and a steps summary as a per-day progress bar against a 10,000-step reference.

I made sure this never loads unlimited raw records into the UI at once, in two ways. First, the query is capped and paginated through an explicit Load More button, growing by 20 rows per tap, instead of fetching the whole table. True keyset or cursor pagination on `recordedAt` would be the next step instead of a growing limit, but I haven't done that yet. Second, the rendering of that list is lazy. I used a `CustomScrollView` with `SliverList.builder` on `HistoryScreen`, so only the rows actually scrolled into view get built, no matter how large the loaded list gets. This was actually a real gap I found and fixed partway through. I'd originally used a plain `ListView` with all children built eagerly, which doesn't scale as Load More grows the list.

At real scale, beyond what this take-home's local dataset needs, I'd want a retention and downsampling policy: full resolution briefly, then hourly, then daily rollups. I designed for it but didn't implement it, since I didn't have a large enough dataset in the time I had to justify the extra surface area yet.

## Offline synchronization

Every reading gets saved to Drift before the app tries the network, so it keeps collecting and storing readings with no internet at all.

The queue is just one table with one `synced` boolean column. Unsynced rows are the queue, no separate table needed.

For duplicate prevention, each reading gets a client-generated UUID when it's created. The backend enforces uniqueness on that UUID and upserts on conflict, so a retried batch never creates duplicate rows. I verified this directly against the real backend.

Device ID resolution was a detail I almost missed. The wearable tags readings with a vendor ID string, `FITRING-001`, but the backend needs its own device UUID for that same device. Before the first sync of a session, I look up or register the device and cache the UUID I get back, then use that for every sync after. This was a real bug I caught and fixed: without it, every sync would fail validation on the backend, silently, since sync failures don't surface as user-facing errors.

Sync is triggered on every new reading, and whenever connectivity comes back. A sync already in progress absorbs any new trigger instead of running twice at once. Failed batches just stay unsynced and retry next time, up to 50 rows per request.

For the target scenario of 100 readings generated fully offline then synced once connectivity returns, the pieces are all built and verified individually: a duplicate-batch test against the real backend, the Drift upsert unit test, and a live Android run where I watched readings land in Postgres. I haven't recorded that exact scenario end-to-end as one continuous take yet.

## Testing

```bash
flutter test
```

14 tests total.

Wearable reconnection, in `test/features/wearable/wearable_repository_impl_test.dart`, 5 tests: exponential backoff, the 30 second cap and 6 attempt cutoff, connection success resetting the counter, user-initiated disconnect not triggering auto-reconnect, manual reconnect resetting the backoff.

Health duplicate prevention, in `test/features/health/app_database_test.dart`, 3 tests: the Drift upsert used by `saveReading()` keeps exactly one row for a repeated `clientUuid`, distinct `clientUuid`s produce separate rows, new rows default to unsynced.

Dashboard and reconnect widget behavior, in `test/widget_test.dart`, 2 tests: the dashboard renders disconnected then live-reading states correctly, and the reconnect button appears only when disconnected or failed and dispatches the right event.

Cart logic, in `test/features/shop/cart_cubit_test.dart`, 4 tests: cart total computation, and `placeOrder` clearing the cart and recording the order on success versus surfacing an error and leaving the cart untouched on failure.
