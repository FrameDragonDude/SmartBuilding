import { useEffect, useState } from 'react'
import { Icon } from '../../components/Icon'
import {
  getUtilitySummary,
  getUtilityUsages,
  recordUtilityReading,
  registerUtilityMeter,
  lockUtilityCycle,
  type UtilitySummary,
  type UtilityUsageItem
} from '../../data/api'
import '../../styles/mep.css'

export function MepPage({ query, buildingId }: { query: string; buildingId?: string }) {
  const [summary, setSummary] = useState<UtilitySummary | null>(null)
  const [usages, setUsages] = useState<UtilityUsageItem[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState(query)
  const [meterType, setMeterType] = useState<string>('All')
  const [selectedMonth, setSelectedMonth] = useState<number>(9)
  const [selectedYear, setSelectedYear] = useState<number>(2026)
  const [floorFilter, setFloorFilter] = useState<number | undefined>(undefined)

  // Local state for inline input readings: { [meterId]: string }
  const [inputReadings, setInputReadings] = useState<Record<string, string>>({})
  const [savingMeterId, setSavingMeterId] = useState<string | null>(null)
  const [toastMessage, setToastMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null)

  // Modal Proof Photo
  const [proofModalItem, setProofModalItem] = useState<UtilityUsageItem | null>(null)
  const [proofUrlInput, setProofUrlInput] = useState('')

  // Modal Register Meter
  const [isRegisterOpen, setIsRegisterOpen] = useState(false)
  const [newApartmentId, setNewApartmentId] = useState('')
  const [newMeterType, setNewMeterType] = useState('Electricity')
  const [newSerialNumber, setNewSerialNumber] = useState('')

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
      const [sumData, usageData] = await Promise.all([
        getUtilitySummary(buildingId, selectedMonth, selectedYear),
        getUtilityUsages(buildingId, floorFilter, meterType, selectedMonth, selectedYear, search)
      ])
      setSummary(sumData)
      setUsages(usageData)

      // Pre-fill inputReadings with existing currentReading if already recorded
      const initialInputs: Record<string, string> = {}
      usageData.forEach((u) => {
        if (u.isRecorded) {
          initialInputs[u.meterId] = u.currentReading.toString()
        }
      })
      setInputReadings(initialInputs)
    } catch (err: any) {
      showToast(err.message || 'Lỗi tải dữ liệu chỉ số MEP', 'error')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [buildingId, meterType, selectedMonth, selectedYear, floorFilter, search])

  const handleInputChange = (meterId: string, val: string) => {
    setInputReadings((prev) => ({ ...prev, [meterId]: val }))
  }

  const handleSaveReading = async (item: UtilityUsageItem) => {
    const rawVal = inputReadings[item.meterId]
    if (!rawVal || isNaN(Number(rawVal))) {
      showToast('Vui lòng nhập chỉ số hợp lệ', 'error')
      return
    }

    const currentVal = Number(rawVal)
    if (currentVal < item.previousReading) {
      showToast(`Chỉ số mới (${currentVal}) không được nhỏ hơn chỉ số cũ (${item.previousReading})!`, 'error')
      return
    }

    try {
      setSavingMeterId(item.meterId)
      await recordUtilityReading({
        meterId: item.meterId,
        billingMonth: selectedMonth,
        billingYear: selectedYear,
        currentReading: currentVal,
        proofImageUrl: item.proofImageUrl || undefined
      })
      showToast(`Đã lưu chỉ số căn hộ ${item.apartmentNumber} thành công!`)
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi khi lưu chỉ số', 'error')
    } finally {
      setSavingMeterId(null)
    }
  }

  const handleSaveProofPhoto = async () => {
    if (!proofModalItem) return
    const rawVal = inputReadings[proofModalItem.meterId] || proofModalItem.currentReading.toString()
    try {
      await recordUtilityReading({
        meterId: proofModalItem.meterId,
        billingMonth: selectedMonth,
        billingYear: selectedYear,
        currentReading: Number(rawVal) || proofModalItem.previousReading,
        proofImageUrl: proofUrlInput
      })
      showToast('Đã lưu ảnh minh chứng mặt số đồng hồ!')
      setProofModalItem(null)
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi lưu ảnh', 'error')
    }
  }

  const handleLockCycle = async () => {
    if (!buildingId) {
      showToast('Vui lòng chọn tòa nhà để chốt sổ', 'error')
      return
    }
    if (window.confirm(`Bạn có chắc chắn muốn khóa chốt sổ chỉ số MEP tháng ${selectedMonth}/${selectedYear} của tòa nhà này không?`)) {
      try {
        const res = await lockUtilityCycle(buildingId, selectedMonth, selectedYear)
        showToast(res.message, res.success ? 'success' : 'error')
      } catch (err: any) {
        showToast(err.message || 'Lỗi khóa sổ', 'error')
      }
    }
  }

  const handleRegisterMeter = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newApartmentId || !newSerialNumber) {
      showToast('Vui lòng nhập đầy đủ thông tin', 'error')
      return
    }
    try {
      await registerUtilityMeter({
        apartmentId: newApartmentId,
        meterType: newMeterType,
        meterSerialNumber: newSerialNumber
      })
      showToast('Đăng ký công tơ mới thành công!')
      setIsRegisterOpen(false)
      setNewApartmentId('')
      setNewSerialNumber('')
      loadData()
    } catch (err: any) {
      showToast(err.message || 'Lỗi đăng ký công tơ', 'error')
    }
  }

  return (
    <div className="mep-container">
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

      {/* METRIC CARDS */}
      <section className="metric-grid">
        <div className="metric-card">
          <label>Tổng số công tơ</label>
          <div className="metric-icon blue">
            <Icon name="speed" />
          </div>
          <strong>{summary?.totalMeters ?? 0}</strong>
          <small className="blue">
            <span>⚡ {summary?.electricityMetersCount ?? 0} điện | 💧 {summary?.waterMetersCount ?? 0} nước</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Đã ghi số kỳ T{selectedMonth}</label>
          <div className="metric-icon green">
            <Icon name="check_circle" />
          </div>
          <strong>{summary?.recordedCount ?? 0} / {summary?.totalMeters ?? 0}</strong>
          <small className="green">
            <span>Còn lại: {summary?.pendingCount ?? 0} công tơ</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Tổng sản lượng Điện</label>
          <div className="metric-icon amber">
            <Icon name="bolt" />
          </div>
          <strong>{summary?.totalElectricityKwh ? summary.totalElectricityKwh.toLocaleString('vi-VN') : 0} kWh</strong>
          <small className="amber">
            <span>Nước sạch: {summary?.totalWaterM3 ? summary.totalWaterM3.toLocaleString('vi-VN') : 0} m³</span>
          </small>
        </div>

        <div className="metric-card">
          <label>Cảnh báo bất thường</label>
          <div className="metric-icon red">
            <Icon name="warning" />
          </div>
          <strong>{summary?.anomalyAlertsCount ?? 0}</strong>
          <small className="red">
            <span>{summary?.anomalyAlertsCount ? 'Cần đối soát lại số' : 'Số liệu bình thường'}</span>
          </small>
        </div>
      </section>

      {/* TOOLBAR */}
      <div className="mep-toolbar">
        <div className="mep-filters">
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Icon name="calendar_month" />
            <select
              className="mep-select"
              value={selectedMonth}
              onChange={(e) => setSelectedMonth(Number(e.target.value))}
            >
              {[...Array(12)].map((_, i) => (
                <option key={i + 1} value={i + 1}>
                  Tháng {i + 1 < 10 ? `0${i + 1}` : i + 1}
                </option>
              ))}
            </select>
            <select
              className="mep-select"
              value={selectedYear}
              onChange={(e) => setSelectedYear(Number(e.target.value))}
            >
              <option value={2026}>Năm 2026</option>
              <option value={2025}>Năm 2025</option>
            </select>
          </div>

          <select
            className="mep-select"
            value={floorFilter ?? ''}
            onChange={(e) => setFloorFilter(e.target.value ? Number(e.target.value) : undefined)}
          >
            <option value="">Tất cả các tầng</option>
            <option value="1">Tầng 01</option>
            <option value="2">Tầng 02</option>
            <option value="3">Tầng 03</option>
            <option value="4">Tầng 04</option>
            <option value="5">Tầng 05</option>
          </select>

          <select
            className="mep-select"
            value={meterType}
            onChange={(e) => setMeterType(e.target.value)}
          >
            <option value="All">Tất cả loại đồng hồ</option>
            <option value="Electricity">⚡ Đồng hồ Điện</option>
            <option value="Water">💧 Đồng hồ Nước</option>
          </select>

          <input
            type="text"
            className="mep-input"
            placeholder="Tìm mã căn / seri..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ width: '180px' }}
          />

          <button
            className="secondary-button"
            onClick={loadData}
            style={{ display: 'flex', alignItems: 'center', gap: '4px' }}
          >
            <Icon name="refresh" />
            Tải lại
          </button>
        </div>

        <div className="mep-actions">
          <button className="btn-register" onClick={() => setIsRegisterOpen(true)}>
            <Icon name="add" />
            Gắn công tơ mới
          </button>
          <button className="btn-lock" onClick={handleLockCycle}>
            <Icon name="lock" />
            Chốt sổ kỳ này
          </button>
        </div>
      </div>

      {/* MEP DATA TABLE */}
      <div className="mep-table-wrapper">
        <table className="mep-table">
          <thead>
            <tr>
              <th>Căn hộ / Tầng</th>
              <th>Loại & Số Seri</th>
              <th style={{ textAlign: 'right' }}>Chỉ số cũ (kỳ trước)</th>
              <th style={{ textAlign: 'right' }}>Chỉ số mới (nhập)</th>
              <th style={{ textAlign: 'right' }}>Tiêu thụ thực tế</th>
              <th style={{ textAlign: 'right' }}>Thành tiền ước tính</th>
              <th>Minh chứng ảnh</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={9} style={{ textAlign: 'center', padding: '36px', color: '#64748b' }}>
                  Đang tải dữ liệu chỉ số công tơ...
                </td>
              </tr>
            ) : usages.length === 0 ? (
              <tr>
                <td colSpan={9} style={{ textAlign: 'center', padding: '36px', color: '#64748b' }}>
                  Không tìm thấy đồng hồ nào phù hợp với bộ lọc hiện tại.
                </td>
              </tr>
            ) : (
              usages.map((u) => {
                const currentValStr = inputReadings[u.meterId] ?? (u.isRecorded ? u.currentReading.toString() : '')
                const currentValNum = Number(currentValStr) || 0
                const isInvalid = currentValStr !== '' && currentValNum < u.previousReading
                const liveConsumption = currentValStr !== '' ? Math.max(0, currentValNum - u.previousReading) : (u.isRecorded ? u.consumption : 0)

                return (
                  <tr key={u.meterId}>
                    <td>
                      <strong style={{ color: '#1e293b', fontSize: '14px' }}>{u.apartmentNumber}</strong>
                      <div style={{ fontSize: '11px', color: '#64748b' }}>
                        Tầng {u.floorNumber} • {u.buildingName}
                      </div>
                    </td>

                    <td>
                      <span className={`meter-type-badge ${u.meterType.toLowerCase()}`}>
                        <Icon name={u.meterType === 'Electricity' ? 'bolt' : 'water_drop'} />
                        {u.meterType === 'Electricity' ? 'Điện' : 'Nước'}
                      </span>
                      <div style={{ fontSize: '11px', color: '#64748b', marginTop: '3px' }}>
                        Seri: {u.meterSerialNumber}
                      </div>
                    </td>

                    <td style={{ textAlign: 'right', fontWeight: 600, color: '#64748b' }}>
                      {u.previousReading.toLocaleString('vi-VN')} {u.meterType === 'Electricity' ? 'kWh' : 'm³'}
                    </td>

                    <td style={{ textAlign: 'right' }}>
                      <div className="reading-input-wrap" style={{ justifyContent: 'flex-end' }}>
                        <input
                          type="number"
                          step="0.1"
                          className={`reading-input ${isInvalid ? 'error' : ''}`}
                          value={currentValStr}
                          placeholder="Nhập..."
                          onChange={(e) => handleInputChange(u.meterId, e.target.value)}
                        />
                        <span style={{ fontSize: '11px', color: '#64748b' }}>
                          {u.meterType === 'Electricity' ? 'kWh' : 'm³'}
                        </span>
                      </div>
                      {isInvalid && (
                        <div style={{ fontSize: '10px', color: '#ef4444', marginTop: '2px' }}>
                          Số mới &lt; số cũ
                        </div>
                      )}
                    </td>

                    <td style={{ textAlign: 'right' }}>
                      <span className={`consumption-cell ${liveConsumption > 400 ? 'warning' : ''}`}>
                        +{liveConsumption.toLocaleString('vi-VN')}
                      </span>
                    </td>

                    <td style={{ textAlign: 'right' }}>
                      <span className="amount-preview">
                        {u.calculatedAmount > 0
                          ? `${u.calculatedAmount.toLocaleString('vi-VN')} đ`
                          : u.isRecorded ? '0 đ' : '--'}
                      </span>
                    </td>

                    <td>
                      <button
                        className={`btn-proof-photo ${u.proofImageUrl ? 'has-photo' : ''}`}
                        onClick={() => {
                          setProofModalItem(u)
                          setProofUrlInput(u.proofImageUrl || '')
                        }}
                      >
                        <Icon name="camera_alt" />
                        {u.proofImageUrl ? 'Xem ảnh' : 'Tải ảnh'}
                      </button>
                    </td>

                    <td>
                      {u.hasAnomaly ? (
                        <span className="status-tag anomaly" title={u.anomalyReason || 'Bất thường'}>
                          <Icon name="warning" />
                          Bất thường
                        </span>
                      ) : u.isRecorded ? (
                        <span className="status-tag recorded">
                          <Icon name="check_circle" />
                          Đã chốt
                        </span>
                      ) : (
                        <span className="status-tag pending">
                          <Icon name="schedule" />
                          Chờ ghi
                        </span>
                      )}
                    </td>

                    <td>
                      <button
                        className="secondary-button"
                        style={{
                          fontSize: '11px',
                          padding: '6px 10px',
                          background: '#eff6ff',
                          borderColor: '#bfdbfe',
                          color: '#2563eb'
                        }}
                        disabled={savingMeterId === u.meterId || isInvalid}
                        onClick={() => handleSaveReading(u)}
                      >
                        {savingMeterId === u.meterId ? 'Đang lưu...' : 'Lưu số'}
                      </button>
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>

      {/* MODAL PROOF PHOTO */}
      {proofModalItem && (
        <div className="modal-overlay" onClick={() => setProofModalItem(null)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Bằng chứng mặt số công tơ - {proofModalItem.apartmentNumber}</h3>
              <button className="modal-close" onClick={() => setProofModalItem(null)}>✕</button>
            </div>
            <div className="modal-body">
              <p style={{ margin: 0, fontSize: '13px', color: '#64748b' }}>
                Đồng hồ {proofModalItem.meterType === 'Electricity' ? 'Điện' : 'Nước'} (Seri: {proofModalItem.meterSerialNumber}) kỳ T{selectedMonth}/{selectedYear}.
              </p>

              {proofUrlInput ? (
                <div style={{ textAlign: 'center' }}>
                  <img
                    src={proofUrlInput}
                    alt="Mặt số đồng hồ"
                    style={{ maxWidth: '100%', maxHeight: '240px', borderRadius: '8px', border: '1px solid #cbd5e1' }}
                  />
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: '30px', background: '#f8fafc', borderRadius: '8px', color: '#64748b' }}>
                  <Icon name="image" />
                  <p style={{ margin: '6px 0 0', fontSize: '13px' }}>Chưa có ảnh chụp mặt số công tơ</p>
                </div>
              )}

              <div>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                  Đường dẫn ảnh chứng thực (URL):
                </label>
                <input
                  type="text"
                  className="mep-input"
                  style={{ width: '100%' }}
                  placeholder="https://... hoặc dán link ảnh chụp camera"
                  value={proofUrlInput}
                  onChange={(e) => setProofUrlInput(e.target.value)}
                />
              </div>
            </div>
            <div className="modal-footer">
              <button className="secondary-button" onClick={() => setProofModalItem(null)}>Đóng</button>
              <button className="primary-button" onClick={handleSaveProofPhoto}>Lưu ảnh minh chứng</button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL REGISTER METER */}
      {isRegisterOpen && (
        <div className="modal-overlay" onClick={() => setIsRegisterOpen(false)}>
          <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
            <form onSubmit={handleRegisterMeter}>
              <div className="modal-header">
                <h3>Gắn công tơ đo đếm mới cho căn hộ</h3>
                <button type="button" className="modal-close" onClick={() => setIsRegisterOpen(false)}>✕</button>
              </div>
              <div className="modal-body">
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Mã Căn Hộ (Apartment ID) *
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
                    Loại đồng hồ *
                  </label>
                  <select
                    className="mep-select"
                    style={{ width: '100%' }}
                    value={newMeterType}
                    onChange={(e) => setNewMeterType(e.target.value)}
                  >
                    <option value="Electricity">⚡ Điện sinh hoạt</option>
                    <option value="Water">💧 Nước sinh hoạt</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                    Số seri niêm phong đồng hồ *
                  </label>
                  <input
                    type="text"
                    required
                    className="mep-input"
                    style={{ width: '100%' }}
                    placeholder="Vd: EM-2026-888"
                    value={newSerialNumber}
                    onChange={(e) => setNewSerialNumber(e.target.value)}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setIsRegisterOpen(false)}>Hủy</button>
                <button type="submit" className="primary-button">Lưu công tơ</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
