import '../../data/model/complaint_data_model.dart';

abstract class IComplaintRepository {
  Future<ComplaintSummaryDataModel> getComplaints({
    String residentId = 'Res1',
    String? category,
    String? status,
  });

  Future<bool> createComplaint({
    required String residentId,
    required String category,
    required String title,
    required String content,
    String? attachedImageUrl,
  });
}
