import type React from 'react'
import { localIcons } from '../assets/icons'

type Props = { name: string; className?: string; style?: React.CSSProperties }

export function Icon({ name, className = '', style }: Props) {
  const svg = localIcons[name]
  if (svg) {
    return (
      <span
        className={`local-icon material-symbols-outlined ${className}`}
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          width: '1em',
          height: '1em',
          verticalAlign: '-0.125em',
          lineHeight: 1,
          ...style
        }}
        dangerouslySetInnerHTML={{ __html: svg }}
      />
    )
  }

  // Fallback icon for any unknown name
  return (
    <span
      className={`local-icon material-symbols-outlined ${className}`}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: '1em',
        height: '1em',
        verticalAlign: '-0.125em',
        lineHeight: 1,
        ...style
      }}
      title={name}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="1em"
        height="1em"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <circle cx="12" cy="12" r="10" />
        <line x1="12" y1="8" x2="12" y2="12" />
        <line x1="12" y1="16" x2="12.01" y2="16" />
      </svg>
    </span>
  )
}
