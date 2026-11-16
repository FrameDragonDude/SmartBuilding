import '../repo/i_complaint_repository.dart';

class CreateComplaintUseCase {
  final IComplaintRepository repository;

  CreateComplaintUseCase(this.repository);

  Future<bool> execute({
    required String residentId,
    required String category,
    required String title,
    required String content,
    String? attachedImageUrl,
  }) {
    return repository.createComplaint(
      residentId: residentId,
      category: category,
      title: title,
      content: content,
      attachedImageUrl: attachedImageUrl,
    );
  }
}
