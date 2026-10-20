import { useEffect, useId, useRef } from "react";
import { cx } from "../../lib/cx.js";
import { usePresence } from "../../lib/hooks/usePresence.js";
import { Button } from "./Button.jsx";
import { Icon } from "./Icon.jsx";
import { Portal } from "./Portal.jsx";

const FOCUSABLE = 'button:not([disabled]), input:not([disabled]), textarea:not([disabled]), [href], [tabindex]:not([tabindex="-1"])';

/**
 * Focus the first [data-autofocus] (or focusable) element, trap Tab, restore focus on close.
 * `active` must be true only once the panel is mounted (open && mounted).
 */
function useModalFocus(active, panelRef) {
  useEffect(() => {
    if (!active) return;
    const previous = document.activeElement;
    const panel = panelRef.current;
    const first = panel?.querySelector("[data-autofocus]") ?? panel?.querySelector(FOCUSABLE);
    first?.focus({ preventScroll: true });
    return () => previous?.focus?.({ preventScroll: true });
  }, [active, panelRef]);

  return (e, onClose) => {
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
}

/** Bottom sheet: the primary modal surface. Omit onClose for a non-dismissable sheet. */
export function Sheet({ open, onClose, labelledBy, label, className, children }) {
  const mounted = usePresence(open, 320);
  const panelRef = useRef(null);
  const onKeyDown = useModalFocus(open && mounted, panelRef);
  if (!mounted) return null;

  return (
    <Portal>
      <div className={cx("sheet", open ? "is-open" : "is-closing", className)}>
        <div className="sheet__scrim" onClick={onClose} aria-hidden="true" />
        <div
          ref={panelRef}
          className="sheet__panel"
          role="dialog"
          aria-modal="true"
          aria-labelledby={labelledBy}
          aria-label={labelledBy ? undefined : label}
          onKeyDown={(e) => onKeyDown(e, onClose)}
        >
          <span className="sheet__grabber" aria-hidden="true" />
          {children}
        </div>
      </div>
    </Portal>
  );
}

/**
 * List of actions in a sheet. Each action: { label, onSelect, tone?: "destructive", icon? }.
 * Cancel is always present and last.
 */
export function ActionSheet({ open, onClose, title, actions }) {
  const titleId = useId();
  return (
    <Sheet open={open} onClose={onClose} labelledBy={title ? titleId : undefined} label="Actions" className="sheet--actions">
      {title && (
        <p id={titleId} className="action-sheet__title">
          {title}
        </p>
      )}
      <div className="action-sheet__list" role="group">
        {actions.map((a) => (
          <button
            key={a.label}
            type="button"
            className={cx("action-sheet__item", a.tone === "destructive" && "is-destructive")}
            onClick={() => {
              a.onSelect?.();
            }}
          >
            {a.icon && <Icon name={a.icon} size={20} />}
            {a.label}
          </button>
        ))}
      </div>
      <Button variant="secondary" onClick={onClose}>
        Cancel
      </Button>
    </Sheet>
  );
}

/**
 * Centred confirmation dialog for destructive or irreversible actions.
 * Cancel receives initial focus.
 */
export function Dialog({ open, onClose, title, children, confirmLabel = "Confirm", cancelLabel = "Cancel", tone = "default", onConfirm, loading = false }) {
  const mounted = usePresence(open, 220);
  const panelRef = useRef(null);
  const onKeyDown = useModalFocus(open && mounted, panelRef);
  const titleId = useId();
  const bodyId = useId();
  if (!mounted) return null;
  return (
    <Portal>
      <div className={cx("dialog", open ? "is-open" : "is-closing")}>
        <div className="dialog__scrim" onClick={onClose} aria-hidden="true" />
        <div
          ref={panelRef}
          className="dialog__panel"
          role="alertdialog"
          aria-modal="true"
          aria-labelledby={titleId}
          aria-describedby={bodyId}
          onKeyDown={(e) => onKeyDown(e, onClose)}
        >
          <h2 id={titleId} className="dialog__title">
            {title}
          </h2>
          <div id={bodyId} className="dialog__body">
            {children}
          </div>
          <div className="dialog__actions">
            <Button variant={tone === "destructive" ? "destructive-solid" : "primary"} loading={loading} onClick={onConfirm}>
              {confirmLabel}
            </Button>
            <Button variant="quiet" onClick={onClose} data-autofocus>
              {cancelLabel}
            </Button>
          </div>
        </div>
      </div>
    </Portal>
  );
}

/** Small floating status (after Bumble's "Loading" pill). Polite live region. */
export function Toast({ open, busy = false, placement = "center", icon, children }) {
  const mounted = usePresence(open, 240);
  if (!mounted) return null;
  return (
    <Portal>
      <div className={cx("pill", `pill--${placement}`, open ? "is-open" : "is-closing")} role="status" aria-live="polite">
        {busy && (
          <span className="pill__dots" aria-hidden="true">
            <span />
            <span />
            <span />
          </span>
        )}
        {icon && !busy && <Icon name={icon} size={16} stroke={2.2} />}
        <span>{children}</span>
      </div>
    </Portal>
  );
}

/** Coach mark / tooltip anchored above content, with optional step count. */
export function CoachMark({ title, children, step, total, actionLabel = "Got it", onDismiss, placement = "above" }) {
  return (
    <div className={cx("coach", `coach--${placement}`)} role="dialog" aria-label={title}>
      <p className="coach__title">{title}</p>
      {children && <p className="coach__body">{children}</p>}
      <div className="coach__footer">
        <Button variant="primary" size="sm" block={false} onClick={onDismiss}>
          {actionLabel}
        </Button>
        {total > 1 && (
          <span className="coach__step">
            {step} of {total}
          </span>
        )}
      </div>
    </div>
  );
}

const BANNER_ICON = { info: "info", warning: "alert", error: "alert", success: "check", offline: "wifiOff" };

/** Inline status banner for system states (offline, error, pending review). */
export function Banner({ tone = "info", title, children, action, onAction }) {
  return (
    <div className={cx("banner", `banner--${tone}`)} role={tone === "error" || tone === "offline" ? "alert" : "status"}>
      <Icon name={BANNER_ICON[tone]} size={20} stroke={1.9} className="banner__icon" />
      <div className="banner__content">
        {title && <p className="banner__title">{title}</p>}
        {children && <p className="banner__body">{children}</p>}
      </div>
      {action && (
        <button type="button" className="banner__action" onClick={onAction}>
          {action}
        </button>
      )}
    </div>
  );
}
