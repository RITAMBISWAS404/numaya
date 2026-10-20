import { useEffect, useRef } from "react";
import { cx } from "../lib/cx.js";
import { usePresence } from "../hooks/usePresence.js";
import { Overlay } from "./DeviceContext.jsx";
import { Icon } from "./Icon.jsx";

const FOCUSABLE = 'button:not([disabled]), input:not([disabled]), [href], [tabindex]:not([tabindex="-1"])';

export function Sheet({ open, onClose, labelledBy, className, children }) {
  const mounted = usePresence(open, 320);
  const panelRef = useRef(null);
  const returnFocusRef = useRef(null);

  useEffect(() => {
    if (!open) return;
    returnFocusRef.current = document.activeElement;
    const first = panelRef.current?.querySelector("[data-autofocus]") ??
      panelRef.current?.querySelector(FOCUSABLE);
    first?.focus({ preventScroll: true });
    return () => returnFocusRef.current?.focus?.({ preventScroll: true });
  }, [open]);

  if (!mounted) return null;

  const onKeyDown = (e) => {
    if (e.key === "Escape") {
      e.stopPropagation();
      onClose?.();
      return;
    }
    if (e.key !== "Tab") return;
    const items = [...panelRef.current.querySelectorAll(FOCUSABLE)];
    if (!items.length) return;
    const first = items[0];
    const last = items[items.length - 1];
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  };

  return (
    <Overlay>
      <div className={cx("sheet", open ? "is-open" : "is-closing", className)}>
        <div className="sheet__scrim" onClick={onClose} aria-hidden="true" />
        <div
          ref={panelRef}
          className="sheet__panel"
          role="dialog"
          aria-modal="true"
          aria-labelledby={labelledBy}
          onKeyDown={onKeyDown}
        >
          <span className="sheet__grabber" aria-hidden="true" />
          {children}
        </div>
      </div>
    </Overlay>
  );
}

/** Small floating status, after Bumble's "Loading" pill. */
export function Pill({ open, busy = false, placement = "center", children }) {
  const mounted = usePresence(open, 240);
  if (!mounted) return null;
  return (
    <Overlay>
      <div
        className={cx("pill", `pill--${placement}`, open ? "is-open" : "is-closing")}
        role="status"
        aria-live="polite"
      >
        {busy && (
          <span className="pill__dots" aria-hidden="true">
            <span />
            <span />
            <span />
          </span>
        )}
        <span>{children}</span>
      </div>
    </Overlay>
  );
}

/** iOS-style banner notification, used to deliver the demo SMS code. */
export function Notification({ open, app, time = "now", title, body, onSelect }) {
  const mounted = usePresence(open, 360);
  if (!mounted) return null;
  return (
    <Overlay>
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
    </Overlay>
  );
}
