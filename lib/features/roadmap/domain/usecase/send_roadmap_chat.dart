import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class SendRoadmapChatUsecase {
  const SendRoadmapChatUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapChatResponse> call({
    required String itineraryId,
    required RoadmapChatRequest request,
  }) {
    return _repository.sendRoadmapChat(
      itineraryId: itineraryId,
      request: request,
    );
  }
}
