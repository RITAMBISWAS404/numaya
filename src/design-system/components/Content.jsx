import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";
import { IconButton } from "./Button.jsx";

/* -------------------------------------------------------------------------- */
/* Identity                                                                    */
/* -------------------------------------------------------------------------- */

/**
 * Avatar. size: xs | sm | md | lg | xl. Optional ring: { value 0–1, tone: "brand" | "muted" }
 * for profile completion or match countdown.
 */
export function Avatar({ name, src, size = "md", ring, verified = false, decorative = false, className }) {
  const initial = name?.trim()?.[0]?.toUpperCase() ?? "";
  return (
    <span className={cx("avatar", `avatar--${size}`, ring && "has-ring", className)} aria-hidden={decorative || undefined}>
      {ring && (
        <svg className={cx("avatar__ring", `avatar__ring--${ring.tone ?? "brand"}`)} viewBox="0 0 36 36" aria-hidden="true">
          <circle cx="18" cy="18" r="16.5" pathLength="100" className="avatar__ring-track" />
          <circle
            cx="18"
            cy="18"
            r="16.5"
            pathLength="100"
            className="avatar__ring-value"
            style={{ strokeDasharray: `${Math.round(ring.value * 100)} 100` }}
          />
        </svg>
      )}
      <span className="avatar__image" role={decorative ? undefined : "img"} aria-label={decorative ? undefined : name}>
        {src ? <img src={src} alt="" /> : initial}
      </span>
      {verified && (
        <span className="avatar__badge" aria-hidden="true">
          <Icon name="check" size={10} stroke={3} />
        </span>
      )}
    </span>
  );
}

/** Verified mark: ink check on the exact brand pink, always paired with a text label. */
export function VerifiedBadge({ label = "Verified", compact = false }) {
  return (
    <span className={cx("verified", compact && "verified--compact")}>
      <span className="verified__mark" aria-hidden="true">
        <Icon name="check" size={compact ? 10 : 12} stroke={3} />
      </span>
      {compact ? <span className="visually-hidden">{label}</span> : <span>{label}</span>}
    </span>
  );
}

/** Badge: small status label. tone: neutral | brand | success | warning | danger | inverse. */
export function Badge({ tone = "neutral", icon, children }) {
  return (
    <span className={cx("badge", `badge--${tone}`)}>
      {icon && <Icon name={icon} size={12} stroke={2.2} />}
      {children}
    </span>
  );
}

/** Numeric count for tabs and avatars. Caps at 99+. */
export function CountBadge({ count, label }) {
  if (!count) return null;
  return (
    <span className="count-badge" aria-label={label ?? `${count} new`}>
      {count > 99 ? "99+" : count}
    </span>
  );
}

/** Eyebrow / tag text: uppercase, tracked. */
export function Tag({ tone = "brand", children }) {
  return <span className={cx("tag", `tag--${tone}`)}>{children}</span>;
}

/* -------------------------------------------------------------------------- */
/* Surfaces and lists                                                          */
/* -------------------------------------------------------------------------- */

export function Card({ as: As = "div", padded = true, elevated = false, className, children, ...rest }) {
  return (
    <As className={cx("card", padded && "card--padded", elevated && "card--elevated", className)} {...rest}>
      {children}
    </As>
  );
}

export function Section({ title, description, action, children }) {
  return (
    <section className="section">
      {(title || description) && (
        <header className="section__header">
          <div>
            {title && <h3 className="section__title">{title}</h3>}
            {description && <p className="section__description">{description}</p>}
          </div>
          {action}
        </header>
      )}
      {children}
    </section>
  );
}

export function Divider({ inset = false }) {
  return <hr className={cx("divider", inset && "divider--inset")} />;
}

/** Rounded group of list rows with an optional footnote (settings, profile details). */
export function ListGroup({ title, footnote, plain = false, children }) {
  return (
    <div className={cx("list-group", plain && "list-group--plain")}>
      {title && <p className="list-group__title">{title}</p>}
      <ul className="list-group__items">{children}</ul>
      {footnote && <p className="list-group__footnote">{footnote}</p>}
    </div>
  );
}

/**
 * List row. kind: "nav" (chevron), "value" (value + chevron), "action" (centred),
 * "destructive", "locked" (premium). Rendered as a button when onPress is set.
 */
export function ListRow({ icon, label, value, description, kind = "nav", onPress, trailing }) {
  const content = (
    <>
      {icon && <Icon name={icon} size={20} className="list-row__icon" />}
      <span className="list-row__text">
        <span className="list-row__label">{label}</span>
        {description && <span className="list-row__description">{description}</span>}
      </span>
      {value && <span className="list-row__value">{value}</span>}
      {trailing}
      {kind === "locked" && <Icon name="lock" size={18} className="list-row__trail" />}
      {(kind === "nav" || kind === "value") && <Icon name="chevronRight" size={18} stroke={2} className="list-row__trail" />}
    </>
  );
  return (
    <li className={cx("list-row", `list-row--${kind}`)}>
      {onPress ? (
        <button type="button" className="list-row__hit" onClick={onPress}>
          {content}
        </button>
      ) : (
        <div className="list-row__hit">{content}</div>
      )}
    </li>
  );
}

export function TipCard({ icon = "sparkle", title, children, onPress }) {
  const Tag = onPress ? "button" : "div";
  return (
    <Tag type={onPress ? "button" : undefined} className={cx("tip-card", onPress && "tip-card--action")} onClick={onPress}>
      <span className="tip-card__icon" aria-hidden="true">
        <Icon name={icon} size={20} />
      </span>
      <span className="tip-card__text">
        <span className="tip-card__title">{title}</span>
        {children && <span className="tip-card__body">{children}</span>}
      </span>
      {onPress && <Icon name="chevronRight" size={18} stroke={2} className="tip-card__chevron" />}
    </Tag>
  );
}

/** Icon + statement rows explaining the consequences of an action (unmatch, delete). */
export function ConsequenceList({ items }) {
  return (
    <ul className="consequences">
      {items.map((item) => (
        <li key={item.text} className="consequences__item">
          <Icon name={item.icon} size={20} />
          <span>{item.text}</span>
        </li>
      ))}
    </ul>
  );
}

/* -------------------------------------------------------------------------- */
/* Profile content                                                             */
/* -------------------------------------------------------------------------- */

/** Question + answer. Answer in the display serif. Editable variant shows edit/remove. */
export function PromptCard({ prompt, answer, onEdit, onRemove, className }) {
  return (
    <article className={cx("prompt", className)}>
      <p className="prompt__label">{prompt}</p>
      <p className="prompt__answer">{answer}</p>
      {(onEdit || onRemove) && (
        <div className="prompt__actions">
          {onEdit && <IconButton icon="chevronRight" label={`Edit answer to ${prompt}`} variant="plain" size="sm" onClick={onEdit} />}
          {onRemove && <IconButton icon="close" label={`Remove ${prompt}`} variant="plain" size="sm" onClick={onRemove} />}
        </div>
      )}
    </article>
  );
}

const PLACEHOLDER_TONES = ["sky", "stone", "mist", "sand"];

/** Image with a calm neutral placeholder while loading or when absent. */
export function ImagePlaceholder({ label, tone = 0, ratio = "4 / 5", className, children }) {
  return (
    <div
      className={cx("image-placeholder", `image-placeholder--${PLACEHOLDER_TONES[tone % PLACEHOLDER_TONES.length]}`, className)}
      style={{ aspectRatio: ratio }}
      role={label ? "img" : undefined}
      aria-label={label}
    >
      {children ?? <Icon name="image" size={28} stroke={1.5} className="image-placeholder__icon" />}
    </div>
  );
}

/** Photo slot in the profile grid. Empty slots are add buttons. */
export function PhotoSlot({ index, filled = false, tone = 0, main = false, uploading = false, onAdd, onRemove }) {
  if (!filled) {
    return (
      <button type="button" className="photo-slot photo-slot--empty" aria-label={`Add photo ${index + 1}`} onClick={onAdd}>
        <Icon name="plus" size={24} stroke={1.8} />
      </button>
    );
  }
  return (
    <div className={cx("photo-slot", uploading && "is-uploading")}>
      <ImagePlaceholder tone={tone} ratio="3 / 4" label={`Photo ${index + 1}`}>
        <span className="photo-slot__index">{main ? "Main" : index + 1}</span>
      </ImagePlaceholder>
      {uploading ? (
        <span className="photo-slot__status" role="status">
          <span className="spinner spinner--sm" aria-hidden="true" />
          <span className="visually-hidden">Uploading</span>
        </span>
      ) : (
        <button type="button" className="photo-slot__remove" aria-label={`Remove photo ${index + 1}`} onClick={onRemove}>
          <Icon name="close" size={14} stroke={2.4} />
        </button>
      )}
    </div>
  );
}

/** 3 × 2 profile photo grid. photos: [{ id, tone, uploading? }]. */
export function PhotoGrid({ photos, slots = 6, onAdd, onRemove, hint = "Hold and drag to reorder" }) {
  return (
    <div className="photo-grid-wrap">
      <div className="photo-grid">
        {Array.from({ length: slots }, (_, i) => {
          const p = photos[i];
          return (
            <PhotoSlot
              key={p?.id ?? `empty-${i}`}
              index={i}
              filled={Boolean(p)}
              tone={p?.tone}
              main={i === 0}
              uploading={p?.uploading}
              onAdd={() => onAdd?.(i)}
              onRemove={() => onRemove?.(p.id)}
            />
          );
        })}
      </div>
      {hint && (
        <p className="photo-grid__hint">
          <Icon name="info" size={14} stroke={2} /> {hint}
        </p>
      )}
    </div>
  );
}

/**
 * Discovery card (reference: Bumble profile card). The photo fills the card; status pills, name, age
 * and the headline detail sit bottom-left over a legibility scrim; `actions` (e.g. a SuperSwipe
 * button) sits bottom-right on the photo. Without a photo, a neutral stand-in with a silhouette is
 * shown; it never pretends to be a photograph.
 */
export function ProfileCard({ name, age, verified, details = [], isNew = false, src, photoAlt, actions }) {
  const [headline] = details;
  return (
    <article className="profile-card" aria-label={`${name}, ${age}`}>
      <div className="profile-card__media">
        {src ? (
          <img className="profile-card__img" src={src} alt={photoAlt ?? `Photo of ${name}`} draggable="false" />
        ) : (
          <div className="profile-card__stand-in" role="img" aria-label={`${name} has not added a photo yet`}>
            <Icon name="image" size={40} />
          </div>
        )}
        <div className="profile-card__overlay">
          {(verified || isNew) && (
            <div className="profile-card__pills">
              {verified && (
                <span className="profile-card__pill">
                  <Icon name="verified" size={14} /> Verified
                </span>
              )}
              {isNew && <span className="profile-card__pill">New here</span>}
            </div>
          )}
          <h3 className="profile-card__name">
            {name}, {age}
          </h3>
          {headline && (
            <p className="profile-card__detail">
              <Icon name={headline.icon} size={16} weight="bold" /> {headline.text}
            </p>
          )}
        </div>
        {actions && <div className="profile-card__actions">{actions}</div>}
      </div>
    </article>
  );
}

/**
 * Pass / SuperSwipe / Like controls (reference: end of a Bumble profile). Pass and Like are ink
 * circles at the edges; SuperSwipe is the one accent action in the centre.
 */
export function ActionBar({ onPass, onSuper, onLike, superDisabled = false }) {
  return (
    <div className="action-bar">
      <button type="button" className="action-bar__btn action-bar__btn--pass" aria-label="Pass" onClick={onPass}>
        <Icon name="close" size={26} weight="bold" />
      </button>
      <button type="button" className="action-bar__btn action-bar__btn--super" aria-label="Super like" onClick={onSuper} disabled={superDisabled}>
        <Icon name="star" size={26} weight="fill" />
      </button>
      <button type="button" className="action-bar__btn action-bar__btn--like" aria-label="Like" onClick={onLike}>
        <Icon name="heart" size={26} weight="fill" />
      </button>
    </div>
  );
}

export function PageDots({ count, index, label = "Page" }) {
  return (
    <div className="page-dots" role="img" aria-label={`${label} ${index + 1} of ${count}`}>
      {Array.from({ length: count }, (_, i) => (
        <span key={i} className={cx(i === index && "is-current")} />
      ))}
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/* States                                                                      */
/* -------------------------------------------------------------------------- */

export function Skeleton({ width = "100%", height = 16, radius = "var(--radius-xs)", circle = false }) {
  return (
    <span
      className="skeleton"
      aria-hidden="true"
      style={{ width: circle ? height : width, height, borderRadius: circle ? "50%" : radius }}
    />
  );
}

/** One clear next step when there is nothing to show. */
/** Empty state. `art` reserves the illustration area with a neutral placeholder instead of an icon. */
export function EmptyState({ icon = "sparkle", art = false, title, children, action, onAction, tone = "neutral" }) {
  return (
    <div className={cx("empty-state", tone === "error" && "empty-state--error")}>
      {art ? (
        <span className="empty-state__art" aria-hidden="true" />
      ) : (
        <span className="empty-state__icon" aria-hidden="true">
          <Icon name={icon} size={28} />
        </span>
      )}
      <h3 className="empty-state__title">{title}</h3>
      {children && <p className="empty-state__body">{children}</p>}
      {action && (
        <button type="button" className={cx("btn btn--inline btn--sm", art ? "btn--primary" : "btn--secondary")} onClick={onAction}>
          <span className="btn__label">{action}</span>
        </button>
      )}
    </div>
  );
}

/** Completion feedback after a flow (verified, reported, purchased). */
export function ResultPanel({ tone = "success", icon = "check", title, children, footer }) {
  return (
    <div className={cx("result", `result--${tone}`)}>
      <span className="result__badge" aria-hidden="true">
        <Icon name={icon} size={30} stroke={2.75} />
      </span>
      <h2 className="result__title">{title}</h2>
      {children && <div className="result__body">{children}</div>}
      {footer && <div className="result__footer">{footer}</div>}
    </div>
  );
}
