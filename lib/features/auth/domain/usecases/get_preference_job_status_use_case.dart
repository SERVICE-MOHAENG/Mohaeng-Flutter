import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class GetPreferenceJobStatusUseCase {
  const GetPreferenceJobStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call({required String jobId}) {
    return _repository.getPreferenceJobStatus(jobId: jobId);
  }
}
