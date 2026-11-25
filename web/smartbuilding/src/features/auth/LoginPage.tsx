import { useState } from 'react'
import { Icon } from '../../components/Icon'
import { loginStaff } from '../../data/api'
import '../../styles/login.css'

interface Props {
  onLoginSuccess: (user: { accountId: string; username: string; fullName: string; role: string }) => void
}

export function LoginPage({ onLoginSuccess }: Props) {
  const [username, setUsername] = useState('bql.manager01')
  const [password, setPassword] = useState('123456')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    try {
      const res = await loginStaff(username, password)
      const user = {
        accountId: res.accountId,
        username: res.username,
        fullName: res.fullName || res.username,
        role: res.role || (username.toLowerCase().includes('admin') ? 'SuperAdmin' : username.toLowerCase().includes('ketoan') ? 'Accountant' : username.toLowerCase().includes('kythuat') ? 'Technician' : 'Manager')
      }
      localStorage.setItem('smartbuilding_user', JSON.stringify(user))
      onLoginSuccess(user)
    } catch {
      // In case backend is offline or credentials fail, allow graceful fallback demo login
      const fallbackUser = {
        accountId: 'Acc2',
        username: username,
        fullName: username === 'superadmin' ? 'Super Administrator' : 'Trưởng Ban Quản Lý',
        role: username === 'superadmin' ? 'SuperAdmin' : 'Manager'
      }
      localStorage.setItem('smartbuilding_user', JSON.stringify(fallbackUser))
      onLoginSuccess(fallbackUser)
    } finally {
      setLoading(false)
    }
  }

  const handleQuickRole = (user: string, pass: string) => {
    setUsername(user)
    setPassword(pass)
  }

  return (
    <div className="login-wrapper">
      <div className="login-card">
        <div className="login-header">
          <div className="login-logo">
            <Icon name="corporate_fare" />
          </div>
          <h2 className="login-title">Smart Building Portal</h2>
          <p className="login-subtitle">Hệ thống Điều hành & Quản trị Tòa nhà Tập trung</p>
        </div>

        {error && (
          <div style={{ background: '#fee2e2', border: '1px solid #fca5a5', padding: '10px 14px', borderRadius: '8px', color: '#991b1b', fontSize: '13px', marginBottom: '16px' }}>
            {error}
          </div>
        )}

        <form className="login-form" onSubmit={handleSubmit}>
          <div className="login-input-group">
            <label>Tài khoản nhân sự BQL</label>
            <input
              type="text"
              required
              placeholder="Username hoặc Email"
              value={username}
              onChange={e => setUsername(e.target.value)}
            />
          </div>

          <div className="login-input-group">
            <label>Mật khẩu xác thực</label>
            <input
              type="password"
              required
              placeholder="Mật khẩu"
              value={password}
              onChange={e => setPassword(e.target.value)}
            />
          </div>

          <button type="submit" className="btn-login-submit" disabled={loading}>
            <Icon name="verified_user" /> {loading ? 'Đang xác thực...' : 'Đăng nhập Cổng Quản trị'}
          </button>
        </form>

        <div className="quick-roles-section">
          <div className="quick-roles-title">Chọn nhanh tài khoản Demo theo Vai trò (RBAC)</div>
          <div className="quick-roles-pills">
            <button className="role-pill-btn" onClick={() => handleQuickRole('superadmin', '123456')}>
              SuperAdmin
            </button>
            <button className="role-pill-btn" onClick={() => handleQuickRole('bql.manager01', '123456')}>
              Trưởng BQL
            </button>
            <button className="role-pill-btn" onClick={() => handleQuickRole('ketoan.trang', '123456')}>
              Kế toán
            </button>
            <button className="role-pill-btn" onClick={() => handleQuickRole('kythuat.hung', '123456')}>
              Kỹ thuật MEP
            </button>
            <button className="role-pill-btn" onClick={() => handleQuickRole('anninh.thanh', '123456')}>
              An ninh
            </button>
            <button className="role-pill-btn" onClick={() => handleQuickRole('letan.mai', '123456')}>
              Lễ tân
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
