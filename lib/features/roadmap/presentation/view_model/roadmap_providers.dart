import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/additional_request_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/budget_range_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/companion_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/concept_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/countries_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/country_regions_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/people_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/region_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/schedule_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_itinerary_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_itinerary_status_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_itinerary_result_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_survey_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_chat_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_modification_status_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_preference_result_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/travel_style_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/data/repository/country_repository_impl.dart';
import 'package:mohaeng_app_service/features/roadmap/data/repository/country_region_repository_impl.dart';
import 'package:mohaeng_app_service/features/roadmap/data/repository/roadmap_repository_impl.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_repository.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_region_repository.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/create_roadmap_itinerary.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/create_roadmap_survey.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_countries.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_itinerary_status.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_itinerary_result.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_country_regions.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_job_result.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_me_result.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/send_roadmap_chat.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_modification_status.dart';

final regionSelectViewModelProvider =
    StateNotifierProvider<RegionSelectViewModel, RegionSelectState>(
      (ref) => RegionSelectViewModel(),
    );

final countryRepositoryProvider = Provider<CountryRepository>(
  (ref) => CountryRepositoryImpl(),
);

final getCountriesUsecaseProvider = Provider<GetCountriesUsecase>(
  (ref) => GetCountriesUsecase(ref.watch(countryRepositoryProvider)),
);

final countriesViewModelProvider =
    StateNotifierProvider<CountriesViewModel, CountriesState>(
      (ref) => CountriesViewModel(ref.watch(getCountriesUsecaseProvider)),
    );

final countryRegionRepositoryProvider = Provider<CountryRegionRepository>(
  (ref) => CountryRegionRepositoryImpl(),
);

final getCountryRegionsUsecaseProvider = Provider<GetCountryRegionsUsecase>(
  (ref) => GetCountryRegionsUsecase(ref.watch(countryRegionRepositoryProvider)),
);

final countryRegionsViewModelProvider =
    StateNotifierProvider<CountryRegionsViewModel, CountryRegionsState>(
      (ref) =>
          CountryRegionsViewModel(ref.watch(getCountryRegionsUsecaseProvider)),
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

final roadmapRepositoryProvider = Provider<RoadmapRepository>(
  (ref) => RoadmapRepositoryImpl(),
);

final createRoadmapSurveyUsecaseProvider = Provider<CreateRoadmapSurveyUsecase>(
  (ref) => CreateRoadmapSurveyUsecase(ref.watch(roadmapRepositoryProvider)),
);

final createRoadmapItineraryUsecaseProvider =
    Provider<CreateRoadmapItineraryUsecase>(
      (ref) =>
          CreateRoadmapItineraryUsecase(ref.watch(roadmapRepositoryProvider)),
    );

final getRoadmapItineraryStatusUsecaseProvider =
    Provider<GetRoadmapItineraryStatusUsecase>(
      (ref) => GetRoadmapItineraryStatusUsecase(
        ref.watch(roadmapRepositoryProvider),
      ),
    );

final getRoadmapItineraryResultUsecaseProvider =
    Provider<GetRoadmapItineraryResultUsecase>(
      (ref) => GetRoadmapItineraryResultUsecase(
        ref.watch(roadmapRepositoryProvider),
      ),
    );

final getRoadmapPreferenceJobResultUsecaseProvider =
    Provider<GetRoadmapPreferenceJobResultUsecase>(
      (ref) => GetRoadmapPreferenceJobResultUsecase(
        ref.watch(roadmapRepositoryProvider),
      ),
    );

final getRoadmapPreferenceMeResultUsecaseProvider =
    Provider<GetRoadmapPreferenceMeResultUsecase>(
      (ref) => GetRoadmapPreferenceMeResultUsecase(
        ref.watch(roadmapRepositoryProvider),
      ),
    );

final sendRoadmapChatUsecaseProvider = Provider<SendRoadmapChatUsecase>(
  (ref) => SendRoadmapChatUsecase(ref.watch(roadmapRepositoryProvider)),
);

final getRoadmapModificationStatusUsecaseProvider =
    Provider<GetRoadmapModificationStatusUsecase>(
      (ref) => GetRoadmapModificationStatusUsecase(
        ref.watch(roadmapRepositoryProvider),
      ),
    );

final roadmapSurveyViewModelProvider =
    StateNotifierProvider<RoadmapSurveyViewModel, RoadmapSurveyState>(
      (ref) =>
          RoadmapSurveyViewModel(ref.watch(createRoadmapSurveyUsecaseProvider)),
    );

final roadmapItineraryViewModelProvider =
    StateNotifierProvider<RoadmapItineraryViewModel, RoadmapItineraryState>(
      (ref) => RoadmapItineraryViewModel(
        ref.watch(createRoadmapItineraryUsecaseProvider),
      ),
    );

final roadmapItineraryStatusViewModelProvider =
    StateNotifierProvider<
      RoadmapItineraryStatusViewModel,
      RoadmapItineraryStatusState
    >(
      (ref) => RoadmapItineraryStatusViewModel(
        ref.watch(getRoadmapItineraryStatusUsecaseProvider),
      ),
    );

final roadmapItineraryResultViewModelProvider =
    StateNotifierProvider<
      RoadmapItineraryResultViewModel,
      RoadmapItineraryResultState
    >(
      (ref) => RoadmapItineraryResultViewModel(
        ref.watch(getRoadmapItineraryResultUsecaseProvider),
      ),
    );

final roadmapChatViewModelProvider =
    StateNotifierProvider<RoadmapChatViewModel, RoadmapChatState>(
      (ref) => RoadmapChatViewModel(ref.watch(sendRoadmapChatUsecaseProvider)),
    );

final roadmapModificationStatusViewModelProvider =
    StateNotifierProvider<
      RoadmapModificationStatusViewModel,
      RoadmapModificationStatusState
    >(
      (ref) => RoadmapModificationStatusViewModel(
        ref.watch(getRoadmapModificationStatusUsecaseProvider),
      ),
    );

final roadmapPreferenceResultViewModelProvider =
    StateNotifierProvider<
      RoadmapPreferenceResultViewModel,
      RoadmapPreferenceResultState
    >(
      (ref) => RoadmapPreferenceResultViewModel(
        ref.watch(getRoadmapPreferenceJobResultUsecaseProvider),
        ref.watch(getRoadmapPreferenceMeResultUsecaseProvider),
      ),
    );
