import '../../data/model/home_data_model.dart';
import '../repo/i_home_repository.dart';

class GetHomeDataUseCase {
  final IHomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<HomeDataModel> execute({String residentId = ''}) {
    return repository.getHomeData(residentId: residentId);
  }
}
