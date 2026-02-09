import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

@immutable
class CompanionSelectState {
  const CompanionSelectState({this.selected});

  final CompanionType? selected;

  CompanionSelectState copyWith({CompanionType? selected}) {
    return CompanionSelectState(selected: selected);
  }
}

class CompanionSelectViewModel extends StateNotifier<CompanionSelectState> {
  CompanionSelectViewModel() : super(const CompanionSelectState());

  void select(CompanionType type) {
    state = state.copyWith(selected: type);
  }
}
