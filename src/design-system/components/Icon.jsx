/**
 * Numaya icon set. 24px grid, round caps and joins, currentColor.
 * Default stroke follows the icon.stroke token (1.75); filled controls use 2.
 */
const PATHS = {
  chevronLeft: <path d="M14.5 5.5 8 12l6.5 6.5" />,
  chevronRight: <path d="M9.5 5.5 16 12l-6.5 6.5" />,
  chevronDown: <path d="m6.5 9.5 5.5 5.5 5.5-5.5" />,
  chevronUp: <path d="m6.5 14.5 5.5-5.5 5.5 5.5" />,
  arrowRight: <path d="M5 12h13.5M13 6.5l5.5 5.5-5.5 5.5" />,
  arrowUp: <path d="M12 19V5.5M6.5 11 12 5.5l5.5 5.5" />,
  check: <path d="m5.5 12.5 4.25 4.25L18.5 8" />,
  plus: <path d="M12 5.5v13M5.5 12h13" />,
  close: <path d="M6.5 6.5l11 11M17.5 6.5l-11 11" />,
  search: (
    <>
      <circle cx="11" cy="11" r="6.25" />
      <path d="m20 20-4.4-4.4" />
    </>
  ),
  lock: (
    <>
      <rect x="5.25" y="10.75" width="13.5" height="9.5" rx="2.5" />
      <path d="M8.5 10.75V8a3.5 3.5 0 0 1 7 0v2.75" />
    </>
  ),
  heart: (
    <path d="M12 19.25s-7.25-4.3-7.25-9.6A3.9 3.9 0 0 1 8.7 5.75c1.45 0 2.6.75 3.3 1.95.7-1.2 1.85-1.95 3.3-1.95a3.9 3.9 0 0 1 3.95 3.9c0 5.3-7.25 9.6-7.25 9.6Z" />
  ),
  star: <path d="m12 4.75 2.2 4.55 5 .7-3.6 3.5.85 4.95L12 16.1l-4.45 2.35.85-4.95-3.6-3.5 5-.7L12 4.75Z" />,
  delete: (
    <>
      <path d="M9.2 5.75h9.05a2 2 0 0 1 2 2v8.5a2 2 0 0 1-2 2H9.2a2 2 0 0 1-1.5-.68L3.75 12l3.95-5.57a2 2 0 0 1 1.5-.68Z" />
      <path d="m11.5 9.5 5 5m0-5-5 5" />
    </>
  ),
  message: (
    <path d="M12 4.75c4.56 0 8.25 3.02 8.25 6.75s-3.69 6.75-8.25 6.75c-.9 0-1.77-.12-2.58-.34L5.25 19.5l.92-3.42C4.61 14.86 3.75 13.25 3.75 11.5c0-3.73 3.69-6.75 8.25-6.75Z" />
  ),
  shield: (
    <>
      <path d="M12 3.75 5.25 6.5v5c0 4.2 2.9 7.3 6.75 8.75 3.85-1.45 6.75-4.55 6.75-8.75v-5L12 3.75Z" />
      <path d="m9 12.25 2.1 2.1L15.25 10" />
    </>
  ),
  verified: (
    <>
      <path d="M12 3.5 14.2 5l2.65-.1.85 2.5 2.1 1.6-.8 2.5.8 2.5-2.1 1.6-.85 2.5-2.65-.1L12 20.5 9.8 19l-2.65.1-.85-2.5-2.1-1.6.8-2.5-.8-2.5 2.1-1.6.85-2.5L9.8 5 12 3.5Z" />
      <path d="m9 12.25 2.1 2.1L15.25 10" />
    </>
  ),
  flag: <path d="M6 20.25V4.75m0 0h10.5l-2 4 2 4H6" />,
  info: (
    <>
      <circle cx="12" cy="12" r="8.25" />
      <path d="M12 11v5M12 7.75v.01" />
    </>
  ),
  alert: (
    <>
      <path d="M10.3 4.9 3.6 16.6a2 2 0 0 0 1.73 3h13.34a2 2 0 0 0 1.73-3L13.7 4.9a2 2 0 0 0-3.4 0Z" />
      <path d="M12 9.5v4M12 16.75v.01" />
    </>
  ),
  wifiOff: (
    <>
      <path d="M4 9.5a12 12 0 0 1 4.2-2.5M12 6.5c2.9 0 5.6 1.1 7.9 3" />
      <path d="M7 12.6a7.6 7.6 0 0 1 3-1.6M14.6 11.3c.9.35 1.7.8 2.4 1.4" />
      <path d="M10.3 15.6a2.6 2.6 0 0 1 3.4 0M12 19h.01M4.5 4.5l15 15" />
    </>
  ),
  camera: (
    <>
      <path d="M4.75 8.75a2 2 0 0 1 2-2h1.6l1.4-2h4.5l1.4 2h1.6a2 2 0 0 1 2 2v8.5a2 2 0 0 1-2 2H6.75a2 2 0 0 1-2-2v-8.5Z" />
      <circle cx="12" cy="12.75" r="3.25" />
    </>
  ),
  image: (
    <>
      <rect x="4.25" y="4.75" width="15.5" height="14.5" rx="2.75" />
      <circle cx="9.25" cy="9.75" r="1.5" />
      <path d="m19.5 15.5-4.25-4.25L6 19" />
    </>
  ),
  mic: (
    <>
      <rect x="9" y="3.75" width="6" height="10.5" rx="3" />
      <path d="M5.75 11.5a6.25 6.25 0 0 0 12.5 0M12 17.75v2.5" />
    </>
  ),
  send: <path d="M5 12 19.25 5l-4 14.25-3.1-5.85L5 12Zm7.15 1.4L19.25 5" />,
  more: (
    <>
      <circle cx="6" cy="12" r="1.25" fill="currentColor" />
      <circle cx="12" cy="12" r="1.25" fill="currentColor" />
      <circle cx="18" cy="12" r="1.25" fill="currentColor" />
    </>
  ),
  filter: <path d="M4.75 7h9.5M18.25 7h1M4.75 17h1M9.75 17h9.5M16.25 4.75v4.5M7.75 14.75v4.5" />,
  settings: (
    <>
      <circle cx="12" cy="12" r="2.75" />
      <path d="M12 3.75v2M12 18.25v2M20.25 12h-2M5.75 12h-2M17.85 6.15l-1.4 1.4M7.55 16.45l-1.4 1.4M17.85 17.85l-1.4-1.4M7.55 7.55l-1.4-1.4" />
    </>
  ),
  user: (
    <>
      <circle cx="12" cy="8.5" r="3.75" />
      <path d="M4.75 19.5c1.2-3.3 4-5 7.25-5s6.05 1.7 7.25 5" />
    </>
  ),
  location: (
    <>
      <path d="M12 20.25s6.25-5.4 6.25-10.25a6.25 6.25 0 1 0-12.5 0c0 4.85 6.25 10.25 6.25 10.25Z" />
      <circle cx="12" cy="10" r="2.25" />
    </>
  ),
  bell: (
    <>
      <path d="M6.25 16.5V11a5.75 5.75 0 0 1 11.5 0v5.5l1.5 1.75H4.75l1.5-1.75Z" />
      <path d="M10 20.25h4" />
    </>
  ),
  eyeOff: (
    <>
      <path d="M9.9 5.4A8.6 8.6 0 0 1 12 5.25c4.6 0 7.75 4.25 8.5 6.75-.35 1.15-1.2 2.7-2.55 4.05M14.1 18.6a8.6 8.6 0 0 1-2.1.15c-4.6 0-7.75-4.25-8.5-6.75.35-1.15 1.2-2.7 2.55-4.05" />
      <path d="M4.5 4.5l15 15" />
    </>
  ),
  undo: <path d="M8.5 6.5 4.75 10.25 8.5 14M5 10.25h9.25a5 5 0 0 1 0 10H11" />,
  sparkle: <path d="M12 4.25c.7 3.9 2.85 6.05 6.75 6.75-3.9.7-6.05 2.85-6.75 6.75-.7-3.9-2.85-6.05-6.75-6.75 3.9-.7 6.05-2.85 6.75-6.75Z" />,
};

export const ICON_NAMES = Object.keys(PATHS);

export function Icon({ name, size = 24, stroke = 1.75, className, ...rest }) {
  return (
    <svg
      className={className}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={stroke}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...rest}
    >
      {PATHS[name]}
    </svg>
  );
}
