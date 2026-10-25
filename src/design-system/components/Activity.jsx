import { cx } from "../../lib/cx.js";
import { Avatar, Badge, ImagePlaceholder, VerifiedBadge } from "./Content.jsx";
import { Icon } from "./Icon.jsx";

/* Status vocabulary shared by activity cards and details. Every status is written out. */
const STATUS = {
  live: { tone: "brand", icon: "clock", label: "Live now" },
  full: { tone: "warning", icon: "groups", label: "Full" },
  cancelled: { tone: "danger", icon: "eventBusy", label: "Cancelled" },
  past: { tone: "neutral", icon: "check", label: "Ended" },
  draft: { tone: "neutral", icon: "draft", label: "Draft" },
};
const PARTICIPATION = {
  joined: { tone: "success", icon: "check", label: "You’re going" },
  requested: { tone: "neutral", icon: "pending", label: "Requested" },
  waitlisted: { tone: "warning", icon: "waitlist", label: "On the waitlist" },
  host: { tone: "brand", icon: "star", label: "You’re hosting" },
};

/** Activity status (live, full, cancelled, past, draft) or participation (joined, requested…). */
export function ActivityStatus({ status, participation }) {
  const s = STATUS[status] ?? PARTICIPATION[participation];
  if (!s) return null;
  return (
    <Badge tone={s.tone} icon={s.icon}>
      {s.label}
    </Badge>
  );
}

/** Icon + text metadata line (date and time, place, attendees). */
export function MetaRow({ icon, children, className }) {
  return (
    <p className={cx("meta-row", className)}>
      <Icon name={icon} size={18} className="meta-row__icon" />
      <span className="meta-row__text">{children}</span>
    </p>
  );
}

/** A person with an avatar, name, optional verified seal and a caption (host, attendee rows). */
export function IdentityRow({ name, verified = false, caption, size = "sm", trailing, className }) {
  return (
    <div className={cx("identity-row", className)}>
      <Avatar name={name} size={size} decorative />
      <span className="identity-row__text">
        <span className="identity-row__name">
          {name}
          {verified && <VerifiedBadge compact />}
        </span>
        {caption && <span className="identity-row__caption">{caption}</span>}
      </span>
      {trailing}
    </div>
  );
}

/**
 * Overlapping initial avatars for the first few named attendees, then a count. `total` is the full
 * head count; only `names` are identified, the rest stay a number.
 */
export function AttendeeStack({ names = [], total, max = 4, label }) {
  const shown = names.slice(0, max);
  return (
    <span className="attendee-stack" role="img" aria-label={label ?? `${total} going`}>
      {shown.map((n) => (
        <Avatar key={n} name={n} size="xs" decorative className="attendee-stack__avatar" />
      ))}
      <span className="attendee-stack__count" aria-hidden="true">
        {total} going
      </span>
    </span>
  );
}

/**
 * Hero image for an activity: the supplied photo, or a designed fallback (the category glyph on a
 * neutral tone). Never a fake photo.
 */
export function ActivityMedia({ src, tone, icon = "event", label, ratio = "16 / 9", className, children }) {
  return (
    <div className={cx("activity-media", className)}>
      {src ? (
        <img className="activity-media__img" src={src} alt={label ?? ""} style={{ aspectRatio: ratio }} />
      ) : tone != null ? (
        <ImagePlaceholder tone={tone} ratio={ratio} label={label}>
          <Icon name={icon} size={36} className="image-placeholder__icon" />
        </ImagePlaceholder>
      ) : (
        <div className="activity-media__fallback" style={{ aspectRatio: ratio }} role={label ? "img" : undefined} aria-label={label}>
          <Icon name={icon} size={40} />
        </div>
      )}
      {children && <div className="activity-media__badges">{children}</div>}
    </div>
  );
}

/**
 * Activity card for feeds and lists. The whole card opens the details; the status and
 * participation badges sit on the image. Only the general place is shown, never a precise location.
 */
export function ActivityCard({ id, title, category, categoryIcon, host, when, place, going, capacity, attendees, status, participation, tone, src, onOpen, compact = false }) {
  const capacityText = capacity ? ` of ${capacity}` : "";
  return (
    <article className={cx("activity-card", compact && "activity-card--compact")} data-activity={id}>
      <button type="button" className="activity-card__hit" onClick={onOpen}>
        <ActivityMedia tone={tone} src={src} icon={categoryIcon} ratio={compact ? "1 / 1" : "16 / 9"} className="activity-card__media">
          {(status || participation) && (
            <>
              <ActivityStatus status={status} />
              <ActivityStatus participation={participation} />
            </>
          )}
        </ActivityMedia>
        <span className="activity-card__body">
          <span className="activity-card__title">{title}</span>
          <span className="activity-card__category">{category}</span>
          <MetaRow icon="calendar">{when}</MetaRow>
          <MetaRow icon="location">{place}</MetaRow>
          <span className="activity-card__foot">
            {host && (
              <span className="activity-card__host">
                Hosted by {host.name}
                {host.verified && <VerifiedBadge compact />}
              </span>
            )}
            <AttendeeStack names={attendees} total={going} label={`${going}${capacityText} going`} />
          </span>
        </span>
      </button>
    </article>
  );
}
