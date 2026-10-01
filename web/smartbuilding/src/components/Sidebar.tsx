import { navigation } from '../data/navigation'
import { Icon } from './Icon'

type Props = { active: string; onSelect: (id: string) => void; open: boolean; onClose: () => void }
export function Sidebar({ active, onSelect, open, onClose }: Props) {
  return <><aside className={`sidebar ${open ? 'open' : ''}`}><div className="brand"><div className="brand-mark"><Icon name="apartment" /></div><div><strong>Aura Portal</strong><small>FACILITY INTELLIGENCE</small></div><button className="close-nav" onClick={onClose}><Icon name="close" /></button></div><button className="building"><Icon name="domain" /><span><small>Cụm vận hành</small><strong>Ruby Suites Residence</strong></span><Icon name="unfold_more" /></button><nav>{(['Vận hành', 'Quản trị'] as const).map((group) => <section key={group}><p>{group}</p>{navigation.filter((item) => item.group === group).map((item) => <button key={item.id} className={active === item.id ? 'active' : ''} onClick={() => onSelect(item.id)}><Icon name={item.icon} /><span>{item.label}</span></button>)}</section>)}</nav><div className="support"><span className="support-icon"><Icon name="support_agent" /></span><div><strong>Hotline kỹ thuật</strong><small>Nhánh 102 · 24/7</small></div><Icon name="call" /></div></aside>{open && <button className="scrim" onClick={onClose} aria-label="Đóng menu" />}</>
}
