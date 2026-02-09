import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class TravelStyleSelectState {
  const TravelStyleSelectState({this.pageIndex = 0, this.answers = const {}});

  final int pageIndex;
  final Map<String, String> answers;

  TravelStyleSelectState copyWith({
    int? pageIndex,
    Map<String, String>? answers,
  }) {
    return TravelStyleSelectState(
      pageIndex: pageIndex ?? this.pageIndex,
      answers: answers ?? this.answers,
    );
  }
}

class TravelStyleSelectViewModel extends StateNotifier<TravelStyleSelectState> {
  TravelStyleSelectViewModel() : super(const TravelStyleSelectState());

  void setPageIndex(int index) {
    state = state.copyWith(pageIndex: index);
  }

  void selectAnswer({required String questionId, required String optionId}) {
    final next = {...state.answers};
    next[questionId] = optionId;
    state = state.copyWith(answers: next);
  }
}
