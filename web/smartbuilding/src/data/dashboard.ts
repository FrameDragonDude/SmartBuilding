export const metrics = [
  { icon: 'apartment', tone: 'blue', label: 'Tổng căn hộ', value: '1.248', note: '96,8% đã lấp đầy', trend: 'trending_up' },
  { icon: 'payments', tone: 'green', label: 'Thu phí tháng 09', value: '2,86 tỷ', note: '84,2% đã thu', trend: 'trending_up' },
  { icon: 'engineering', tone: 'amber', label: 'Yêu cầu kỹ thuật', value: '18', note: '06 đang xử lý', trend: 'schedule' },
  { icon: 'warning', tone: 'red', label: 'Hóa đơn quá hạn', value: '12', note: '84,5 triệu đồng', trend: 'priority_high' },
]

export const residentRequests = [
  { unit: 'RB-0101', name: 'Nguyễn Văn An', detail: 'Hành lang tầng 1 có rác chưa thu gom', time: '15 phút trước', status: 'Chờ duyệt', tone: 'amber' },
  { unit: 'RB-0102', name: 'Trần Thị Bình', detail: 'Tiếng ồn từ căn hộ tầng trên ban đêm', time: '1 giờ trước', status: 'Đang xử lý', tone: 'blue' },
  { unit: 'RB-0201', name: 'Lê Hoàng Cường', detail: 'Đèn chiếu sáng sảnh tầng 2 bị nhấp nháy', time: '3 giờ trước', status: 'Đã hoàn tất', tone: 'green' },
]

export const workOrders = [
  { code: 'CR3', title: 'Đèn chiếu sáng sảnh tầng 2 bị nhấp nháy', location: 'Tòa Ruby Suites · Tầng 2', status: 'Đang xử lý' },
  { code: 'CR6', title: 'Cửa chống cháy thoát hiểm tầng 3 bị kẹt', location: 'Tòa Ruby Suites · Tầng 3', status: 'Đã phân công' },
  { code: 'CR4', title: 'Kiểm tra camera an ninh tầng hầm B1', location: 'Tòa Ruby Suites · Hầm B1', status: 'Theo kế hoạch' },
]
