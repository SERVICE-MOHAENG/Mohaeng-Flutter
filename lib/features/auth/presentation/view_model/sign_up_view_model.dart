import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/get_preference_job_status_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/send_email_otp_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/submit_preferences_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/verify_email_otp_use_case.dart';

@immutable
class SignUpViewState {
  const SignUpViewState({
    this.isSubmitting = false,
    this.isOtpSending = false,
    this.isOtpVerifying = false,
    this.isPreferenceSubmitting = false,
  });

  final bool isSubmitting;
  final bool isOtpSending;
  final bool isOtpVerifying;
  final bool isPreferenceSubmitting;

  bool get isBusy =>
      isSubmitting || isOtpSending || isOtpVerifying || isPreferenceSubmitting;

  SignUpViewState copyWith({
    bool? isSubmitting,
    bool? isOtpSending,
    bool? isOtpVerifying,
    bool? isPreferenceSubmitting,
  }) {
    return SignUpViewState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isOtpVerifying: isOtpVerifying ?? this.isOtpVerifying,
      isPreferenceSubmitting:
          isPreferenceSubmitting ?? this.isPreferenceSubmitting,
    );
  }
}

enum SignUpActionType { success, failure }

@immutable
class SignUpActionResult {
  const SignUpActionResult({required this.type, this.message, this.jobId});

  final SignUpActionType type;
  final String? message;
  final String? jobId;

  bool get isSuccess => type == SignUpActionType.success;
}

class SignUpViewModel extends StateNotifier<SignUpViewState> {
  static const Duration _preferenceStatusPollingInterval = Duration(seconds: 30);
  static const int _preferenceStatusMaxAttempts = 40;

  SignUpViewModel({
    required SignUpUseCase signUpUseCase,
    required SendEmailOtpUseCase sendEmailOtpUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required SubmitPreferencesUseCase submitPreferencesUseCase,
    required GetPreferenceJobStatusUseCase getPreferenceJobStatusUseCase,
  }) : _signUpUseCase = signUpUseCase,
       _sendEmailOtpUseCase = sendEmailOtpUseCase,
       _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
       _submitPreferencesUseCase = submitPreferencesUseCase,
       _getPreferenceJobStatusUseCase = getPreferenceJobStatusUseCase,
       super(const SignUpViewState());

  final SignUpUseCase _signUpUseCase;
  final SendEmailOtpUseCase _sendEmailOtpUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final SubmitPreferencesUseCase _submitPreferencesUseCase;
  final GetPreferenceJobStatusUseCase _getPreferenceJobStatusUseCase;

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

  Future<SignUpActionResult> submitPreferences({
    required String weather,
    required String travelRange,
    required String travelStyle,
    required List<String> foodPersonality,
    required List<String> mainInterests,
    required String budgetLevel,
  }) async {
    if (state.isPreferenceSubmitting) {
      return const SignUpActionResult(type: SignUpActionType.failure);
    }

    state = state.copyWith(isPreferenceSubmitting: true);
    try {
      final response = await _submitPreferencesUseCase(
        weather: weather,
        travelRange: travelRange,
        travelStyle: travelStyle,
        foodPersonality: foodPersonality,
        mainInterests: mainInterests,
        budgetLevel: budgetLevel,
      );
      final jobId = response.jobId.trim();
      if (jobId.isEmpty) {
        return const SignUpActionResult(
          type: SignUpActionType.failure,
          message: '작업 ID를 확인할 수 없어요.',
        );
      }

      for (var attempt = 0; attempt < _preferenceStatusMaxAttempts; attempt++) {
        final status = await _getPreferenceJobStatusUseCase(jobId: jobId);
        final normalized = status.trim().toUpperCase();

        if (_isSuccessStatus(normalized)) {
          return SignUpActionResult(
            type: SignUpActionType.success,
            jobId: response.jobId,
          );
        }

        if (_isFailedStatus(normalized)) {
          return SignUpActionResult(
            type: SignUpActionType.failure,
            message: '추천 작업이 실패했어요. (status: $normalized)',
          );
        }

        if (attempt < _preferenceStatusMaxAttempts - 1) {
          await Future.delayed(_preferenceStatusPollingInterval);
        }
      }

      return const SignUpActionResult(
        type: SignUpActionType.failure,
        message: '추천 작업이 지연되고 있어요. 잠시 후 다시 시도해주세요.',
      );
    } catch (error) {
      return SignUpActionResult(
        type: SignUpActionType.failure,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      state = state.copyWith(isPreferenceSubmitting: false);
    }
  }

  bool _isSuccessStatus(String status) {
    return status == 'SUCCESS' ||
        status == 'COMPLETED' ||
        status == 'SUCCEEDED' ||
        status == 'DONE';
  }

  bool _isFailedStatus(String status) {
    return status == 'FAILED' ||
        status == 'TIMEOUT' ||
        status == 'ERROR' ||
        status == 'CANCELLED';
  }
}
