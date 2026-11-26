import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/network/api_client.dart';
import '../../../../data/model/notification_model.dart';
import '../../../../data/url/api_urls.dart';
import 'thong_bao_state.dart';

class ThongBaoCubit extends Cubit<ThongBaoState> {
  final ApiClient apiClient;
  static const String _prefKey = 'read_notification_ids';

  ThongBaoCubit({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient(),
        super(ThongBaoInitial());

  Future<Set<String>> _getSavedReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveReadIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, ids.toList());
    } catch (_) {}
  }

  Future<void> fetchNotifications({String residentId = 'Res1'}) async {
    emit(ThongBaoLoading());
    final savedReadIds = await _getSavedReadIds();

    List<NotificationModel> rawList = [];
    try {
      final response = await apiClient.dio.get(ApiUrls.notifications(residentId));
      if (response.data is List) {
        rawList = (response.data as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }
    } catch (_) {}



    // Apply persisted read states from SharedPreferences
    final list = rawList.map((item) {
      if (savedReadIds.contains(item.id)) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    emit(ThongBaoLoaded(list));
  }

  Future<void> markAllAsRead() async {
    if (state is ThongBaoLoaded) {
      final currentList = (state as ThongBaoLoaded).notifications;
      final savedReadIds = await _getSavedReadIds();
      savedReadIds.addAll(currentList.map((n) => n.id));
      await _saveReadIds(savedReadIds);

      final updatedList = currentList
          .map((item) => item.copyWith(isRead: true))
          .toList();
      emit(ThongBaoLoaded(updatedList));
    }
  }

  Future<void> markAsRead(String id) async {
    final savedReadIds = await _getSavedReadIds();
    savedReadIds.add(id);
    await _saveReadIds(savedReadIds);

    if (state is ThongBaoLoaded) {
      final currentList = (state as ThongBaoLoaded).notifications;
      final updatedList = currentList.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();
      emit(ThongBaoLoaded(updatedList));
    }
  }
}
