import { Icon } from './Icon'
import { type BuildingItem } from '../data/api'

type Props = {
  query: string
  onQuery: (value: string) => void
  onMenu: () => void
  buildings?: BuildingItem[]
  selectedBuildingId?: string
  onSelectBuilding?: (buildingId: string) => void
}

export function Topbar({
  query,
  onQuery,
  onMenu,
  buildings = [],
  selectedBuildingId = 'B1',
  onSelectBuilding
}: Props) {
  const currentBuilding = buildings.find((b) => b.id === selectedBuildingId)

  return (
    <header className="topbar">
      <button className="menu-button" onClick={onMenu}>
        <Icon name="menu" />
      </button>

      <label className="search">
        <Icon name="search" />
        <input
          value={query}
          onChange={(event) => onQuery(event.target.value)}
          placeholder="Tìm căn hộ, cư dân, xe, hóa đơn..."
        />
      </label>

      {/* Building Quick Switcher */}
      {buildings.length > 0 && onSelectBuilding && (
        <div className="topbar-building-selector" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Icon name="domain" style={{ color: '#2563eb', fontSize: '18px' }} />
          <select
            value={selectedBuildingId}
            onChange={(e) => onSelectBuilding(e.target.value)}
            style={{
              padding: '6px 10px',
              borderRadius: '8px',
              border: '1px solid #dce7f7',
              background: '#f8fafc',
              fontSize: '12px',
              fontWeight: 600,
              color: '#1e293b',
              cursor: 'pointer',
              outline: 'none'
            }}
            title="Đổi tòa nhà làm việc"
          >
            <option value="All">🏢 Tất cả tòa nhà ({buildings.length} tòa)</option>
            {buildings
              .filter((b) => b.id !== 'All')
              .map((b) => (
                <option key={b.id} value={b.id}>
                  {b.name} ({b.buildingCode})
                </option>
              ))}
          </select>
        </div>
      )}

      <div className="top-actions">
        <span className="system-status">
          <i /> {currentBuilding ? currentBuilding.name : 'Ruby Suites'} · Vận hành
        </span>
        <button className="notification">
          <Icon name="notifications" />
          <b />
        </button>
        <span className="avatar">BQ</span>
      </div>
    </header>
  )
}
