import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';

abstract class RoadmapRepository {
  Future<RoadmapSurveyResponse> createSurvey({
    required RoadmapSurveyRequest request,
  });

  Future<RoadmapItineraryResponse> createItinerary({
    required RoadmapItineraryRequest request,
  });

  Future<RoadmapItineraryStatusResponse> getItineraryStatus({
    required String jobId,
  });

  Future<RoadmapItineraryResultResponse> getItineraryResult({
    required String jobId,
  });

  Future<RoadmapChatResponse> sendRoadmapChat({
    required String itineraryId,
    required RoadmapChatRequest request,
  });

  Future<RoadmapModificationStatusResponse> getModificationStatus({
    required String jobId,
  });

  Future<List<RoadmapPreferenceResultItem>> getPreferenceJobResult({
    required String jobId,
  });

  Future<List<RoadmapPreferenceResultItem>> getPreferenceMeResult();
}
