import '../../domain/repo/i_home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../model/home_data_model.dart';

class HomeRepository implements IHomeRepository {
  final IHomeRemoteDataSource remoteDataSource;

  HomeRepository({IHomeRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? HomeRemoteDataSourceImpl();

  @override
  Future<HomeDataModel> getHomeData({String residentId = 'Res1'}) {
    return remoteDataSource.getHomeData(residentId: residentId);
  }
}
