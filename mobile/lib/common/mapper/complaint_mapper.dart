import '../../data/model/complaint_model.dart';
import '../../domain/entities/complaint.dart';

extension ComplaintMapper on ComplaintModel {
  Complaint toEntity() {
    return Complaint(
      id: id,
      residentId: residentId,
      apartmentId: apartmentId,
      category: category,
      title: title,
      content: content,
      attachedImageUrl: attachedImageUrl,
      status: status,
    );
  }
}
