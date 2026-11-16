import '../../domain/repo/i_resident_repository.dart';
import '../datasources/resident_remote_datasource.dart';
import '../model/resident_profile_model.dart';

class ResidentRepository implements IResidentRepository {
  final IResidentRemoteDataSource remoteDataSource;

  ResidentRepository({IResidentRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ResidentRemoteDataSourceImpl();

  Future<ResidentProfileDataModel> getFullProfile({String residentId = 'Res1'}) {
    return remoteDataSource.getResidentProfile(residentId);
  }

  @override
  Future<ResidentProfileDataModel> getResidentProfile(String residentId) {
    return remoteDataSource.getResidentProfile(residentId);
  }

  @override
  Future<bool> registerVehicle({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  }) {
    return remoteDataSource.registerVehicle(
      residentId: residentId,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      rfidCardCode: rfidCardCode,
      brand: brand,
      slotCode: slotCode,
    );
  }
}
