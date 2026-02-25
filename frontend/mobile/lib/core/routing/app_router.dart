import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/order_list_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/profile/presentation/screens/favorites_screen.dart';
import '../../features/vendors/presentation/screens/vendor_list_screen.dart';
import '../../features/vendors/presentation/screens/vendor_detail_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/meal_builder/presentation/screens/meal_builder_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/delivery_tracking/presentation/screens/delivery_tracking_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_list_screen.dart';
import '../../features/subscriptions/presentation/screens/create_subscription_screen.dart';
import '../../features/notifications/presentation/screens/notification_list_screen.dart';
import 'route_names.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router;

  AppRouter(AuthBloc authBloc) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthRoute = state.matchedLocation.startsWith('/auth');

        if (authState is! AuthAuthenticated && !isAuthRoute) {
          return '/auth/login';
        }
        if (authState is AuthAuthenticated && isAuthRoute) {
          return '/home';
        }
        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      routes: [
        // Auth routes
        GoRoute(
          path: '/auth/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/otp',
          name: RouteNames.otp,
          builder: (context, state) {
            final principal = state.extra as String? ?? '';
            return OtpScreen(principal: principal);
          },
        ),
        GoRoute(
          path: '/auth/register',
          name: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main shell with bottom nav
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _ScaffoldWithNav(shell: shell),
          branches: [
            // Home tab
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ]),
            // Orders tab
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/orders',
                name: RouteNames.orders,
                builder: (context, state) => const OrderListScreen(),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    name: RouteNames.orderDetail,
                    builder: (context, state) => OrderDetailScreen(
                      orderId: state.pathParameters['orderId']!,
                    ),
                  ),
                ],
              ),
            ]),
            // Profile tab
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.editProfile,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    name: RouteNames.addresses,
                    builder: (context, state) => const AddressesScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    name: RouteNames.favorites,
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                ],
              ),
            ]),
          ],
        ),

        // Full-screen routes (outside bottom nav)
        GoRoute(
          path: '/vendors',
          name: RouteNames.vendors,
          builder: (context, state) => const VendorListScreen(),
        ),
        GoRoute(
          path: '/vendors/:vendorId',
          name: RouteNames.vendorDetail,
          builder: (context, state) => VendorDetailScreen(
            vendorId: state.pathParameters['vendorId']!,
          ),
        ),
        GoRoute(
          path: '/vendors/:vendorId/menu',
          name: RouteNames.menu,
          builder: (context, state) => MenuScreen(
            vendorId: state.pathParameters['vendorId']!,
          ),
        ),
        GoRoute(
          path: '/meal-builder',
          name: RouteNames.mealBuilder,
          builder: (context, state) => const MealBuilderScreen(),
        ),
        GoRoute(
          path: '/cart',
          name: RouteNames.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          name: RouteNames.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/delivery-tracking/:orderId',
          name: RouteNames.deliveryTracking,
          builder: (context, state) => DeliveryTrackingScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
        GoRoute(
          path: '/subscriptions',
          name: RouteNames.subscriptions,
          builder: (context, state) => const SubscriptionListScreen(),
        ),
        GoRoute(
          path: '/subscriptions/create',
          name: RouteNames.createSubscription,
          builder: (context, state) => const CreateSubscriptionScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: RouteNames.notifications,
          builder: (context, state) => const NotificationListScreen(),
        ),
      ],
    );
  }
}

class _ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _ScaffoldWithNav({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Converts a Stream into a Listenable for GoRouter's refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
