import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";
import { IconButton } from "./Button.jsx";

/* -------------------------------------------------------------------------- */
/* Identity                                                                    */
/* -------------------------------------------------------------------------- */

/* Avatar sizes in px (mirror --size-avatar-*; a unit test keeps them in sync). The completion ring
   is drawn in pixel space so its 4px band and round caps are the same at every size. */
export const AVATAR_PX = { xs: 24, sm: 36, md: 48, lg: 64, xl: 96 };
/* Avatars are rounded rectangles: corner radius = 30% of the image's side (mirrors content.css). */
export const AVATAR_RADIUS = 0.3;
const RING_BAND = 4;
const ringPaths = {};

/** Rounded rectangle centreline starting at the top centre and running clockwise, so a
    stroke-dasharray on pathLength=100 reads as progress. Shared by avatar and portrait rings. */
export function ringRectPath(w, h, r, inset = RING_BAND / 2) {
  const f = (v) => v.toFixed(2);
  const [l, t, rt, b] = [inset, inset, w - inset, h - inset];
  return `M${f(w / 2)} ${f(t)}H${f(rt - r)}A${f(r)} ${f(r)} 0 0 1 ${f(rt)} ${f(t + r)}V${f(b - r)}A${f(r)} ${f(r)} 0 0 1 ${f(rt - r)} ${f(b)}H${f(l + r)}A${f(r)} ${f(r)} 0 0 1 ${f(l)} ${f(b - r)}V${f(t + r)}A${f(r)} ${f(r)} 0 0 1 ${f(l + r)} ${f(t)}Z`;
}

/** Ring centreline for an avatar of `px`: concentric with the image, which sits 4px inside. */
function ringPath(px) {
  ringPaths[px] ??= ringRectPath(px, px, AVATAR_RADIUS * (px - 2 * RING_BAND) + RING_BAND / 2);
  return ringPaths[px];
}

/**
 * Avatar. size: xs | sm | md | lg | xl. Optional ring: { value 0–1, tone: "brand" | "muted" }
 * for profile completion or match countdown.
 */
/** Initial avatars take one of four Meetup pastel framings (pink, periwinkle, lavender, yellow),
    chosen from the name so a person keeps the same tint everywhere. */
export const avatarTone = (name = "") => [...name].reduce((h, c) => (h * 31 + c.charCodeAt(0)) >>> 0, 7) % 4;

export function Avatar({ name, src, size = "md", ring, verified = false, decorative = false, className }) {
  const initial = name?.trim()?.[0]?.toUpperCase() ?? "";
  return (
    <span className={cx("avatar", `avatar--${size}`, !src && `avatar--tone-${avatarTone(name)}`, ring && "has-ring", className)} aria-hidden={decorative || undefined}>
      {ring && (
        <svg
          className={cx("avatar__ring", `avatar__ring--${ring.tone ?? "brand"}`)}
          viewBox={`0 0 ${AVATAR_PX[size]} ${AVATAR_PX[size]}`}
          aria-hidden="true"
        >
          <path d={ringPath(AVATAR_PX[size])} pathLength="100" className="avatar__ring-track" />
          <path
            d={ringPath(AVATAR_PX[size])}
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
          <Icon name="check" size={12} strokeWidth={3.5} />
        </span>
      )}
    </span>
  );
}

/** Verified mark: a white check on brand purple, always paired with a text label. */
export function VerifiedBadge({ label = "Verified", compact = false }) {
  return (
    <span className={cx("verified", compact && "verified--compact")}>
      <span className="verified__mark" aria-hidden="true">
        <Icon name="check" size={compact ? 12 : 13} strokeWidth={3.5} />
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

/**
 * Information card: a grouped privacy, guidance or safety message on its own quiet surface (white,
 * hairline, 20px), led by a filled icon. For short hints tied to one field, use the field's hint.
 */
export function InfoCard({ icon = "info", title, children, id, className }) {
  return (
    <div className={cx("info-card", className)} id={id}>
      <span className="info-card__icon" aria-hidden="true">
        <Icon name={icon} size={22} weight="duotone" />
      </span>
      <span className="info-card__text">
        <span className="info-card__title">{title}</span>
        {children && <span className="info-card__body">{children}</span>}
      </span>
    </div>
  );
}

const SETUP_STATUS = { done: "Done", active: "Next", upcoming: "Not started" };

/**
 * Profile setup progress: a white card listing the steps, each with its filled icon on a round tile
 * joined by a short connector. status per step: done (purple tile, white check), active (ink tile,
 * "Next") or upcoming (muted). The header counts finished steps; the active step is
 * aria-current="step", and every state is written out, not carried by colour alone.
 */
export function SetupProgress({ title, steps, className }) {
  const done = steps.filter((s) => s.status === "done").length;
  return (
    <section className={cx("setup-progress", className)} aria-label={title}>
      {title && (
        <header className="setup-progress__head">
          <span className="setup-progress__title">{title}</span>
          <span className="setup-progress__count">
            {done} of {steps.length} done
          </span>
        </header>
      )}
      <ol className="setup-progress__list">
        {steps.map((step) => (
          <li key={step.label} className={cx("setup-progress__step", `is-${step.status}`)} aria-current={step.status === "active" ? "step" : undefined}>
            <span className="setup-progress__icon" aria-hidden="true">
              <Icon name={step.status === "done" ? "check" : step.icon} size={20} weight={step.status === "done" ? "bold" : "fill"} />
            </span>
            <span className="setup-progress__text">
              <span className="setup-progress__label">{step.label}</span>
              {step.detail && <span className="setup-progress__detail">{step.detail}</span>}
            </span>
            <span className={cx("setup-progress__status", step.status === "upcoming" && "visually-hidden")}>{SETUP_STATUS[step.status]}</span>
          </li>
        ))}
      </ol>
    </section>
  );
}

/**
 * Interests you share with someone, on their profile. A white card (hairline + soft shadow, card
 * radius) with a small purple mark beside the title and grey pills with a leading icon (Meetup
 * "Shared interests"). items: [{ label, icon? }].
 */
export function SharedInterests({ title = "You both like", items, className }) {
  if (!items?.length) return null;
  return (
    <section className={cx("card", "shared-interests", className)}>
      <h2 className="shared-interests__title">
        <span className="shared-interests__mark" aria-hidden="true">
          <Icon name="heart" size={20} weight="fill" />
        </span>
        {title}
      </h2>
      <ul className="shared-interests__list">
        {items.map((item) => (
          <li key={item.label} className="chip chip--static shared-interests__pill">
            {item.icon && <Icon name={item.icon} size={16} className="chip__icon" />}
            {item.label}
          </li>
        ))}
      </ul>
    </section>
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

/**
 * Reserved area for supplied artwork (see docs/numaya-illustration-map.md). A quiet neutral block
 * until `src` is provided; decorative, so it is hidden from assistive tech either way. Distinct from
 * photo placeholders, which stand in for people's photos.
 */
export function IllustrationPlaceholder({ id, src, ratio = "1 / 1", width, size = "md", reserved = false, className }) {
  const props = {
    className: cx("illustration", `illustration--${size}`, reserved && !src && "illustration--reserved", className),
    style: { aspectRatio: ratio, width },
    "data-illustration": id,
  };
  return src ? <img {...props} src={src} alt="" /> : <div {...props} aria-hidden="true" />;
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
export function PhotoSlot({ index, filled = false, tone = 0, main = false, uploading = false, onAdd, onRemove, onSelect }) {
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
      {onSelect && !uploading && (
        <button type="button" className="photo-slot__select" aria-label={`Photo ${index + 1}${main ? ", main photo" : ""}: options`} onClick={onSelect} />
      )}
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

/** 3 × 2 profile photo grid. photos: [{ id, tone, uploading? }]. `onSelect(id)` makes filled photos tappable (photo options). */
export function PhotoGrid({ photos, slots = 6, onAdd, onRemove, onSelect, hint = "Hold and drag to reorder" }) {
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
              onSelect={onSelect && p ? () => onSelect(p.id) : undefined}
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
              <Icon name={headline.icon} size={16} /> {headline.text}
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
        <Icon name="close" size={26} strokeWidth={2.5} />
      </button>
      <button type="button" className="action-bar__btn action-bar__btn--super" aria-label="Super like" onClick={onSuper} disabled={superDisabled}>
        <Icon name="star" size={22} weight="fill" />
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
/**
 * Empty state. `art` reserves an illustration slot instead of the icon: pass the slot id from the
 * illustration map (or `true` for an unnamed slot); `artSrc` fills it once artwork exists.
 */
export function EmptyState({ icon = "sparkle", art = false, artSrc, title, children, action, onAction, tone = "neutral" }) {
  return (
    <div className={cx("empty-state", tone === "error" && "empty-state--error")}>
      {art ? (
        <IllustrationPlaceholder id={typeof art === "string" ? art : undefined} src={artSrc} ratio="5 / 4" width="160px" className="empty-state__art" />
      ) : (
        <span className="empty-state__icon" aria-hidden="true">
          <Icon name={icon} size={28} weight="duotone" />
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

/** Completion feedback after a flow. tone: success (verified, purchased) | neutral (unmatched, blocked) | danger. */
/* 9-sided "cookie" (Material shape set) for the success badge: the outer halo and the purple fill. */
const COOKIE_HALO = "M50.00 0.00L51.45 0.10L52.89 0.39L54.30 0.85L55.67 1.46L57.00 2.18L58.29 2.98L59.54 3.81L60.75 4.63L61.95 5.41L63.14 6.12L64.34 6.74L65.56 7.24L66.83 7.64L68.14 7.94L69.51 8.17L70.93 8.33L72.39 8.48L73.88 8.65L75.37 8.86L76.86 9.17L78.30 9.58L79.68 10.14L80.96 10.84L82.14 11.70L83.19 12.71L84.11 13.85L84.89 15.11L85.55 16.46L86.11 17.87L86.58 19.31L87.00 20.74L87.40 22.16L87.81 23.52L88.27 24.83L88.79 26.07L89.40 27.25L90.12 28.37L90.93 29.44L91.83 30.49L92.81 31.53L93.84 32.59L94.87 33.67L95.88 34.80L96.82 35.98L97.66 37.23L98.36 38.54L98.89 39.90L99.24 41.32L99.40 42.76L99.36 44.23L99.15 45.70L98.79 47.16L98.31 48.59L97.75 50.00L97.15 51.37L96.55 52.71L95.98 54.02L95.49 55.32L95.10 56.61L94.81 57.90L94.64 59.22L94.57 60.56L94.59 61.95L94.67 63.37L94.77 64.84L94.87 66.33L94.92 67.84L94.88 69.36L94.72 70.85L94.41 72.30L93.94 73.69L93.30 75.00L92.49 76.21L91.52 77.31L90.42 78.30L89.20 79.19L87.91 79.98L86.58 80.69L85.24 81.36L83.91 82.00L82.64 82.64L81.43 83.31L80.30 84.05L79.25 84.86L78.27 85.75L77.35 86.74L76.48 87.81L75.62 88.95L74.76 90.15L73.88 91.35L72.94 92.54L71.94 93.68L70.85 94.72L69.68 95.63L68.43 96.40L67.10 96.98L65.70 97.39L64.25 97.61L62.77 97.66L61.27 97.56L59.77 97.33L58.29 97.02L56.84 96.67L55.41 96.31L54.02 95.98L52.66 95.72L51.33 95.56L50.00 95.50L48.67 95.56L47.34 95.72L45.98 95.98L44.59 96.31L43.16 96.67L41.71 97.02L40.23 97.33L38.73 97.56L37.23 97.66L35.75 97.61L34.30 97.39L32.90 96.98L31.57 96.40L30.32 95.63L29.15 94.72L28.06 93.68L27.06 92.54L26.12 91.35L25.24 90.15L24.38 88.95L23.52 87.81L22.65 86.74L21.73 85.75L20.75 84.86L19.70 84.05L18.57 83.31L17.36 82.64L16.09 82.00L14.76 81.36L13.42 80.69L12.09 79.98L10.80 79.19L9.58 78.30L8.48 77.31L7.51 76.21L6.70 75.00L6.06 73.69L5.59 72.30L5.28 70.85L5.12 69.36L5.08 67.84L5.13 66.33L5.23 64.84L5.33 63.37L5.41 61.95L5.43 60.56L5.36 59.22L5.19 57.90L4.90 56.61L4.51 55.32L4.02 54.02L3.45 52.71L2.85 51.37L2.25 50.00L1.69 48.59L1.21 47.16L0.85 45.70L0.64 44.23L0.60 42.76L0.76 41.32L1.11 39.90L1.64 38.54L2.34 37.23L3.18 35.98L4.12 34.80L5.13 33.67L6.16 32.59L7.19 31.53L8.17 30.49L9.07 29.44L9.88 28.37L10.60 27.25L11.21 26.07L11.73 24.83L12.19 23.52L12.60 22.16L13.00 20.74L13.42 19.31L13.89 17.87L14.45 16.46L15.11 15.11L15.89 13.85L16.81 12.71L17.86 11.70L19.04 10.84L20.32 10.14L21.70 9.58L23.14 9.17L24.63 8.86L26.13 8.65L27.61 8.48L29.07 8.33L30.49 8.17L31.86 7.94L33.17 7.64L34.44 7.24L35.66 6.74L36.86 6.12L38.05 5.41L39.25 4.63L40.46 3.81L41.71 2.98L43.00 2.18L44.33 1.46L45.70 0.85L47.11 0.39L48.55 0.10Z";
const COOKIE_FILL = "M50.00 10.00L51.16 10.09L52.31 10.36L53.43 10.79L54.52 11.36L55.56 12.04L56.56 12.77L57.53 13.54L58.46 14.29L59.38 14.99L60.29 15.61L61.22 16.14L62.18 16.55L63.17 16.85L64.22 17.04L65.32 17.15L66.47 17.20L67.67 17.23L68.90 17.26L70.14 17.34L71.38 17.50L72.57 17.76L73.71 18.15L74.76 18.68L75.71 19.36L76.54 20.17L77.25 21.12L77.83 22.17L78.29 23.31L78.66 24.49L78.96 25.70L79.20 26.91L79.44 28.08L79.69 29.21L79.99 30.28L80.36 31.27L80.83 32.20L81.40 33.07L82.08 33.89L82.85 34.68L83.70 35.46L84.60 36.25L85.52 37.07L86.42 37.93L87.27 38.84L88.01 39.81L88.63 40.84L89.10 41.93L89.39 43.05L89.50 44.21L89.44 45.39L89.21 46.57L88.83 47.74L88.35 48.88L87.80 50.00L87.21 51.08L86.64 52.13L86.11 53.16L85.65 54.17L85.30 55.17L85.06 56.18L84.94 57.21L84.93 58.28L85.01 59.38L85.16 60.53L85.34 61.71L85.52 62.93L85.66 64.17L85.72 65.41L85.67 66.63L85.48 67.82L85.14 68.95L84.64 70.00L83.98 70.96L83.17 71.82L82.24 72.57L81.20 73.23L80.10 73.80L78.96 74.30L77.81 74.75L76.69 75.19L75.63 75.63L74.63 76.11L73.72 76.65L72.88 77.27L72.13 77.98L71.43 78.79L70.79 79.69L70.17 80.66L69.55 81.69L68.90 82.74L68.21 83.77L67.46 84.76L66.63 85.67L65.73 86.46L64.74 87.10L63.68 87.59L62.56 87.90L61.39 88.04L60.19 88.01L58.97 87.85L57.76 87.58L56.56 87.23L55.40 86.84L54.26 86.45L53.16 86.11L52.09 85.83L51.04 85.66L50.00 85.60L48.96 85.66L47.91 85.83L46.84 86.11L45.74 86.45L44.60 86.84L43.44 87.23L42.24 87.58L41.03 87.85L39.81 88.01L38.61 88.04L37.44 87.90L36.32 87.59L35.26 87.10L34.27 86.46L33.37 85.67L32.54 84.76L31.79 83.77L31.10 82.74L30.45 81.69L29.83 80.66L29.21 79.69L28.57 78.79L27.87 77.98L27.12 77.27L26.28 76.65L25.37 76.11L24.37 75.63L23.31 75.19L22.19 74.75L21.04 74.30L19.90 73.80L18.80 73.23L17.76 72.57L16.83 71.82L16.02 70.96L15.36 70.00L14.86 68.95L14.52 67.82L14.33 66.63L14.28 65.41L14.34 64.17L14.48 62.93L14.66 61.71L14.84 60.53L14.99 59.38L15.07 58.28L15.06 57.21L14.94 56.18L14.70 55.17L14.35 54.17L13.89 53.16L13.36 52.13L12.79 51.08L12.20 50.00L11.65 48.88L11.17 47.74L10.79 46.57L10.56 45.39L10.50 44.21L10.61 43.05L10.90 41.93L11.37 40.84L11.99 39.81L12.73 38.84L13.58 37.93L14.48 37.07L15.40 36.25L16.30 35.46L17.15 34.68L17.92 33.89L18.60 33.07L19.17 32.20L19.64 31.27L20.01 30.28L20.31 29.21L20.56 28.08L20.80 26.91L21.04 25.70L21.34 24.49L21.71 23.31L22.17 22.17L22.75 21.12L23.46 20.17L24.29 19.36L25.24 18.68L26.29 18.15L27.43 17.76L28.62 17.50L29.86 17.34L31.10 17.26L32.33 17.23L33.53 17.20L34.68 17.15L35.78 17.04L36.83 16.85L37.82 16.55L38.78 16.14L39.71 15.61L40.62 14.99L41.54 14.29L42.47 13.54L43.44 12.77L44.44 12.04L45.48 11.36L46.57 10.79L47.69 10.36L48.84 10.09Z";

export function ResultPanel({ tone = "success", icon = "check", title, children, footer }) {
  return (
    <div className={cx("result", `result--${tone}`)}>
      <span className="result__badge" aria-hidden="true">
        {tone === "success" && (
          <svg className="result__shape" viewBox="0 0 100 100">
            <path className="result__shape-halo" d={COOKIE_HALO} />
            <path className="result__shape-fill" d={COOKIE_FILL} />
          </svg>
        )}
        <Icon name={icon} size={30} stroke={2.75} />
      </span>
      <h2 className="result__title">{title}</h2>
      {children && <div className="result__body">{children}</div>}
      {footer && <div className="result__footer">{footer}</div>}
    </div>
  );
}
