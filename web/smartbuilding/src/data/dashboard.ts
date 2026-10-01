export const metrics = [
  { icon: 'apartment', tone: 'blue', label: 'Tổng căn hộ', value: '1.248', note: '96,8% đã lấp đầy', trend: 'trending_up' },
  { icon: 'payments', tone: 'green', label: 'Thu phí tháng 09', value: '2,86 tỷ', note: '84,2% đã thu', trend: 'trending_up' },
  { icon: 'engineering', tone: 'amber', label: 'Yêu cầu kỹ thuật', value: '18', note: '06 đang xử lý', trend: 'schedule' },
  { icon: 'warning', tone: 'red', label: 'Hóa đơn quá hạn', value: '12', note: '84,5 triệu đồng', trend: 'priority_high' },
]

export const residentRequests = [
  { unit: 'RB-1402', name: 'Đặng Thảo Vy', detail: 'Đăng ký tạm trú mới', time: '15 phút trước', status: 'Chờ duyệt', tone: 'amber' },
  { unit: 'RB-0805', name: 'Trần Quốc Bảo', detail: 'Khai báo tạm vắng', time: '1 giờ trước', status: 'Đã tiếp nhận', tone: 'blue' },
  { unit: 'RB-1901', name: 'Lê Minh Châu', detail: 'Cấp thẻ cư dân mới', time: '3 giờ trước', status: 'Hoàn tất', tone: 'green' },
]

export const workOrders = [
  { code: 'MEP-0268', title: 'Đèn hành lang tầng 12 chập chờn', location: 'Tòa Ruby · Tầng 12', status: 'Đang xử lý' },
  { code: 'MEP-0267', title: 'Bảo trì bơm nước khu B2', location: 'Tòa Aqua · Hầm B2', status: 'Đã phân công' },
  { code: 'MEP-0266', title: 'Kiểm định định kỳ hệ thống PCCC', location: 'Tất cả tòa', status: 'Theo kế hoạch' },
]
