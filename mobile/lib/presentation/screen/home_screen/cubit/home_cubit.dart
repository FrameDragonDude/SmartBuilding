import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;

  HomeCubit({HomeRepository? homeRepository})
      : homeRepository = homeRepository ?? HomeRepository(),
        super(HomeInitial());

  Future<void> fetchHomeData({String residentId = 'Res1'}) async {
    emit(HomeLoading());
    try {
      final homeData = await homeRepository.getHomeData(residentId: residentId);
      emit(HomeLoaded(homeData));
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
