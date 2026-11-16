import '../../data/model/complaint_data_model.dart';
import '../../domain/entities/complaint_entity.dart';

extension ComplaintSummaryMapper on ComplaintSummaryDataModel {
  ComplaintSummaryEntity toEntity() {
    return ComplaintSummaryEntity(
      totalCount: totalCount,
      pendingCount: pendingCount,
      processingCount: processingCount,
      resolvedCount: resolvedCount,
      complaints: complaints.map((c) => c.toEntity()).toList(),
    );
  }
}

extension ComplaintListItemMapper on ComplaintListItemModel {
  ComplaintListItemEntity toEntity() {
    return ComplaintListItemEntity(
      id: id,
      apartmentNumber: apartmentNumber,
      category: category,
      title: title,
      content: content,
      attachedImageUrl: attachedImageUrl,
      resolvedImageUrl: resolvedImageUrl,
      status: status,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
    );
  }
}
