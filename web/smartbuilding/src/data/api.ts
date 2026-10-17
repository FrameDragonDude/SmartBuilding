const apiUrl = 'http://localhost:5169/api'

export type Resident = {
  apartmentId: string
  apartmentNumber: string
  apartmentStatus: string
  residentId: string | null
  fullName: string | null
  phoneNumber: string | null
  email: string | null
  contractType: string | null
}

export type Parking = {
  slotId: string
  slotCode: string
  basementLevel: string
  slotType: string
  isOccupied: boolean
  vehicleId: string | null
  vehicleType: string | null
  licensePlate: string | null
  rfidCardCode: string | null
  brand: string | null
  fullName: string | null
  phoneNumber: string | null
  apartmentNumber: string | null
}

export type ParkingSummaryMetrics = {
  totalSlots: number
  occupiedSlots: number
  availableSlots: number
  b1Total: number
  b1Occupied: number
  b2Total: number
  b2Occupied: number
  carSlotsTotal: number
  carSlotsOccupied: number
  motoSlotsTotal: number
  motoSlotsOccupied: number
}

export type ParkingDetail = {
  slotId: string
  slotCode: string
  basementLevel: string
  slotType: string
  isOccupied: boolean
  vehicleId: string | null
  vehicleType: string | null
  licensePlate: string | null
  rfidCardCode: string | null
  brand: string | null
  isActive: boolean | null
  registeredAt: string | null
  residentId: string | null
  fullName: string | null
  phoneNumber: string | null
  identityCardNumber: string | null
  apartmentId: string | null
  apartmentNumber: string | null
  buildingName: string
}

export type RegisterVehiclePayload = {
  residentId: string
  apartmentId: string
  vehicleType: string
  licensePlate: string
  rfidCardCode: string
  brand?: string
  slotId?: string
}

export type VehicleDto = {
  id: string
  vehicleType: string
  licensePlate: string
  rfidCardCode: string
  brand: string | null
}

export type DocumentDto = {
  id: string
  documentType: string
  documentNumber: string | null
  issuedDate: string | null
  issuedPlace: string | null
  attachmentUrl: string
  verificationStatus: string
}

export type InvoiceDto = {
  id: string
  invoiceCode: string
  billingMonth: number
  billingYear: number
  totalAmount: number
  paidAmount: number
  status: string
  dueDate: string
}

export type ResidentDetail = {
  residentId: string | null
  fullName: string | null
  identityCardNumber: string | null
  phoneNumber: string | null
  email: string | null
  dateOfBirth: string | null
  gender: string | null
  avatarUrl: string | null
  residentCreatedAt: string | null
  apartmentId: string
  apartmentNumber: string
  area: number
  roomsCount: number
  bathroomsCount: number
  apartmentStatus: string
  floorDescription: string | null
  buildingName: string | null
  contractType: string | null
  contractStartDate: string | null
  contractEndDate: string | null
  vehicles: VehicleDto[]
  documents: DocumentDto[]
  invoices: InvoiceDto[]
}

export type ResidentSummaryMetrics = {
  totalApartments: number
  occupiedApartments: number
  availableApartments: number
  totalResidents: number
  pendingApprovals: number
}

export type ApartmentOption = {
  id: string
  apartmentNumber: string
  status: string
  area: number
  floorNumber: number
  buildingName: string
}

export type CreateResidentPayload = {
  fullName: string
  identityCardNumber: string
  phoneNumber: string
  email?: string
  dateOfBirth: string
  gender: string
  apartmentId: string
  contractType: string
  startDate: string
}

// -------------------------------------------------------------
// BUILDINGS APIs
// -------------------------------------------------------------
export type BuildingItem = {
  id: string
  buildingCode: string
  name: string
  totalFloors: number
  totalBasements: number
  address: string
  totalApartments: number
}

export async function getBuildings(): Promise<BuildingItem[]> {
  const result = await fetch(`${apiUrl}/buildings`)
  if (!result.ok) throw new Error('Không thể tải danh sách tòa nhà')
  return result.json()
}

// Residents APIs
export async function getResidents(params?: {
  search?: string
  status?: string
  contractType?: string
  buildingId?: string
}): Promise<Resident[]> {
  const query = new URLSearchParams()
  if (params?.search) query.set('search', params.search)
  if (params?.status && params.status !== 'All') query.set('status', params.status)
  if (params?.contractType && params.contractType !== 'All') query.set('contractType', params.contractType)
  if (params?.buildingId && params.buildingId !== 'All') query.set('buildingId', params.buildingId)

  const url = `${apiUrl}/residents${query.toString() ? `?${query.toString()}` : ''}`
  const result = await fetch(url)
  if (!result.ok) throw new Error('Không thể tải dữ liệu cư dân')
  return result.json()
}

export async function getResidentDetail(apartmentId: string): Promise<ResidentDetail> {
  const result = await fetch(`${apiUrl}/residents/${encodeURIComponent(apartmentId)}/detail`)
  if (!result.ok) throw new Error('Không thể tải chi tiết cư dân')
  return result.json()
}

export async function getResidentMetrics(buildingId?: string): Promise<ResidentSummaryMetrics> {
  const query = buildingId && buildingId !== 'All' ? `?buildingId=${encodeURIComponent(buildingId)}` : ''
  const result = await fetch(`${apiUrl}/residents/summary${query}`)
  if (!result.ok) throw new Error('Không thể tải thống kê cư dân')
  return result.json()
}

export async function getApartments(buildingId?: string): Promise<ApartmentOption[]> {
  const query = buildingId && buildingId !== 'All' ? `?buildingId=${encodeURIComponent(buildingId)}` : ''
  const result = await fetch(`${apiUrl}/apartments${query}`)
  if (!result.ok) throw new Error('Không thể tải danh sách căn hộ')
  return result.json()
}

export async function createResident(payload: CreateResidentPayload): Promise<{ id: string; message: string }> {
  const result = await fetch(`${apiUrl}/residents`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  })

  if (!result.ok) {
    const errorData = await result.json().catch(() => null)
    throw new Error(errorData?.message || errorData?.detail || 'Lỗi khi tạo mới cư dân')
  }

  return result.json()
}

// Parking APIs
export async function getParking(params?: {
  search?: string
  basement?: string
  slotType?: string
  isOccupied?: boolean
  buildingId?: string
} | string): Promise<Parking[]> {
  const query = new URLSearchParams()
  if (typeof params === 'string') {
    if (params) query.set('search', params)
  } else if (params) {
    if (params.search) query.set('search', params.search)
    if (params.basement && params.basement !== 'All') query.set('basement', params.basement)
    if (params.slotType && params.slotType !== 'All') query.set('slotType', params.slotType)
    if (params.isOccupied !== undefined) query.set('isOccupied', String(params.isOccupied))
    if (params.buildingId && params.buildingId !== 'All') query.set('buildingId', params.buildingId)
  }

  const url = `${apiUrl}/parking${query.toString() ? `?${query.toString()}` : ''}`
  const result = await fetch(url)
  if (!result.ok) throw new Error('Không thể tải dữ liệu bãi xe')
  return result.json()
}

export async function getParkingSummary(buildingId?: string): Promise<ParkingSummaryMetrics> {
  const query = buildingId && buildingId !== 'All' ? `?buildingId=${encodeURIComponent(buildingId)}` : ''
  const result = await fetch(`${apiUrl}/parking/summary${query}`)
  if (!result.ok) throw new Error('Không thể tải thống kê bãi xe')
  return result.json()
}

export async function getParkingDetail(slotId: string): Promise<ParkingDetail> {
  const result = await fetch(`${apiUrl}/parking/${encodeURIComponent(slotId)}/detail`)
  if (!result.ok) throw new Error('Không thể tải chi tiết vị trí đỗ')
  return result.json()
}

export async function registerVehicle(payload: RegisterVehiclePayload): Promise<{ vehicleId: string; message: string }> {
  const result = await fetch(`${apiUrl}/parking/register`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  })

  if (!result.ok) {
    const errorData = await result.json().catch(() => null)
    throw new Error(errorData?.message || errorData?.detail || 'Lỗi khi đăng ký xe')
  }

  return result.json()
}

export async function releaseParkingSlot(slotId: string): Promise<{ success: boolean; message: string }> {
  const result = await fetch(`${apiUrl}/parking/${encodeURIComponent(slotId)}/release`, {
    method: 'POST'
  })

  if (!result.ok) {
    const errorData = await result.json().catch(() => null)
    throw new Error(errorData?.message || errorData?.detail || 'Lỗi khi trả vị trí đỗ')
  }

  return result.json()
}

// -------------------------------------------------------------
// INVOICES & BILLING & RECONCILIATION APIs
// -------------------------------------------------------------
export type InvoiceItem = {
  id: string
  invoiceCode: string
  apartmentId: string
  apartmentNumber: string
  residentName: string | null
  phoneNumber: string | null
  billingMonth: number
  billingYear: number
  managementFee: number
  electricityFee: number
  waterFee: number
  parkingFee: number
  totalAmount: number
  paidAmount: number
  status: string
  dueDate: string
  overdueDays: number
  penaltyAmount: number
}

export type InvoiceSummary = {
  totalAmount: number
  paidAmount: number
  pendingAmount: number
  overdueAmount: number
  cashFundAmount: number
  totalInvoices: number
  paidCount: number
  pendingCount: number
  overdueCount: number
}

export type PendingPayment = {
  paymentId: string
  invoiceId: string
  invoiceCode: string
  apartmentNumber: string
  residentName: string | null
  transactionCode: string
  paymentMethod: string
  amount: number
  proofReceiptUrl: string | null
  paymentDate: string
  payerNote: string | null
}

export type PenaltyRecord = {
  penaltyId: string
  invoiceId: string
  invoiceCode: string
  apartmentNumber: string
  residentName: string | null
  overdueDays: number
  originalAmount: number
  penaltyAmount: number
  reason: string
  isResolved: boolean
}

export type RevenueStructure = {
  managementTotal: number
  electricityTotal: number
  waterAndParkingTotal: number
  grandTotal: number
}

export async function getInvoices(params?: {
  search?: string
  filterTab?: string
  month?: number
  year?: number
  buildingId?: string
}): Promise<InvoiceItem[]> {
  const query = new URLSearchParams()
  if (params?.search) query.set('search', params.search)
  if (params?.filterTab && params.filterTab !== 'All') query.set('filterTab', params.filterTab)
  if (params?.month) query.set('month', String(params.month))
  if (params?.year) query.set('year', String(params.year))
  if (params?.buildingId && params.buildingId !== 'All') query.set('buildingId', params.buildingId)

  const url = `${apiUrl}/invoices${query.toString() ? `?${query.toString()}` : ''}`
  const result = await fetch(url)
  if (!result.ok) throw new Error('Không thể tải danh sách hóa đơn')
  return result.json()
}

export async function getInvoiceSummary(month?: number, year?: number, buildingId?: string): Promise<InvoiceSummary> {
  const query = new URLSearchParams()
  if (month) query.set('month', String(month))
  if (year) query.set('year', String(year))
  if (buildingId && buildingId !== 'All') query.set('buildingId', buildingId)

  const url = `${apiUrl}/invoices/summary${query.toString() ? `?${query.toString()}` : ''}`
  const result = await fetch(url)
  if (!result.ok) throw new Error('Không thể tải tổng hợp tài chính')
  return result.json()
}

export async function getPendingPayments(): Promise<PendingPayment[]> {
  const result = await fetch(`${apiUrl}/invoices/pending-payments`)
  if (!result.ok) throw new Error('Không thể tải danh sách chứng từ chờ duyệt')
  return result.json()
}

export async function getPenalties(): Promise<PenaltyRecord[]> {
  const result = await fetch(`${apiUrl}/invoices/penalties`)
  if (!result.ok) throw new Error('Không thể tải danh sách nợ & lãi phạt')
  return result.json()
}

export async function getRevenueStructure(month?: number, year?: number): Promise<RevenueStructure> {
  const query = new URLSearchParams()
  if (month) query.set('month', String(month))
  if (year) query.set('year', String(year))

  const url = `${apiUrl}/invoices/revenue-structure${query.toString() ? `?${query.toString()}` : ''}`
  const result = await fetch(url)
  if (!result.ok) throw new Error('Không thể tải cơ cấu doanh thu')
  return result.json()
}

export async function approvePayment(paymentId: string): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/invoices/payments/${encodeURIComponent(paymentId)}/approve`, {
    method: 'POST'
  })
  if (!result.ok) throw new Error('Lỗi khi duyệt chứng từ')
  return result.json()
}

export async function rejectPayment(paymentId: string): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/invoices/payments/${encodeURIComponent(paymentId)}/reject`, {
    method: 'POST'
  })
  if (!result.ok) throw new Error('Lỗi khi từ chối chứng từ')
  return result.json()
}

export async function waivePenalty(penaltyId: string): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/invoices/penalties/${encodeURIComponent(penaltyId)}/waive`, {
    method: 'POST'
  })
  if (!result.ok) throw new Error('Lỗi khi duyệt miễn phạt')
  return result.json()
}

export async function sendBatchReminders(): Promise<{ count: number; message: string }> {
  const result = await fetch(`${apiUrl}/invoices/reminders/send-batch`, {
    method: 'POST'
  })
  if (!result.ok) throw new Error('Lỗi khi gửi nhắc nợ đồng loạt')
  return result.json()
}

export async function generateMonthlyInvoices(month: number, year: number): Promise<{ count: number; message: string }> {
  const result = await fetch(`${apiUrl}/invoices/generate-monthly`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ month, year })
  })
  if (!result.ok) throw new Error('Lỗi khi tính toán hóa đơn mới')
  return result.json()
}

// -------------------------------------------------------------
// SERVICE TARIFFS CONFIGURATION APIs
// -------------------------------------------------------------
export type TariffItem = {
  id: string
  serviceType: string
  tierName: string
  fromUnit: number
  toUnit: number | null
  unitPrice: number
  vatRate: number
  effectiveDate: string
}

export type TariffRules = {
  meterCutoffDay: number
  invoiceIssueDay: number
  dueDay: number
  gracePeriodDays: number
  lateInterestRatePercent: number
  blockRfidDays: number
  autoWaiveWithExtensionRequest: boolean
}

export type TariffAuditLog = {
  period: string
  itemName: string
  oldPrice: string
  newPrice: string
  changePercent: string
  approvedBy: string
}

export type ForecastRevenue = {
  managementRevenue: number
  parkingRevenue: number
  utilityRevenue: number
  totalMonthlyForecast: number
}

export type TariffConfig = {
  managementTariffs: TariffItem[]
  electricityTariffs: TariffItem[]
  waterTariffs: TariffItem[]
  parkingTariffs: TariffItem[]
  rules: TariffRules
  auditLogs: TariffAuditLog[]
  forecast: ForecastRevenue
}

export async function getTariffConfig(): Promise<TariffConfig> {
  const result = await fetch(`${apiUrl}/tariffs`)
  if (!result.ok) throw new Error('Không thể tải cấu hình biểu phí')
  return result.json()
}

export async function updateTariffPrice(tariffId: string, newUnitPrice: number): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/tariffs/price`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tariffId, newUnitPrice })
  })
  if (!result.ok) throw new Error('Lỗi khi cập nhật đơn giá biểu phí')
  return result.json()
}

export async function updateTariffRules(rules: TariffRules): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/tariffs/rules`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(rules)
  })
  if (!result.ok) throw new Error('Lỗi khi cập nhật quy tắc vận hành')
  return result.json()
}

export async function approveDraftTariff(): Promise<{ message: string }> {
  const result = await fetch(`${apiUrl}/tariffs/approve-draft`, {
    method: 'POST'
  })
  if (!result.ok) throw new Error('Lỗi khi phê duyệt dự thảo biểu phí')
  return result.json()
}

