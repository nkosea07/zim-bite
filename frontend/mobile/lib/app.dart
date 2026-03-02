import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/routing/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';

// Repositories
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/vendors/data/repositories/vendor_repository.dart';
import 'features/menu/data/repositories/menu_repository.dart';
import 'features/orders/data/repositories/order_repository.dart';
import 'features/checkout/data/repositories/checkout_repository.dart';
import 'features/delivery_tracking/data/repositories/delivery_repository.dart';
import 'features/subscriptions/data/repositories/subscription_repository.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/meal_builder/data/repositories/meal_builder_repository.dart';

// BLoCs
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/vendors/bloc/vendor_bloc.dart';
import 'features/vendors/bloc/vendor_event.dart';
import 'features/menu/bloc/menu_bloc.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/orders/bloc/orders_bloc.dart';
import 'features/subscriptions/bloc/subscriptions_bloc.dart';
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';

class ZimBiteApp extends StatefulWidget {
  const ZimBiteApp({super.key});

  @override
  State<ZimBiteApp> createState() => _ZimBiteAppState();
}

class _ZimBiteAppState extends State<ZimBiteApp> {
  // ── Infrastructure ───────────────────────────────────────────────────────
  late final SecureStorage _secureStorage;
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;

  // ── Repositories ─────────────────────────────────────────────────────────
  late final AuthRepository _authRepository;
  late final VendorRepository _vendorRepository;
  late final MenuRepository _menuRepository;
  late final OrderRepository _orderRepository;
  late final CheckoutRepository _checkoutRepository;
  late final DeliveryRepository _deliveryRepository;
  late final SubscriptionRepository _subscriptionRepository;
  late final NotificationRepository _notificationRepository;
  late final ProfileRepository _profileRepository;
  late final MealBuilderRepository _mealBuilderRepository;

  // ── BLoCs (global / long-lived) ───────────────────────────────────────────
  late final AuthBloc _authBloc;
  late final CartBloc _cartBloc;
  late final VendorBloc _vendorBloc;
  late final MenuBloc _menuBloc;
  late final OrdersBloc _ordersBloc;
  late final SubscriptionsBloc _subscriptionsBloc;
  late final NotificationsBloc _notificationsBloc;
  late final ProfileBloc _profileBloc;

  // ── Routing ───────────────────────────────────────────────────────────────
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    // Infrastructure
    _secureStorage = SecureStorage();
    _tokenStorage  = TokenStorage(_secureStorage);
    _dioClient     = DioClient(baseUrl: EnvConfig.apiBaseUrl);

    // Separate Dio for token refresh (avoids interceptor recursion)
    final refreshDioClient = DioClient(baseUrl: EnvConfig.apiBaseUrl);
    _dioClient.addInterceptor(
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        refreshDio: refreshDioClient.dio,
      ),
    );

    final dio = _dioClient.dio;

    // Repositories
    _authRepository         = AuthRepository(dio, _tokenStorage);
    _vendorRepository       = VendorRepository(dio);
    _menuRepository         = MenuRepository(dio);
    _orderRepository        = OrderRepository(dio);
    _checkoutRepository     = CheckoutRepository(dio);
    _deliveryRepository     = DeliveryRepository(dio);
    _subscriptionRepository = SubscriptionRepository(dio);
    _notificationRepository = NotificationRepository(dio);
    _profileRepository      = ProfileRepository(dio);
    _mealBuilderRepository  = MealBuilderRepository(dio);

    // BLoCs
    _authBloc = AuthBloc(_authRepository, _tokenStorage)
      ..add(AuthCheckStatus());
    _cartBloc          = CartBloc();
    _vendorBloc        = VendorBloc(_vendorRepository)..add(const LoadVendors());
    _menuBloc          = MenuBloc(_menuRepository);
    _ordersBloc        = OrdersBloc(_orderRepository);
    _subscriptionsBloc = SubscriptionsBloc(_subscriptionRepository);
    _notificationsBloc = NotificationsBloc(_notificationRepository);
    _profileBloc       = ProfileBloc(_profileRepository);

    // Router (depends on authBloc for redirect logic)
    _appRouter = AppRouter(_authBloc, _tokenStorage);
  }

  @override
  void dispose() {
    _authBloc.close();
    _cartBloc.close();
    _vendorBloc.close();
    _menuBloc.close();
    _ordersBloc.close();
    _subscriptionsBloc.close();
    _notificationsBloc.close();
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _vendorRepository),
        RepositoryProvider.value(value: _menuRepository),
        RepositoryProvider.value(value: _orderRepository),
        RepositoryProvider.value(value: _checkoutRepository),
        RepositoryProvider.value(value: _deliveryRepository),
        RepositoryProvider.value(value: _subscriptionRepository),
        RepositoryProvider.value(value: _notificationRepository),
        RepositoryProvider.value(value: _profileRepository),
        RepositoryProvider.value(value: _mealBuilderRepository),
        RepositoryProvider.value(value: _dioClient),
        RepositoryProvider.value(value: _tokenStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _cartBloc),
          BlocProvider.value(value: _vendorBloc),
          BlocProvider.value(value: _menuBloc),
          BlocProvider.value(value: _ordersBloc),
          BlocProvider.value(value: _subscriptionsBloc),
          BlocProvider.value(value: _notificationsBloc),
          BlocProvider.value(value: _profileBloc),
        ],
        child: MaterialApp.router(
          title: 'ZimBite',
          theme: AppTheme.light,
          routerConfig: _appRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
