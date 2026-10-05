import '../../domain/entities/complaint.dart';

class ComplaintModel extends Complaint {
  ComplaintModel({
    required super.id,
    required super.residentId,
    required super.apartmentId,
    required super.category,
    required super.title,
    required super.content,
    super.attachedImageUrl,
    required super.status,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      residentId: json['residentId'] ?? '',
      apartmentId: json['apartmentId'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachedImageUrl: json['attachedImageUrl'],
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'apartmentId': apartmentId,
      'category': category,
      'title': title,
      'content': content,
      'attachedImageUrl': attachedImageUrl,
      'status': status,
    };
  }
}
