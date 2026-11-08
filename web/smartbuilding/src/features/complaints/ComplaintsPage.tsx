import { useEffect, useState } from 'react'
import { Icon } from '../../components/Icon'
import {
  getComplaintsSummary,
  getComplaints,
  createComplaint,
  assignComplaint,
  resolveComplaint,
  updateComplaintStatus,
  type ComplaintSummary,
  type ComplaintItem
} from '../../data/api'
import '../../styles/complaints.css'

export function ComplaintsPage({ query, buildingId }: { query: string; buildingId?: string }) {
  const [summary, setSummary] = useState<ComplaintSummary | null>(null)
  const [complaints, setComplaints] = useState<ComplaintItem[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState(query)
  const [statusFilter, setStatusFilter] = useState<string>('All')
  const [categoryFilter, setCategoryFilter] = useState<string>('All')
  const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null)

  // Modals
  const [selectedDetail, setSelectedDetail] = useState<ComplaintItem | null>(null)
  const [assigningItem, setAssigningItem] = useState<ComplaintItem | null>(null)
  const [assignRole, setAssignRole] = useState('Kỹ thuật viên Điện nước (Tổ MEP)')
  const [assignNote, setAssignNote] = useState('')

  const [resolvingItem, setResolvingItem] = useState<ComplaintItem | null>(null)
  const [resolvedImageUrl, setResolvedImageUrl] = useState('')
  const [resolutionNote, setResolutionNote] = useState('')

  const [isCreateOpen, setIsCreateOpen] = useState(false)
  const [newApartmentId, setNewApartmentId] = useState('B1-F01-01')
  const [newResidentId, setNewResidentId] = useState('Res1')
  const [newCategory, setNewCategory] = useState<'FacilityDamage' | 'Sanitation' | 'Noise' | 'Security'>('FacilityDamage')
  const [newTitle, setNewTitle] = useState('')
  const [newContent, setNewContent] = useState('')
  const [newAttachedImageUrl, setNewAttachedImageUrl] = useState('')

  useEffect(() => {
    setSearch(query)
  }, [query])

  const showToast = (text: string, type: 'success' | 'error' = 'success') => {
    setToastMessage({ text, type })
    setTimeout(() => setToastMessage(null), 4000)
  }

  const loadData = async () => {
    try {
      setLoading(true)
      const [sumData, compList] = await Promise.all([
        getComplaintsSummary(buildingId),
        getComplaints(buildingId, categoryFilter, statusFilter, search)
      ])
      setSummary(sumData)
      setComplaints(compList)
    } catch (err: any) {
      showToast(err.message || 'Lỗi tải danh sách khiếu nại', 'error')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [buildingId, categoryFilter, statusFilter, search])

  const handleAssign = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!assigningItem) return
    try {
      await assignComplaint(assigningItem.id, assignRole, assignNote)
      showToast(`Đã phân công xử lý cho ${assignRole}!`)
      setAssigningItem(null)
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi phân công', 'error')
    }
  }

  const handleResolve = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!resolvingItem) return
    if (!resolvedImageUrl) {
      showToast('Bắt buộc phải tải ảnh nghiệm thu thực tế sau khi sửa chữa!', 'error')
      return
    }
    try {
      await resolveComplaint(resolvingItem.id, resolvedImageUrl, resolutionNote)
      showToast('Nghiệm thu sự cố thành công! Đã chuyển trạng thái ĐÃ XỬ LÝ.')
      setResolvingItem(null)
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi nghiệm thu', 'error')
    }
  }

  const handleCloseComplaint = async (id: string) => {
    try {
      await updateComplaintStatus(id, 'Closed')
      showToast('Đã đóng phiếu khiếu nại minh bạch!')
      loadData()
      if (selectedDetail?.id === id) {
        setSelectedDetail((prev) => (prev ? { ...prev, status: 'Closed' } : null))
      }
    } catch (err: any) {
      showToast(err.message || 'Lỗi đóng phiếu', 'error')
    }
  }

  const handleCreateComplaint = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newTitle || !newContent) {
      showToast('Vui lòng nhập tiêu đề và nội dung phản ánh', 'error')
      return
    }
    try {
      await createComplaint({
        apartmentId: newApartmentId,
        residentId: newResidentId,
        category: newCategory,
        title: newTitle,
        content: newContent,
        attachedImageUrl: newAttachedImageUrl || undefined
      })
      showToast('Tiếp nhận phiếu sự cố mới thành công!')
      setIsCreateOpen(false)
      setNewTitle('')
      setNewContent('')
      setNewAttachedImageUrl('')
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi tạo phản ánh', 'error')
    }
  }

  const getCategoryLabel = (cat: string) => {
    switch (cat) {
      case 'FacilityDamage':
        return { label: 'Hạ tầng / Điện nước', icon: 'build' }
      case 'Sanitation':
        return { label: 'Vệ sinh môi trường', icon: 'cleaning_services' }
      case 'Noise':
        return { label: 'Tiếng ồn / Trật tự', icon: 'volume_up' }
      case 'Security':
        return { label: 'An ninh / Thẻ từ', icon: 'security' }
      default:
        return { label: cat, icon: 'report_problem' }
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'Pending':
        return <span className="badge-status pending">Chờ tiếp nhận</span>
      case 'Assigned':
        return <span className="badge-status assigned">Đã phân công</span>
      case 'Processing':
        return <span className="badge-status processing">Đang xử lý</span>
      case 'Resolved':
        return <span className="badge-status resolved">Đã nghiệm thu</span>
      case 'Closed':
        return <span className="badge-status closed">Đã đóng phiếu</span>
      default:
        return <span className="badge-status">{status}</span>
    }
  }

  return (
    <div className="complaints-container">
      {toastMessage && (
        <div
          style={{
            position: 'fixed',
            top: '80px',
            right: '28px',
            zIndex: 1000,
            background: toastMessage.type === 'error' ? '#ef4444' : '#10b981',
            color: '#fff',
            padding: '12px 20px',
            borderRadius: '10px',
            boxShadow: '0 8px 20px rgba(0,0,0,0.15)',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            fontWeight: 600,
            fontSize: '13px'
          }}
        >
          <Icon name={toastMessage.type === 'error' ? 'error' : 'check_circle'} />
          {toastMessage.text}
        </div>
      )}

      {/* SUMMARY METRICS */}
      <section className="metric-grid">
        <div className="metric-card">
          <label>Tổng số sự cố tiếp nhận</label>
          <div className="metric-icon blue">
            <Icon name="assignment_late" />
          </div>
          <strong>{summary?.totalComplaints ?? 0}</strong>
          <small className="blue">
            <span>Toàn bộ phản ánh cư dân</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Chờ BQL tiếp nhận</label>
          <div className="metric-icon amber">
            <Icon name="schedule" />
          </div>
          <strong>{summary?.pendingCount ?? 0}</strong>
          <small className="amber">
            <span>Chưa phân công nhân sự</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Đang xử lý hiện trường</label>
          <div className="metric-icon blue">
            <Icon name="engineering" />
          </div>
          <strong>{(summary?.assignedCount ?? 0) + (summary?.processingCount ?? 0)}</strong>
          <small className="blue">
            <span>Kỹ thuật / Vệ sinh đang làm</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Đã hoàn thành nghiệm thu</label>
          <div className="metric-icon green">
            <Icon name="task_alt" />
          </div>
          <strong>{(summary?.resolvedCount ?? 0) + (summary?.closedCount ?? 0)}</strong>
          <small className="green">
            <span>Đã có ảnh nghiệm thu đóng phiếu</span>
          </small>
        </div>
      </section>

      {/* FILTER TABS & TOOLBAR */}
      <div className="mep-toolbar">
        <div className="complaints-tabs">
          {[
            { id: 'All', label: 'Tất cả' },
            { id: 'Pending', label: 'Chờ tiếp nhận' },
            { id: 'Assigned', label: 'Đã phân công' },
            { id: 'Processing', label: 'Đang xử lý' },
            { id: 'Resolved', label: 'Đã nghiệm thu' },
            { id: 'Closed', label: 'Đã đóng' }
          ].map((tab) => (
            <button
              key={tab.id}
              className={`complaint-tab-btn ${statusFilter === tab.id ? 'active' : ''}`}
              onClick={() => setStatusFilter(tab.id)}
            >
              {tab.label}
            </button>
          ))}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <select
            className="mep-select"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="All">Tất cả phân loại</option>
            <option value="FacilityDamage">Hạ tầng & Điện nước</option>
            <option value="Sanitation">Vệ sinh môi trường</option>
            <option value="Noise">Tiếng ồn & Trật tự</option>
            <option value="Security">An ninh tòa nhà</option>
          </select>

          <input
            type="text"
            className="mep-input"
            placeholder="Tìm theo tiêu đề, phòng, tên..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ width: '220px' }}
          />

          <button className="primary-button" onClick={() => setIsCreateOpen(true)}>
            <Icon name="add" />
            Tạo phiếu sự cố
          </button>
        </div>
      </div>

      {/* COMPLAINTS GRID CARDS */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '60px', color: '#64748b' }}>
          Đang nạp danh sách sự cố hiện trường...
        </div>
      ) : complaints.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '60px', background: '#fff', borderRadius: '12px', border: '1px solid #e2e8f0', color: '#64748b' }}>
          <Icon name="check_circle" />
          <h3 style={{ margin: '10px 0 4px', color: '#1e293b' }}>Không có sự cố nào cần xử lý</h3>
          <p style={{ margin: 0, fontSize: '13px' }}>Hệ thống vận hành tòa nhà đang hoạt động ổn định và an toàn.</p>
        </div>
      ) : (
        <div className="complaints-grid">
          {complaints.map((item) => {
            const catInfo = getCategoryLabel(item.category)
            return (
              <div key={item.id} className="complaint-card">
                <div className="card-top">
                  <span className="badge-category">
                    <Icon name={catInfo.icon} />
                    {catInfo.label}
                  </span>
                  {getStatusBadge(item.status)}
                </div>

                <h4 className="card-title">{item.title}</h4>
                <p className="card-content">{item.content}</p>

                {/* IMAGE PREVIEW */}
                <div className="card-photos-preview">
                  {item.attachedImageUrl && (
                    <div style={{ position: 'relative' }}>
                      <img
                        src={item.attachedImageUrl}
                        alt="Hiện trường"
                        className="thumb-photo"
                        onClick={() => setSelectedDetail(item)}
                        title="Bấm để xem ảnh hiện trường"
                      />
                      <span style={{ position: 'absolute', bottom: '4px', left: '4px', background: 'rgba(0,0,0,0.6)', color: '#fff', fontSize: '9px', padding: '2px 4px', borderRadius: '4px' }}>
                        Hiện trường
                      </span>
                    </div>
                  )}
                  {item.resolvedImageUrl && (
                    <div style={{ position: 'relative' }}>
                      <img
                        src={item.resolvedImageUrl}
                        alt="Nghiệm thu"
                        className="thumb-photo"
                        style={{ borderColor: '#10b981' }}
                        onClick={() => setSelectedDetail(item)}
                        title="Bấm để xem ảnh nghiệm thu"
                      />
                      <span style={{ position: 'absolute', bottom: '4px', left: '4px', background: 'rgba(16,185,129,0.85)', color: '#fff', fontSize: '9px', padding: '2px 4px', borderRadius: '4px' }}>
                        Nghiệm thu
                      </span>
                    </div>
                  )}
                </div>

                <div className="card-meta">
                  <div>
                    <strong style={{ color: '#1e293b' }}>{item.apartmentNumber}</strong> • {item.buildingName}
                  </div>
                  <div style={{ marginLeft: 'auto' }}>
                    {item.residentName} ({item.phoneNumber})
                  </div>
                </div>

                <div className="card-actions">
                  <button
                    className="secondary-button"
                    style={{ fontSize: '12px', padding: '6px 12px' }}
                    onClick={() => setSelectedDetail(item)}
                  >
                    Chi tiết
                  </button>

                  {item.status === 'Pending' && (
                    <button
                      className="primary-button"
                      style={{ fontSize: '12px', padding: '6px 12px', marginLeft: 'auto' }}
                      onClick={() => {
                        setAssigningItem(item)
                        setAssignNote('')
                      }}
                    >
                      Phân công xử lý
                    </button>
                  )}

                  {(item.status === 'Assigned' || item.status === 'Processing') && (
                    <button
                      className="primary-button"
                      style={{ fontSize: '12px', padding: '6px 12px', background: '#059669', borderColor: '#059669', marginLeft: 'auto' }}
                      onClick={() => {
                        setResolvingItem(item)
                        setResolvedImageUrl('')
                        setResolutionNote('')
                      }}
                    >
                      Nghiệm thu kèm ảnh
                    </button>
                  )}

                  {item.status === 'Resolved' && (
                    <button
                      className="secondary-button"
                      style={{ fontSize: '12px', padding: '6px 12px', color: '#475569', marginLeft: 'auto' }}
                      onClick={() => handleCloseComplaint(item.id)}
                    >
                      Đóng phiếu
                    </button>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      )}

      {/* MODAL CHI TIẾT ĐỐI SOÁT */}
      {selectedDetail && (
        <div className="modal-overlay" onClick={() => setSelectedDetail(null)}>
          <div className="modal-dialog" style={{ maxWidth: '640px' }} onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Hồ sơ xử lý sự cố & Đối soát nghiệm thu</h3>
              <button className="modal-close" onClick={() => setSelectedDetail(null)}>✕</button>
            </div>
            <div className="modal-body">
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span className="badge-category">{getCategoryLabel(selectedDetail.category).label}</span>
                {getStatusBadge(selectedDetail.status)}
              </div>

              <h4 style={{ margin: '8px 0 4px', fontSize: '17px', color: '#0f172a' }}>{selectedDetail.title}</h4>
              <p style={{ margin: 0, fontSize: '13px', color: '#475569', background: '#f8fafc', padding: '12px', borderRadius: '8px' }}>
                {selectedDetail.content}
              </p>

              <div style={{ fontSize: '12px', color: '#64748b', display: 'flex', gap: '20px' }}>
                <div>Căn hộ: <strong style={{ color: '#1e293b' }}>{selectedDetail.apartmentNumber}</strong></div>
                <div>Cư dân: <strong style={{ color: '#1e293b' }}>{selectedDetail.residentName}</strong> ({selectedDetail.phoneNumber})</div>
                <div>Tiếp nhận: {new Date(selectedDetail.createdAt).toLocaleDateString('vi-VN')}</div>
              </div>

              {/* PHOTO COMPARISON */}
              <div className="photo-compare">
                <div className="photo-box">
                  <label>📸 Ảnh hiện trường cư dân gửi:</label>
                  {selectedDetail.attachedImageUrl ? (
                    <img src={selectedDetail.attachedImageUrl} alt="Ảnh báo lỗi" />
                  ) : (
                    <div style={{ height: '190px', background: '#f1f5f9', borderRadius: '8px', display: 'grid', placeItems: 'center', color: '#94a3b8' }}>
                      Không đính kèm ảnh
                    </div>
                  )}
                </div>

                <div className="photo-box">
                  <label>✅ Ảnh nghiệm thu sau khi sửa:</label>
                  {selectedDetail.resolvedImageUrl ? (
                    <img src={selectedDetail.resolvedImageUrl} alt="Ảnh nghiệm thu" />
                  ) : (
                    <div style={{ height: '190px', background: '#f8fafc', borderRadius: '8px', border: '1px dashed #cbd5e1', display: 'grid', placeItems: 'center', color: '#94a3b8' }}>
                      Chưa hoàn tất sửa chữa
                    </div>
                  )}
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="secondary-button" onClick={() => setSelectedDetail(null)}>Đóng</button>
              {selectedDetail.status === 'Resolved' && (
                <button className="primary-button" onClick={() => handleCloseComplaint(selectedDetail.id)}>
                  Xác nhận đóng phiếu
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* MODAL PHÂN CÔNG */}
      {assigningItem && (
        <div className="modal-overlay" onClick={() => setAssigningItem(null)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <form onSubmit={handleAssign}>
              <div className="modal-header">
                <h3>Phân công nhân sự xử lý sự cố</h3>
                <button type="button" className="modal-close" onClick={() => setAssigningItem(null)}>✕</button>
              </div>
              <div className="modal-body">
                <p style={{ margin: 0, fontSize: '13px', color: '#475569' }}>
                  Sự cố: <strong>{assigningItem.title}</strong> ({assigningItem.apartmentNumber})
                </p>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Chọn nhân sự / Đội ngũ phụ trách *
                  </label>
                  <select
                    className="mep-select"
                    style={{ width: '100%' }}
                    value={assignRole}
                    onChange={(e) => setAssignRole(e.target.value)}
                  >
                    <option value="Kỹ thuật viên Điện nước (Tổ MEP)">⚡ Kỹ thuật viên Điện nước (Tổ MEP)</option>
                    <option value="Đội ngũ Vệ sinh môi trường">🧹 Đội ngũ Vệ sinh môi trường</option>
                    <option value="Đội Tuần tra An ninh & Trật tự">🛡️ Đội Tuần tra An ninh & Trật tự</option>
                    <option value="Kỹ thuật viên Hạ tầng căn hộ">🔨 Kỹ thuật viên Hạ tầng căn hộ</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Chỉ đạo xử lý / Ghi chú ưu tiên:
                  </label>
                  <textarea
                    rows={3}
                    className="mep-input"
                    style={{ width: '100%', height: 'auto', padding: '10px' }}
                    placeholder="Vd: Ưu tiên qua kiểm tra trước 11h trưa nay..."
                    value={assignNote}
                    onChange={(e) => setAssignNote(e.target.value)}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setAssigningItem(null)}>Hủy</button>
                <button type="submit" className="primary-button">Giao việc ngay</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL NGHIỆM THU KÈM ẢNH */}
      {resolvingItem && (
        <div className="modal-overlay" onClick={() => setResolvingItem(null)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <form onSubmit={handleResolve}>
              <div className="modal-header">
                <h3>Nghiệm thu hoàn thành hiện trường</h3>
                <button type="button" className="modal-close" onClick={() => setResolvingItem(null)}>✕</button>
              </div>
              <div className="modal-body">
                <p style={{ margin: 0, fontSize: '13px', color: '#475569' }}>
                  Xác nhận đã khắc phục xong sự cố <strong>{resolvingItem.title}</strong> tại căn hộ <strong>{resolvingItem.apartmentNumber}</strong>.
                </p>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Ảnh chụp nghiệm thu sạch sẽ/đã sửa xong (URL/Camera) *
                  </label>
                  <input
                    type="text"
                    required
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="https://images.unsplash.com/... hoặc dán link ảnh nghiệm thu"
                    value={resolvedImageUrl}
                    onChange={(e) => setResolvedImageUrl(e.target.value)}
                  />
                </div>

                {resolvedImageUrl && (
                  <div style={{ textAlign: 'center' }}>
                    <img
                      src={resolvedImageUrl}
                      alt="Ảnh nghiệm thu xem trước"
                      style={{ maxWidth: '100%', maxHeight: '180px', borderRadius: '8px', border: '1px solid #10b981' }}
                    />
                  </div>
                )}

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Ghi chú nghiệm thu thực tế:
                  </label>
                  <textarea
                    rows={3}
                    className="mep-input"
                    style={{ width: '100%', height: 'auto', padding: '10px' }}
                    placeholder="Vd: Đã thay gioăng cao su, siết lại ốc rò rỉ, vệ sinh sạch sẽ mặt sàn..."
                    value={resolutionNote}
                    onChange={(e) => setResolutionNote(e.target.value)}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setResolvingItem(null)}>Hủy</button>
                <button type="submit" className="primary-button" style={{ background: '#059669', borderColor: '#059669' }}>
                  Xác nhận nghiệm thu
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* MODAL TẠO PHẢN ÁNH MỚI */}
      {isCreateOpen && (
        <div className="modal-overlay" onClick={() => setIsCreateOpen(false)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <form onSubmit={handleCreateComplaint}>
              <div className="modal-header">
                <h3>Tiếp nhận phiếu phản ánh sự cố mới</h3>
                <button type="button" className="modal-close" onClick={() => setIsCreateOpen(false)}>✕</button>
              </div>
              <div className="modal-body">
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Căn hộ phát sinh sự cố *
                  </label>
                  <input
                    type="text"
                    required
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="Vd: B1-F01-01"
                    value={newApartmentId}
                    onChange={(e) => setNewApartmentId(e.target.value)}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Mã Cư Dân (Resident ID) *
                  </label>
                  <input
                    type="text"
                    required
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="Vd: Res1"
                    value={newResidentId}
                    onChange={(e) => setNewResidentId(e.target.value)}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Phân loại sự cố *
                  </label>
                  <select
                    className="mep-select"
                    style={{ width: '100%' }}
                    value={newCategory}
                    onChange={(e) => setNewCategory(e.target.value as any)}
                  >
                    <option value="FacilityDamage">🔨 Hạ tầng & Hỏng hóc điện nước</option>
                    <option value="Sanitation">🧹 Vệ sinh môi trường & Rác thải</option>
                    <option value="Noise">📢 Tiếng ồn & Trật tự sinh hoạt</option>
                    <option value="Security">🛡️ An ninh & Kiểm soát ra vào</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Tiêu đề sự cố *
                  </label>
                  <input
                    type="text"
                    required
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="Vd: Rò rỉ nước bồn rửa chén"
                    value={newTitle}
                    onChange={(e) => setNewTitle(e.target.value)}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Mô tả chi tiết *
                  </label>
                  <textarea
                    rows={3}
                    required
                    className="mep-input"
                    style={{ width: '100%', height: 'auto', padding: '10px' }}
                    placeholder="Mô tả cụ thể vị trí, mức độ nghiêm trọng..."
                    value={newContent}
                    onChange={(e) => setNewContent(e.target.value)}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Ảnh chụp hiện trường (URL):
                  </label>
                  <input
                    type="text"
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="https://..."
                    value={newAttachedImageUrl}
                    onChange={(e) => setNewAttachedImageUrl(e.target.value)}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setIsCreateOpen(false)}>Hủy</button>
                <button type="submit" className="primary-button">Lưu phiếu tiếp nhận</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
