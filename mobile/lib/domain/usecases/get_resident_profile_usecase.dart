import '../../data/model/resident_profile_model.dart';
import '../../domain/repo/i_resident_repository.dart';

class GetResidentProfileUseCase {
  final IResidentRepository repository;

  GetResidentProfileUseCase(this.repository);

  Future<ResidentProfileDataModel> execute(String residentId) async {
    return await repository.getResidentProfile(residentId);
  }
}
