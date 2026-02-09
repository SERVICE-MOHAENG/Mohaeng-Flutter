import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

@immutable
class ConceptSelectState {
  const ConceptSelectState({this.selected = const {}});

  final Set<TravelConcept> selected;

  ConceptSelectState copyWith({Set<TravelConcept>? selected}) {
    return ConceptSelectState(selected: selected ?? this.selected);
  }
}

class ConceptSelectViewModel extends StateNotifier<ConceptSelectState> {
  ConceptSelectViewModel() : super(const ConceptSelectState());

  void toggle(TravelConcept concept) {
    final next = {...state.selected};
    if (next.contains(concept)) {
      next.remove(concept);
    } else {
      next.add(concept);
    }
    state = state.copyWith(selected: next);
  }
}
