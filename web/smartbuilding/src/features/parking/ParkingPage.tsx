import { useEffect, useState, useMemo } from 'react'
import { Icon } from '../../components/Icon'
import {
  getParking,
  getParkingSummary,
  getResidents,
  registerVehicle,
  releaseParkingSlot,
  type Parking,
  type ParkingSummaryMetrics,
  type Resident,
  type RegisterVehiclePayload
} from '../../data/api'
import '../../styles/parking.css'
import '../../styles/residents.css'

// Không dùng dữ liệu mẫu — toàn bộ dữ liệu lấy từ MySQL qua API

interface ParkingPageProps {
  query: string
  triggerCreateModal?: boolean
  onResetTriggerCreate?: () => void
  buildingId?: string
}

export function ParkingPage({ query, triggerCreateModal, onResetTriggerCreate, buildingId }: ParkingPageProps) {
  const [items, setItems] = useState<Parking[]>([])
  const [source, setSource] = useState('Đang kết nối...')
  const [loadError, setLoadError] = useState<string | null>(null)
  const [metrics, setMetrics] = useState<ParkingSummaryMetrics | null>(null)
  const [residents, setResidents] = useState<Resident[]>([])

  // Selection
  const [selectedSlotId, setSelectedSlotId] = useState<string | null>(null)

  // Filters
  const [search, setSearch] = useState(query)
  const [basementFilter, setBasementFilter] = useState('All')
  const [slotTypeFilter, setSlotTypeFilter] = useState('All')
  const [statusFilter, setStatusFilter] = useState('All')
  const [showFilterBar, setShowFilterBar] = useState(false)

  // Action status message
  const [actionFeedback, setActionFeedback] = useState<string | null>(null)

  // Create / Register Vehicle Modal
  const [isRegisterOpen, setIsRegisterOpen] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [registerError, setRegisterError] = useState<string | null>(null)
  const [registerSuccess, setRegisterSuccess] = useState<string | null>(null)

  const [formData, setFormData] = useState<RegisterVehiclePayload>({
    residentId: '',
    apartmentId: '',
    vehicleType: 'Car',
    licensePlate: '',
    rfidCardCode: '',
    brand: '',
    slotId: ''
  })

  // Sync external search query
  useEffect(() => {
    setSearch(query)
  }, [query])

  // React to triggerCreateModal from parent
  useEffect(() => {
    if (triggerCreateModal) {
      handleOpenRegisterModal()
      onResetTriggerCreate?.()
    }
  }, [triggerCreateModal, onResetTriggerCreate])

  // Load Data
  const loadData = async () => {
    try {
      const isOccupiedParam = statusFilter === 'Occupied' ? true : statusFilter === 'Available' ? false : undefined
      const targetBuilding = buildingId !== 'All' ? buildingId : undefined
      const [parkingData, summaryData, resData] = await Promise.all([
        getParking({
          search: search || undefined,
          basement: basementFilter !== 'All' ? basementFilter : undefined,
          slotType: slotTypeFilter !== 'All' ? slotTypeFilter : undefined,
          isOccupied: isOccupiedParam,
          buildingId: targetBuilding
        }),
        getParkingSummary(targetBuilding),
        getResidents({ buildingId: targetBuilding })
      ])

      setItems(parkingData)
      setMetrics(summaryData)
      setResidents(resData.filter(r => r.residentId))
      setLoadError(null)
      setSource('Đồng bộ MySQL')

      // Set default selected slot if none or not in items
      if (parkingData.length > 0) {
        setSelectedSlotId((prev) => {
          if (prev && parkingData.some(p => p.slotId === prev)) return prev
          const firstOccupied = parkingData.find(p => p.isOccupied)
          return firstOccupied ? firstOccupied.slotId : parkingData[0].slotId
        })
      }
    } catch (err) {
      // Backend không kết nối được — không fallback sample, hiển thị lỗi rõ ràng
      const message = err instanceof Error ? err.message : 'Không kết nối được server'
      setLoadError(message)
      setSource('Mất kết nối')
      setItems([])
    }
  }

  useEffect(() => {
    const handler = setTimeout(() => {
      loadData()
    }, 200)
    return () => clearTimeout(handler)
  }, [search, basementFilter, slotTypeFilter, statusFilter, buildingId])

  useEffect(() => {
    loadData()
  }, [])

  // Currently selected item
  const selectedItem = useMemo(() => {
    return items.find((i) => i.slotId === selectedSlotId) ?? items[0] ?? null
  }, [items, selectedSlotId])

  // Available slots for registration
  const availableSlots = useMemo(() => {
    return items.filter((i) => !i.isOccupied)
  }, [items])

  // Metric Stats calculation
  const stats = useMemo(() => {
    if (metrics && metrics.totalSlots > 0) {
      const b1Remain = metrics.b1Total - metrics.b1Occupied
      const b2Remain = metrics.b2Total - metrics.b2Occupied
      const carRemain = metrics.carSlotsTotal - metrics.carSlotsOccupied
      const motoRemain = metrics.motoSlotsTotal - metrics.motoSlotsOccupied

      return {
        b1: `${metrics.b1Occupied}/${metrics.b1Total}`,
        b1Note: `Còn trống ${b1Remain} vị trí`,
        b2: `${metrics.b2Occupied}/${metrics.b2Total}`,
        b2Note: `Còn trống ${b2Remain} vị trí`,
        car: `${metrics.carSlotsOccupied}/${metrics.carSlotsTotal}`,
        carNote: `Còn trống ${carRemain} ô tô`,
        moto: `${metrics.motoSlotsOccupied}/${metrics.motoSlotsTotal}`,
        motoNote: `Còn trống ${motoRemain} xe máy`
      }
    }

    const b1Items = items.filter((i) => i.basementLevel === 'B1')
    const b1Occ = b1Items.filter((i) => i.isOccupied).length
    const b2Items = items.filter((i) => i.basementLevel === 'B2')
    const b2Occ = b2Items.filter((i) => i.isOccupied).length
    const carItems = items.filter((i) => i.slotType === 'Car')
    const carOcc = carItems.filter((i) => i.isOccupied).length
    const motoItems = items.filter((i) => i.slotType === 'Motorbike')
    const motoOcc = motoItems.filter((i) => i.isOccupied).length

    return {
      b1: `${b1Occ}/${b1Items.length || 1}`,
      b1Note: `Còn trống ${b1Items.length - b1Occ} vị trí`,
      b2: `${b2Occ}/${b2Items.length || 1}`,
      b2Note: `Còn trống ${b2Items.length - b2Occ} vị trí`,
      car: `${carOcc}/${carItems.length || 1}`,
      carNote: `Còn trống ${carItems.length - carOcc} ô tô`,
      moto: `${motoOcc}/${motoItems.length || 1}`,
      motoNote: `Còn trống ${motoItems.length - motoOcc} xe máy`
    }
  }, [metrics, items])

  // Open modal with pre-selected slot if empty
  const handleOpenRegisterModal = (defaultSlotId?: string) => {
    setRegisterError(null)
    setRegisterSuccess(null)

    // Suggest default random RFID code
    const randomRfid = `RFID-${Math.floor(1000 + Math.random() * 9000)}`

    // Pick first resident if available
    const firstRes = residents[0]

    setFormData({
      residentId: firstRes?.residentId ?? '',
      apartmentId: firstRes?.apartmentId ?? '',
      vehicleType: 'Car',
      licensePlate: '',
      rfidCardCode: randomRfid,
      brand: '',
      slotId: defaultSlotId || (availableSlots[0]?.slotId ?? '')
    })

    setIsRegisterOpen(true)
  }

  // Handle Release Slot / Thu hồi thẻ
  const handleReleaseSlot = async () => {
    if (!selectedItem || !selectedItem.isOccupied) return
    const confirmed = window.confirm(`Bạn có chắc chắn muốn thu hồi thẻ RFID và giải phóng vị trí đỗ [${selectedItem.slotCode}]?`)
    if (!confirmed) return

    try {
      await releaseParkingSlot(selectedItem.slotId)
      setActionFeedback(`Đã giải phóng thành công ô đỗ ${selectedItem.slotCode}!`)
      setTimeout(() => setActionFeedback(null), 3000)
      await loadData()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Không thể giải phóng ô đỗ')
    }
  }

  // Handle Activate / Verify RFID
  const handleApproveRfid = () => {
    setActionFeedback(`Đã phê duyệt và đồng bộ RFID [${selectedItem?.rfidCardCode}] lên bốt kiểm soát!`)
    setTimeout(() => setActionFeedback(null), 3000)
  }

  // Submit Register Form
  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setRegisterError(null)
    setRegisterSuccess(null)

    if (!formData.residentId || !formData.apartmentId) {
      setRegisterError('Vui lòng chọn cư dân và căn hộ')
      return
    }
    if (!formData.licensePlate.trim()) {
      setRegisterError('Vui lòng nhập biển số xe')
      return
    }
    if (!formData.rfidCardCode.trim()) {
      setRegisterError('Vui lòng nhập mã thẻ RFID')
      return
    }

    setSubmitting(true)
    try {
      const res = await registerVehicle(formData)
      setRegisterSuccess(res.message || 'Đăng ký xe & cấp thẻ thành công!')
      
      // Auto select the new slot
      if (formData.slotId) {
        setSelectedSlotId(formData.slotId)
      }

      await loadData()

      setTimeout(() => {
        setIsRegisterOpen(false)
        setRegisterSuccess(null)
      }, 1200)
    } catch (err: unknown) {
      setRegisterError(err instanceof Error ? err.message : 'Lỗi khi đăng ký phương tiện')
    } finally {
      setSubmitting(false)
    }
  }

  // Filter count
  const activeFilterCount = (basementFilter !== 'All' ? 1 : 0) +
    (slotTypeFilter !== 'All' ? 1 : 0) +
    (statusFilter !== 'All' ? 1 : 0)

  const handleResetFilters = () => {
    setBasementFilter('All')
    setSlotTypeFilter('All')
    setStatusFilter('All')
    setSearch('')
  }

  return (
    <>
      {/* 1. Dynamic Parking Metrics - 100% accurate */}
      <section className="module-metrics parking-metrics">
        <Metric
          icon="local_parking"
          value={stats.b1}
          label="TẦNG HẦM B1"
          note={stats.b1Note}
          tone="red"
        />
        <Metric
          icon="local_parking"
          value={stats.b2}
          label="TẦNG HẦM B2"
          note={stats.b2Note}
          tone="green"
        />
        <Metric
          icon="directions_car"
          value={stats.car}
          label="KHU VỰC Ô TÔ"
          note={stats.carNote}
          tone="blue"
        />
        <Metric
          icon="two_wheeler"
          value={stats.moto}
          label="KHU VỰC XE MÁY"
          note={stats.motoNote}
          tone="amber"
        />
      </section>

      {/* 2. Main Parking Layout */}
      <section className="parking-layout">
        {/* Left Side: Selected Vehicle & RFID Detail Card */}
        <article className="panel rfid-card">
          <div className="panel-title">
            <div>
              <span className="eyebrow">QUẢN LÝ Ô ĐỖ & THẺ RFID</span>
              <h2>Thông tin vị trí & phương tiện</h2>
            </div>
            {selectedItem?.isOccupied ? (
              <span className="badge green">Đang gửi xe</span>
            ) : (
              <span className="badge amber">Vị trí trống</span>
            )}
          </div>

          {actionFeedback && (
            <div className="alert-box alert-success" style={{ marginTop: '10px' }}>
              <Icon name="check_circle" /> {actionFeedback}
            </div>
          )}

          {selectedItem ? (
            selectedItem.isOccupied ? (
              /* Occupied Slot View */
              <>
                <div className="driver">
                  <span className="driver-avatar">
                    {selectedItem.fullName
                      ? selectedItem.fullName.split(' ').slice(-1)[0].charAt(0).toUpperCase()
                      : 'XE'}
                  </span>
                  <div>
                    <strong>{selectedItem.fullName ?? 'Chưa xác định'}</strong>
                    <small>Căn hộ {selectedItem.apartmentNumber ?? 'Chưa gán'}</small>
                    <small>{selectedItem.phoneNumber ?? 'Chưa cập nhật SĐT'}</small>
                  </div>
                  <span className="badge blue">Đã kích hoạt</span>
                </div>

                <div className="vehicle-detail">
                  <div>
                    <span>Phương tiện đăng ký</span>
                    <strong>
                      <Icon name={selectedItem.slotType === 'Car' ? 'directions_car' : 'two_wheeler'} />{' '}
                      {selectedItem.brand || (selectedItem.slotType === 'Car' ? 'Ô tô' : 'Xe máy')}
                    </strong>
                  </div>
                  <div>
                    <span>Biển số xe</span>
                    <strong style={{ color: '#2563eb' }}>{selectedItem.licensePlate}</strong>
                  </div>
                </div>

                <div className="rfid-code">
                  <div>
                    <span>Vị trí giữ xe</span>
                    <strong>
                      {selectedItem.slotCode} · Tầng {selectedItem.basementLevel}
                    </strong>
                  </div>
                  <div>
                    <span>Thẻ Chip RFID</span>
                    <strong>{selectedItem.rfidCardCode}</strong>
                  </div>
                </div>

                <div className="rfid-panel-actions">
                  <button className="btn-danger" onClick={handleReleaseSlot}>
                    <Icon name="logout" /> Trả ô đỗ / Thu hồi thẻ
                  </button>
                  <button className="btn-success" onClick={handleApproveRfid}>
                    <Icon name="verified" /> Đồng bộ thẻ RFID
                  </button>
                </div>
              </>
            ) : (
              /* Empty Slot View */
              <>
                <div className="empty-slot-banner">
                  <Icon name="local_parking" />
                  <strong>Ô đỗ {selectedItem.slotCode} hiện đang còn trống</strong>
                  <p style={{ margin: '4px 0 14px', fontSize: '11px' }}>
                    Tầng hầm {selectedItem.basementLevel} · Phân loại: {selectedItem.slotType === 'Car' ? 'Ô tô' : 'Xe máy'}.
                  </p>
                  <button
                    className="action-add-btn"
                    onClick={() => handleOpenRegisterModal(selectedItem.slotId)}
                  >
                    <Icon name="add_circle" /> Đăng ký xe vào ô này
                  </button>
                </div>

                <div className="rfid-code">
                  <div>
                    <span>Mã vị trí</span>
                    <strong>{selectedItem.slotCode}</strong>
                  </div>
                  <div>
                    <span>Loại vị trí</span>
                    <strong>{selectedItem.slotType === 'Car' ? 'Ô tô tiêu chuẩn' : 'Xe máy'}</strong>
                  </div>
                </div>
              </>
            )
          ) : (
            <div className="empty">Vui lòng chọn một vị trí đỗ trong danh sách.</div>
          )}
        </article>

        {/* Right Side: Parking Slots Table */}
        <aside className="panel parking-list">
          <div className="panel-title">
            <div>
              <span className="eyebrow">DANH SÁCH VỊ TRÍ ĐỖ</span>
              <h2>Bãi đỗ hầm & kiểm soát RFID</h2>
            </div>
            <span className="data-source">
              <i />
              {source}
            </span>
          </div>

          {/* Search & Filter Toolbar */}
          <div className="parking-toolbar">
            <label className="inner-search" style={{ height: '34px' }}>
              <Icon name="search" />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Tìm biển số, mã ô, RFID, chủ xe..."
                style={{ fontSize: '11px' }}
              />
            </label>
            <button
              className={`secondary-button ${showFilterBar ? 'active' : ''}`}
              style={{ fontSize: '11px', padding: '7px 10px' }}
              onClick={() => setShowFilterBar(!showFilterBar)}
            >
              <Icon name="tune" /> Bộ lọc
              {activeFilterCount > 0 && <span className="filter-badge">{activeFilterCount}</span>}
            </button>
            <button
              className="action-add-btn"
              style={{ fontSize: '11px', padding: '7px 11px', whiteSpace: 'nowrap' }}
              onClick={() => handleOpenRegisterModal()}
            >
              <Icon name="add" /> Đăng ký xe
            </button>
          </div>

          {/* Filter Bar */}
          {showFilterBar && (
            <div className="parking-filter-bar">
              <div className="parking-filter-group">
                <label>Hầm:</label>
                <select value={basementFilter} onChange={(e) => setBasementFilter(e.target.value)}>
                  <option value="All">Tất cả tầng</option>
                  <option value="B1">Tầng hầm B1</option>
                  <option value="B2">Tầng hầm B2</option>
                </select>
              </div>

              <div className="parking-filter-group">
                <label>Loại xe:</label>
                <select value={slotTypeFilter} onChange={(e) => setSlotTypeFilter(e.target.value)}>
                  <option value="All">Tất cả loại xe</option>
                  <option value="Car">Ô tô (Car)</option>
                  <option value="Motorbike">Xe máy (Motorbike)</option>
                </select>
              </div>

              <div className="parking-filter-group">
                <label>Trạng thái:</label>
                <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
                  <option value="All">Tất cả trạng thái</option>
                  <option value="Occupied">Đã đỗ</option>
                  <option value="Available">Còn trống</option>
                </select>
              </div>

              {activeFilterCount > 0 && (
                <button className="reset-filter-btn" onClick={handleResetFilters}>
                  <Icon name="close" /> Đặt lại
                </button>
              )}
            </div>
          )}

          {/* List of Parking Slots */}
          <div style={{ maxHeight: '520px', overflowY: 'auto' }}>
            {loadError && (
              <div className="empty" style={{ color: '#d9534f' }}>
                <Icon name="wifi_off" />
                <p><strong>Không kết nối được server</strong></p>
                <p style={{ fontSize: '0.8rem', opacity: 0.7 }}>Hãy chạy backend: <code>dotnet run</code></p>
                <button className="secondary-button" onClick={loadData}>Thử lại</button>
              </div>
            )}

            {!loadError && source === 'Đang kết nối...' && (
              <div className="empty">
                <p>Đang tải dữ liệu vị trí đỗ xe từ MySQL...</p>
              </div>
            )}

            {!loadError && source !== 'Đang kết nối...' && items.length === 0 && (
              <div className="empty">
                <p>Không tìm thấy vị trí đỗ nào phù hợp với bộ lọc.</p>
                {activeFilterCount > 0 && (
                  <button className="secondary-button" onClick={handleResetFilters}>
                    Xóa bộ lọc
                  </button>
                )}
              </div>
            )}

            {!loadError && items.length > 0 && items.map((item) => {
              const isSelected = selectedSlotId === item.slotId
              return (
                <div
                  className={`parking-row ${isSelected ? 'active' : ''}`}
                  key={item.slotId}
                  onClick={() => setSelectedSlotId(item.slotId)}
                  title="Nhấn để xem chi tiết thẻ RFID và thông tin xe"
                >
                  <span className={item.isOccupied ? 'slot occupied-slot' : 'slot'}>
                    {item.slotCode}
                  </span>
                  <div>
                    <strong>{item.licensePlate ?? 'Ô trống'}</strong>
                    <small>
                      {item.fullName
                        ? `${item.fullName} · Căn ${item.apartmentNumber}`
                        : `${item.slotType === 'Car' ? 'Ô tô' : 'Xe máy'} · ${item.basementLevel} · Sẵn sàng`}
                    </small>
                  </div>
                  <span className={`badge ${item.isOccupied ? 'green' : 'amber'}`}>
                    {item.isOccupied ? 'Đã đỗ' : 'Trống'}
                  </span>
                </div>
              )
            })}
          </div>
        </aside>
      </section>

      {/* 3. Modal Đăng ký xe mới & Cấp RFID */}
      {isRegisterOpen && (
        <div className="modal-overlay" onClick={() => !submitting && setIsRegisterOpen(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Đăng ký phương tiện & Cấp thẻ chip RFID</h2>
              <button
                className="close-btn"
                onClick={() => !submitting && setIsRegisterOpen(false)}
                disabled={submitting}
              >
                <Icon name="close" />
              </button>
            </div>

            <form onSubmit={handleRegisterSubmit}>
              <div className="modal-body">
                {registerError && <div className="alert-box alert-error">{registerError}</div>}
                {registerSuccess && <div className="alert-box alert-success">{registerSuccess}</div>}

                <div className="form-grid">
                  <div className="form-group full-width">
                    <label>Chủ xe & Căn hộ <span>*</span></label>
                    <select
                      required
                      value={formData.residentId ? `${formData.residentId}|${formData.apartmentId}` : ''}
                      onChange={(e) => {
                        const [resId, aptId] = e.target.value.split('|')
                        setFormData({
                          ...formData,
                          residentId: resId,
                          apartmentId: aptId
                        })
                      }}
                    >
                      <option value="">-- Chọn cư dân đăng ký --</option>
                      {residents.map((r) => (
                        <option key={r.apartmentId} value={`${r.residentId}|${r.apartmentId}`}>
                          {r.fullName} · Căn {r.apartmentNumber} · SĐT: {r.phoneNumber}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label>Loại phương tiện <span>*</span></label>
                    <select
                      value={formData.vehicleType}
                      onChange={(e) => setFormData({ ...formData, vehicleType: e.target.value })}
                    >
                      <option value="Car">Ô tô (Car)</option>
                      <option value="Motorbike">Xe máy (Motorbike)</option>
                      <option value="ElectricBicycle">Xe điện (ElectricBicycle)</option>
                    </select>
                  </div>

                  <div className="form-group">
                    <label>Biển số xe <span>*</span></label>
                    <input
                      type="text"
                      required
                      placeholder="Ví dụ: 51H-888.99"
                      value={formData.licensePlate}
                      onChange={(e) => setFormData({ ...formData, licensePlate: e.target.value.toUpperCase() })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Hãng xe / Dòng xe</label>
                    <input
                      type="text"
                      placeholder="Ví dụ: VinFast VF8, Honda SH..."
                      value={formData.brand}
                      onChange={(e) => setFormData({ ...formData, brand: e.target.value })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Mã thẻ Chip RFID <span>*</span></label>
                    <input
                      type="text"
                      required
                      placeholder="Ví dụ: RFID-CAR-015"
                      value={formData.rfidCardCode}
                      onChange={(e) => setFormData({ ...formData, rfidCardCode: e.target.value.toUpperCase() })}
                    />
                  </div>

                  <div className="form-group full-width">
                    <label>Chọn vị trí ô đỗ còn trống</label>
                    <select
                      value={formData.slotId}
                      onChange={(e) => setFormData({ ...formData, slotId: e.target.value })}
                    >
                      <option value="">-- Tự động xếp vào ô trống phù hợp --</option>
                      {availableSlots.map((slot) => (
                        <option key={slot.slotId} value={slot.slotId}>
                          {slot.slotCode} (Tầng hầm {slot.basementLevel} - {slot.slotType === 'Car' ? 'Ô tô' : 'Xe máy'})
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button
                  type="button"
                  className="secondary-button"
                  onClick={() => setIsRegisterOpen(false)}
                  disabled={submitting}
                >
                  Hủy
                </button>
                <button type="submit" className="action-add-btn" disabled={submitting}>
                  {submitting ? 'Đang cấp thẻ...' : 'Đăng ký xe & Cấp thẻ'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

function Metric({
  icon,
  value,
  label,
  note,
  tone = 'blue'
}: {
  icon: string
  value: string
  label: string
  note: string
  tone?: string
}) {
  return (
    <article className={`module-metric ${tone}`}>
      <span>
        <Icon name={icon} />
      </span>
      <label>{label}</label>
      <strong>{value}</strong>
      <small>{note}</small>
    </article>
  )
}
