import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/additional_request_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/budget_range_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/companion_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/concept_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/people_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/region_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/schedule_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/travel_style_select_view_model.dart';

final regionSelectViewModelProvider =
    StateNotifierProvider<RegionSelectViewModel, RegionSelectState>(
      (ref) => RegionSelectViewModel(),
    );

final scheduleSelectViewModelProvider =
    StateNotifierProvider<ScheduleSelectViewModel, ScheduleSelectState>(
      (ref) => ScheduleSelectViewModel(),
    );

final peopleSelectViewModelProvider =
    StateNotifierProvider<PeopleSelectViewModel, PeopleSelectState>(
      (ref) => PeopleSelectViewModel(),
    );

final companionSelectViewModelProvider =
    StateNotifierProvider<CompanionSelectViewModel, CompanionSelectState>(
      (ref) => CompanionSelectViewModel(),
    );

final conceptSelectViewModelProvider =
    StateNotifierProvider<ConceptSelectViewModel, ConceptSelectState>(
      (ref) => ConceptSelectViewModel(),
    );

final travelStyleSelectViewModelProvider =
    StateNotifierProvider<TravelStyleSelectViewModel, TravelStyleSelectState>(
      (ref) => TravelStyleSelectViewModel(),
    );

final budgetRangeViewModelProvider =
    StateNotifierProvider<BudgetRangeViewModel, BudgetRangeState>(
      (ref) => BudgetRangeViewModel(),
    );

final additionalRequestViewModelProvider =
    StateNotifierProvider<AdditionalRequestViewModel, AdditionalRequestState>(
      (ref) => AdditionalRequestViewModel(),
    );
