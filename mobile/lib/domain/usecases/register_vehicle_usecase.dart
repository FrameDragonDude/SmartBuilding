import '../repo/i_resident_repository.dart';

class RegisterVehicleUseCase {
  final IResidentRepository repository;

  RegisterVehicleUseCase(this.repository);

  Future<bool> execute({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  }) {
    return repository.registerVehicle(
      residentId: residentId,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      rfidCardCode: rfidCardCode,
      brand: brand,
      slotCode: slotCode,
    );
  }
}
