import '../../domain/repo/i_complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../model/complaint_data_model.dart';

class ComplaintRepository implements IComplaintRepository {
  final IComplaintRemoteDataSource remoteDataSource;

  ComplaintRepository({IComplaintRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ComplaintRemoteDataSourceImpl();

  @override
  Future<ComplaintSummaryDataModel> getComplaints({
    String residentId = 'Res1',
    String? category,
    String? status,
  }) {
    return remoteDataSource.getComplaints(
      residentId: residentId,
      category: category,
      status: status,
    );
  }

  @override
  Future<bool> createComplaint({
    required String residentId,
    required String category,
    required String title,
    required String content,
    String? attachedImageUrl,
  }) {
    return remoteDataSource.createComplaint(
      residentId: residentId,
      category: category,
      title: title,
      content: content,
      attachedImageUrl: attachedImageUrl,
    );
  }
}
