import { forwardRef } from "react";
import { cx } from "../../lib/cx.js";
import { Avatar } from "./Content.jsx";
import { Icon } from "./Icon.jsx";

/**
 * Message bubble. from: "me" | "them". status (mine only): sending | sent | delivered | failed.
 * Failed messages expose retry and delete; text is never lost.
 */
export function MessageBubble({ from = "them", children, status, time, onRetry, onDelete, grouped = false }) {
  const mine = from === "me";
  return (
    <div className={cx("message", mine ? "message--me" : "message--them", grouped && "is-grouped", status && `is-${status}`)}>
      <div className="message__bubble">{children}</div>
      {mine && status === "failed" ? (
        <div className="message__failed" role="alert">
          <Icon name="alert" size={14} stroke={2} />
          <span>Not sent.</span>
          <button type="button" onClick={onRetry}>
            Retry
          </button>
          <button type="button" onClick={onDelete}>
            Delete
          </button>
        </div>
      ) : (
        (status || time) && (
          <p className="message__meta">
            {status === "sending" ? "Sending…" : status === "delivered" ? "Delivered" : status === "sent" ? "Sent" : null}
            {time && status ? " · " : null}
            {time}
          </p>
        )
      )}
    </div>
  );
}

/** Centred system line: dates, match events, call logs. */
export function SystemMessage({ children }) {
  return <p className="system-message">{children}</p>;
}

/**
 * Message composer. Send is enabled only with non-whitespace text; Enter sends,
 * Shift+Enter adds a line. Attachment actions are optional.
 */
export const Composer = forwardRef(function Composer(
  { value, onChange, onSend, placeholder = "Message", onAttach, disabled = false, maxLength = 1000 },
  ref,
) {
  const canSend = value.trim().length > 0 && !disabled;
  return (
    <form
      className={cx("composer", disabled && "is-disabled")}
      onSubmit={(e) => {
        e.preventDefault();
        if (canSend) onSend(value.trim());
      }}
    >
      {onAttach && (
        <button type="button" className="composer__icon" aria-label="Add photo" onClick={onAttach} disabled={disabled}>
          <Icon name="camera" size={22} />
        </button>
      )}
      <label className="composer__field">
        <span className="visually-hidden">Message</span>
        <textarea
          ref={ref}
          rows={1}
          value={value}
          maxLength={maxLength}
          placeholder={placeholder}
          disabled={disabled}
          onChange={(e) => onChange(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              if (canSend) onSend(value.trim());
            }
          }}
        />
      </label>
      <button type="submit" className="composer__send" aria-label="Send" disabled={!canSend}>
        <Icon name="arrowUp" size={20} stroke={2.2} />
      </button>
    </form>
  );
});

/** Inbox row: avatar, name, preview, time, unread / "Your move" indicators. */
export function ConversationRow({ name, preview, time, unread = 0, yourMove = false, verified = false, onPress }) {
  return (
    <li className="conversation">
      <button type="button" className="conversation__hit" onClick={onPress}>
        <Avatar name={name} size="lg" verified={verified} />
        <span className="conversation__text">
          <span className="conversation__top">
            <span className="conversation__name">{name}</span>
            {time && <span className="conversation__time">{time}</span>}
          </span>
          <span className="conversation__bottom">
            <span className={cx("conversation__preview", unread > 0 && "is-unread")}>{preview}</span>
            {yourMove && <span className="conversation__move">Your move</span>}
            {unread > 0 && (
              <span className="conversation__unread" aria-label={`${unread} unread`}>
                {unread}
              </span>
            )}
          </span>
        </span>
      </button>
    </li>
  );
}

/** Horizontal queue of new matches. ring.value = time remaining (0–1) when timers apply. */
export function MatchQueue({ matches, onSelect }) {
  return (
    <ul className="match-queue" aria-label="New matches">
      {matches.map((m) => (
        <li key={m.id}>
          <button type="button" className="match-queue__item" onClick={() => onSelect?.(m.id)}>
            <Avatar name={m.name} size="lg" ring={m.remaining != null ? { value: m.remaining, tone: m.remaining < 0.2 ? "muted" : "brand" } : undefined} />
            <span className="match-queue__name">{m.name}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
