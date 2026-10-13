import 'package:flutter/material.dart';
import '../../../configs/theme/app_color.dart';
import 'widgets/complaint_header.dart';
import 'widgets/complaint_stats_section.dart';
import 'widgets/complaint_filter_chips.dart';
import 'widgets/complaint_card.dart';
import 'widgets/floating_report_button.dart';

class KhieuNaiScreen extends StatelessWidget {
  const KhieuNaiScreen({super.key});

  final List<ComplaintCardData> _mockComplaints = const [
    ComplaintCardData(
      code: 'CR1',
      location: 'Căn RB-0101',
      title: 'Hành lang tầng 1 có rác chưa thu gom',
      description:
          'Khu vực gần thang máy sảnh A có túi rác sinh hoạt lớn gây bốc mùi từ sáng sớm, chưa thấy tạp vụ thu dọn.',
      status: ComplaintStatusType.pending,
      statusText: 'Chờ tiếp nhận',
      timeText: 'Hôm nay, 08:15',
      attachmentText: '1 ảnh đính kèm',
      imageUrl:
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=300&q=80',
    ),
    ComplaintCardData(
      code: 'CR2',
      location: 'Căn RB-0504',
      title: 'Tiếng ồn từ căn hộ tầng trên ban đêm',
      description:
          'Căn hộ RB-0604 thường xuyên kéo lê bàn ghế và mở nhạc lớn sau 23h30 làm gián đoạn giấc ngủ người già.',
      status: ComplaintStatusType.processing,
      statusText: 'Đang xử lý',
      responseTitle: 'BQL Tòa Ruby tiếp nhận',
      responseSubtitle: 'Đã nhắc nhở trực tiếp chủ căn 0604',
    ),
    ComplaintCardData(
      code: 'CR3',
      location: 'Khu công cộng T2',
      title: 'Đèn chiếu sáng sảnh tầng 2 bị nhấp nháy',
      description:
          'Dãy đèn LED downlight đối diện cửa căn 0208 chớp tắt liên tục, có tiếng rề nhỏ nguy cơ chập cháy.',
      status: ComplaintStatusType.assigned,
      statusText: 'Đã phân công',
      technicianName: 'Kỹ sư Hùng (Bảo trì)',
      estimatedTime: '14:00',
    ),
    ComplaintCardData(
      code: 'CR6',
      location: 'Thoát hiểm T3',
      title: 'Cửa chống cháy thoát hiểm tầng 3 bị kẹt',
      description:
          'Tay co thủy lực bị lệch khiến cửa không tự động đóng kín, gây gió rít mạnh và mất an toàn PCCC.',
      status: ComplaintStatusType.assigned,
      statusText: 'Đã phân công',
      priorityText: 'Ưu tiên cao PCCC',
    ),
    ComplaintCardData(
      code: 'CR4',
      location: 'Hầm gửi xe B1',
      title: 'Kiểm tra camera an ninh tầng hầm B1',
      description:
          'Cư dân yêu cầu trích xuất hình ảnh kiểm tra va quẹt nhẹ xe máy tại vị trí cột C14 tối qua.',
      status: ComplaintStatusType.completed,
      statusText: 'Đã hoàn thành',
      completedNote: 'Đã đối soát & bàn giao video cho cư dân',
      completedAction: 'Đóng hồ sơ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const ComplaintHeader(),
                const SizedBox(height: 16),

                // Stats Cards Section
                const ComplaintStatsSection(
                  totalCount: 10,
                  processingCount: 3,
                  completedCount: 4,
                ),
                const SizedBox(height: 16),

                // Category Filter Chips
                const ComplaintFilterChips(),
                const SizedBox(height: 16),

                // List of Complaint Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockComplaints.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ComplaintCard(
                      data: _mockComplaints[index],
                    );
                  },
                ),
              ],
            ),
          ),

          // Floating Action Button at Bottom Right
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingReportButton(
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
