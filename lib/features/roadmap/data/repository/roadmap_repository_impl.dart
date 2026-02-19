import 'package:mohaeng_app_service/features/roadmap/data/datasource/roadmap_remote_datasource.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class RoadmapRepositoryImpl implements RoadmapRepository {
  RoadmapRepositoryImpl({RoadmapRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? RoadmapRemoteDataSource();

  final RoadmapRemoteDataSource _remoteDataSource;

  @override
  Future<RoadmapSurveyResponse> createSurvey({
    required RoadmapSurveyRequest request,
  }) {
    return _remoteDataSource.createSurvey(request: request);
  }

  @override
  Future<RoadmapItineraryResponse> createItinerary({
    required RoadmapItineraryRequest request,
  }) {
    return _remoteDataSource.createItinerary(request: request);
  }

  @override
  Future<RoadmapItineraryStatusResponse> getItineraryStatus({
    required String jobId,
  }) {
    return _remoteDataSource.getItineraryStatus(jobId: jobId);
  }

  @override
  Future<RoadmapItineraryResultResponse> getItineraryResult({
    required String jobId,
  }) {
    return _remoteDataSource.getItineraryResult(jobId: jobId);
  }

  @override
  Future<RoadmapChatResponse> sendRoadmapChat({
    required String itineraryId,
    required RoadmapChatRequest request,
  }) {
    return _remoteDataSource.sendRoadmapChat(
      itineraryId: itineraryId,
      request: request,
    );
  }

  @override
  Future<RoadmapModificationStatusResponse> getModificationStatus({
    required String jobId,
  }) {
    return _remoteDataSource.getModificationStatus(jobId: jobId);
  }
}
