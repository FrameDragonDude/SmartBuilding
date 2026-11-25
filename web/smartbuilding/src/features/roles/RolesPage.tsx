import { useEffect, useState } from 'react'
import { Icon } from '../../components/Icon'
import {
  getStaffAccounts,
  toggleAccountStatus,
  getAuditTrails,
  type StaffAccountItem,
  type AuditTrailItem
} from '../../data/api'
import '../../styles/roles.css'

interface Props {
  query?: string
}

// Initial default permission matrix
const initialModules = [
  { id: 'dashboard', name: 'Bảng điều khiển (Dashboard)', roles: { SuperAdmin: true, Manager: true, Accountant: true, Technician: true, Security: true, Receptionist: true } },
  { id: 'residents', name: 'Căn hộ & Cư dân (Residents)', roles: { SuperAdmin: true, Manager: true, Accountant: false, Technician: false, Security: true, Receptionist: true } },
  { id: 'invoices', name: 'Hóa đơn & Thu phí (Finance)', roles: { SuperAdmin: true, Manager: true, Accountant: true, Technician: false, Security: false, Receptionist: false } },
  { id: 'mep', name: 'Kỹ thuật & Điện nước (MEP)', roles: { SuperAdmin: true, Manager: true, Accountant: true, Technician: true, Security: false, Receptionist: false } },
  { id: 'parking', name: 'Xe & Bãi đỗ RFID (Parking)', roles: { SuperAdmin: true, Manager: true, Accountant: false, Technician: false, Security: true, Receptionist: false } },
  { id: 'amenities', name: 'Tiện ích & Đặt lịch (Amenities)', roles: { SuperAdmin: true, Manager: true, Accountant: false, Technician: false, Security: false, Receptionist: true } },
  { id: 'complaints', name: 'Phản ánh & Nghiệm thu (Complaints)', roles: { SuperAdmin: true, Manager: true, Accountant: false, Technician: true, Security: true, Receptionist: true } },
  { id: 'pricing', name: 'Cấu hình biểu phí (Tariff)', roles: { SuperAdmin: true, Manager: true, Accountant: true, Technician: false, Security: false, Receptionist: false } },
  { id: 'roles', name: 'Phân quyền & Kiểm toán (RBAC)', roles: { SuperAdmin: true, Manager: false, Accountant: false, Technician: false, Security: false, Receptionist: false } }
]

export function RolesPage({ query = '' }: Props) {
  const [activeTab, setActiveTab] = useState<'accounts' | 'matrix' | 'audit'>('accounts')
  const [staffList, setStaffList] = useState<StaffAccountItem[]>([])
  const [auditList, setAuditList] = useState<AuditTrailItem[]>([])
  const [permMatrix, setPermMatrix] = useState(initialModules)
  const [loading, setLoading] = useState(true)
  const [feedback, setFeedback] = useState<string | null>(null)
  const [selectedAuditLog, setSelectedAuditLog] = useState<AuditTrailItem | null>(null)

  const loadData = async () => {
    setLoading(true)
    try {
      const [staffData, auditData] = await Promise.all([
        getStaffAccounts(),
        getAuditTrails()
      ])
      setStaffList(staffData)
      setAuditList(auditData)
    } catch (err) {
      console.error('Error loading roles data:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  const handleToggleStatus = async (accountId: string, currentActive: boolean) => {
    try {
      await toggleAccountStatus(accountId)
      setStaffList(prev => prev.map(s => s.id === accountId ? { ...s, isActive: !currentActive } : s))
      setFeedback(`Đã ${!currentActive ? 'mở khóa' : 'khóa'} tài khoản thành công! Quyền hạn có hiệu lực ngay lập tức.`)
      setTimeout(() => setFeedback(null), 4000)
    } catch {
      alert('Không thể cập nhật trạng thái tài khoản.')
    }
  }

  const handleToggleMatrixPerm = (moduleId: string, role: string) => {
    setPermMatrix(prev =>
      prev.map(m => {
        if (m.id === moduleId) {
          const currentVal = (m.roles as any)[role]
          return {
            ...m,
            roles: {
              ...m.roles,
              [role]: !currentVal
            }
          }
        }
        return m
      })
    )
    setFeedback(`Đã cập nhật quyền "${role}" cho phân hệ "${moduleId}" (In-memory Cache Invalidation kích hoạt tức thì).`)
    setTimeout(() => setFeedback(null), 4000)
  }

  const filteredStaff = staffList.filter(s =>
    query
      ? s.username.toLowerCase().includes(query.toLowerCase()) ||
        s.email.toLowerCase().includes(query.toLowerCase()) ||
        s.roleName.toLowerCase().includes(query.toLowerCase())
      : true
  )

  const filteredAudit = auditList.filter(a =>
    query
      ? a.username.toLowerCase().includes(query.toLowerCase()) ||
        a.tableName.toLowerCase().includes(query.toLowerCase()) ||
        a.actionType.toLowerCase().includes(query.toLowerCase())
      : true
  )

  return (
    <div className="roles-container">
      {feedback && (
        <div style={{ background: '#dcfce7', border: '1px solid #86efac', padding: '10px 16px', borderRadius: '8px', color: '#166534', fontSize: '14px', fontWeight: 600 }}>
          {feedback}
        </div>
      )}

      {/* KPI Cards */}
      <section className="stats-row">
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#eff6ff', color: '#2563eb' }}>
            <Icon name="groups" />
          </div>
          <div>
            <div className="stat-value">{staffList.length}</div>
            <div className="stat-label">Tài khoản nhân sự BQL</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#f0fdf4', color: '#16a34a' }}>
            <Icon name="verified_user" />
          </div>
          <div>
            <div className="stat-value">6</div>
            <div className="stat-label">Vai trò vận hành (RBAC)</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#fef3c7', color: '#d97706' }}>
            <Icon name="history" />
          </div>
          <div>
            <div className="stat-value">{auditList.length}</div>
            <div className="stat-label">Bản ghi vết Audit Trail</div>
          </div>
        </article>
        <article className="stat-card">
          <div className="stat-icon-wrapper" style={{ background: '#f8fafc', color: '#64748b' }}>
            <Icon name="tune" />
          </div>
          <div>
            <div className="stat-value">9 / 9</div>
            <div className="stat-label">Phân hệ động kích hoạt</div>
          </div>
        </article>
      </section>

      {/* Tab bar */}
      <div className="roles-tabs">
        <button
          className={`role-tab-btn ${activeTab === 'accounts' ? 'active' : ''}`}
          onClick={() => setActiveTab('accounts')}
        >
          <Icon name="groups" /> Nhân sự & Tài khoản ({staffList.length})
        </button>
        <button
          className={`role-tab-btn ${activeTab === 'matrix' ? 'active' : ''}`}
          onClick={() => setActiveTab('matrix')}
        >
          <Icon name="shield_person" /> Ma trận Phân quyền Động (Dynamic RBAC)
        </button>
        <button
          className={`role-tab-btn ${activeTab === 'audit' ? 'active' : ''}`}
          onClick={() => setActiveTab('audit')}
        >
          <Icon name="history" /> Nhật ký Kiểm toán Hệ thống (Audit Trail)
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>Đang tải cấu hình phân quyền...</div>
      ) : activeTab === 'accounts' ? (
        <div className="panel-card">
          <div style={{ padding: '14px 18px', borderBottom: '1px solid #f1f5f9', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h3 style={{ margin: 0, fontSize: '15px', color: '#0f172a' }}>Danh sách tài khoản BQL & Nhân viên vận hành</h3>
            <span style={{ fontSize: '12px', color: '#64748b' }}>Mã băm mật khẩu Bcrypt · Token JWT</span>
          </div>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0', textAlign: 'left', color: '#475569' }}>
                <th style={{ padding: '10px 14px' }}>Mã TK</th>
                <th style={{ padding: '10px 14px' }}>Tên đăng nhập</th>
                <th style={{ padding: '10px 14px' }}>Email làm việc</th>
                <th style={{ padding: '10px 14px' }}>Vai trò RBAC</th>
                <th style={{ padding: '10px 14px' }}>Trạng thái</th>
                <th style={{ padding: '10px 14px', textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredStaff.map(s => (
                <tr key={s.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '10px 14px', fontWeight: 600, color: '#1e293b' }}>{s.id}</td>
                  <td style={{ padding: '10px 14px', fontWeight: 600, color: '#2563eb' }}>{s.username}</td>
                  <td style={{ padding: '10px 14px', color: '#475569' }}>{s.email}</td>
                  <td style={{ padding: '10px 14px' }}>
                    <span className={`badge-role ${s.roleCode.toLowerCase()}`}>
                      {s.roleName}
                    </span>
                  </td>
                  <td style={{ padding: '10px 14px' }}>
                    <span style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '4px',
                      padding: '2px 8px',
                      borderRadius: '12px',
                      fontSize: '12px',
                      fontWeight: 600,
                      background: s.isActive ? '#dcfce7' : '#fee2e2',
                      color: s.isActive ? '#15803d' : '#991b1b'
                    }}>
                      {s.isActive ? '● Đang hoạt động' : '✕ Đã khóa'}
                    </span>
                  </td>
                  <td style={{ padding: '10px 14px', textAlign: 'right' }}>
                    <button
                      onClick={() => handleToggleStatus(s.id, s.isActive)}
                      style={{
                        padding: '4px 10px',
                        borderRadius: '6px',
                        fontSize: '12px',
                        fontWeight: 600,
                        cursor: 'pointer',
                        border: '1px solid #cbd5e1',
                        background: s.isActive ? '#fff1f2' : '#f0fdf4',
                        color: s.isActive ? '#e11d48' : '#16a34a'
                      }}
                    >
                      {s.isActive ? 'Khóa tài khoản' : 'Mở khóa'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : activeTab === 'matrix' ? (
        <div className="panel-card">
          <div style={{ padding: '14px 18px', borderBottom: '1px solid #f1f5f9', background: '#f8fafc' }}>
            <h3 style={{ margin: 0, fontSize: '15px', color: '#0f172a' }}>Ma trận Phân quyền 2 chiều (Role-Permission Matrix Grid)</h3>
            <p style={{ margin: '4px 0 0', fontSize: '12px', color: '#64748b' }}>
              SuperAdmin có thể bật/tắt trực tiếp quyền truy cập từng phân hệ bằng switch toggle mà không cần sửa code backend.
            </p>
          </div>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr style={{ background: '#f1f5f9', borderBottom: '1px solid #cbd5e1', textAlign: 'center', color: '#334155' }}>
                <th style={{ padding: '12px 16px', textAlign: 'left' }}>Phân hệ chức năng</th>
                <th style={{ padding: '12px 10px' }}>SuperAdmin</th>
                <th style={{ padding: '12px 10px' }}>Trưởng BQL</th>
                <th style={{ padding: '12px 10px' }}>Kế toán</th>
                <th style={{ padding: '12px 10px' }}>Kỹ thuật MEP</th>
                <th style={{ padding: '12px 10px' }}>An ninh/Bãi xe</th>
                <th style={{ padding: '12px 10px' }}>Lễ tân</th>
              </tr>
            </thead>
            <tbody>
              {permMatrix.map(m => (
                <tr key={m.id} style={{ borderBottom: '1px solid #f1f5f9', textAlign: 'center' }}>
                  <td style={{ padding: '12px 16px', textAlign: 'left', fontWeight: 600, color: '#1e293b' }}>
                    {m.name}
                  </td>
                  {['SuperAdmin', 'Manager', 'Accountant', 'Technician', 'Security', 'Receptionist'].map(role => {
                    const checked = (m.roles as any)[role]
                    return (
                      <td key={role} style={{ padding: '10px' }}>
                        <label className="switch">
                          <input
                            type="checkbox"
                            checked={checked}
                            disabled={role === 'SuperAdmin'} // SuperAdmin always has full access
                            onChange={() => handleToggleMatrixPerm(m.id, role)}
                          />
                          <span className="slider" />
                        </label>
                      </td>
                    )
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="panel-card">
          <div style={{ padding: '14px 18px', borderBottom: '1px solid #f1f5f9' }}>
            <h3 style={{ margin: 0, fontSize: '15px', color: '#0f172a' }}>Nhật ký Vết Kiểm toán Hệ thống (Audit Trail Viewer)</h3>
            <p style={{ margin: '4px 0 0', fontSize: '12px', color: '#64748b' }}>
              Tự động ghi vết toàn bộ hành vi tác động dữ liệu nhạy cảm (biểu giá, duyệt phạt nợ, sửa cư dân) kèm địa chỉ IP và giá trị JSON trước/sau khi sửa.
            </p>
          </div>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
            <thead>
              <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0', textAlign: 'left', color: '#475569' }}>
                <th style={{ padding: '10px 14px' }}>Thời gian</th>
                <th style={{ padding: '10px 14px' }}>Tài khoản</th>
                <th style={{ padding: '10px 14px' }}>Hành vi</th>
                <th style={{ padding: '10px 14px' }}>Bảng tác động</th>
                <th style={{ padding: '10px 14px' }}>Mã bản ghi</th>
                <th style={{ padding: '10px 14px' }}>Địa chỉ IP</th>
                <th style={{ padding: '10px 14px' }}>Chi tiết thay đổi</th>
              </tr>
            </thead>
            <tbody>
              {filteredAudit.map(a => (
                <tr key={a.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '10px 14px', whiteSpace: 'nowrap' }}>
                    {new Date(a.timestamp).toLocaleString('vi-VN')}
                  </td>
                  <td style={{ padding: '10px 14px', fontWeight: 600, color: '#2563eb' }}>
                    {a.username}
                  </td>
                  <td style={{ padding: '10px 14px' }}>
                    <span style={{
                      padding: '2px 6px',
                      borderRadius: '4px',
                      fontWeight: 700,
                      fontSize: '11px',
                      background: a.actionType === 'DELETE' ? '#fee2e2' : a.actionType === 'UPDATE' ? '#fef3c7' : '#dcfce7',
                      color: a.actionType === 'DELETE' ? '#dc2626' : a.actionType === 'UPDATE' ? '#b45309' : '#15803d'
                    }}>
                      {a.actionType}
                    </span>
                  </td>
                  <td style={{ padding: '10px 14px', fontWeight: 600, color: '#475569' }}>
                    {a.tableName}
                  </td>
                  <td style={{ padding: '10px 14px', fontFamily: 'monospace' }}>
                    {a.recordId}
                  </td>
                  <td style={{ padding: '10px 14px', color: '#64748b' }}>
                    {a.ipAddress}
                  </td>
                  <td style={{ padding: '10px 14px' }}>
                    <button
                      onClick={() => setSelectedAuditLog(a)}
                      style={{
                        padding: '3px 8px',
                        borderRadius: '4px',
                        border: '1px solid #cbd5e1',
                        background: '#f8fafc',
                        cursor: 'pointer',
                        fontSize: '11px',
                        fontWeight: 600
                      }}
                    >
                      Xem JSON Old/New
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal xem OldValues / NewValues */}
      {selectedAuditLog && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div style={{ background: '#fff', borderRadius: '12px', padding: '24px', width: '600px', maxWidth: '90%', boxShadow: '0 10px 25px rgba(0,0,0,0.2)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ margin: 0, fontSize: '16px', color: '#0f172a' }}>
                Chi tiết Audit Log #{selectedAuditLog.id} ({selectedAuditLog.actionType} on {selectedAuditLog.tableName})
              </h3>
              <button onClick={() => setSelectedAuditLog(null)} style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                <Icon name="close" />
              </button>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
              <div>
                <h4 style={{ fontSize: '13px', margin: '0 0 6px', color: '#dc2626' }}>Giá trị trước sửa (OldValues):</h4>
                <div className="code-preview" style={{ maxHeight: '200px' }}>
                  {selectedAuditLog.oldValues || '(Không có / NULL)'}
                </div>
              </div>
              <div>
                <h4 style={{ fontSize: '13px', margin: '0 0 6px', color: '#16a34a' }}>Giá trị sau sửa (NewValues):</h4>
                <div className="code-preview" style={{ maxHeight: '200px' }}>
                  {selectedAuditLog.newValues || '(Không có / NULL)'}
                </div>
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <button
                onClick={() => setSelectedAuditLog(null)}
                style={{ padding: '8px 18px', borderRadius: '6px', border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontSize: '13px', fontWeight: 600 }}
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
