import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/send_roadmap_chat.dart';

@immutable
class RoadmapChatState {
  const RoadmapChatState({
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapChatResponse? response;

  RoadmapChatState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapChatResponse? response,
    bool keepResponse = true,
  }) {
    return RoadmapChatState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: keepResponse ? (response ?? this.response) : response,
    );
  }
}

class RoadmapChatViewModel extends StateNotifier<RoadmapChatState> {
  RoadmapChatViewModel(this._sendRoadmapChatUsecase)
    : super(const RoadmapChatState());

  final SendRoadmapChatUsecase _sendRoadmapChatUsecase;

  Future<bool> submit({
    required String itineraryId,
    required String message,
  }) async {
    if (state.isLoading) return false;
    if (itineraryId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '로드맵 ID가 필요합니다.');
      return false;
    }
    if (message.trim().isEmpty) {
      state = state.copyWith(errorMessage: '메시지를 입력해주세요.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _sendRoadmapChatUsecase(
        itineraryId: itineraryId.trim(),
        request: RoadmapChatRequest(message: message.trim()),
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '로드맵 수정 요청을 전송하지 못했어요.',
        },
      );
      return false;
    }
  }
}
