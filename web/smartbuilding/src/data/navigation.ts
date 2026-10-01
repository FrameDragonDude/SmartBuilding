export type AppModule = { id: string; label: string; icon: string; group: 'Vận hành' | 'Quản trị' }

export const navigation: AppModule[] = [
  { id: 'dashboard', label: 'Bảng điều khiển', icon: 'grid_view', group: 'Vận hành' },
  { id: 'residents', label: 'Căn hộ & Cư dân', icon: 'groups', group: 'Vận hành' },
  { id: 'invoices', label: 'Hóa đơn & Thu phí', icon: 'receipt_long', group: 'Vận hành' },
  { id: 'mep', label: 'Kỹ thuật & Điện nước', icon: 'bolt', group: 'Vận hành' },
  { id: 'parking', label: 'Xe & Bãi đỗ RFID', icon: 'directions_car', group: 'Vận hành' },
  { id: 'amenities', label: 'Tiện ích & Đặt lịch', icon: 'event_available', group: 'Vận hành' },
  { id: 'complaints', label: 'Phản ánh & Nghiệm thu', icon: 'assignment_late', group: 'Vận hành' },
  { id: 'pricing', label: 'Cấu hình biểu phí', icon: 'request_quote', group: 'Quản trị' },
  { id: 'roles', label: 'Phân quyền & Audit', icon: 'shield_person', group: 'Quản trị' },
]
