import { forwardRef, useImperativeHandle, useLayoutEffect, useRef } from "react";
import { cx } from "../../lib/cx.js";
import { Avatar, avatarTone, ringRectPath } from "./Content.jsx";
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

/* Composer field growth: one line at 44px, then up to five lines (120px), then it scrolls. */
const COMPOSER_MAX = 120;

/**
 * Message composer. Send is enabled only with non-whitespace text; Enter sends,
 * Shift+Enter adds a line. Attachment actions are optional. The field is a rounded rectangle
 * that grows with its text up to COMPOSER_MAX (CSS field-sizing where supported, measured otherwise).
 */
export const Composer = forwardRef(function Composer(
  { value, onChange, onSend, placeholder = "Message", onAttach, disabled = false, maxLength = 1000 },
  ref,
) {
  const canSend = value.trim().length > 0 && !disabled;
  const field = useRef(null);
  useImperativeHandle(ref, () => field.current, []);
  useLayoutEffect(() => {
    const el = field.current;
    if (!el || globalThis.CSS?.supports?.("field-sizing", "content")) return;
    el.style.height = "auto";
    el.style.height = `${Math.min(el.scrollHeight, COMPOSER_MAX)}px`;
  }, [value]);
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
          ref={field}
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
        <Icon name="arrowUp" size={18} stroke={2.2} />
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
/* Match-queue portraits: 72 x 96 portrait rectangles with the 20px card corner; the countdown ring
   sits 4px outside and follows the corner. Sizes mirror chat.css. */
const PORTRAIT = { w: 72, h: 96, r: 20, band: 4 };
const PORTRAIT_RING = ringRectPath(PORTRAIT.w + 2 * PORTRAIT.band, PORTRAIT.h + 2 * PORTRAIT.band, PORTRAIT.r + PORTRAIT.band / 2);

/**
 * New matches as portrait previews (Bumble match queue): the photo when there is one, otherwise the
 * initial on the person's pastel. A horizontal rail that scrolls when the matches outgrow the width. Unopened matches carry a brand ring; a
 * `remaining` value (0–1) draws the time left as a ring instead (muted when under 20%).
 */
export function MatchQueue({ matches, onSelect }) {
  return (
    <ul className="match-queue" aria-label="New matches">
      {matches.map((m) => (
        <li key={m.id}>
          <button type="button" className="match-queue__item" onClick={() => onSelect?.(m.id)}>
            <span className={cx("match-queue__portrait", m.remaining != null ? "has-ring" : "is-new")}>
              {m.remaining != null && (
                <svg
                  className={cx("avatar__ring", m.remaining < 0.2 && "avatar__ring--muted")}
                  viewBox={`0 0 ${PORTRAIT.w + 2 * PORTRAIT.band} ${PORTRAIT.h + 2 * PORTRAIT.band}`}
                  aria-hidden="true"
                >
                  <path d={PORTRAIT_RING} pathLength="100" className="avatar__ring-track" />
                  <path d={PORTRAIT_RING} pathLength="100" className="avatar__ring-value" style={{ strokeDasharray: `${Math.round(m.remaining * 100)} 100` }} />
                </svg>
              )}
              <span className={cx("match-queue__image", !m.src && `avatar--tone-${avatarTone(m.name)}`)} role="img" aria-label={m.name}>
                {m.src ? <img src={m.src} alt="" /> : m.name?.trim()?.[0]?.toUpperCase()}
              </span>
            </span>
            <span className="match-queue__name">{m.name}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
