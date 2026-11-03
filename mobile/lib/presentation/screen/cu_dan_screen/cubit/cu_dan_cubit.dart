import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/resident_repository.dart';
import 'cu_dan_state.dart';

class CuDanCubit extends Cubit<CuDanState> {
  final ResidentRepository residentRepository;

  CuDanCubit({ResidentRepository? residentRepository})
      : residentRepository = residentRepository ?? ResidentRepository(),
        super(CuDanInitial());

  Future<void> fetchResidentProfile({String residentId = 'Res1'}) async {
    emit(CuDanLoading());
    try {
      final profile = await residentRepository.getFullProfile(residentId: residentId);
      emit(CuDanLoaded(profile));
    } catch (e) {
      emit(CuDanError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
