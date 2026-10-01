import { useState } from 'react'
import { Sidebar } from './components/Sidebar'
import { Topbar } from './components/Topbar'
import { navigation } from './data/navigation'
import { Dashboard } from './features/dashboard/Dashboard'
import { ModulePlaceholder } from './features/placeholder/ModulePlaceholder'

export default function App() {
  const [active, setActive] = useState('dashboard')
  const [query, setQuery] = useState('')
  const [navOpen, setNavOpen] = useState(false)
  const module = navigation.find((item) => item.id === active) ?? navigation[0]
  const selectModule = (id: string) => { setActive(id); setNavOpen(false) }
  return <div className="app-shell"><Sidebar active={active} onSelect={selectModule} open={navOpen} onClose={() => setNavOpen(false)} /><div className="page"><Topbar query={query} onQuery={setQuery} onMenu={() => setNavOpen(true)} /><main><section className="page-heading"><div><span className="eyebrow">VẬN HÀNH TRUNG TÂM</span><h1>{module.label}</h1><p>{active === 'dashboard' ? 'Tổng quan trạng thái vận hành khu căn hộ trong hôm nay.' : `Quản lý ${module.label.toLowerCase()} tại Ruby Suites Residence.`}</p></div><div className="heading-actions"><button className="secondary-button">Tháng 09, 2026</button><button className="primary-button">Tạo mới</button></div></section>{active === 'dashboard' ? <Dashboard query={query} /> : <ModulePlaceholder module={module} onBack={() => setActive('dashboard')} />}</main></div></div>
}
