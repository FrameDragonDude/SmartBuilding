import '../../data/model/complaint_data_model.dart';
import '../../domain/repo/i_complaint_repository.dart';

class GetComplaintsUseCase {
  final IComplaintRepository repository;

  GetComplaintsUseCase(this.repository);

  Future<ComplaintSummaryDataModel> execute({
    String residentId = 'Res1',
    String? category,
    String? status,
  }) async {
    return await repository.getComplaints(
      residentId: residentId,
      category: category,
      status: status,
    );
  }
}
