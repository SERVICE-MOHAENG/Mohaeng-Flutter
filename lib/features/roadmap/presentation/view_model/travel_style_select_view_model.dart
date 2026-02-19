import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

@immutable
class TravelStyleSelectState {
  const TravelStyleSelectState({
    this.pageIndex = 0,
    this.pacePreference,
    this.planningPreference,
    this.destinationPreference,
    this.activityPreference,
    this.priorityPreference,
  });

  final int pageIndex;
  final PacePreference? pacePreference;
  final PlanningPreference? planningPreference;
  final DestinationPreference? destinationPreference;
  final ActivityPreference? activityPreference;
  final PriorityPreference? priorityPreference;

  TravelStyleSelectState copyWith({
    int? pageIndex,
    PacePreference? pacePreference,
    PlanningPreference? planningPreference,
    DestinationPreference? destinationPreference,
    ActivityPreference? activityPreference,
    PriorityPreference? priorityPreference,
  }) {
    return TravelStyleSelectState(
      pageIndex: pageIndex ?? this.pageIndex,
      pacePreference: pacePreference ?? this.pacePreference,
      planningPreference: planningPreference ?? this.planningPreference,
      destinationPreference:
          destinationPreference ?? this.destinationPreference,
      activityPreference: activityPreference ?? this.activityPreference,
      priorityPreference: priorityPreference ?? this.priorityPreference,
    );
  }

  Object? selectedValue(TravelStyleQuestion question) {
    return switch (question) {
      TravelStyleQuestion.pace => pacePreference,
      TravelStyleQuestion.planning => planningPreference,
      TravelStyleQuestion.destination => destinationPreference,
      TravelStyleQuestion.activity => activityPreference,
      TravelStyleQuestion.priority => priorityPreference,
    };
  }

  bool isAnswered(TravelStyleQuestion question) {
    return selectedValue(question) != null;
  }
}

class TravelStyleSelectViewModel extends StateNotifier<TravelStyleSelectState> {
  TravelStyleSelectViewModel() : super(const TravelStyleSelectState());

  void setPageIndex(int index) {
    state = state.copyWith(pageIndex: index);
  }

  void selectAnswer({
    required TravelStyleQuestion question,
    required Object value,
  }) {
    switch (question) {
      case TravelStyleQuestion.pace:
        if (value is PacePreference) {
          state = state.copyWith(pacePreference: value);
        }
        break;
      case TravelStyleQuestion.planning:
        if (value is PlanningPreference) {
          state = state.copyWith(planningPreference: value);
        }
        break;
      case TravelStyleQuestion.destination:
        if (value is DestinationPreference) {
          state = state.copyWith(destinationPreference: value);
        }
        break;
      case TravelStyleQuestion.activity:
        if (value is ActivityPreference) {
          state = state.copyWith(activityPreference: value);
        }
        break;
      case TravelStyleQuestion.priority:
        if (value is PriorityPreference) {
          state = state.copyWith(priorityPreference: value);
        }
        break;
    }
  }
}
