import { Icon, Portal } from "../../design-system/index.js";
import { cx } from "../../lib/cx.js";
import { usePresence } from "../../lib/hooks/usePresence.js";

/** Simulated iOS banner notification that delivers the demo SMS code. System chrome, not product UI. */
export function Notification({ open, app, time = "now", title, body, onSelect }) {
  const mounted = usePresence(open, 360);
  if (!mounted) return null;
  return (
    <Portal>
      <button
        type="button"
        className={cx("notification", open ? "is-open" : "is-closing")}
        aria-label={`${app}, ${title}: ${body} Tap to fill in the code.`}
        onClick={onSelect}
      >
        <span className="notification__icon" aria-hidden="true">
          <Icon name="message" size={22} stroke={0} fill="currentColor" />
        </span>
        <span className="notification__content">
          <span className="notification__meta">
            <span className="notification__title">{title}</span>
            <span className="notification__time">{time}</span>
          </span>
          <span className="notification__body">{body}</span>
        </span>
      </button>
    </Portal>
  );
}
