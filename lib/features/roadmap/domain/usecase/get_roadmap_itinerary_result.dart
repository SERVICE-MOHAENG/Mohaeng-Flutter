import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class GetRoadmapItineraryResultUsecase {
  const GetRoadmapItineraryResultUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapItineraryResultResponse> call({
    required String jobId,
  }) {
    return _repository.getItineraryResult(jobId: jobId);
  }
}
