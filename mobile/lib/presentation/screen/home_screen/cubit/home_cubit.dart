import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/home_repository.dart';
import '../../../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeCubit({GetHomeDataUseCase? getHomeDataUseCase})
      : getHomeDataUseCase = getHomeDataUseCase ?? GetHomeDataUseCase(HomeRepository()),
        super(HomeInitial());

  Future<void> fetchHomeData({String residentId = 'Res1'}) async {
    emit(HomeLoading());
    try {
      final homeData = await getHomeDataUseCase.execute(residentId: residentId);
      emit(HomeLoaded(homeData));
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
