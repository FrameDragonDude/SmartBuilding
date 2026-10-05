class Complaint {
  final String id;
  final String residentId;
  final String apartmentId;
  final String category;
  final String title;
  final String content;
  final String? attachedImageUrl;
  final String status;

  Complaint({
    required this.id,
    required this.residentId,
    required this.apartmentId,
    required this.category,
    required this.title,
    required this.content,
    this.attachedImageUrl,
    required this.status,
  });
}
