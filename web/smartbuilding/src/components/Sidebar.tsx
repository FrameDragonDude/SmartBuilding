import { useState, useRef, useEffect } from 'react'
import { navigation } from '../data/navigation'
import { Icon } from './Icon'
import { type BuildingItem } from '../data/api'

type Props = {
  active: string
  onSelect: (id: string) => void
  open: boolean
  onClose: () => void
  buildings: BuildingItem[]
  selectedBuildingId: string
  onSelectBuilding: (buildingId: string) => void
}

export function Sidebar({
  active,
  onSelect,
  open,
  onClose,
  buildings,
  selectedBuildingId,
  onSelectBuilding
}: Props) {
  const [dropdownOpen, setDropdownOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const currentBuilding = buildings.find(b => b.id === selectedBuildingId) || buildings[0]

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  return (
    <>
      <aside className={`sidebar ${open ? 'open' : ''}`}>
        <div className="brand">
          <div className="brand-mark">
            <Icon name="apartment" />
          </div>
          <div>
            <strong>Aura Portal</strong>
            <small>FACILITY INTELLIGENCE</small>
          </div>
          <button className="close-nav" onClick={onClose}>
            <Icon name="close" />
          </button>
        </div>

        {/* Building Selector with Dropdown */}
        <div className="building-selector-wrapper" ref={dropdownRef} style={{ position: 'relative', margin: '0 3px 16px' }}>
          <button
            type="button"
            className="building"
            onClick={() => setDropdownOpen(!dropdownOpen)}
            style={{ width: '100%', margin: 0, cursor: 'pointer' }}
            title="Nhấn để chọn tòa nhà vận hành"
          >
            <Icon name="domain" />
            <span>
              <small>Cụm vận hành ({buildings.length > 0 ? `${buildings.length} tòa` : 'Đang tải'})</small>
              <strong>{currentBuilding?.name || 'Tòa Ruby Suites'}</strong>
            </span>
            <Icon name={dropdownOpen ? 'expand_less' : 'unfold_more'} />
          </button>

          {dropdownOpen && (
            <div
              className="building-dropdown-menu"
              style={{
                position: 'absolute',
                top: '100%',
                left: 0,
                right: 0,
                marginTop: '6px',
                background: '#ffffff',
                border: '1px solid #dce7f7',
                borderRadius: '10px',
                boxShadow: '0 10px 25px rgba(15, 23, 42, 0.15)',
                zIndex: 100,
                maxHeight: '320px',
                overflowY: 'auto',
                padding: '6px'
              }}
            >
              <div style={{ padding: '6px 8px', fontSize: '11px', fontWeight: 700, color: '#64748b', textTransform: 'uppercase' }}>
                Chọn Tòa Nhà Vận Hành
              </div>
              <button
                type="button"
                className={`building-dropdown-item ${selectedBuildingId === 'All' ? 'active' : ''}`}
                onClick={() => {
                  onSelectBuilding('All')
                  setDropdownOpen(false)
                }}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '8px 10px',
                  borderRadius: '6px',
                  border: 'none',
                  background: selectedBuildingId === 'All' ? '#e5efff' : 'transparent',
                  color: selectedBuildingId === 'All' ? '#2563eb' : '#1e293b',
                  fontSize: '12px',
                  fontWeight: selectedBuildingId === 'All' ? 700 : 500,
                  cursor: 'pointer',
                  textAlign: 'left'
                }}
              >
                <Icon name="corporate_fare" />
                <span style={{ flex: 1 }}>Tất cả tòa nhà (Toàn dự án)</span>
                {selectedBuildingId === 'All' && <Icon name="check" />}
              </button>
              <hr style={{ margin: '4px 0', border: 'none', borderTop: '1px solid #f1f5f9' }} />
              {buildings.filter(b => b.id !== 'All').map((b) => {
                const isSelected = b.id === selectedBuildingId
                return (
                  <button
                    key={b.id}
                    type="button"
                    className={`building-dropdown-item ${isSelected ? 'active' : ''}`}
                    onClick={() => {
                      onSelectBuilding(b.id)
                      setDropdownOpen(false)
                    }}
                    style={{
                      width: '100%',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '8px',
                      padding: '8px 10px',
                      borderRadius: '6px',
                      border: 'none',
                      background: isSelected ? '#e5efff' : 'transparent',
                      color: isSelected ? '#2563eb' : '#1e293b',
                      fontSize: '12px',
                      fontWeight: isSelected ? 700 : 500,
                      cursor: 'pointer',
                      textAlign: 'left',
                      marginBottom: '2px'
                    }}
                  >
                    <Icon name="apartment" />
                    <span style={{ flex: 1 }}>
                      <div>{b.name}</div>
                      <small style={{ fontSize: '10px', color: '#64748b', display: 'block' }}>
                        {b.buildingCode} · {b.totalFloors} tầng · {b.totalApartments > 0 ? `${b.totalApartments} căn` : 'Đang cập nhật'}
                      </small>
                    </span>
                    {isSelected && <Icon name="check" />}
                  </button>
                )
              })}
            </div>
          )}
        </div>

        <nav>
          {(['Vận hành', 'Quản trị'] as const).map((group) => (
            <section key={group}>
              <p>{group}</p>
              {navigation
                .filter((item) => item.group === group)
                .map((item) => (
                  <button
                    key={item.id}
                    className={active === item.id ? 'active' : ''}
                    onClick={() => onSelect(item.id)}
                  >
                    <Icon name={item.icon} />
                    <span>{item.label}</span>
                  </button>
                ))}
            </section>
          ))}
        </nav>

        <div className="support">
          <span className="support-icon">
            <Icon name="support_agent" />
          </span>
          <div>
            <strong>Hotline kỹ thuật</strong>
            <small>Nhánh 102 · 24/7</small>
          </div>
          <Icon name="call" />
        </div>
      </aside>

      {open && <button className="scrim" onClick={onClose} aria-label="Đóng menu" />}
    </>
  )
}
