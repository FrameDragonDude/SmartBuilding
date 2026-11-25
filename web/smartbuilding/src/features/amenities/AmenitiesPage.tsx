import { useEffect, useState, useMemo } from 'react'
import { Icon } from '../../components/Icon'
import {
  getAllAmenities,
  getAllAmenityBookings,
  updateBookingStatus,
  type AmenityItem,
  type AmenityBookingItem
} from '../../data/api'
import '../../styles/amenities.css'

interface Props {
  query?: string
  buildingId?: string
}

export function AmenitiesPage({ query = '' }: Props) {
  const [amenities, setAmenities] = useState<AmenityItem[]>([])
  const [bookings, setBookings] = useState<AmenityBookingItem[]>([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState<'amenities' | 'bookings'>('bookings')
  const [statusFilter, setStatusFilter] = useState<string>('All')
  const [actionMessage, setActionMessage] = useState<string | null>(null)

  // Counter booking modal
  const [selectedAmenityForBook, setSelectedAmenityForBook] = useState<AmenityItem | null>(null)
  const [residentName, setResidentName] = useState('')
  const [apartmentNumber, setApartmentNumber] = useState('')
  const [guestsCount, setGuestsCount] = useState(2)

  const loadData = async () => {
    setLoading(true)
    try {
      const [amenitiesData, bookingsData] = await Promise.all([
        getAllAmenities(),
        getAllAmenityBookings()
      ])
      setAmenities(amenitiesData)
      setBookings(bookingsData)
    } catch (err) {
      console.error('Error fetching amenities:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  const handleStatusChange = async (bookingId: string, newStatus: 'Confirmed' | 'Cancelled' | 'Completed') => {
    try {
      await updateBookingStatus(bookingId, newStatus)
      setActionMessage(`Đã cập nhật trạng thái phiếu #${bookingId} thành "${newStatus}".`)
      setTimeout(() => setActionMessage(null), 4000)
      setBookings(prev => prev.map(b => b.id === bookingId ? { ...b, status: newStatus } : b))
    } catch {
      alert('Không thể cập nhật trạng thái. Vui lòng thử lại.')
    }
  }

  const handleCounterBookSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!residentName || !apartmentNumber || !selectedAmenityForBook) {
      alert('Vui lòng điền đầy đủ thông tin cư dân.')
      return
    }
    const newBooking: AmenityBookingItem = {
      id: `AB-POS-${Date.now().toString().slice(-4)}`,
      amenityId: selectedAmenityForBook.id,
      amenityName: selectedAmenityForBook.name,
      residentName: residentName,
      residentPhone: '090-LE-TAN',
      apartmentNumber: apartmentNumber,
      bookingDate: new Date().toISOString().split('T')[0],
      startTime: '18:00:00',
      endTime: '20:00:00',
      numberOfGuests: guestsCount,
      status: 'Confirmed',
      createdAt: new Date().toISOString()
    }
    setBookings([newBooking, ...bookings])
    setSelectedAmenityForBook(null)
    setResidentName('')
    setApartmentNumber('')
    setActionMessage(`Lễ tân đã đặt lịch thành công cho cư dân ${residentName} tại "${selectedAmenityForBook.name}".`)
    setTimeout(() => setActionMessage(null), 5000)
  }

  const filteredBookings = useMemo(() => {
    return bookings.filter(b => {
      const matchesSearch = query
        ? b.residentName.toLowerCase().includes(query.toLowerCase()) ||
          b.apartmentNumber.toLowerCase().includes(query.toLowerCase()) ||
          b.amenityName.toLowerCase().includes(query.toLowerCase())
        : true
      const matchesStatus = statusFilter === 'All' ? true : b.status === statusFilter
      return matchesSearch && matchesStatus
    })
  }, [bookings, query, statusFilter])

  return (
    <div className="amenities-container">
      {actionMessage && (
        <div style={{ background: '#dcfce7', border: '1px solid #86efac', padding: '10px 16px', borderRadius: '8px', color: '#166534', fontSize: '14px', fontWeight: 600 }}>
          {actionMessage}
        </div>
      )}

      {/* KPI Cards */}
      <section className="stats-row">
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#eff6ff', color: '#2563eb' }}>
            <Icon name="event_available" />
          </div>
          <div>
            <div className="stat-value">{amenities.length}</div>
            <div className="stat-label">Tiện ích nội khu</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#f0fdf4', color: '#16a34a' }}>
            <Icon name="check_circle" />
          </div>
          <div>
            <div className="stat-value">{bookings.filter(b => b.status === 'Confirmed').length}</div>
            <div className="stat-label">Đã duyệt & đang dùng</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#fef2f2', color: '#dc2626' }}>
            <Icon name="assignment_late" />
          </div>
          <div>
            <div className="stat-value">{bookings.filter(b => b.status === 'Cancelled').length}</div>
            <div className="stat-label">Đã hủy / từ chối</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#f8fafc', color: '#64748b' }}>
            <Icon name="task_alt" />
          </div>
          <div>
            <div className="stat-value">{bookings.filter(b => b.status === 'Completed').length}</div>
            <div className="stat-label">Hoàn tất trả chỗ</div>
          </div>
        </article>
      </section>

      {/* Tabs */}
      <div className="amenities-tabs">
        <button
          className={`amenity-tab-btn ${activeTab === 'bookings' ? 'active' : ''}`}
          onClick={() => setActiveTab('bookings')}
        >
          <Icon name="event_available" /> Lịch đặt chỗ cư dân ({filteredBookings.length})
        </button>
        <button
          className={`amenity-tab-btn ${activeTab === 'amenities' ? 'active' : ''}`}
          onClick={() => setActiveTab('amenities')}
        >
          <Icon name="apartment" /> Danh mục tiện ích công cộng ({amenities.length})
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>Đang tải dữ liệu tiện ích từ máy chủ...</div>
      ) : activeTab === 'bookings' ? (
        <div className="bookings-table-wrapper">
          <div style={{ padding: '12px 16px', borderBottom: '1px solid #f1f5f9', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ display: 'flex', gap: '8px' }}>
              {['All', 'Confirmed', 'Completed', 'Cancelled'].map(st => (
                <button
                  key={st}
                  onClick={() => setStatusFilter(st)}
                  style={{
                    padding: '4px 12px',
                    borderRadius: '6px',
                    fontSize: '12px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    border: '1px solid #cbd5e1',
                    background: statusFilter === st ? '#2563eb' : '#f8fafc',
                    color: statusFilter === st ? '#fff' : '#475569'
                  }}
                >
                  {st === 'All' ? 'Tất cả' : st === 'Confirmed' ? 'Đã duyệt' : st === 'Completed' ? 'Hoàn tất' : 'Đã hủy'}
                </button>
              ))}
            </div>
            <span style={{ fontSize: '13px', color: '#64748b' }}>Tổng: {filteredBookings.length} lượt đặt</span>
          </div>

          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0', textAlign: 'left', color: '#475569' }}>
                <th style={{ padding: '10px 14px' }}>Mã đặt</th>
                <th style={{ padding: '10px 14px' }}>Tiện ích</th>
                <th style={{ padding: '10px 14px' }}>Cư dân & Căn hộ</th>
                <th style={{ padding: '10px 14px' }}>Ngày & Khung giờ</th>
                <th style={{ padding: '10px 14px' }}>Số người</th>
                <th style={{ padding: '10px 14px' }}>Trạng thái</th>
                <th style={{ padding: '10px 14px', textAlign: 'right' }}>Thao tác BQL</th>
              </tr>
            </thead>
            <tbody>
              {filteredBookings.length === 0 ? (
                <tr>
                  <td colSpan={7} style={{ textAlign: 'center', padding: '30px', color: '#94a3b8' }}>
                    Không tìm thấy yêu cầu đặt chỗ nào.
                  </td>
                </tr>
              ) : (
                filteredBookings.map(b => (
                  <tr key={b.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                    <td style={{ padding: '10px 14px', fontWeight: 600, color: '#1e293b' }}>{b.id}</td>
                    <td style={{ padding: '10px 14px', fontWeight: 600, color: '#2563eb' }}>{b.amenityName}</td>
                    <td style={{ padding: '10px 14px' }}>
                      <div style={{ fontWeight: 600, color: '#0f172a' }}>{b.residentName}</div>
                      <div style={{ fontSize: '11px', color: '#64748b' }}>Phòng {b.apartmentNumber} · {b.residentPhone}</div>
                    </td>
                    <td style={{ padding: '10px 14px' }}>
                      <div>{b.bookingDate}</div>
                      <div style={{ fontSize: '11px', color: '#64748b' }}>{b.startTime} - {b.endTime}</div>
                    </td>
                    <td style={{ padding: '10px 14px' }}>
                      <span style={{ fontWeight: 600 }}>{b.numberOfGuests}</span> người
                    </td>
                    <td style={{ padding: '10px 14px' }}>
                      <span className={`booking-status-badge ${b.status.toLowerCase()}`}>
                        {b.status === 'Confirmed' ? '● Đã duyệt' : b.status === 'Completed' ? '✓ Đã dùng xong' : '✕ Đã hủy'}
                      </span>
                    </td>
                    <td style={{ padding: '10px 14px', textAlign: 'right' }}>
                      <div className="booking-actions" style={{ justifyContent: 'flex-end' }}>
                        {b.status !== 'Confirmed' && (
                          <button className="btn-status-action btn-confirm" onClick={() => handleStatusChange(b.id, 'Confirmed')}>
                            <Icon name="check" /> Duyệt
                          </button>
                        )}
                        {b.status !== 'Completed' && (
                          <button className="btn-status-action btn-complete" onClick={() => handleStatusChange(b.id, 'Completed')}>
                            <Icon name="task_alt" /> Hoàn tất
                          </button>
                        )}
                        {b.status !== 'Cancelled' && (
                          <button className="btn-status-action btn-cancel" onClick={() => handleStatusChange(b.id, 'Cancelled')}>
                            <Icon name="close" /> Hủy
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="amenities-grid">
          {amenities.map(a => (
            <div key={a.id} className="amenity-card">
              <div className="amenity-card-img-wrapper">
                <img src={a.imageUrl || 'https://storage.bms.vn/amenities/hall.jpg'} alt={a.name} className="amenity-card-img" />
                <span className={`amenity-card-badge ${a.isActive ? 'active' : 'inactive'}`}>
                  {a.isActive ? 'Đang mở cửa' : 'Bảo trì'}
                </span>
              </div>
              <div className="amenity-card-body">
                <h3 className="amenity-card-title">{a.name}</h3>
                <div className="amenity-meta-list">
                  <div className="amenity-meta-item">
                    <Icon name="groups" /> Sức chứa tối đa: <strong>{a.maxCapacity} người</strong>
                  </div>
                  <div className="amenity-meta-item">
                    <Icon name="schedule" /> Giờ mở cửa: {a.openTime} - {a.closeTime}
                  </div>
                  <div className="amenity-meta-item">
                    <Icon name="timelapse" /> Thời lượng mỗi ca: {a.slotDurationMinutes} phút
                  </div>
                </div>
                <div className="amenity-card-actions">
                  <button className="btn-book-counter" onClick={() => setSelectedAmenityForBook(a)}>
                    <Icon name="add_circle" /> Đặt lịch tại quầy (Lễ tân)
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal Đặt lịch trực tiếp tại quầy */}
      {selectedAmenityForBook && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div style={{ background: '#fff', borderRadius: '12px', padding: '24px', width: '420px', maxWidth: '90%', boxShadow: '0 10px 25px rgba(0,0,0,0.2)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ margin: 0, fontSize: '17px', color: '#0f172a' }}>Lễ tân đặt lịch tiện ích</h3>
              <button onClick={() => setSelectedAmenityForBook(null)} style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                <Icon name="close" />
              </button>
            </div>
            <form onSubmit={handleCounterBookSubmit}>
              <div style={{ marginBottom: '12px' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px', color: '#334155' }}>Tiện ích:</label>
                <div style={{ padding: '8px 12px', background: '#f1f5f9', borderRadius: '6px', fontWeight: 600, color: '#1e293b', fontSize: '13px' }}>
                  {selectedAmenityForBook.name} (Tối đa {selectedAmenityForBook.maxCapacity} người)
                </div>
              </div>
              <div style={{ marginBottom: '12px' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px', color: '#334155' }}>Họ tên cư dân:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: Bác Nguyễn Văn An"
                  value={residentName}
                  onChange={e => setResidentName(e.target.value)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '13px', boxSizing: 'border-box' }}
                />
              </div>
              <div style={{ marginBottom: '12px' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px', color: '#334155' }}>Mã căn hộ:</label>
                <input
                  type="text"
                  required
                  placeholder="Ví dụ: B1-F03-02"
                  value={apartmentNumber}
                  onChange={e => setApartmentNumber(e.target.value)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '13px', boxSizing: 'border-box' }}
                />
              </div>
              <div style={{ marginBottom: '18px' }}>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, marginBottom: '4px', color: '#334155' }}>Số lượng người tham gia:</label>
                <input
                  type="number"
                  min={1}
                  max={selectedAmenityForBook.maxCapacity}
                  value={guestsCount}
                  onChange={e => setGuestsCount(parseInt(e.target.value) || 1)}
                  style={{ width: '100%', padding: '8px 12px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '13px', boxSizing: 'border-box' }}
                />
              </div>
              <div style={{ display: 'flex', gap: '10px', justifyContent: 'flex-end' }}>
                <button
                  type="button"
                  onClick={() => setSelectedAmenityForBook(null)}
                  style={{ padding: '8px 16px', borderRadius: '6px', border: '1px solid #cbd5e1', background: '#f8fafc', cursor: 'pointer', fontSize: '13px' }}
                >
                  Đóng
                </button>
                <button
                  type="submit"
                  style={{ padding: '8px 16px', borderRadius: '6px', border: 'none', background: '#2563eb', color: '#fff', fontWeight: 600, cursor: 'pointer', fontSize: '13px' }}
                >
                  Xác nhận đặt lịch
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
