# Mobile Framework Comparison
# Dial-A-Breakfast Zimbabwe

Last updated: 2026-02-25

---

## Context

This document compares four mobile development strategies for the Dial-A-Breakfast Zimbabwe platform.
It is written specifically against this project's requirements — not as a generic framework survey.

**The four options evaluated:**

| Option | Languages | Platforms |
|---|---|---|
| A — Native Android only | Kotlin + Jetpack Compose | Android |
| B — Kotlin Multiplatform (KMP) | Kotlin (shared) + SwiftUI (iOS UI) | Android + iOS |
| C — Flutter | Dart | Android + iOS (+ limited web) |
| D — React Native | TypeScript + React | Android + iOS (+ limited web) |

**Project requirements driving the evaluation:**

- Drag-and-drop breakfast meal builder (core product differentiator)
- Breakfast delivery window 05:00–10:00 Africa/Harare enforcement
- Live rider tracking with map
- EcoCash, OneMoney, Visa/Mastercard, cash-on-delivery payment flows
- Offline mode and low-bandwidth optimisation (Zimbabwe mobile networks)
- Performance on budget Android devices ($50–$120 price range)
- Corporate ordering and subscription/meal plan management
- Android-first market (iOS secondary)
- Existing team: Kotlin backend developers, TypeScript/React frontend developers

---

## 1. Architecture Overview

### Option A — Native Android (Kotlin + Compose)

```
android/
  app/
    ui/           Jetpack Compose screens
    data/         Retrofit, Room, DataStore
    domain/       Use cases, repositories
    di/           Hilt modules
```

Single platform. Highest native fidelity on Android. No iOS.

---

### Option B — Kotlin Multiplatform (KMP)

```
shared/                     ← pure Kotlin, compiles to Android + iOS framework
  commonMain/
    data/api/               Ktor HTTP client
    data/repository/        shared repositories
    domain/model/           shared domain models
    domain/usecase/         shared business logic
  androidMain/              Android-specific implementations
  iosMain/                  iOS-specific implementations

android/
  ui/                       Jetpack Compose

ios/                        ← Xcode project
  UI/                       SwiftUI screens (calls shared Kotlin framework)
```

Shared business logic, native UI per platform.
Kotlin compiles to a native iOS framework via Kotlin/Native.
iOS developer writes SwiftUI; all logic underneath is Kotlin.

---

### Option C — Flutter

```
lib/
  features/
    auth/
    home/
    vendor/
    meal_builder/
    order/
    tracking/
    subscription/
  data/
    api/                    Dio HTTP client
    repository/
    local/                  Drift (SQLite)
  core/
    state/                  Riverpod providers
    theme/
    router/                 GoRouter
  main.dart
```

Single Dart codebase. Flutter's Impeller engine renders all UI to a canvas.
No native UI components used. Identical rendering on Android and iOS.

---

### Option D — React Native

```
src/
  screens/
    Auth/
    Home/
    Vendor/
    MealBuilder/
    Order/
    Tracking/
    Subscription/
  services/               shared with web frontend (API client, stores)
  navigation/             React Navigation
  store/                  Zustand (same as web)
```

TypeScript and React. Hermes JS engine at runtime.
Bridges to native modules for platform-specific features.
~70% of business logic can be shared with the existing web frontend.

---

## 2. Drag-and-Drop Meal Builder

The drag-and-drop breakfast customiser is the most demanding UI feature in the app.
It requires smooth gesture handling, real-time price/calorie updates, haptic feedback,
and item swapping — all at 60fps.

### Native Android (Compose)

Jetpack Compose provides `Modifier.draggable()` and `LazyColumn` with built-in drag support.
The gesture system runs entirely on the main thread with no bridge overhead.
Haptic feedback via `HapticFeedbackType` is a one-line call.
Custom animations use `animate*AsState` and `rememberAnimatedContentState`.
This is the gold standard for Android drag interactions.

**Implementation complexity:** Low
**Performance:** 60fps, always
**Haptics:** Native, automatic
**Edge scrolling while dragging:** Built-in

---

### KMP

The Android side uses the same Jetpack Compose implementation above.
The iOS side uses SwiftUI's `DragGesture` combined with `DropDelegate` and `@GestureState`.
SwiftUI drag is the gold standard for iOS interactions — spring physics, haptics,
and accessibility are handled by the platform automatically.

The trade-off: you implement the drag interaction **twice** — once in Compose, once in SwiftUI.
The logic underneath (price calculation, validation) is shared Kotlin, but the gesture code is not.

**Implementation complexity:** Medium (two implementations)
**Performance:** 60fps on both platforms natively
**Haptics:** Native on both
**Code duplication:** Gesture code only; pricing/validation logic is shared

---

### Flutter

Flutter's `Draggable<T>` + `DragTarget<T>` widgets are framework primitives.
For more complex reorderable lists, `ReorderableListView` is built-in.
Custom drag-and-drop with snap animations requires `AnimationController` and
`TweenAnimationBuilder`. The `flutter_reorderable_list` package adds production-quality
reorder UX with minimal code.

Haptic feedback via `HapticFeedback.mediumImpact()` works on both platforms.
Scroll physics can be tuned to feel more Android-like or iOS-like via `ScrollPhysics`.

One important limitation: iOS users expect the spring physics of native UIKit drag.
Flutter's physics are configurable but require deliberate tuning to match iOS expectations.
Without this tuning, iOS users will notice the difference.

**Implementation complexity:** Medium (one implementation, but iOS physics need tuning)
**Performance:** 60fps (Impeller renders on a dedicated raster thread)
**Haptics:** Supported, explicit
**iOS feel without tuning:** Slightly off

---

### React Native

React Native's built-in `PanResponder` is not suitable for production drag-and-drop.
The correct stack is `react-native-gesture-handler` (RNGH) + `react-native-reanimated` v3.
Reanimated v3 is critical: it moves animation worklets off the JS thread onto the UI thread,
eliminating the bridge bottleneck that makes RN drag feel laggy on older devices.

With this stack the experience is good. Without it — specifically on low-end devices
common in Zimbabwe — dropped frames are noticeable under load.

`react-native-draggable-flatlist` built on top of RNGH + Reanimated provides a polished
reorderable list component.

**Implementation complexity:** Medium-high (requires correct library stack)
**Performance:** Good with Reanimated v3; noticeable jank without it on budget devices
**Haptics:** Via `react-native-haptic-feedback` (community package)
**Risk:** Library stack version compatibility issues are a recurring maintenance problem

---

### Drag-and-Drop Summary

```
Native Android   ██████████  Best on Android, Android only
KMP              ██████████  Best on both, two implementations required
Flutter          █████████   Near-best, one implementation, iOS physics need work
React Native     ███████     Good with correct library stack, budget device risk
```

---

## 3. Performance on Low-End Android Devices

This is the single most important performance dimension for the Zimbabwe market.
Target device profile: 2GB RAM, Snapdragon 430-class SoC, Android 10–12, $50–$100 retail.

### Startup Time (cold launch to interactive)

| Option | Typical cold start | Mechanism |
|---|---|---|
| Native Android | 200–400 ms | Compiled ARM, ART JIT warmup |
| KMP (Android) | 200–400 ms | Same as native |
| Flutter | 400–700 ms | Dart AOT + Flutter engine init |
| React Native | 800–1500 ms | Hermes engine init + JS bundle parse |

React Native's startup time is the most impactful difference on low-end devices.
Hermes mitigates the classic RN startup problem but does not eliminate it.
Flutter's AOT-compiled Dart has no interpretation step, making it significantly faster.

---

### Memory Usage

| Option | Baseline RSS (approximate) |
|---|---|
| Native Android | 30–50 MB |
| KMP (Android) | 30–50 MB |
| Flutter | 50–80 MB (Flutter engine ~20 MB) |
| React Native | 60–90 MB (Hermes + native modules) |

On a 2GB device running background services, the difference between 50 MB and 90 MB
is the difference between the OS killing your app and keeping it alive.
Budget Android devices aggressively kill background apps to reclaim memory.

---

### Scroll and Animation Frame Rate

On a mid-range SoC under load (e.g., live tracking map + list scrolling simultaneously):

| Option | Frame consistency | Reason |
|---|---|---|
| Native Android | 60fps stable | Direct Choreographer integration |
| KMP (Android) | 60fps stable | Same |
| Flutter | 58–60fps stable | Raster thread separate from UI thread |
| React Native | 45–60fps variable | JS thread contention under load |

React Native's single JS thread means heavy computation (e.g., real-time price
recalculation during drag) competes with UI updates. Reanimated v3 moves animations
off this thread but logic still runs on it.

---

### APK Size (download size)

This directly affects install rates in low-bandwidth markets.

| Option | Base APK | With App Bundle (Play) |
|---|---|---|
| Native Android | 3–6 MB | 2–4 MB |
| KMP (Android) | 4–7 MB | 3–5 MB |
| Flutter | 12–18 MB | 6–10 MB |
| React Native | 18–28 MB | 12–18 MB |

Flutter's APK includes the Impeller rendering engine (~7 MB compressed).
React Native includes the Hermes runtime and a bundled JS payload.

For users downloading on prepaid data at $0.50–$1.00/MB (common in Zimbabwe),
a 20 MB app versus a 5 MB app is a meaningful barrier to installation.

Using Android App Bundles (AAB) with Play Store delivery significantly reduces
the delivered size for Flutter and React Native by stripping unused ABIs and
density-specific assets. Direct APK distribution (sideloading) receives no benefit.

---

### Low-End Performance Summary

```
Native Android   ██████████  Reference baseline
KMP (Android)    ██████████  Identical to native on Android
Flutter          ████████    Excellent; engine overhead manageable
React Native     ██████      Good on mid-range; noticeable on budget devices
```

---

## 4. Offline Mode and Low-Bandwidth Support

Zimbabwe's mobile data context:
- Econet, NetOne, Telecel are dominant carriers
- 3G coverage is widespread; 4G is urban-concentrated
- Data is expensive relative to income; users ration usage
- Intermittent connectivity is normal, not exceptional

### Local Database

| Option | Database | Query type | Migration support |
|---|---|---|---|
| Native Android | Room (SQLite) | Type-safe Kotlin DSL | Automatic via `@Migration` |
| KMP | SQLDelight | Type-safe SQL codegen | Schema versioning built-in |
| Flutter | Drift (SQLite) | Type-safe Dart DSL | Migration API |
| React Native | WatermelonDB or SQLite plugin | JS query builder | Manual |

Room, SQLDelight, and Drift are all production-grade, well-tested SQLite wrappers.
WatermelonDB is good but less mature than the JVM-based options.

---

### Background Sync

This is where native Android and KMP have a meaningful advantage.

**Android WorkManager** (available natively to Native Android and KMP, accessible
via plugin to Flutter and React Native) provides:
- OS-scheduled background execution that survives app process death
- Battery-aware scheduling (respects Doze mode, App Standby buckets)
- Retry policies with exponential backoff
- Chained work requests (sync orders → sync inventory → send notifications)
- Guaranteed execution even after device restart (with persistent work)

Flutter's `workmanager` plugin wraps WorkManager on Android and BGTaskScheduler on iOS.
It covers ~80% of use cases but lacks fine-grained control over constraints and
chaining that native WorkManager provides directly.

React Native has no first-party WorkManager integration. Community packages exist
(`react-native-background-fetch`) but they are less reliable on aggressive Android OEM
battery optimisation (Xiaomi MIUI, Samsung One UI, OPPO ColorOS are all aggressive).

For Dial-A-Breakfast, the background sync requirement is:
- Sync pending orders when connectivity returns
- Cache vendor menus for offline browsing
- Push subscription delivery notifications at 05:00

This is achievable in all options but Native Android/KMP provides the most reliable
implementation on the cheap OEM devices your delivery riders will use.

---

### Network Caching Strategy

| Option | HTTP caching | Stale-while-revalidate | Offline fallback |
|---|---|---|---|
| Native Android | OkHttp cache | Manual or via interceptor | Room queries |
| KMP | Ktor with OkHttp | Manual interceptor | SQLDelight queries |
| Flutter | Dio + `dio_cache_interceptor` | Configurable per-endpoint | Drift queries |
| React Native | Axios/Fetch + react-query | React Query built-in | AsyncStorage / WatermelonDB |

React Query (used in the web frontend) has built-in stale-while-revalidate,
offline mutation queuing, and background refetch. If React Native is chosen,
`@tanstack/react-query` works identically to the web version — the entire
caching strategy from the web frontend is directly reusable.

---

### Offline/Low-Bandwidth Summary

```
Native Android   ██████████  WorkManager + Room = best combination
KMP              █████████   WorkManager via plugin + SQLDelight
Flutter          ████████    Drift + workmanager plugin; minor plugin gaps
React Native     ███████     React Query reuse advantage; WorkManager gaps on OEM devices
```

---

## 5. Live Delivery Tracking and Maps

### Map SDK Quality

| Option | Map SDK | Quality |
|---|---|---|
| Native Android | Google Maps Android SDK (direct) | Excellent |
| KMP Android | Google Maps Android SDK (direct) | Excellent |
| KMP iOS | MapKit (Apple Maps, native) | Excellent |
| Flutter | `google_maps_flutter` (official Google plugin) | Very good |
| React Native | `react-native-maps` (wraps native SDKs) | Very good |

Both `google_maps_flutter` and `react-native-maps` wrap the same native Google Maps
Android SDK under the hood. The gap between these and direct native SDK usage is
minimal for standard map operations (markers, polylines, camera animation).

---

### Real-Time Location Polling

The tracking screen polls `GET /api/v1/deliveries/orders/{orderId}/tracking` every 15 seconds.
All options implement this equally. The difference is in how they handle the app
being backgrounded during a long delivery:

| Option | Background polling | Mechanism |
|---|---|---|
| Native Android | Reliable via WorkManager + foreground service | Best |
| KMP | Same as native on Android | Best |
| Flutter | `flutter_background_service` + `geolocator` | Good; some OEM battery restriction issues |
| React Native | `react-native-background-fetch` | Variable; OEM-dependent |

---

### Rider Location Updates (For Rider App)

Dial-A-Breakfast requires a rider-facing app view that continuously sends GPS coordinates
to `POST /api/v1/deliveries/{deliveryId}/location`. This is a continuous background
location use case — the most demanding background task in the system.

Native Android with a Foreground Service + FusedLocationProviderClient is the most
reliable implementation for continuous background location on Android.
Flutter's `geolocator` plugin wraps FusedLocationProviderClient but the foreground
service setup requires platform channel code (Kotlin) anyway.
React Native's `react-native-background-geolocation` (paid library) or
`react-native-geolocation-service` (free) both require Kotlin/Swift configuration.

**Practical consequence:** For the rider location feature, all cross-platform options
require writing native Kotlin code regardless of the chosen framework.

---

## 6. Payment Integration

### EcoCash and OneMoney

Both are Zimbabwe-specific payment gateways. Neither has an official Flutter or
React Native SDK. Integration is via:
1. WebView redirect flow (app opens a WebView pointing to the gateway's payment page)
2. Deep link handling (gateway redirects back to the app via a custom URI scheme)

This implementation is identical across all options. The WebView and deep link
handling APIs differ slightly:

| Option | WebView | Deep link handling |
|---|---|---|
| Native Android | `WebView` widget | `Intent` filter in `AndroidManifest.xml` |
| Flutter | `webview_flutter` (official) | `app_links` package |
| React Native | `react-native-webview` | Linking API |

No meaningful difference. All options handle EcoCash and OneMoney equivalently.

---

### Visa / Mastercard (Stripe)

| Option | SDK | Quality |
|---|---|---|
| Native Android | Stripe Android SDK (direct) | Excellent |
| KMP | Stripe Android SDK on Android side | Excellent |
| Flutter | `flutter_stripe` (official Stripe plugin) | Very good |
| React Native | `@stripe/stripe-react-native` (official) | Very good |

Both `flutter_stripe` and `@stripe/stripe-react-native` are officially maintained
by Stripe. The gap from direct native integration is minimal for standard card
collection flows (PaymentSheet).

---

### Security and PCI Compliance

All options use Android Keystore for secure token storage.
Native Android and KMP access it directly.
Flutter uses `flutter_secure_storage` (wraps Android Keystore).
React Native uses `react-native-keychain` (wraps Android Keystore).

PCI compliance is determined by your payment gateway integration, not the framework.
All options are equivalent here.

---

## 7. Development Velocity and Team Fit

### Language Familiarity

| Framework | Languages required | Your team's existing knowledge |
|---|---|---|
| Native Android | Kotlin | Backend team knows Kotlin — direct transfer |
| KMP | Kotlin (shared + Android) + Swift (iOS UI) | Backend knows Kotlin; nobody knows Swift |
| Flutter | Dart | Nobody knows Dart |
| React Native | TypeScript + React | Frontend team knows TypeScript + React |

**Native Android** has the lowest ramp-up — your Kotlin backend developers can
contribute to mobile immediately. Their Spring Boot patterns (dependency injection,
repository pattern, sealed classes for results) map directly to modern Android development.

**KMP** requires Kotlin for everything except the iOS UI layer. One Swift developer
is needed for SwiftUI screens. If you cannot hire that person, KMP's iOS story stalls.

**Flutter** requires learning Dart. Dart is syntactically similar to Kotlin and TypeScript
but is still a new language, new ecosystem, new tooling, and new mental model for state
management. Productive in 2–4 weeks; idiomatic in 2–3 months.

**React Native** has the lowest ramp-up for the **frontend team** specifically.
The same TypeScript patterns, React hooks, Zustand stores, and TanStack Query
that power the web app transfer directly to React Native.
The backend team contributes nothing to React Native mobile.

---

### Code Reuse Between Layers

| Framework | Shares code with backend (Kotlin) | Shares code with web frontend (TypeScript) |
|---|---|---|
| Native Android | No (separate Kotlin app) | No |
| KMP | Yes — shared Kotlin domain/data logic | No |
| Flutter | No | No |
| React Native | No | Yes — API client, stores, types, hooks |

KMP is the only option that shares code with the Kotlin backend services.
React Native is the only option that shares code with the TypeScript web frontend.
Flutter shares code with neither.

For Dial-A-Breakfast specifically, the most reusable layer is the API client and
state management. React Native's ability to share `zimbiteApi.ts`, `authStore.ts`,
and `cartStore.ts` directly with the mobile app represents roughly 3–4 weeks of
avoided work on the API integration layer alone.

---

### Time to First Working App

Rough estimate for a team unfamiliar with the target framework, building to feature-complete MVP:

| Option | Estimated time to MVP | Key assumption |
|---|---|---|
| Native Android | 8–12 weeks | Kotlin-familiar team |
| KMP (Android + iOS) | 16–22 weeks | Needs Swift developer |
| Flutter | 12–16 weeks | Team learns Dart during development |
| React Native | 10–14 weeks | Frontend team leads; API layer reused from web |

These estimates assume a 2–3 developer mobile team and exclude app store submission overhead.

---

## 8. iOS Considerations

### What Each Option Requires to Ship on iOS

| Option | What you need | What you write |
|---|---|---|
| Native Android only | Nothing — no iOS support | Nothing |
| KMP | macOS + Xcode, Apple Dev account, Swift developer | SwiftUI screens (~30–35% of mobile code) |
| Flutter | macOS + Xcode, Apple Dev account | Nothing additional beyond Android code |
| React Native | macOS + Xcode, Apple Dev account | Nothing additional beyond Android code |

**macOS and Xcode are unavoidable for all iOS targets**, regardless of framework.
Apple's build toolchain requires macOS. CI for iOS requires a macOS runner (GitHub Actions
provides these; they are more expensive than Linux runners).

Flutter and React Native eliminate the need for a Swift developer.
KMP requires one. This is a significant team composition difference.

---

### App Store Review Timeline

All options submit the same `.ipa` binary to App Store Connect.
Review times are framework-agnostic: typically 1–3 days for standard reviews.
Flutter, React Native, and KMP have all shipped high-profile apps on the App Store
without framework-related rejection issues.

---

### iOS Market Share in Zimbabwe

iOS market share in Zimbabwe is estimated at 5–8% of smartphone users.
Android dominates entirely due to the cost of iOS devices.
This directly affects the priority of iOS support.

A phased approach — Android first, iOS 6–12 months later — is the most pragmatic
strategy for this market regardless of framework choice.

---

## 9. Long-Term Maintenance

### Ecosystem Health

| Framework | Backed by | Community size | Risk of abandonment |
|---|---|---|---|
| Native Android | Google (Android team) | Largest | Very low |
| KMP | JetBrains (core business) | Growing rapidly | Low |
| Flutter | Google (Flutter team) | Large | Medium — Google has killed products |
| React Native | Meta (Facebook) | Large | Medium — Meta's mobile priorities shift |

JetBrains' core business is developer tooling. KMP's survival is tied to JetBrains'
existence as a company, not to a single product team's prioritisation within a large
corporation. This makes it structurally more stable than Flutter or React Native
long-term.

Flutter and React Native are both mature enough that even if corporate backing
were reduced, the community would sustain them. Both have happened before with
React Native (Meta significantly reduced its investment in 2018, community carried on).

---

### Plugin/Package Maintenance

| Framework | Package ecosystem | Known maintenance issues |
|---|---|---|
| Native Android | Maven Central, Google Maven | Stable, Google-maintained core |
| KMP | Maven Central + KMP-specific | Some packages lag native equivalents |
| Flutter | pub.dev | Plugin quality varies; some abandon-ware |
| React Native | npm | Same issues as npm generally |

Flutter's pub.dev has a Pub Points system that scores package quality, testing,
and maintenance. It helps surface well-maintained packages but does not guarantee them.
The `flutter_workmanager` and `geolocator` packages are well-maintained.
Obscure packages may lag behind Android/iOS platform updates by weeks to months.

---

### Platform API Updates

When Google or Apple releases a new OS version with new APIs or deprecations:

| Framework | Time to support new platform APIs |
|---|---|
| Native Android | Day one (you write it directly) |
| KMP | Day one for Android; plugin lag possible for iOS |
| Flutter | Days to weeks (Flutter team + plugin maintainers must update) |
| React Native | Days to weeks (same) |

In practice, major Android API changes (e.g., Android 13 notification permissions,
Android 14 photo picker) reach Flutter and React Native within 2–4 weeks via
plugin updates. This is rarely a production blocker unless you need day-one support.

---

## 10. Testing Strategy

### Unit Testing

All options support unit testing of business logic with equivalent tooling:

| Framework | Unit test framework |
|---|---|
| Native Android | JUnit 5 + MockK + Turbine (for Flow) |
| KMP shared | Kotlin Test + MockK (runs on JVM) |
| Flutter | `flutter_test` built-in, `mocktail` for mocking |
| React Native | Jest + React Testing Library |

---

### UI Testing

| Framework | UI test framework | Approach |
|---|---|---|
| Native Android | Compose UI testing, Espresso | Semantic tree inspection |
| KMP | Compose UI testing (Android), XCTest (iOS) | Two test suites |
| Flutter | Widget testing (built-in, fast) | In-process widget tree inspection |
| React Native | React Testing Library, Detox (E2E) | DOM-like testing |

Flutter's widget testing is a genuine differentiator. Widget tests run in a lightweight
test environment (no simulator required), execute in milliseconds, and can test
complex widget trees including animations. This results in a faster TDD cycle than
any other option for UI-level tests.

---

### Integration / E2E Testing

| Framework | Tool | Device required |
|---|---|---|
| Native Android | Espresso, UI Automator | Android emulator/device |
| KMP | Espresso (Android), XCUITest (iOS) | Both required |
| Flutter | `integration_test` package | Android/iOS simulator |
| React Native | Detox | Android/iOS simulator |

---

## 11. Specific Feature Implementation Complexity

### Subscription Management UI

Complex multi-step form: select vendor, select items, choose plan frequency,
set delivery address, confirm. All options handle this with equivalent complexity.
No meaningful difference.

### Real-Time Price and Calorie Calculation

Pure computation triggered on state changes. Equivalent in all options.
Flutter's reactive widget rebuild system and React Native's React rendering model
both handle this well. Native Android's Compose `derivedStateOf` is marginally
more efficient for complex derived state trees.

### Corporate Ordering

Multi-user order with a company account. Standard list/form UI with slightly
more complex state. No meaningful difference between options.

### Push Notifications (Order Status, Delivery Updates)

All options use Firebase Cloud Messaging (FCM) on Android.
Flutter: `firebase_messaging` (FlutterFire, official)
React Native: `@react-native-firebase/messaging` (Invertase, well-maintained)
Native/KMP: FCM Android SDK directly

No meaningful difference. FCM setup is identical across frameworks.

### Biometric Authentication (Secure Payment Confirmation)

All options wrap Android BiometricPrompt.
Flutter: `local_auth` (official Flutter team plugin)
React Native: `react-native-biometrics` (community, well-maintained)
Native/KMP: BiometricPrompt directly

Known issues on budget Android devices (inconsistent fingerprint sensor quality)
affect all options equally — this is a hardware/OEM issue, not a framework issue.

---

## 12. Tooling and Developer Experience

### IDE Support

| Framework | Primary IDE | Quality of support |
|---|---|---|
| Native Android | Android Studio | Excellent (Google-built) |
| KMP | Android Studio + IntelliJ IDEA | Excellent |
| Flutter | Android Studio, VS Code | Excellent (Flutter plugin) |
| React Native | VS Code | Very good |

---

### Hot Reload

| Framework | Hot reload | Scope |
|---|---|---|
| Native Android | Compose live literals (limited) | UI constants only |
| KMP | Compose live literals (Android) | UI constants only |
| Flutter | Hot reload | Most code changes without state loss |
| React Native | Fast Refresh | Most code changes without state loss |

Flutter's hot reload is the fastest development iteration cycle of any native-compiled
option. Changes to widget trees, styles, and most logic are reflected in under a second
without losing application state. This meaningfully reduces iteration time during
UI development — particularly for the complex meal builder screen.

---

### Debugging Tools

| Framework | Layout inspector | Network inspector | Performance profiler |
|---|---|---|---|
| Native Android | Layout Inspector (AS) | Network Inspector (AS) | Android Profiler |
| KMP | Same as Native Android | Same | Same |
| Flutter | Flutter DevTools | DevTools (excellent) | DevTools timeline |
| React Native | Flipper | Flipper network plugin | Hermes profiler |

Flutter DevTools is notably good — the widget inspector, network inspector,
memory profiler, and performance timeline are all integrated and purpose-built for Flutter.
It is comparable in quality to Android Studio's profilers.

---

## 13. The Web Frontend Question

The existing web frontend is built on Vite + React + TypeScript. It is substantially
complete: all pages, API client, auth/cart stores, service worker, PWA manifest.

| Framework | Can replace the web frontend? | Should it? |
|---|---|---|
| Native Android | No | N/A |
| KMP | No | N/A |
| Flutter | Flutter Web — technically yes | No — SEO, accessibility, and low-bandwidth loading make Flutter Web a poor fit for a food ordering web experience |
| React Native | React Native Web — technically yes | Partially — RN Web has CSS layout quirks and performs worse than pure React for standard web UI |

**The correct answer for all options: keep the existing Vite/React web frontend.**

Flutter Web and React Native Web are valid for specific use cases
(internal dashboards, single-page tools) but are not suitable replacements
for a consumer-facing food ordering web experience where SEO, accessibility,
and sub-2-second load times on slow connections matter.

---

## 14. Summary Scorecards

Scored 1–5 per criterion for this specific project.
5 = best fit, 1 = worst fit.

| Criterion | Native Android | KMP | Flutter | React Native |
|---|---|---|---|---|
| Drag-and-drop meal builder | 5 | 5 | 4 | 3 |
| Low-end Android performance | 5 | 5 | 4 | 3 |
| Offline / background sync reliability | 5 | 5 | 4 | 3 |
| Live tracking maps | 5 | 5 | 4 | 4 |
| Payment integration (EcoCash etc.) | 4 | 4 | 4 | 4 |
| iOS coverage | 1 | 5 | 5 | 5 |
| Team ramp-up (Kotlin backend) | 5 | 4 | 2 | 2 |
| Team ramp-up (React frontend) | 2 | 2 | 2 | 5 |
| Code sharing with backend | 3 | 5 | 1 | 1 |
| Code sharing with web frontend | 1 | 1 | 1 | 5 |
| App size (install barrier) | 5 | 5 | 3 | 2 |
| Hot reload / dev iteration speed | 2 | 2 | 5 | 4 |
| Long-term ecosystem stability | 5 | 4 | 3 | 3 |
| Single language / codebase | 5 | 3 | 5 | 5 |
| Widget / UI testing speed | 4 | 4 | 5 | 3 |
| **Total (out of 75)** | **57** | **64** | **54** | **52** |

**Note:** KMP scores highest because it delivers native quality on both platforms
with maximum code sharing. Its main cost is the Swift developer requirement.
If that requirement is removed (iOS is not a near-term target), Native Android
scores equivalently for the Android-only phase.

---

## 15. Decision Matrix by Team Composition

### Scenario A: Android-only now, iOS later (6–12 months)

**Recommended: Native Android → migrate to KMP when iOS becomes a priority**

Start with Native Android (Kotlin + Compose). When iOS is needed, restructure
into a KMP shared module — this is a mechanical refactor, not a rewrite.
The Kotlin code you write today is the Kotlin code that runs in the shared module tomorrow.

---

### Scenario B: Android + iOS simultaneously, Kotlin-heavy team

**Recommended: KMP**

Share all business logic in Kotlin. Hire or contract one Swift developer for
the SwiftUI UI layer. Both platforms get native performance and feel.
The shared module leverages your team's existing Kotlin expertise.

---

### Scenario C: Android + iOS simultaneously, React-heavy team

**Recommended: Flutter (over React Native)**

Your React team's TypeScript knowledge transfers to Dart faster than expected.
Flutter's performance on low-end Android is materially better than React Native's —
critical for the Zimbabwe market. The drag-and-drop meal builder is more reliable.
React Native's advantage (code sharing with the web frontend) is real but
the performance penalty on the target device profile is not worth it.

---

### Scenario D: Android + iOS simultaneously, mixed team, maximum velocity

**Recommended: React Native**

The frontend team ships immediately with familiar tools. API client, stores, and
types are shared with the web frontend — weeks of work avoided. The performance
gap on low-end Android is real but manageable with correct Reanimated implementation.
Accept the trade-off consciously.

---

### Scenario E: Long-term, scaling, maximum platform quality

**Recommended: KMP → eventually split to fully native**

Start KMP. As the team grows and platform-specific requirements become more complex
(custom camera, AR food preview, NFC tap-to-pay), progressively move UI layers
to full native. The shared Kotlin logic layer remains intact throughout.
This is the path Cash App, Netflix, and Philips have taken.

---

## 16. Final Recommendation for Dial-A-Breakfast Zimbabwe

Given:
- Android-first market (iOS < 8% of Zimbabwe smartphone users)
- Low-end device performance is critical
- Offline / low-bandwidth optimisation is a stated requirement
- Backend team knows Kotlin
- Frontend team knows TypeScript/React
- Drag-and-drop meal builder is a core product differentiator

**Phase 1 (now — 3 months): Native Android with Kotlin + Jetpack Compose**

Best performance. Team's existing Kotlin expertise applies immediately.
Drag-and-drop and offline sync are best-in-class.
No iOS overhead while the Android product is being validated.

**Phase 2 (3–9 months): Restructure into KMP**

When the Android app is stable and iOS demand emerges, extract the data and
domain layers into a KMP shared module. The Android UI does not change.
Add an iOS Xcode project with SwiftUI screens. This is a refactor, not a rewrite.

**What this means for the current Android scaffold:**

The Kotlin/Compose Android project already scaffolded in `mobile/android/` is the
correct starting point. When Phase 2 begins, the directory structure becomes:

```
mobile/
  shared/           ← extract data/ and domain/ here as KMP module
  android/          ← existing app, ui/ layer unchanged
  ios/              ← new Xcode project, SwiftUI UI only
```

---

## Appendix: Key Libraries Reference

### Native Android / KMP Android

| Purpose | Library |
|---|---|
| HTTP client | Retrofit (Android-only) / Ktor (KMP) |
| JSON | Moshi / kotlinx.serialization |
| Local database | Room (Android-only) / SQLDelight (KMP) |
| DI | Hilt |
| Image loading | Coil |
| Maps | Google Maps Android SDK |
| Background sync | WorkManager |
| Secure storage | Android Keystore / DataStore |
| Payments | Stripe Android SDK, WebView for EcoCash |

### Flutter

| Purpose | Library |
|---|---|
| HTTP client | Dio |
| JSON | `json_serializable` + `freezed` |
| Local database | Drift (SQLite) |
| State management | Riverpod 2 |
| DI | Riverpod (also serves as DI) |
| Image loading | `cached_network_image` |
| Maps | `google_maps_flutter` |
| Navigation | GoRouter |
| Background sync | `workmanager` |
| Secure storage | `flutter_secure_storage` |
| Payments | `flutter_stripe`, `webview_flutter` |

### React Native

| Purpose | Library |
|---|---|
| HTTP client | Axios / fetch |
| JSON | Native (no extra library needed) |
| Local database | WatermelonDB / SQLite |
| State management | Zustand (shared with web) |
| Server state | TanStack Query (shared with web) |
| DI | Manual / context |
| Image loading | `react-native-fast-image` |
| Maps | `react-native-maps` |
| Navigation | React Navigation v6 |
| Gestures | `react-native-gesture-handler` |
| Animations | `react-native-reanimated` v3 |
| Background sync | `react-native-background-fetch` |
| Secure storage | `react-native-keychain` |
| Payments | `@stripe/stripe-react-native`, WebView |
