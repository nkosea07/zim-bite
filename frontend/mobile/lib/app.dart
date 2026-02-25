import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/routing/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class ZimBiteApp extends StatefulWidget {
  const ZimBiteApp({super.key});

  @override
  State<ZimBiteApp> createState() => _ZimBiteAppState();
}

class _ZimBiteAppState extends State<ZimBiteApp> {
  late final SecureStorage _secureStorage;
  late final TokenStorage _tokenStorage;
  late final DioClient _dioClient;
  late final AuthRepository _authRepository;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _secureStorage = SecureStorage();
    _tokenStorage = TokenStorage(_secureStorage);

    _dioClient = DioClient(baseUrl: EnvConfig.apiBaseUrl);

    // Separate Dio for token refresh (avoids interceptor recursion)
    final refreshDioClient = DioClient(baseUrl: EnvConfig.apiBaseUrl);

    _dioClient.addInterceptor(
      AuthInterceptor(
        tokenStorage: _tokenStorage,
        refreshDio: refreshDioClient.dio,
      ),
    );

    _authRepository = AuthRepository(_dioClient.dio, _tokenStorage);
    _authBloc = AuthBloc(_authRepository, _tokenStorage)
      ..add(AuthCheckStatus());

    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _authRepository),
          RepositoryProvider.value(value: _dioClient),
          RepositoryProvider.value(value: _tokenStorage),
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
