import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/send_email_otp_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/verify_email_otp_use_case.dart';

@immutable
class SignUpViewState {
  const SignUpViewState({
    this.isSubmitting = false,
    this.isOtpSending = false,
    this.isOtpVerifying = false,
  });

  final bool isSubmitting;
  final bool isOtpSending;
  final bool isOtpVerifying;

  bool get isBusy => isSubmitting || isOtpSending || isOtpVerifying;

  SignUpViewState copyWith({
    bool? isSubmitting,
    bool? isOtpSending,
    bool? isOtpVerifying,
  }) {
    return SignUpViewState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isOtpVerifying: isOtpVerifying ?? this.isOtpVerifying,
    );
  }
}

enum SignUpActionType { success, failure }

@immutable
class SignUpActionResult {
  const SignUpActionResult({required this.type, this.message});

  final SignUpActionType type;
  final String? message;

  bool get isSuccess => type == SignUpActionType.success;
}

class SignUpViewModel extends StateNotifier<SignUpViewState> {
  SignUpViewModel({
    required SignUpUseCase signUpUseCase,
    required SendEmailOtpUseCase sendEmailOtpUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
  }) : _signUpUseCase = signUpUseCase,
       _sendEmailOtpUseCase = sendEmailOtpUseCase,
       _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
       super(const SignUpViewState());

  final SignUpUseCase _signUpUseCase;
  final SendEmailOtpUseCase _sendEmailOtpUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;

  Future<SignUpActionResult> submit({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    if (state.isSubmitting) {
      return const SignUpActionResult(type: SignUpActionType.failure);
    }

    state = state.copyWith(isSubmitting: true);
    try {
      await _signUpUseCase(
        name: name,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      return const SignUpActionResult(type: SignUpActionType.success);
    } catch (error) {
      return SignUpActionResult(
        type: SignUpActionType.failure,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<SignUpActionResult> sendEmailOtp({required String email}) async {
    if (state.isOtpSending) {
      return const SignUpActionResult(type: SignUpActionType.failure);
    }

    state = state.copyWith(isOtpSending: true);
    try {
      await _sendEmailOtpUseCase(email: email);
      return const SignUpActionResult(type: SignUpActionType.success);
    } catch (error) {
      return SignUpActionResult(
        type: SignUpActionType.failure,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      state = state.copyWith(isOtpSending: false);
    }
  }

  Future<SignUpActionResult> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (state.isOtpVerifying) {
      return const SignUpActionResult(type: SignUpActionType.failure);
    }

    state = state.copyWith(isOtpVerifying: true);
    try {
      await _verifyEmailOtpUseCase(email: email, otp: otp);
      return const SignUpActionResult(type: SignUpActionType.success);
    } catch (error) {
      return SignUpActionResult(
        type: SignUpActionType.failure,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      state = state.copyWith(isOtpVerifying: false);
    }
  }
}
