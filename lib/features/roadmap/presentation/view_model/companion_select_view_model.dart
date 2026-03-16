import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

@immutable
class CompanionSelectState {
  const CompanionSelectState({this.selected = const {}});

  final Set<CompanionType> selected;

  CompanionSelectState copyWith({Set<CompanionType>? selected}) {
    return CompanionSelectState(selected: selected ?? this.selected);
  }
}

class CompanionSelectViewModel extends StateNotifier<CompanionSelectState> {
  CompanionSelectViewModel() : super(const CompanionSelectState());

  void toggle(CompanionType type) {
    final next = state.selected.contains(type)
        ? <CompanionType>{}
        : <CompanionType>{type};
    state = state.copyWith(selected: next);
  }
}
