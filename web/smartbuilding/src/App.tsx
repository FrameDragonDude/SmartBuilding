import { useState, useEffect } from 'react'
import { Sidebar } from './components/Sidebar'
import { Topbar } from './components/Topbar'
import { navigation } from './data/navigation'
import { Dashboard } from './features/dashboard/Dashboard'
import { ModulePlaceholder } from './features/placeholder/ModulePlaceholder'
import { ResidentsPage } from './features/residents/ResidentsPage'
import { ParkingPage } from './features/parking/ParkingPage'
import { InvoicesPage } from './features/invoices/InvoicesPage'
import { PricingPage } from './features/pricing/PricingPage'
import { getBuildings, type BuildingItem } from './data/api'

const defaultBuildings: BuildingItem[] = [
  { id: 'B1', name: 'Tòa Ruby Suites', buildingCode: 'RUBY-01', totalFloors: 25, totalBasements: 2, address: '01 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 14 },
  { id: 'B2', name: 'Tòa Aqua Premier', buildingCode: 'AQUA-02', totalFloors: 30, totalBasements: 3, address: '02 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 15 },
  { id: 'B3', name: 'Tòa Emerald Park', buildingCode: 'EMERALD-03', totalFloors: 28, totalBasements: 2, address: '03 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 12 },
  { id: 'B4', name: 'Tòa Diamond Crown', buildingCode: 'DIAMOND-04', totalFloors: 35, totalBasements: 3, address: '04 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 15 },
  { id: 'B5', name: 'Tòa Sapphire Sky', buildingCode: 'SAPPHIRE-05', totalFloors: 22, totalBasements: 2, address: '05 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 12 },
  { id: 'B6', name: 'Tòa Topaz Residence', buildingCode: 'TOPAZ-06', totalFloors: 20, totalBasements: 1, address: '06 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 9 },
  { id: 'B7', name: 'Tòa Opal Garden', buildingCode: 'OPAL-07', totalFloors: 26, totalBasements: 2, address: '07 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 12 },
  { id: 'B8', name: 'Tòa Pearl Plaza', buildingCode: 'PEARL-08', totalFloors: 32, totalBasements: 3, address: '08 Mai Chí Thọ, Phường An Phú, TP. Thủ Đức', totalApartments: 15 }
]

export default function App() {
  const [active, setActive] = useState('dashboard')
  const [query, setQuery] = useState('')
  const [navOpen, setNavOpen] = useState(false)
  const [createResidentTrigger, setCreateResidentTrigger] = useState(false)
  const [createParkingTrigger, setCreateParkingTrigger] = useState(false)
  const [buildings, setBuildings] = useState<BuildingItem[]>(defaultBuildings)
  const [selectedBuildingId, setSelectedBuildingId] = useState<string>('B1')

  useEffect(() => {
    getBuildings()
      .then(data => {
        if (data && data.length > 0) {
          setBuildings(data)
        }
      })
      .catch(() => {
        // use default fallback
      })
  }, [])

  const selectedBuilding = buildings.find(b => b.id === selectedBuildingId) || buildings[0]

  const module = navigation.find((item) => item.id === active) ?? navigation[0]
  const selectModule = (id: string) => {
    setActive(id)
    setNavOpen(false)
  }

  const handleGlobalCreate = () => {
    if (active === 'residents') {
      setCreateResidentTrigger(true)
    } else if (active === 'parking') {
      setCreateParkingTrigger(true)
    } else if (active === 'invoices') {
      alert('Vui lòng sử dụng tính năng "Tính HĐ Tháng Mới" trên thanh công cụ.')
    } else {
      setActive('residents')
      setCreateResidentTrigger(true)
    }
  }

  return (
    <div className="app-shell">
      <Sidebar
        active={active}
        onSelect={selectModule}
        open={navOpen}
        onClose={() => setNavOpen(false)}
        buildings={buildings}
        selectedBuildingId={selectedBuildingId}
        onSelectBuilding={setSelectedBuildingId}
      />
      <div className="page">
        <Topbar
          query={query}
          onQuery={setQuery}
          onMenu={() => setNavOpen(true)}
          buildings={buildings}
          selectedBuildingId={selectedBuildingId}
          onSelectBuilding={setSelectedBuildingId}
        />
        <main>
          <section className="page-heading">
            <div>
              <span className="eyebrow">VẬN HÀNH TRUNG TÂM</span>
              <h1>{module.label}</h1>
              <p>
                {active === 'dashboard'
                  ? `Tổng quan trạng thái vận hành khu phức hợp ${selectedBuilding?.name || 'Smart Building'}.`
                  : active === 'invoices'
                  ? `Quản lý doanh thu, lập hóa đơn, đối soát sao kê và xử lý nợ quá hạn tại ${selectedBuilding?.name || 'khu căn hộ'}.`
                  : active === 'pricing'
                  ? `Cấu hình định mức 04 dịch vụ vận hành cốt lõi, quy tắc ân hạn và chế tài tự động cho ${selectedBuilding?.name || 'tòa nhà'}.`
                  : `Quản lý ${module.label.toLowerCase()} tại ${selectedBuilding?.name || 'Ruby Suites Residence'}.`}
              </p>
            </div>
            <div className="heading-actions">
              <button className="secondary-button">Tháng 09, 2026</button>
              <button className="primary-button" onClick={handleGlobalCreate}>
                Tạo mới
              </button>
            </div>
          </section>

          {active === 'dashboard' ? (
            <Dashboard query={query} />
          ) : active === 'residents' ? (
            <ResidentsPage
              query={query}
              triggerCreateModal={createResidentTrigger}
              onResetTriggerCreate={() => setCreateResidentTrigger(false)}
              buildingId={selectedBuildingId}
              onSelectBuilding={setSelectedBuildingId}
            />
          ) : active === 'parking' ? (
            <ParkingPage
              query={query}
              triggerCreateModal={createParkingTrigger}
              onResetTriggerCreate={() => setCreateParkingTrigger(false)}
              buildingId={selectedBuildingId}
            />
          ) : active === 'invoices' ? (
            <InvoicesPage query={query} buildingId={selectedBuildingId} />
          ) : active === 'pricing' ? (
            <PricingPage query={query} buildingName={selectedBuilding?.name} />
          ) : (
            <ModulePlaceholder module={module} onBack={() => setActive('dashboard')} />
          )}
        </main>
      </div>
    </div>
  )
}
