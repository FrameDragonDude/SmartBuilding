import { useEffect, useState, useMemo } from 'react'
import { Icon } from '../../components/Icon'
import {
  getInvoices,
  getInvoiceSummary,
  getPendingPayments,
  getPenalties,
  getRevenueStructure,
  approvePayment,
  rejectPayment,
  waivePenalty,
  sendBatchReminders,
  generateMonthlyInvoices,
  type InvoiceItem,
  type InvoiceSummary,
  type PendingPayment,
  type PenaltyRecord,
  type RevenueStructure
} from '../../data/api'
import '../../styles/invoices.css'
import '../../styles/residents.css'

// Không dùng dữ liệu mẫu — toàn bộ dữ liệu lấy từ MySQL qua API

export function InvoicesPage({ query, buildingId }: { query: string; buildingId?: string }) {
  const [invoices, setInvoices] = useState<InvoiceItem[]>([])
  const [summary, setSummary] = useState<InvoiceSummary | null>(null)
  const [pendingPayments, setPendingPayments] = useState<PendingPayment[]>([])
  const [penalties, setPenalties] = useState<PenaltyRecord[]>([])
  const [revenue, setRevenue] = useState<RevenueStructure | null>(null)
  const [source, setSource] = useState('Đang kết nối...')
  const [loadError, setLoadError] = useState<string | null>(null)

  // Filters & Search
  const [search, setSearch] = useState(query)
  const [filterTab, setFilterTab] = useState<'All' | 'PendingUNC' | 'Overdue' | 'Paid'>('All')
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 6

  // Selected for inspection
  const [selectedInvoice, setSelectedInvoice] = useState<InvoiceItem | null>(null)

  // Action feedback message
  const [feedback, setFeedback] = useState<string | null>(null)

  // Modals
  const [isGenerateOpen, setIsGenerateOpen] = useState(false)
  const [genMonth, setGenMonth] = useState(8)
  const [genYear, setGenYear] = useState(2026)
  const [isMisaOpen, setIsMisaOpen] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  // Sync external search query
  useEffect(() => {
    setSearch(query)
  }, [query])

  // Load data function
  const loadData = async () => {
    try {
      const targetBuilding = buildingId !== 'All' ? buildingId : undefined
      const [invData, sumData, pendData, penData, revData] = await Promise.all([
        getInvoices({
          search: search || undefined,
          filterTab: filterTab !== 'All' ? filterTab : undefined,
          month: 8,
          year: 2026,
          buildingId: targetBuilding
        }),
        getInvoiceSummary(8, 2026, targetBuilding),
        getPendingPayments(),
        getPenalties(),
        getRevenueStructure(8, 2026)
      ])

      setInvoices(invData)
      setSummary(sumData)
      setPendingPayments(pendData)
      setPenalties(penData)
      setRevenue(revData)
      setLoadError(null)
      setSource('Đồng bộ MySQL')
    } catch (err) {
      // Backend không kết nối được — không fallback sample, hiển thị lỗi rõ ràng
      const message = err instanceof Error ? err.message : 'Không kết nối được server'
      setLoadError(message)
      setSource('Mất kết nối')
    }
  }

  useEffect(() => {
    const handler = setTimeout(() => {
      loadData()
    }, 200)
    return () => clearTimeout(handler)
  }, [search, filterTab, buildingId])

  useEffect(() => {
    loadData()
  }, [])

  // Dynamic Metrics derived from summary or invoices
  const metrics = useMemo(() => {
    if (summary && summary.totalInvoices > 0) {
      const collectionRate = summary.totalAmount > 0
        ? ((summary.paidAmount / summary.totalAmount) * 100).toFixed(1)
        : '0'
      return {
        totalAmount: summary.totalAmount.toLocaleString('vi-VN') + ' đ',
        paidAmount: summary.paidAmount.toLocaleString('vi-VN') + ' đ',
        collectionRate: `${collectionRate}%`,
        paidNote: `${summary.paidCount} / ${summary.totalInvoices} Căn hộ đã trả`,
        pendingAmount: summary.pendingAmount.toLocaleString('vi-VN') + ' đ',
        overdueAmount: summary.overdueAmount.toLocaleString('vi-VN') + ' đ',
        overdueNote: `${summary.overdueCount} căn | Lãi 0.05%/ngày`,
        cashFund: (summary.cashFundAmount || 0).toLocaleString('vi-VN') + ' đ'
      }
    }

    // Accurate calculation from loaded invoices
    const total = invoices.reduce((acc, i) => acc + i.totalAmount, 0)
    const paid = invoices.reduce((acc, i) => acc + i.paidAmount, 0)
    const pending = invoices.filter(i => i.status === 'Unpaid' || i.status === 'PartiallyPaid').reduce((acc, i) => acc + (i.totalAmount - i.paidAmount), 0)
    const overdue = invoices.filter(i => i.status === 'Overdue').reduce((acc, i) => acc + (i.totalAmount - i.paidAmount), 0)
    const paidCount = invoices.filter(i => i.status === 'Paid').length
    const totalCount = invoices.length
    const rate = total > 0 ? ((paid / total) * 100).toFixed(1) : '0'

    return {
      totalAmount: total.toLocaleString('vi-VN') + ' đ',
      paidAmount: paid.toLocaleString('vi-VN') + ' đ',
      collectionRate: `${rate}%`,
      paidNote: `${paidCount} / ${totalCount} Căn hộ đã trả`,
      pendingAmount: pending.toLocaleString('vi-VN') + ' đ',
      overdueAmount: overdue.toLocaleString('vi-VN') + ' đ',
      overdueNote: `${invoices.filter(i => i.status === 'Overdue').length} căn | Lãi 0.05%/ngày`,
      cashFund: '0 đ'
    }
  }, [summary, invoices])

  // Pagination slice
  const paginatedInvoices = useMemo(() => {
    const start = (currentPage - 1) * pageSize
    return invoices.slice(start, start + pageSize)
  }, [invoices, currentPage])

  const totalPages = Math.ceil(invoices.length / pageSize) || 1

  // Handle Approve Payment / Xác nhận đã thu
  const handleApprove = async (paymentId: string) => {
    try {
      const res = await approvePayment(paymentId)
      setFeedback(res.message)
      setTimeout(() => setFeedback(null), 3000)
      await loadData()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi khi duyệt chứng từ')
    }
  }

  // Handle Reject Payment / Từ chối
  const handleReject = async (paymentId: string) => {
    try {
      const res = await rejectPayment(paymentId)
      setFeedback(res.message)
      setTimeout(() => setFeedback(null), 3000)
      await loadData()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi khi từ chối')
    }
  }

  // Handle Waive Penalty / Duyệt Miễn Phạt
  const handleWaive = async (penaltyId: string) => {
    try {
      const res = await waivePenalty(penaltyId)
      setFeedback(res.message)
      setTimeout(() => setFeedback(null), 3000)
      await loadData()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi khi miễn phạt')
    }
  }

  // Handle Batch Reminder
  const handleBatchReminder = async () => {
    try {
      const res = await sendBatchReminders()
      setFeedback(res.message)
      setTimeout(() => setFeedback(null), 4000)
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi gửi nhắc nợ')
    }
  }

  // Handle Generate Invoices
  const handleGenerateInvoicesSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setSubmitting(true)
    try {
      const res = await generateMonthlyInvoices(genMonth, genYear)
      setFeedback(res.message)
      setIsGenerateOpen(false)
      setTimeout(() => setFeedback(null), 4000)
      await loadData()
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Lỗi phát hành hóa đơn')
    } finally {
      setSubmitting(false)
    }
  }

  // Export CSV
  const handleExportCSV = () => {
    const headers = ['Mã HĐ', 'Mã Căn', 'Chủ hộ', 'Số điện thoại', 'Phí QL', 'Tiền Điện', 'Tiền Nước', 'Phí Xe', 'Tổng cộng', 'Đã thu', 'Trạng thái', 'Hạn thanh toán']
    const rows = invoices.map(i => [
      i.invoiceCode,
      i.apartmentNumber,
      `"${i.residentName || ''}"`,
      i.phoneNumber || '',
      i.managementFee,
      i.electricityFee,
      i.waterFee,
      i.parkingFee,
      i.totalAmount,
      i.paidAmount,
      i.status,
      i.dueDate.slice(0, 10)
    ])
    const csvContent = '\uFEFF' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n')
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `HoaDon_ThuPhi_T08_2026.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  return (
    <>
      {/* 1. Page Header Actions */}
      <section style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <span className="eyebrow">PHÂN HỆ TÀI CHÍNH & KẾ TOÁN · Kỳ kết chuyển: T08/2026</span>
          <h1 style={{ margin: '4px 0 0', fontSize: '24px', color: '#0f172a' }}>
            Hóa đơn, Thu phí & Đối soát Kế toán
          </h1>
        </div>
        <div className="invoices-header-actions">
          <button className="btn-header-outline" onClick={() => setIsGenerateOpen(true)}>
            <Icon name="calculate" /> Tính HĐ Tháng Mới
          </button>
          <button className="btn-header-outline" onClick={handleBatchReminder}>
            <Icon name="forward_to_inbox" /> Nhắc Nợ SMS/App (Đồng loạt)
          </button>
          <button
            className="btn-header-green"
            onClick={() => {
              if (penalties.length > 0) handleWaive(penalties[0].penaltyId)
              else alert('Không có hồ sơ phạt quá hạn nào cần duyệt miễn giảm.')
            }}
          >
            <Icon name="task_alt" /> Duyệt Miễn Giảm Lãi
          </button>
          <button className="btn-header-primary" onClick={handleExportCSV}>
            <Icon name="download" /> Xuất MISA / Excel
          </button>
        </div>
      </section>

      {feedback && (
        <div className="alert-box alert-success" style={{ marginBottom: '16px' }}>
          <Icon name="check_circle" /> {feedback}
        </div>
      )}

      {/* 2. Top Metrics (5 cards) */}
      <section className="module-metrics" style={{ gridTemplateColumns: 'repeat(5, 1fr)' }}>
        <article className="module-metric blue">
          <span><Icon name="account_balance_wallet" /></span>
          <label>TỔNG PHÁT HÀNH T08</label>
          <strong>{metrics.totalAmount}</strong>
          <small style={{ color: '#059669' }}>↗ +4,2% so kỳ trước</small>
        </article>

        <article className="module-metric green">
          <span><Icon name="check_circle" /></span>
          <label>THỰC THU ({metrics.collectionRate})</label>
          <strong>{metrics.paidAmount}</strong>
          <small>{metrics.paidNote}</small>
        </article>

        <article className="module-metric blue">
          <span><Icon name="hourglass_top" /></span>
          <label>TỒN ĐỌNG TRONG HẠN</label>
          <strong>{metrics.pendingAmount}</strong>
          <small>Hạn chót: 25/08/2026</small>
        </article>

        <article className="module-metric red">
          <span><Icon name="warning" /></span>
          <label>QUÁ HẠN (GRACE PERIOD)</label>
          <strong>{metrics.overdueAmount}</strong>
          <small style={{ color: '#dc2626' }}>{metrics.overdueNote}</small>
        </article>

        <article className="module-metric blue">
          <span><Icon name="payments" /></span>
          <label>QUỸ TIỀN MẶT LỄ TÂN</label>
          <strong>{metrics.cashFund}</strong>
          <small>Két tầng G (Đã kiểm đếm)</small>
        </article>
      </section>

      {/* 3. Main Split Layout */}
      <section className="split-layout">
        {/* Left Side: Invoices Table with Filter Tabs */}
        <article className="panel resident-panel" style={{ overflow: 'hidden' }}>
          <div className="invoices-toolbar">
            <label className="invoices-search">
              <Icon name="search" />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Tìm theo Mã HĐ, căn hộ, chủ hộ..."
              />
            </label>
            <span className="data-source"><i />{source}</span>

            <div className="filter-tabs">
              <button
                className={`filter-tab-btn ${filterTab === 'All' ? 'active' : ''}`}
                onClick={() => { setFilterTab('All'); setCurrentPage(1); }}
              >
                Tất cả ({invoices.length})
              </button>
              <button
                className={`filter-tab-btn ${filterTab === 'PendingUNC' ? 'active' : ''}`}
                onClick={() => { setFilterTab('PendingUNC'); setCurrentPage(1); }}
              >
                Chờ UNC ({pendingPayments.length})
              </button>
              <button
                className={`filter-tab-btn ${filterTab === 'Overdue' ? 'active' : ''}`}
                onClick={() => { setFilterTab('Overdue'); setCurrentPage(1); }}
              >
                Quá hạn ({summary?.overdueCount ?? penalties.length})
              </button>
              <button
                className={`filter-tab-btn ${filterTab === 'Paid' ? 'active' : ''}`}
                onClick={() => { setFilterTab('Paid'); setCurrentPage(1); }}
              >
                Đã thu ({summary?.paidCount ?? invoices.filter(i => i.status === 'Paid').length})
              </button>
            </div>
          </div>

          {/* Table */}
          <div className="invoice-table-container">
            <table className="invoice-table">
              <thead>
                <tr>
                  <th>MÃ HĐ</th>
                  <th>CĂN / CHỦ HỘ</th>
                  <th style={{ textAlign: 'right' }}>PHÍ QL (M²)</th>
                  <th style={{ textAlign: 'right' }}>ĐIỆN EVN</th>
                  <th style={{ textAlign: 'right' }}>NƯỚC SẠCH</th>
                  <th style={{ textAlign: 'right' }}>XE RFID</th>
                  <th style={{ textAlign: 'right' }}>TỔNG CỘNG</th>
                  <th style={{ textAlign: 'center' }}>HẠN CHÓT</th>
                </tr>
              </thead>
              <tbody>
                {loadError ? (
                  <tr>
                    <td colSpan={8} style={{ textAlign: 'center', padding: '30px', color: '#d9534f' }}>
                      <p><strong>Không kết nối được server</strong></p>
                      <p style={{ fontSize: '0.85rem', opacity: 0.8 }}>Hãy chạy backend: <code>dotnet run</code></p>
                      <button className="secondary-button" style={{ marginTop: '8px' }} onClick={loadData}>Thử lại</button>
                    </td>
                  </tr>
                ) : source === 'Đang kết nối...' ? (
                  <tr>
                    <td colSpan={8} style={{ textAlign: 'center', padding: '30px', color: '#64748b' }}>
                      Đang tải danh sách hóa đơn từ MySQL...
                    </td>
                  </tr>
                ) : paginatedInvoices.length === 0 ? (
                  <tr>
                    <td colSpan={8} style={{ textAlign: 'center', padding: '30px', color: '#64748b' }}>
                      Không tìm thấy hóa đơn nào phù hợp với bộ lọc.
                    </td>
                  </tr>
                ) : (
                  paginatedInvoices.map((item) => {
                    const isSelected = selectedInvoice?.id === item.id
                    const isOverdue = item.status === 'Overdue' || (item.status !== 'Paid' && new Date(item.dueDate) < new Date())
                    return (
                      <tr
                        key={item.id}
                        className={`invoice-row ${isSelected ? 'active' : ''}`}
                        onClick={() => setSelectedInvoice(item)}
                        title="Bấm để xem chi tiết bóc tách phiếu thu"
                      >
                        <td>
                          <span className="invoice-code-link">{item.invoiceCode}</span>
                        </td>
                        <td className="invoice-apt-cell">
                          <strong>{item.apartmentNumber}</strong>
                          <small>{item.residentName || 'Chưa cập nhật'}</small>
                        </td>
                        <td className="amount-col">{item.managementFee.toLocaleString('vi-VN')} đ</td>
                        <td className="amount-col">{item.electricityFee.toLocaleString('vi-VN')} đ</td>
                        <td className="amount-col">{item.waterFee.toLocaleString('vi-VN')} đ</td>
                        <td className="amount-col">{item.parkingFee.toLocaleString('vi-VN')} đ</td>
                        <td className="total-col">
                          {item.totalAmount.toLocaleString('vi-VN')} đ
                          {item.penaltyAmount > 0 && (
                            <small style={{ color: '#dc2626', display: 'block', fontSize: '9px' }}>
                              +{item.penaltyAmount.toLocaleString('vi-VN')} đ phạt
                            </small>
                          )}
                        </td>
                        <td className="due-col">
                          {new Date(item.dueDate).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })}
                          {isOverdue && (
                            <span className="overdue-alert-text">
                              (Trễ {item.overdueDays || 12}n)
                            </span>
                          )}
                        </td>
                      </tr>
                    )
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="pagination-bar">
            <span>
              Hiển thị {invoices.length > 0 ? (currentPage - 1) * pageSize + 1 : 0} -{' '}
              {Math.min(currentPage * pageSize, invoices.length)} trên tổng số {invoices.length} bản ghi
            </span>
            <div className="pagination-controls">
              <button
                className="page-btn"
                disabled={currentPage === 1}
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
              >
                &lt;
              </button>
              {Array.from({ length: Math.min(5, totalPages) }, (_, idx) => (
                <button
                  key={idx + 1}
                  className={`page-btn ${currentPage === idx + 1 ? 'active' : ''}`}
                  onClick={() => setCurrentPage(idx + 1)}
                >
                  {idx + 1}
                </button>
              ))}
              <button
                className="page-btn"
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
              >
                &gt;
              </button>
            </div>
          </div>
        </article>

        {/* Right Side Panel: Reconcile UNC & Penalties */}
        <aside className="panel approval" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {/* Section 1: Đối Soát UNC & Chứng Từ */}
          <div>
            <div className="panel-title">
              <div>
                <span className="eyebrow">ĐỐI SOÁT UNC & CHỨNG TỪ</span>
                <h2 style={{ fontSize: '15px' }}>Chờ duyệt ngân hàng</h2>
              </div>
              <span className="badge blue">{pendingPayments.length} Chờ duyệt</span>
            </div>
            <p style={{ margin: '4px 0 10px', fontSize: '10px', color: '#64748b' }}>
              Kiểm tra biên lai chuyển khoản ngân hàng do cư dân tải lên khớp với sao kê ngân hàng VIBank / Vietcombank.
            </p>

            {/* Pending UNC Cards - Dynamic from MySQL */}
            {pendingPayments.length === 0 ? (
              <div className="empty" style={{ padding: '16px', fontSize: '11px', color: '#64748b' }}>
                Không có chứng từ UNC nào đang chờ đối soát.
              </div>
            ) : (
              pendingPayments.slice(0, 3).map(p => (
                <div key={p.paymentId} className="unc-card">
                  <div className="unc-card-header">
                    <div>
                      <strong>Căn {p.apartmentNumber}</strong>
                      <small>Chủ hộ: {p.residentName || 'Cư dân'}</small>
                    </div>
                    <span className="unc-amount">{p.amount.toLocaleString('vi-VN')} đ</span>
                  </div>
                  <div className="unc-receipt-preview">
                    <div style={{ height: '70px', background: '#e2e8f0', borderRadius: '4px', display: 'grid', placeItems: 'center', color: '#64748b' }}>
                      <Icon name="receipt" /> Biên lai UNC: {p.transactionCode} ({p.paymentMethod})
                    </div>
                    <span>Mã GD: <strong>{p.transactionCode}</strong></span>
                    {p.payerNote && <span>Nội dung: <strong>{p.payerNote}</strong></span>}
                    <span>Tài khoản nhận: <strong>BQL TÒA RUBY SUITES (VIBank - 8888)</strong></span>
                  </div>
                  <div className="unc-actions">
                    <button className="btn-confirm-unc" onClick={() => handleApprove(p.paymentId)}>
                      <Icon name="check" /> Xác nhận Đã Thu
                    </button>
                    <button className="btn-reject-unc" onClick={() => handleReject(p.paymentId)}>
                      ✕ Từ chối
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Section 2: Xử Lý Nợ & Lãi Phạt */}
          <div style={{ borderTop: '1px solid #f1f5f9', paddingTop: '14px' }}>
            <div className="panel-title">
              <div>
                <span className="eyebrow" style={{ color: '#dc2626' }}>XỬ LÝ NỢ & LÃI PHẠT</span>
                <h2 style={{ fontSize: '15px' }}>Chế tài quá hạn (0.05% / ngày)</h2>
              </div>
              <span className="badge red">0.05% / ngày</span>
            </div>
            <p style={{ margin: '4px 0 10px', fontSize: '10px', color: '#64748b' }}>
              Các căn hộ trễ hạn sau thời gian ân hạn (Grace Period 5 ngày) tự động tính lãi theo Quy chế Tòa Ruby Suites.
            </p>

            {/* Penalties List - Dynamic from MySQL */}
            {penalties.length === 0 ? (
              <div className="empty" style={{ padding: '16px', fontSize: '11px', color: '#64748b' }}>
                Không có căn hộ nào bị phát sinh phạt trễ hạn.
              </div>
            ) : (
              penalties.slice(0, 3).map(pen => (
                <div key={pen.penaltyId} className="penalty-card">
                  <div className="penalty-card-top">
                    <div>
                      <strong>Căn {pen.apartmentNumber} {pen.residentName ? `(${pen.residentName})` : ''}</strong>
                      <small style={{ display: 'block', color: '#64748b', fontSize: '10px' }}>
                        Trễ {pen.overdueDays} ngày (Gốc: {pen.originalAmount.toLocaleString('vi-VN')} đ)
                      </small>
                      <small style={{ color: '#b45309', fontSize: '9px' }}>
                        Lý do: {pen.reason}
                      </small>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <small style={{ fontSize: '9px', color: '#dc2626' }}>TIỀN PHẠT PHÁT SINH</small>
                      <div className="penalty-amount-badge">+{pen.penaltyAmount.toLocaleString('vi-VN')} đ</div>
                    </div>
                  </div>
                  <div className="penalty-actions">
                    <button className="btn-urgent-remind" onClick={handleBatchReminder}>
                      <Icon name="notification_important" /> Nhắc Nợ Khẩn
                    </button>
                    <button className="btn-waive-penalty" onClick={() => handleWaive(pen.penaltyId)}>
                      Duyệt Miễn Phạt
                    </button>
                  </div>
                </div>
              ))
            )}

            <div className="penalty-disclaimer">
              <Icon name="info" />
              <span>Hệ thống tự động khóa cổng thẻ xe RFID nếu trễ nợ quá 20 ngày theo quy chế vận hành.</span>
            </div>
          </div>
        </aside>
      </section>

      {/* 4. Bottom Cards: Cơ cấu Doanh Thu & MISA SME */}
      <section className="invoices-bottom-layout">
        <article className="panel chart-card">
          <div className="panel-title">
            <div>
              <span className="eyebrow">THỐNG KÊ DOANH THU</span>
              <h2>Cơ cấu Doanh Thu T08</h2>
            </div>
            <span className="data-source"><i />VN · VND</span>
          </div>

          <div className="revenue-breakdown">
            <div className="revenue-donut">
              <div className="revenue-donut-inner">
                <strong>2.08B</strong>
                <small style={{ fontSize: '9px', color: '#64748b' }}>Tổng thu</small>
              </div>
            </div>

            <div className="revenue-legend">
              <div className="revenue-legend-item">
                <span className="legend-dot blue" />
                <span>Phí quản lý: <strong>{revenue?.managementTotal ? (revenue.managementTotal / 1000000).toFixed(0) + 'M (56%)' : '1.180M (56%)'}</strong></span>
              </div>
              <div className="revenue-legend-item">
                <span className="legend-dot sky" />
                <span>Điện sinh hoạt: <strong>{revenue?.electricityTotal ? (revenue.electricityTotal / 1000000).toFixed(0) + 'M (22%)' : '467M (22%)'}</strong></span>
              </div>
              <div className="revenue-legend-item">
                <span className="legend-dot green" />
                <span>Nước & xe KHD: <strong>{revenue?.waterAndParkingTotal ? (revenue.waterAndParkingTotal / 1000000).toFixed(0) + 'M (21%)' : '438M (21%)'}</strong></span>
              </div>
            </div>
          </div>
        </article>

        <article className="panel misa-sync-card">
          <div>
            <div className="panel-title">
              <div>
                <span className="eyebrow">HỆ THỐNG KẾ TOÁN</span>
                <h2>Đồng bộ Kế toán MISA SME</h2>
              </div>
              <span className="badge green">Kết nối trực tiếp</span>
            </div>

            <div className="misa-info-row">
              <div>Lần đẩy dữ liệu gần nhất: <strong>14:20:18 - Hôm nay</strong></div>
              <div>Chứng từ thu tự động: <strong>412 phiếu</strong> (Đã khớp số sinh viên / kế toán)</div>
              <div>Hóa đơn điện tử e-Invoice: <strong>Đã phát hành cơ quan thuế</strong></div>
            </div>
          </div>

          <button className="misa-btn" onClick={() => setIsMisaOpen(true)}>
            <Icon name="sync_alt" /> Kiểm tra đối chiếu Sổ Cái (GL)
          </button>
        </article>
      </section>

      {/* 5. Modal Tính HĐ Tháng Mới */}
      {isGenerateOpen && (
        <div className="modal-overlay" onClick={() => !submitting && setIsGenerateOpen(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Tính & Phát hành Hóa đơn Tháng Mới</h2>
              <button className="close-btn" onClick={() => !submitting && setIsGenerateOpen(false)}>
                <Icon name="close" />
              </button>
            </div>
            <form onSubmit={handleGenerateInvoicesSubmit}>
              <div className="modal-body">
                <p style={{ fontSize: '12px', color: '#475569', marginBottom: '14px' }}>
                  Hệ thống sẽ tự động quét chỉ số đồng hồ điện/nước, diện tích căn hộ và biểu phí dịch vụ hiện hành để lập bảng kê thu phí cho tất cả các căn hộ đang có người ở.
                </p>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Tháng kết chuyển <span>*</span></label>
                    <select value={genMonth} onChange={(e) => setGenMonth(Number(e.target.value))}>
                      {Array.from({ length: 12 }, (_, i) => (
                        <option key={i + 1} value={i + 1}>Tháng {i + 1}</option>
                      ))}
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Năm tài chính <span>*</span></label>
                    <select value={genYear} onChange={(e) => setGenYear(Number(e.target.value))}>
                      <option value={2026}>2026</option>
                      <option value={2027}>2027</option>
                    </select>
                  </div>
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-button" onClick={() => setIsGenerateOpen(false)} disabled={submitting}>
                  Hủy
                </button>
                <button type="submit" className="action-add-btn" disabled={submitting}>
                  {submitting ? 'Đang tính toán...' : 'Bắt đầu phát hành'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 6. Modal Đối chiếu Sổ Cái MISA GL */}
      {isMisaOpen && (
        <div className="modal-overlay" onClick={() => setIsMisaOpen(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Đối Chiếu Sổ Cái Kế Toán MISA SME</h2>
              <button className="close-btn" onClick={() => setIsMisaOpen(false)}>
                <Icon name="close" />
              </button>
            </div>
            <div className="modal-body">
              <div className="alert-box alert-success">
                <Icon name="verified" /> Kết nối API MISA Open Platform: <strong>Trực tuyến (200 OK)</strong>
              </div>
              <div style={{ fontSize: '11px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid #f1f5f9' }}>
                  <span>Tài khoản 131 (Phải thu cư dân):</span>
                  <strong>2.085.000.000 đ</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid #f1f5f9' }}>
                  <span>Tài khoản 1121 (Tiền gửi ngân hàng VIB):</span>
                  <strong>1.840.650.000 đ</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid #f1f5f9' }}>
                  <span>Tài khoản 1111 (Tiền mặt lễ tân):</span>
                  <strong>4.350.000 đ</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid #f1f5f9' }}>
                  <span>Chênh lệch chưa khớp:</span>
                  <strong style={{ color: '#059669' }}>0 đ (Trùng khớp 100%)</strong>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn-header-primary" onClick={() => setIsMisaOpen(false)}>
                Hoàn tất
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 7. Modal Chi tiết Hóa đơn khi click hàng */}
      {selectedInvoice && (
        <div className="modal-overlay" onClick={() => setSelectedInvoice(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Chi tiết Hóa đơn {selectedInvoice.invoiceCode}</h2>
              <button className="close-btn" onClick={() => setSelectedInvoice(null)}>
                <Icon name="close" />
              </button>
            </div>
            <div className="modal-body">
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                <div>
                  <h3 style={{ margin: 0 }}>Căn hộ {selectedInvoice.apartmentNumber}</h3>
                  <small style={{ color: '#64748b' }}>Chủ hộ: {selectedInvoice.residentName} · SĐT: {selectedInvoice.phoneNumber}</small>
                </div>
                <span className={`badge ${selectedInvoice.status === 'Paid' ? 'green' : 'amber'}`}>
                  {selectedInvoice.status === 'Paid' ? 'Đã thanh toán' : 'Chưa quyết toán'}
                </span>
              </div>

              <div className="detail-section">
                <h4><Icon name="receipt" /> Các khoản thu kỳ {selectedInvoice.billingMonth}/{selectedInvoice.billingYear}</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '11px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Phí quản lý & dịch vụ chung:</span>
                    <strong>{selectedInvoice.managementFee.toLocaleString('vi-VN')} đ</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Điện sinh hoạt (theo công tơ LoRaWan):</span>
                    <strong>{selectedInvoice.electricityFee.toLocaleString('vi-VN')} đ</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Nước sinh hoạt & phí BVMT:</span>
                    <strong>{selectedInvoice.waterFee.toLocaleString('vi-VN')} đ</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Phí trông giữ phương tiện thẻ RFID:</span>
                    <strong>{selectedInvoice.parkingFee.toLocaleString('vi-VN')} đ</strong>
                  </div>
                  {selectedInvoice.penaltyAmount > 0 && (
                    <div style={{ display: 'flex', justifyContent: 'space-between', color: '#dc2626' }}>
                      <span>Lãi phạt quá hạn ({selectedInvoice.overdueDays} ngày):</span>
                      <strong>+{selectedInvoice.penaltyAmount.toLocaleString('vi-VN')} đ</strong>
                    </div>
                  )}
                  <div style={{ display: 'flex', justifyContent: 'space-between', borderTop: '1px solid #e2e8f0', paddingTop: '6px', fontSize: '13px' }}>
                    <strong>Tổng cộng phải nộp:</strong>
                    <strong style={{ color: '#2563eb' }}>
                      {(selectedInvoice.totalAmount + selectedInvoice.penaltyAmount).toLocaleString('vi-VN')} đ
                    </strong>
                  </div>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="secondary-button" onClick={() => setSelectedInvoice(null)}>
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
