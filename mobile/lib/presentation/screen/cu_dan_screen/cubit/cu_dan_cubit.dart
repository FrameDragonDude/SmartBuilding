import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/resident_repository.dart';
import '../../../../domain/usecases/get_resident_profile_usecase.dart';
import '../../../../domain/usecases/register_vehicle_usecase.dart';
import 'cu_dan_state.dart';

class CuDanCubit extends Cubit<CuDanState> {
  final ResidentRepository residentRepository;
  final GetResidentProfileUseCase getResidentProfileUseCase;
  final RegisterVehicleUseCase registerVehicleUseCase;

  CuDanCubit({
    ResidentRepository? residentRepository,
    GetResidentProfileUseCase? getResidentProfileUseCase,
    RegisterVehicleUseCase? registerVehicleUseCase,
  })  : residentRepository = residentRepository ?? ResidentRepository(),
        getResidentProfileUseCase = getResidentProfileUseCase ?? GetResidentProfileUseCase(ResidentRepository()),
        registerVehicleUseCase = registerVehicleUseCase ?? RegisterVehicleUseCase(ResidentRepository()),
        super(CuDanInitial());

  Future<void> fetchResidentProfile({String residentId = 'Res1'}) async {
    emit(CuDanLoading());
    try {
      final profile = await getResidentProfileUseCase.execute(residentId);
      emit(CuDanLoaded(profile));
    } catch (e) {
      emit(CuDanError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> registerVehicle({
    required String residentId,
    required String vehicleType,
    required String licensePlate,
    required String rfidCardCode,
    String? brand,
    String? slotCode,
  }) async {
    try {
      final success = await registerVehicleUseCase.execute(
        residentId: residentId,
        vehicleType: vehicleType,
        licensePlate: licensePlate,
        rfidCardCode: rfidCardCode,
        brand: brand,
        slotCode: slotCode,
      );
      if (success) {
        await fetchResidentProfile(residentId: residentId);
      }
    } catch (e) {
      emit(CuDanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
