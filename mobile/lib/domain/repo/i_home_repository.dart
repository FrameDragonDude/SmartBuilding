import '../../data/model/home_data_model.dart';

abstract class IHomeRepository {
  Future<HomeDataModel> getHomeData({String residentId = 'Res1'});
}
