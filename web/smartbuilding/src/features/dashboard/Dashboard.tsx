import { useEffect, useState } from 'react'
import { metrics as defaultMetrics, residentRequests as defaultRequests, workOrders as defaultWorkOrders } from '../../data/dashboard'
import { Icon } from '../../components/Icon'
import {
  getResidentMetrics,
  getComplaints,
  getInvoiceSummary,
  type ResidentSummaryMetrics,
  type ComplaintItem,
  type InvoiceSummary
} from '../../data/api'

export function Dashboard({ query, buildingId }: { query: string; buildingId?: string }) {
  const [resMetrics, setResMetrics] = useState<ResidentSummaryMetrics | null>(null)
  const [complaints, setComplaints] = useState<ComplaintItem[]>([])
  const [invSummary, setInvSummary] = useState<InvoiceSummary | null>(null)

  useEffect(() => {
    getResidentMetrics(buildingId)
      .then(data => setResMetrics(data))
      .catch(() => {})

    getComplaints(buildingId !== 'All' ? buildingId : undefined)
      .then(data => setComplaints(data))
      .catch(() => {})

    getInvoiceSummary(undefined, undefined, buildingId !== 'All' ? buildingId : undefined)
      .then((data: InvoiceSummary) => setInvSummary(data))
      .catch(() => {})
  }, [buildingId])

  // Computed live metrics with fallback to defaults
  const totalApartments = resMetrics ? resMetrics.totalApartments.toString() : defaultMetrics[0].value
  const occupancyRate = resMetrics
    ? `${((resMetrics.occupiedApartments / (resMetrics.totalApartments || 1)) * 100).toFixed(1)}%`
    : '96.8%'

  const paidAmountText = invSummary
    ? `${(invSummary.paidAmount / 1000000000).toFixed(2)} tỷ`
    : defaultMetrics[1].value

  const technicalCount = complaints.length
    ? complaints.filter(c => c.status !== 'Resolved' && c.status !== 'Closed').length.toString()
    : defaultMetrics[2].value

  const overdueCount = invSummary
    ? invSummary.overdueCount.toString()
    : defaultMetrics[3].value

  const liveMetrics = [
    { icon: 'apartment', tone: 'blue', label: 'Tổng căn hộ', value: totalApartments, note: `${occupancyRate} đã lấp đầy`, trend: 'trending_up' },
    { icon: 'payments', tone: 'green', label: 'Thu phí tháng 09', value: paidAmountText, note: '84,2% đã thu', trend: 'trending_up' },
    { icon: 'engineering', tone: 'amber', label: 'Yêu cầu sự cố', value: technicalCount, note: `${technicalCount} đang xử lý`, trend: 'schedule' },
    { icon: 'warning', tone: 'red', label: 'Hóa đơn quá hạn', value: overdueCount, note: 'Theo dõi cước phát sinh', trend: 'priority_high' },
  ]

  // Live resident requests from database complaints
  const liveRequests = complaints.length > 0
    ? complaints.slice(0, 5).map(c => ({
        unit: c.apartmentNumber ? `Căn ${c.apartmentNumber}` : 'Căn hộ',
        name: c.residentName || 'Cư dân',
        detail: c.title,
        time: c.createdAt ? new Date(c.createdAt).toLocaleDateString('vi-VN') : 'Gần đây',
        status: c.status === 'Pending' ? 'Chờ duyệt' : c.status === 'Processing' ? 'Đang xử lý' : c.status === 'Resolved' ? 'Đã hoàn tất' : c.status,
        tone: c.status === 'Pending' ? 'amber' : c.status === 'Processing' ? 'blue' : 'green'
      }))
    : defaultRequests

  const filteredRequests = liveRequests.filter((item) =>
    `${item.unit} ${item.name} ${item.detail}`.toLowerCase().includes(query.toLowerCase())
  )

  const liveWorkOrders = complaints.length > 0
    ? complaints.slice(0, 4).map(c => ({
        code: c.id,
        title: c.title,
        location: `Căn ${c.apartmentNumber} · ${c.category}`,
        status: c.status === 'Pending' ? 'Chờ phân công' : c.status === 'Processing' ? 'Đang xử lý' : c.status === 'Resolved' ? 'Đã xử lý' : 'Đã đóng'
      }))
    : defaultWorkOrders

  return (
    <>
      <section className="metric-grid">
        {liveMetrics.map((item) => (
          <article className="metric-card" key={item.label}>
            <span className={`metric-icon ${item.tone}`}><Icon name={item.icon} /></span>
            <label>{item.label}</label>
            <strong>{item.value}</strong>
            <small className={item.tone}><Icon name={item.trend} />{item.note}</small>
          </article>
        ))}
      </section>

      <section className="insight-grid">
        <article className="panel finance">
          <PanelTitle eyebrow="TÀI CHÍNH" title="Tiến độ thu phí" />
          <div className="amount">
            <strong>{invSummary ? `${(invSummary.paidAmount).toLocaleString('vi-VN')} đ` : '2.860.000.000 đ'}</strong>
            <span>trên {invSummary ? `${(invSummary.totalAmount).toLocaleString('vi-VN')} đ` : '3.398.000.000 đ'}</span>
          </div>
          <div className="progress"><i /></div>
          <div className="chart">
            {[38, 52, 45, 70, 60, 86, 76].map((height, index) => (
              <i key={index} className={index === 6 ? 'today' : ''} style={{ height: `${height}%` }} />
            ))}
          </div>
          <div className="chart-labels">
            <span>T2</span><span>T3</span><span>T4</span><span>T5</span><span>T6</span><span>T7</span><span>CN</span>
          </div>
        </article>

        <article className="panel occupancy">
          <PanelTitle eyebrow="CÔNG SUẤT" title="Trạng thái căn hộ" />
          <div className="donut">
            <div>
              <strong>{occupancyRate}</strong>
              <span>Đã lấp đầy</span>
            </div>
          </div>
          <div className="legend">
            <span><i className="occupied" />Đang ở <b>{resMetrics ? resMetrics.occupiedApartments : '1.208'}</b></span>
            <span><i className="available" />Còn trống <b>{resMetrics ? resMetrics.availableApartments : '28'}</b></span>
            <span><i className="maintenance" />Bảo trì <b>12</b></span>
          </div>
        </article>

        <article className="panel systems">
          <PanelTitle eyebrow="HỆ THỐNG" title="Trạm vận hành" />
          <span className="online"><i />TRỰC TUYẾN</span>
          <Node icon="dns" title="API Gateway Central" note="Kết nối MySQL ổn định (28 bảng)" rate="99,98%" />
          <Node icon="videocam" title="Hệ thống thẻ xe RFID" note="Đã đồng bộ cổng kiểm soát" rate="100%" />
          <button className="link-button">Xem bảng điều khiển hệ thống <Icon name="arrow_forward" /></button>
        </article>
      </section>

      <section className="content-grid">
        <article className="panel">
          <PanelTitle eyebrow="CƯ DÂN" title="Phản ánh & Yêu cầu từ Mobile" action="Xem tất cả" />
          {filteredRequests.map((item, idx) => (
            <div className="resident-row" key={`${item.unit}-${idx}`}>
              <span className="resident-avatar">{item.name ? item.name[0] : 'C'}</span>
              <div>
                <strong>{item.name}</strong>
                <small>{item.detail}</small>
              </div>
              <div className="unit">
                <strong>{item.unit}</strong>
                <small>{item.time}</small>
              </div>
              <span className={`badge ${item.tone}`}>{item.status}</span>
              <Icon name="chevron_right" />
            </div>
          ))}
          {!filteredRequests.length && <p className="empty">Không tìm thấy yêu cầu phù hợp.</p>}
        </article>

        <article className="panel">
          <PanelTitle eyebrow="KỸ THUẬT" title="Phiếu công việc sự cố (Work Orders)" />
          {liveWorkOrders.map((item) => (
            <div className="work-order" key={item.code}>
              <span className="work-icon"><Icon name="construction" /></span>
              <div>
                <strong>{item.title}</strong>
                <small>{item.code} · {item.location}</small>
              </div>
              <span className="badge blue">{item.status}</span>
            </div>
          ))}
        </article>
      </section>
    </>
  )
}

function PanelTitle({ eyebrow, title, action }: { eyebrow: string; title: string; action?: string }) {
  return (
    <div className="panel-title">
      <div>
        <span className="eyebrow">{eyebrow}</span>
        <h2>{title}</h2>
      </div>
      {action ? <button className="link-button">{action} <Icon name="arrow_forward" /></button> : <button className="more"><Icon name="more_horiz" /></button>}
    </div>
  )
}

function Node({ icon, title, note, rate }: { icon: string; title: string; note: string; rate: string }) {
  return (
    <div className="node">
      <span><Icon name={icon} /></span>
      <div><strong>{title}</strong><small>{note}</small></div>
      <b>{rate}</b>
    </div>
  )
}

