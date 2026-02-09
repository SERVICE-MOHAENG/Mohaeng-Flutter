import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_repository_impl.dart';
import 'package:mohaeng_app_service/features/auth/data/google_login_repository_impl.dart';
import 'package:mohaeng_app_service/features/auth/data/kakao_login_repository_impl.dart';
import 'package:mohaeng_app_service/features/auth/data/naver_login_repository_impl.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/google_login_repository.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/kakao_login_repository.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/naver_login_repository.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/google_login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/kakao_login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/naver_login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/send_email_otp_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/verify_email_otp_use_case.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view_model/login_view_model.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view_model/sign_up_view_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final googleLoginRepositoryProvider = Provider<GoogleLoginRepository>(
  (ref) => GoogleLoginRepositoryImpl(),
);

final kakaoLoginRepositoryProvider = Provider<KakaoLoginRepository>(
  (ref) => KakaoLoginRepositoryImpl(),
);

final naverLoginRepositoryProvider = Provider<NaverLoginRepository>(
  (ref) => NaverLoginRepositoryImpl(),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>(
  (ref) => GoogleLoginUseCase(ref.watch(googleLoginRepositoryProvider)),
);

final kakaoLoginUseCaseProvider = Provider<KakaoLoginUseCase>(
  (ref) => KakaoLoginUseCase(ref.watch(kakaoLoginRepositoryProvider)),
);

final naverLoginUseCaseProvider = Provider<NaverLoginUseCase>(
  (ref) => NaverLoginUseCase(ref.watch(naverLoginRepositoryProvider)),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final sendEmailOtpUseCaseProvider = Provider<SendEmailOtpUseCase>(
  (ref) => SendEmailOtpUseCase(ref.watch(authRepositoryProvider)),
);

final verifyEmailOtpUseCaseProvider = Provider<VerifyEmailOtpUseCase>(
  (ref) => VerifyEmailOtpUseCase(ref.watch(authRepositoryProvider)),
);

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginViewState>(
      (ref) => LoginViewModel(
        loginUseCase: ref.watch(loginUseCaseProvider),
        googleLoginUseCase: ref.watch(googleLoginUseCaseProvider),
        kakaoLoginUseCase: ref.watch(kakaoLoginUseCaseProvider),
        naverLoginUseCase: ref.watch(naverLoginUseCaseProvider),
      ),
    );

final signUpViewModelProvider =
    StateNotifierProvider<SignUpViewModel, SignUpViewState>(
      (ref) => SignUpViewModel(
        signUpUseCase: ref.watch(signUpUseCaseProvider),
        sendEmailOtpUseCase: ref.watch(sendEmailOtpUseCaseProvider),
        verifyEmailOtpUseCase: ref.watch(verifyEmailOtpUseCaseProvider),
      ),
    );
