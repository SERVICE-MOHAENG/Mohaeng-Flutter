import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_repository_impl.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:mohaeng_app_service/features/splash/presentation/view_model/splash_view_model.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(),
);

final splashAuthRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      AuthRepositoryImpl(tokenStorage: ref.watch(authTokenStorageProvider)),
);

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashState>(
      (ref) => SplashViewModel(
        ref.watch(authTokenStorageProvider),
        ref.watch(splashAuthRepositoryProvider),
      ),
    );
