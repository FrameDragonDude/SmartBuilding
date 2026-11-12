import '../../data/model/resident_profile_model.dart';

abstract class IResidentRepository {
  Future<ResidentProfileDataModel> getResidentProfile(String residentId);

  Future<bool> registerVehicle({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  });
}
