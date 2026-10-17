import { useEffect, useState } from 'react'
import { Icon } from '../../components/Icon'
import {
  getTariffConfig,
  updateTariffPrice,
  updateTariffRules,
  approveDraftTariff,
  type TariffConfig,
  type TariffItem,
  type TariffRules
} from '../../data/api'
import '../../styles/pricing.css'
import '../../styles/residents.css'

export function PricingPage({ query: _query = '', buildingName = 'Tòa Ruby Suites' }: { query?: string; buildingName?: string }) {
  const [config, setConfig] = useState<TariffConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [feedback, setFeedback] = useState<string | null>(null)

  // Edit price modal state
  const [editingItem, setEditingItem] = useState<TariffItem | null>(null)
  const [newPrice, setNewPrice] = useState<number>(0)
  const [savingPrice, setSavingPrice] = useState(false)

  // Edit rules modal state
  const [isRulesModalOpen, setIsRulesModalOpen] = useState(false)
  const [rulesForm, setRulesForm] = useState<TariffRules>({
    meterCutoffDay: 25,
    invoiceIssueDay: 28,
    dueDay: 5,
    gracePeriodDays: 5,
    lateInterestRatePercent: 0.05,
    blockRfidDays: 20,
    autoWaiveWithExtensionRequest: true
  })

  // Load config — lấy trực tiếp từ database qua API
  const loadConfig = async () => {
    setLoading(true)
    setLoadError(null)
    try {
      const data = await getTariffConfig()
      setConfig(data)
      setRulesForm(data.rules)
    } catch (err: unknown) {
      setLoadError(err instanceof Error ? err.message : 'Không thể kết nối đến máy chủ để lấy biểu phí')
      setConfig(null)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadConfig()
  }, [])

  // Handle Save Price Edit
  const handleSavePrice = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!editingItem) return
    setSavingPrice(true)
    try {
      const res = await updateTariffPrice(editingItem.id, newPrice)
      setFeedback(res.message)
      setEditingItem(null)
      setTimeout(() => setFeedback(null), 3000)
      await loadConfig()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi cập nhật giá')
    } finally {
      setSavingPrice(false)
    }
  }

  // Handle Toggle Auto Waive
  const handleToggleAutoWaive = async () => {
    if (!config) return
    const updated = {
      ...rulesForm,
      autoWaiveWithExtensionRequest: !rulesForm.autoWaiveWithExtensionRequest
    }
    setRulesForm(updated)
    try {
      await updateTariffRules(updated)
      setFeedback(`Đã ${updated.autoWaiveWithExtensionRequest ? 'kích hoạt' : 'tắt'} chế độ tự động miễn phạt với đơn xin gia hạn!`)
      setTimeout(() => setFeedback(null), 3000)
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi cập nhật')
    }
  }

  // Handle Approve Draft
  const handleApproveDraft = async () => {
    try {
      const res = await approveDraftTariff()
      setFeedback(res.message)
      setTimeout(() => setFeedback(null), 4000)
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi phê duyệt')
    }
  }

  // Export CSV
  const handleExportCSV = () => {
    if (!config) return
    const headers = ['Dịch vụ', 'Tên phân khúc/Bậc', 'Từ', 'Đến', 'Đơn giá', 'Thuế VAT', 'Ngày hiệu lực']
    const all = [
      ...config.managementTariffs,
      ...config.electricityTariffs,
      ...config.waterTariffs,
      ...config.parkingTariffs
    ]
    const rows = all.map(t => [
      t.serviceType,
      `"${t.tierName}"`,
      t.fromUnit,
      t.toUnit ?? 'Không giới hạn',
      t.unitPrice,
      `${t.vatRate}%`,
      t.effectiveDate.slice(0, 10)
    ])
    const csvContent = '\uFEFF' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n')
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `BieuPhi_DinhMuc_RubyCenter.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  if (loadError) {
    return (
      <div className="empty" style={{ padding: '60px', color: '#d9534f' }}>
        <Icon name="wifi_off" />
        <p><strong>Không thể tải biểu phí từ máy chủ</strong></p>
        <p style={{ fontSize: '0.85rem', opacity: 0.8 }}>Hãy chạy backend: <code>dotnet run</code></p>
        <button className="secondary-button" style={{ marginTop: '12px' }} onClick={loadConfig}>
          Thử lại
        </button>
      </div>
    )
  }

  if (loading || !config) {
    return (
      <div className="empty" style={{ padding: '60px' }}>
        <Icon name="hourglass_empty" />
        <p>Đang tải cấu hình biểu phí định mức từ MySQL...</p>
      </div>
    )
  }

  return (
    <>
      {/* 1. Breadcrumbs & Header */}
      <div className="pricing-breadcrumbs">
        <span>TÀI CHÍNH & KẾ TOÁN</span>
        <Icon name="chevron_right" />
        <span>ĐỊNH MỨC BIỂU PHÍ</span>
        <Icon name="chevron_right" />
        <span style={{ color: '#2563eb' }}>SERVICETARIFFS V4.2</span>
      </div>

      <div className="pricing-title-row">
        <h1>
          Biểu Phí Định Mức Dịch Vụ Tòa Nhà
          <span className="building-tag">{buildingName}</span>
        </h1>
        <div className="pricing-header-actions">
          <button className="btn-header-outline" onClick={() => alert('Nhật ký Audit Trail toàn bộ các kỳ điều chỉnh đơn giá đã được đồng bộ.')}>
            <Icon name="history" /> Lịch sử thay đổi
          </button>
          <button className="btn-header-outline" onClick={handleExportCSV}>
            <Icon name="download" /> Xuất bảng kê
          </button>
          <button className="btn-black" onClick={() => alert('Mở trình tạo dự thảo biểu phí kỳ mới')}>
            <Icon name="add_circle" /> Tạo dự thảo biểu phí mới
          </button>
        </div>
      </div>

      {feedback && (
        <div className="alert-box alert-success" style={{ marginBottom: '16px' }}>
          <Icon name="check_circle" /> {feedback}
        </div>
      )}

      {/* 2. Status Cards */}
      <section className="pricing-status-grid">
        {/* Active Tariff Card */}
        <div className="tariff-active-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span className="eyebrow" style={{ color: '#059669' }}>BIỂU PHÍ HIỆU LỰC</span>
            <span className="badge green"><Icon name="verified" /> ACTIVE</span>
          </div>
          <h3>Biểu phí Q3/2026 (Chính thức)</h3>
          <p>Áp dụng từ: <strong>01/07/2026</strong> · 1.682 căn hộ đã gán mã</p>
        </div>

        {/* Draft Tariff Card */}
        <div className="tariff-draft-card">
          <div className="draft-card-top">
            <div>
              <span className="badge amber" style={{ marginBottom: '4px', display: 'inline-block' }}>DỰ THẢO GIÁ MỚI</span>
              <strong>Chờ Trưởng Ban Quản Lý (bql.manager01) ký duyệt số</strong>
              <small>Lập bởi: Kế toán trưởng (ketoan.trang - trang.ketoan@smartbuilding.vn)</small>
            </div>
            <div className="draft-actions">
              <button className="btn-header-outline" style={{ fontSize: '10px', padding: '6px 10px' }} onClick={() => alert('Chênh lệch dự thảo Q4/2026 so với Q3/2026: Tăng +2.8% điện bậc 6, giữ nguyên phí QL.')}>
                <Icon name="compare_arrows" /> Đối chiếu chênh lệch
              </button>
              <button className="btn-header-primary" style={{ fontSize: '10px', padding: '6px 10px' }} onClick={handleApproveDraft}>
                <Icon name="draw" /> Phê duyệt & ký điện tử
              </button>
            </div>
          </div>

          <div className="tariff-stepper">
            <div className="stepper-item completed">
              <strong>1. Khảo sát biến động</strong>
              <div>(Đã chốt)</div>
            </div>
            <div className="stepper-item active">
              <strong>2. Thẩm định BQL</strong>
              <div>(Trưởng BQL)</div>
            </div>
            <div className="stepper-item">
              <strong>3. Niêm yết thông cáo</strong>
              <div>(Cư dân)</div>
            </div>
            <div className="stepper-item">
              <strong>4. Áp dụng</strong>
              <div>(01/10/2026)</div>
            </div>
          </div>
        </div>
      </section>

      {/* 3. Main 4 Core Tariffs */}
      <div style={{ marginBottom: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ fontSize: '15px', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Icon name="tune" /> Định Mức 04 Dịch Vụ Vận Hành Cốt Lõi
        </h2>
        <small style={{ color: '#059669', fontSize: '10px' }}>
          ● Công thức tính cước tự động kích hoạt vào lúc 00:00 ngày đầu tháng
        </small>
      </div>

      <section className="core-tariffs-grid">
        {/* Block 1: Phí Dịch Vụ Quản Lý & Vận Hành */}
        <article className="tariff-card">
          <div className="tariff-card-header">
            <div className="tariff-card-header-left">
              <div className="tariff-icon-badge blue">
                <Icon name="apartment" />
              </div>
              <div>
                <h3>Phí Dịch Vụ Quản Lý & Vận Hành</h3>
                <small>Tính theo diện tích thông thủy / tháng</small>
              </div>
            </div>
            <span className="badge blue">VAT: 10% Tách biệt</span>
          </div>

          <div className="tariff-card-rows">
            {config.managementTariffs.map((item) => (
              <div className="tariff-price-row" key={item.id}>
                <div className="tariff-row-desc">
                  <strong>{item.tierName}</strong>
                  <small>
                    {item.tierName.includes('Penthouse')
                      ? 'Gồm thẻ thang máy VIP không dừng & sảnh riêng'
                      : item.tierName.includes('Shophouse')
                      ? 'Bao gồm diện tích hành lang quảng trường kinh doanh'
                      : 'Áp dụng cho 1.580 căn tầng 03 - tầng 32'}
                  </small>
                </div>
                <div className="tariff-price-tag">
                  {item.unitPrice.toLocaleString('vi-VN')} đ <small>/m²</small>
                </div>
              </div>
            ))}
          </div>

          <div className="tariff-card-footer">
            <span>Chu kỳ thanh toán: Tháng / Quý (Giảm 3% nếu đóng năm)</span>
            <button className="btn-card-action" onClick={() => {
              setEditingItem(config.managementTariffs[0])
              setNewPrice(config.managementTariffs[0].unitPrice)
            }}>
              <Icon name="edit" /> Sửa hệ số diện tích
            </button>
          </div>
        </article>

        {/* Block 2: Điện Bậc Thang Sinh Hoạt (EVN Matrix) */}
        <article className="tariff-card">
          <div className="tariff-card-header">
            <div className="tariff-card-header-left">
              <div className="tariff-icon-badge amber">
                <Icon name="bolt" />
              </div>
              <div>
                <h3>Điện Bậc Thang Sinh Hoạt (EVN Matrix)</h3>
                <small>Định mức theo quy định Bộ Công Thương</small>
              </div>
            </div>
            <span className="badge amber">Hao hụt TBA: +2.8%</span>
          </div>

          <div className="tariff-card-rows" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
            {config.electricityTariffs.map((item, idx) => (
              <div className="tariff-price-row" key={item.id}>
                <div className="tariff-row-desc">
                  <strong>Bậc {idx + 1}</strong>
                  <small>{item.tierName.replace(`Bậc ${idx + 1}`, '')}</small>
                </div>
                <div className="tariff-price-tag">
                  {item.unitPrice.toLocaleString('vi-VN')} đ
                </div>
              </div>
            ))}
          </div>

          <div className="tariff-card-footer">
            <span>Công tơ thông minh LoRaWan chốt số 00:00 ngày 25</span>
            <button className="btn-card-action" onClick={() => {
              setEditingItem(config.electricityTariffs[config.electricityTariffs.length - 1])
              setNewPrice(config.electricityTariffs[config.electricityTariffs.length - 1].unitPrice)
            }}>
              <Icon name="refresh" /> Cập nhật bảng EVN
            </button>
          </div>
        </article>

        {/* Block 3: Biểu Giá Nước Sạch & Nước Thải */}
        <article className="tariff-card">
          <div className="tariff-card-header">
            <div className="tariff-card-header-left">
              <div className="tariff-icon-badge green">
                <Icon name="water_drop" />
              </div>
              <div>
                <h3>Biểu Giá Nước Sạch & Nước Thải</h3>
                <small>Tính theo nhân khẩu đăng ký cư trú (m³/người)</small>
              </div>
            </div>
            <span className="badge green">Phí BVMT: 10%</span>
          </div>

          <div className="tariff-card-rows">
            {config.waterTariffs.map((item) => (
              <div className="tariff-price-row" key={item.id}>
                <div className="tariff-row-desc">
                  <strong>{item.tierName}</strong>
                  <small>
                    {item.unitPrice === 8500
                      ? 'Phục vụ nhu cầu sinh hoạt thiết yếu tiêu chuẩn'
                      : item.unitPrice === 13000
                      ? 'Hỗ trợ khuyến khích sử dụng nước tiết kiệm'
                      : 'Mức tiêu thụ cao / Kinh doanh thương mại ẩm thực'}
                  </small>
                </div>
                <div className="tariff-price-tag">
                  {item.unitPrice.toLocaleString('vi-VN')} đ <small>/m³</small>
                </div>
              </div>
            ))}
          </div>

          <div className="tariff-card-footer">
            <span>Căn chưa đăng ký tạm trú: Mặc định tính định mức 2 người</span>
            <button className="btn-card-action" onClick={() => alert('Đã đồng bộ dữ liệu nhân khẩu từ phân hệ Cư dân!')}>
              <Icon name="sync" /> Đồng bộ nhân khẩu
            </button>
          </div>
        </article>

        {/* Block 4: Biểu Phí Giữ Xe & BÃI ĐỖ RFID */}
        <article className="tariff-card">
          <div className="tariff-card-header">
            <div className="tariff-card-header-left">
              <div className="tariff-icon-badge indigo">
                <Icon name="directions_car" />
              </div>
              <div>
                <h3>Biểu Phí Giữ Xe & BÃI ĐỖ RFID</h3>
                <small>Kiểm soát Barier thẻ chíp tự động 3 tầng hầm (B1-B2-B3)</small>
              </div>
            </div>
            <span className="badge blue">2.100 Chỗ đỗ</span>
          </div>

          <div className="tariff-card-rows" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px' }}>
            {config.parkingTariffs.map((item) => (
              <div className="tariff-price-row" key={item.id}>
                <div className="tariff-row-desc">
                  <strong>{item.tierName}</strong>
                  <small>
                    {item.tierName.includes('Suất 1')
                      ? 'Định mức ưu tiên 1 xe/căn'
                      : item.tierName.includes('Suất phụ')
                      ? 'Áp dụng khi hầm còn chỗ'
                      : item.tierName.includes('xăng')
                      ? 'Tối đa 2 xe / căn hộ'
                      : 'Gồm chi phí lưu xe & sạc thông minh'}
                  </small>
                </div>
                <div className="tariff-price-tag">
                  {item.unitPrice.toLocaleString('vi-VN')} đ <small>/tháng</small>
                </div>
              </div>
            ))}
          </div>

          <div className="tariff-card-footer">
            <span>Khách vãng lai: 5.000 đ/lượt ban ngày + 20.000 đ/đêm</span>
            <button className="btn-card-action" onClick={() => {
              setEditingItem(config.parkingTariffs[0])
              setNewPrice(config.parkingTariffs[0].unitPrice)
            }}>
              <Icon name="settings" /> Cấu hình quỹ vé
            </button>
          </div>
        </article>
      </section>

      {/* 4. Quy Tắc Ân Hạn, Lãi Quá Hạn & Chặn Tiện Ích Tự Động */}
      <section className="rules-section">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <span className="eyebrow" style={{ color: '#2563eb' }}>CHẾ TÀI VẬN HÀNH</span>
            <h2 style={{ fontSize: '15px', margin: '2px 0 0' }}>
              Quy Tắc Ân Hạn, Lãi Quá Hạn & Chặn Tiện Ích Tự Động
            </h2>
          </div>
          <button className="btn-header-outline" style={{ fontSize: '10px', padding: '6px 10px' }} onClick={() => setIsRulesModalOpen(true)}>
            <Icon name="tune" /> Thiết lập theo Nghị quyết BQT
          </button>
        </div>

        <div className="rules-grid">
          {/* Box 1 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="schedule" />
              <span className="rule-box-tag">Ngày {rulesForm.meterCutoffDay}</span>
            </div>
            <strong>Chốt số đồng hồ (Cut-off)</strong>
            <small>Đồng bộ tự động chỉ số công tơ điện nước thông minh toàn bộ tháp R1 & R2.</small>
          </div>

          {/* Box 2 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="forward_to_inbox" />
              <span className="rule-box-tag">Ngày {rulesForm.invoiceIssueDay}</span>
            </div>
            <strong>Phát hành Hóa đơn điện tử</strong>
            <small>Gửi thông báo đẩy Resident SuperApp, SMS Brandname và Zalo ZNS cho chủ hộ.</small>
          </div>

          {/* Box 3 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="event_available" />
              <span className="rule-box-tag">Ngày {rulesForm.dueDay.toString().padStart(2, '0')}</span>
            </div>
            <strong>Hạn chót thanh toán (Due Date)</strong>
            <small>Ngày đến hạn chuẩn định kỳ của tháng kế tiếp, cổng VietQR VA mở 24/7.</small>
          </div>

          {/* Box 4 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="timelapse" />
              <span className="rule-box-tag green">+{rulesForm.gracePeriodDays.toString().padStart(2, '0')} Ngày</span>
            </div>
            <strong>Thời gian ân hạn (Grace Period)</strong>
            <small>Từ ngày 06 đến hết ngày 10: Nhắc nợ tự động thân thiện, chưa tính lãi phạt trễ hạn.</small>
          </div>

          {/* Box 5 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="percent" />
              <span className="rule-box-tag red">{rulesForm.lateInterestRatePercent}% / ngày</span>
            </div>
            <strong>Lãi phạt quá hạn</strong>
            <small>Bắt đầu tính từ ngày 11 trên số dư gốc còn nợ. Lũy kế nhập vào kỳ phí kế tiếp.</small>
          </div>

          {/* Box 6 */}
          <div className="rule-box">
            <div className="rule-box-header">
              <Icon name="no_crash" />
              <span className="rule-box-tag red">&gt;= {rulesForm.blockRfidDays} Ngày</span>
            </div>
            <strong>Tạm khóa RFID Thẻ xe hầm</strong>
            <small>Hệ thống IoT barrier tự động đình chỉ lượt xe ra vào khi quá hạn 20 ngày.</small>
          </div>
        </div>

        {/* Toggle Bar */}
        <div className="rule-toggle-bar">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Icon name="verified_user" />
            <span>
              <strong>Tự động miễn phạt với cư dân gửi đơn gia hạn:</strong> Áp dụng cho căn hộ công tác nước ngoài có phê duyệt trực tuyến của Ban Quản Trị.
            </span>
          </div>
          <button
            className={`badge ${rulesForm.autoWaiveWithExtensionRequest ? 'green' : 'amber'}`}
            style={{ cursor: 'pointer', padding: '6px 12px', border: 'none' }}
            onClick={handleToggleAutoWaive}
          >
            {rulesForm.autoWaiveWithExtensionRequest ? 'Kích hoạt Regime' : 'Tắt'}
          </button>
        </div>
      </section>

      {/* 5. Bottom Section: Audit Trail & Forecast */}
      <section className="pricing-bottom-grid">
        {/* Left: Lịch sử biến động đơn giá */}
        <article className="panel">
          <div className="panel-title">
            <div>
              <span className="eyebrow">LƯU VẾT AUDIT TRAIL</span>
              <h2>Lịch Sử Biến Động Đơn Giá Các Kỳ Gần Nhất</h2>
            </div>
            <span className="badge blue">Chuẩn SOX</span>
          </div>

          <table className="audit-table">
            <thead>
              <tr>
                <th>KỲ ÁP DỤNG</th>
                <th>HẠNG MỤC ĐIỀU CHỈNH</th>
                <th>GIÁ CŨ</th>
                <th>GIÁ MỚI</th>
                <th>BIẾN ĐỘNG</th>
                <th>NGƯỜI PHÊ DUYỆT</th>
              </tr>
            </thead>
            <tbody>
              {config.auditLogs.map((log, idx) => (
                <tr key={idx}>
                  <td><strong>{log.period}</strong></td>
                  <td>{log.itemName}</td>
                  <td style={{ color: '#64748b' }}>{log.oldPrice}</td>
                  <td><strong>{log.newPrice}</strong></td>
                  <td>
                    <span className={`badge ${log.changePercent.includes('+') ? 'red' : 'green'}`}>
                      {log.changePercent}
                    </span>
                  </td>
                  <td><small>{log.approvedBy}</small></td>
                </tr>
              ))}
            </tbody>
          </table>
        </article>

        {/* Right: Dự Báo Doanh Thu Vận Hành */}
        <article className="panel">
          <div className="panel-title">
            <div>
              <span className="eyebrow">DỰ TOÁN THU CHI</span>
              <h2>Dự Báo Doanh Thu Vận Hành</h2>
            </div>
            <span className="badge green">+1.8% QoQ</span>
          </div>
          <p style={{ margin: '4px 0 10px', fontSize: '10px', color: '#64748b' }}>
            Ước tính dòng tiền thu từ 1.682 căn hộ theo biểu phí dự thảo mới Q4/2026.
          </p>

          <div className="forecast-card-body">
            <div className="forecast-row">
              <span>Doanh thu Phí Quản lý:</span>
              <strong>{config.forecast.managementRevenue.toLocaleString('vi-VN')} đ</strong>
            </div>
            <div className="forecast-row">
              <span>Doanh thu Bãi đỗ xe:</span>
              <strong>{config.forecast.parkingRevenue.toLocaleString('vi-VN')} đ</strong>
            </div>
            <div className="forecast-row">
              <span>Thu hộ Điện & Nước sinh hoạt:</span>
              <strong>{config.forecast.utilityRevenue.toLocaleString('vi-VN')} đ</strong>
            </div>

            <div className="forecast-total">
              <div>
                <span>TỔNG DỰ TOÁN / THÁNG</span>
                <small style={{ display: 'block', color: '#64748b', fontSize: '9px' }}>Dựa trên tỷ lệ lấp đầy 94.2%</small>
              </div>
              <strong>{config.forecast.totalMonthlyForecast.toLocaleString('vi-VN')} đ</strong>
            </div>
          </div>
        </article>
      </section>

      {/* 6. Modal Sửa Đơn Giá Biểu Phí */}
      {editingItem && (
        <div className="modal-overlay" onClick={() => !savingPrice && setEditingItem(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Cập nhật đơn giá: {editingItem.tierName}</h2>
              <button className="close-btn" onClick={() => !savingPrice && setEditingItem(null)}>
                <Icon name="close" />
              </button>
            </div>
            <form onSubmit={handleSavePrice}>
              <div className="modal-body">
                <div className="form-group full-width">
                  <label>Đơn giá hiện hành (VND)</label>
                  <input
                    type="number"
                    required
                    min={0}
                    step={1}
                    value={newPrice}
                    onChange={(e) => setNewPrice(Number(e.target.value))}
                  />
                  <small style={{ color: '#64748b', fontSize: '10px', marginTop: '4px' }}>
                    Đơn giá này sẽ được lưu trực tiếp vào CSDL và áp dụng cho các kỳ hóa đơn phát hành tiếp theo.
                  </small>
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setEditingItem(null)} disabled={savingPrice}>
                  Hủy
                </button>
                <button type="submit" className="action-add-btn" disabled={savingPrice}>
                  {savingPrice ? 'Đang lưu...' : 'Lưu đơn giá mới'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 7. Modal Sửa Quy Tắc Chế Tài Vận Hành */}
      {isRulesModalOpen && (
        <div className="modal-overlay" onClick={() => setIsRulesModalOpen(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Thiết lập Quy Tắc & Chế Tài Vận Hành</h2>
              <button className="close-btn" onClick={() => setIsRulesModalOpen(false)}>
                <Icon name="close" />
              </button>
            </div>
            <form onSubmit={async (e) => {
              e.preventDefault()
              try {
                await updateTariffRules(rulesForm)
                setFeedback('Đã cập nhật quy tắc vận hành thành công!')
                setIsRulesModalOpen(false)
                setTimeout(() => setFeedback(null), 3000)
              } catch (err: unknown) {
                alert(err instanceof Error ? err.message : 'Lỗi cập nhật')
              }
            }}>
              <div className="modal-body">
                <div className="form-grid">
                  <div className="form-group">
                    <label>Ngày chốt số đồng hồ (Cut-off)</label>
                    <input
                      type="number"
                      min={1}
                      max={31}
                      value={rulesForm.meterCutoffDay}
                      onChange={(e) => setRulesForm({ ...rulesForm, meterCutoffDay: Number(e.target.value) })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Ngày phát hành hóa đơn</label>
                    <input
                      type="number"
                      min={1}
                      max={31}
                      value={rulesForm.invoiceIssueDay}
                      onChange={(e) => setRulesForm({ ...rulesForm, invoiceIssueDay: Number(e.target.value) })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Ngày hạn chót thanh toán (Due Day)</label>
                    <input
                      type="number"
                      min={1}
                      max={31}
                      value={rulesForm.dueDay}
                      onChange={(e) => setRulesForm({ ...rulesForm, dueDay: Number(e.target.value) })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Thời gian ân hạn (Grace Period - ngày)</label>
                    <input
                      type="number"
                      min={0}
                      max={30}
                      value={rulesForm.gracePeriodDays}
                      onChange={(e) => setRulesForm({ ...rulesForm, gracePeriodDays: Number(e.target.value) })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Lãi phạt quá hạn (% / ngày)</label>
                    <input
                      type="number"
                      step={0.01}
                      min={0}
                      value={rulesForm.lateInterestRatePercent}
                      onChange={(e) => setRulesForm({ ...rulesForm, lateInterestRatePercent: Number(e.target.value) })}
                    />
                  </div>

                  <div className="form-group">
                    <label>Tạm khóa RFID Thẻ xe (sau số ngày trễ)</label>
                    <input
                      type="number"
                      min={1}
                      value={rulesForm.blockRfidDays}
                      onChange={(e) => setRulesForm({ ...rulesForm, blockRfidDays: Number(e.target.value) })}
                    />
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setIsRulesModalOpen(false)}>
                  Hủy
                </button>
                <button type="submit" className="action-add-btn">
                  Lưu cấu hình quy tắc
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
