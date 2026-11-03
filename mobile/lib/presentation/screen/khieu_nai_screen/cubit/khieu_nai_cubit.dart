import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repo/complaint_repository.dart';
import 'khieu_nai_state.dart';

class KhieuNaiCubit extends Cubit<KhieuNaiState> {
  final ComplaintRepository complaintRepository;

  KhieuNaiCubit({ComplaintRepository? complaintRepository})
      : complaintRepository = complaintRepository ?? ComplaintRepository(),
        super(KhieuNaiInitial());

  Future<void> fetchComplaints({
    String residentId = 'Res1',
    String? filter,
  }) async {
    emit(KhieuNaiLoading());
    try {
      String? statusParam;
      if (filter == 'Chờ tiếp nhận') statusParam = 'Pending';
      if (filter == 'Đang xử lý') statusParam = 'Processing';
      if (filter == 'Đã hoàn thành') statusParam = 'Resolved';

      final summary = await complaintRepository.getComplaints(
        residentId: residentId,
        status: statusParam,
      );

      emit(KhieuNaiLoaded(summary: summary, selectedFilter: filter ?? 'Tất cả'));
    } catch (e) {
      emit(KhieuNaiError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void filterComplaints(String filter, {String residentId = 'Res1'}) {
    fetchComplaints(residentId: residentId, filter: filter);
  }

  Future<void> createComplaint({
    required String residentId,
    required String title,
    required String content,
    String category = 'Sanitation',
    String? attachedImageUrl,
  }) async {
    try {
      final success = await complaintRepository.createComplaint(
        residentId: residentId,
        title: title,
        content: content,
        category: category,
        attachedImageUrl: attachedImageUrl,
      );
      if (success) {
        emit(const ComplaintCreatedSuccess("Tạo khiếu nại/phản hồi thành công!"));
        await fetchComplaints(residentId: residentId);
      }
    } catch (e) {
      emit(KhieuNaiError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
