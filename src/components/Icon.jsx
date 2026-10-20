const PATHS = {
  chevronLeft: <path d="M14.5 5.5 8 12l6.5 6.5" />,
  chevronRight: <path d="M9.5 5.5 16 12l-6.5 6.5" />,
  chevronDown: <path d="m6.5 9.5 5.5 5.5 5.5-5.5" />,
  arrowRight: <path d="M5 12h13.5M13 6.5l5.5 5.5-5.5 5.5" />,
  check: <path d="m5.5 12.5 4.25 4.25L18.5 8" />,
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
  close: <path d="M6.5 6.5l11 11M17.5 6.5l-11 11" />,
  delete: (
    <>
      <path d="M9.2 5.75h9.05a2 2 0 0 1 2 2v8.5a2 2 0 0 1-2 2H9.2a2 2 0 0 1-1.5-.68L3.75 12l3.95-5.57a2 2 0 0 1 1.5-.68Z" />
      <path d="m11.5 9.5 5 5m0-5-5 5" />
    </>
  ),
  message: (
    <path d="M12 4.75c4.56 0 8.25 3.02 8.25 6.75s-3.69 6.75-8.25 6.75c-.9 0-1.77-.12-2.58-.34L5.25 19.5l.92-3.42C4.61 14.86 3.75 13.25 3.75 11.5c0-3.73 3.69-6.75 8.25-6.75Z" />
  ),
};

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
