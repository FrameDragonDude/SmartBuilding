import '../../data/model/home_data_model.dart';
import '../repo/i_home_repository.dart';

class GetHomeDataUseCase {
  final IHomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<HomeDataModel> execute({String residentId = 'Res1'}) {
    return repository.getHomeData(residentId: residentId);
  }
}
