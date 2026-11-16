import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../configs/theme/app_color.dart';
import 'cubit/khieu_nai_cubit.dart';
import 'cubit/khieu_nai_state.dart';
import 'widgets/complaint_header.dart';
import 'widgets/complaint_stats_section.dart';
import 'widgets/complaint_filter_chips.dart';
import 'widgets/complaint_card.dart';
import 'widgets/floating_report_button.dart';

class KhieuNaiScreen extends StatelessWidget {
  final String? residentId;

  const KhieuNaiScreen({super.key, this.residentId});

  ComplaintStatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatusType.pending;
      case 'assigned':
        return ComplaintStatusType.assigned;
      case 'processing':
        return ComplaintStatusType.processing;
      case 'resolved':
      case 'closed':
        return ComplaintStatusType.completed;
      default:
        return ComplaintStatusType.pending;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ tiếp nhận';
      case 'assigned':
        return 'Đã phân công';
      case 'processing':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã giải quyết';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Chờ tiếp nhận';
    }
  }

  void _showCreateComplaintDialog(BuildContext context, KhieuNaiCubit cubit, String currentResidentId) {
    final formKey = GlobalKey<FormState>();
    String category = 'Sanitation';
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gửi phản ánh & Sự cố mới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Danh mục sự cố',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Sanitation', child: Text('Vệ sinh môi trường')),
                          DropdownMenuItem(value: 'Security', child: Text('An ninh & Trật tự')),
                          DropdownMenuItem(value: 'Technical', child: Text('Kỹ thuật / Điện nước')),
                          DropdownMenuItem(value: 'Noise', child: Text('Tiếng ồn')),
                          DropdownMenuItem(value: 'Other', child: Text('Dịch vụ khác')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => category = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề sự cố *',
                          hintText: 'VD: Rò rỉ nước tại bồn rửa, chập đèn hành lang...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Vui lòng nhập tiêu đề phản ánh'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Nội dung chi tiết *',
                          hintText: 'Mô tả cụ thể vị trí, thời gian xảy ra và tình trạng sự cố...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Vui lòng nhập nội dung chi tiết'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          try {
                            final picker = ImagePicker();
                            final img = await picker.pickImage(source: ImageSource.gallery);
                            if (img != null) {
                              setModalState(() {
                                imageController.text = img.name;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi chọn ảnh: $e')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.lightSlateContainer,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined, color: AppColors.secondary, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  imageController.text.isNotEmpty
                                      ? 'Ảnh đã chọn: ${imageController.text}'
                                      : 'Đính kèm ảnh hiện trường (Bấm để chọn ảnh)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: imageController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                    color: imageController.text.isNotEmpty ? AppColors.secondary : AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (imageController.text.isNotEmpty)
                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(context);
                              cubit.createComplaint(
                                residentId: currentResidentId,
                                title: titleController.text.trim(),
                                content: contentController.text.trim(),
                                category: category,
                                attachedImageUrl: imageController.text.trim().isNotEmpty
                                    ? imageController.text.trim()
                                    : null,
                              );
                            }
                          },
                          child: const Text(
                            'Gửi phản ánh ngay',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentResId = residentId ?? 'Res1';
    return BlocProvider(
      create: (context) => KhieuNaiCubit()..fetchComplaints(residentId: currentResId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<KhieuNaiCubit, KhieuNaiState>(
          listener: (context, state) {
            if (state is KhieuNaiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is ComplaintCreatedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.tertiary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is KhieuNaiLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is KhieuNaiLoaded) {
              final summary = state.summary;
              final complaints = summary.complaints;

              final cardDataList = complaints.map((item) {
                return ComplaintCardData(
                  code: item.id,
                  location: 'Căn ${item.apartmentNumber}',
                  title: item.title,
                  description: item.content,
                  status: _getStatusType(item.status),
                  statusText: _getStatusText(item.status),
                  timeText: item.createdAt,
                  imageUrl: item.attachedImageUrl,
                  attachmentText: item.attachedImageUrl != null ? '1 ảnh đính kèm' : null,
                );
              }).toList();

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await context.read<KhieuNaiCubit>().fetchComplaints(residentId: currentResId);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const ComplaintHeader(),
                          const SizedBox(height: 16),

                          // Stats Cards Section
                          ComplaintStatsSection(
                            totalCount: summary.totalCount,
                            processingCount: summary.pendingCount + summary.processingCount,
                            completedCount: summary.resolvedCount,
                          ),
                          const SizedBox(height: 16),

                          // Category Filter Chips
                          ComplaintFilterChips(
                            selectedFilter: state.selectedFilter,
                            onFilterSelected: (filter) {
                              context.read<KhieuNaiCubit>().filterComplaints(filter, residentId: currentResId);
                            },
                          ),
                          const SizedBox(height: 16),

                          // List of Complaint Cards
                          if (cardDataList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text('Không có khiếu nại/phản hồi nào'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cardDataList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return ComplaintCard(
                                  data: cardDataList[index],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Action Button at Bottom Right
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingReportButton(
                      onPressed: () {
                        _showCreateComplaintDialog(context, context.read<KhieuNaiCubit>(), currentResId);
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
