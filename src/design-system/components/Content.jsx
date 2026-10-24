import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";
import { IconButton } from "./Button.jsx";
import { Illustration } from "./Illustration.jsx";
import { IllustrationSlot } from "./IllustrationSlot.jsx";
import { ILLUSTRATIONS } from "../illustrations/registry.js";

/* -------------------------------------------------------------------------- */
/* Identity                                                                    */
/* -------------------------------------------------------------------------- */

/* Avatar sizes in px (mirror --size-avatar-*; a unit test keeps them in sync). The completion ring
   is drawn in pixel space so its 4px band and round caps are the same at every size. */
export const AVATAR_PX = { xs: 24, sm: 36, md: 48, lg: 64, xl: 96 };
/* Avatars are circles, as in Meetup (radius = half the image's side; mirrors content.css). The
   only drawn shapes are the Illustration scenes. */
export const AVATAR_RADIUS = 0.5;
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
      {verified && <Icon name="verified" size={20} className="avatar__badge" />}
    </span>
  );
}

/** Verified mark: the filled Material "verified" seal in brand purple (one glyph, no disc behind a
    check), always paired with a text label. */
export function VerifiedBadge({ label = "Verified", compact = false }) {
  return (
    <span className={cx("verified", compact && "verified--compact")}>
      <Icon name="verified" size={compact ? 18 : 20} className="verified__mark" />
      {compact ? <span className="visually-hidden">{label}</span> : <span>{label}</span>}
    </span>
  );
}

/** Badge: small status label. tone: neutral | brand | success | warning | danger | inverse. */
export function Badge({ tone = "neutral", icon, children }) {
  return (
    <span className={cx("badge", `badge--${tone}`)}>
      {icon && <Icon name={icon} size={12} />}
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
      {(kind === "nav" || kind === "value") && <Icon name="chevronRight" size={18} className="list-row__trail" />}
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
      <Icon name={icon} size={20} className="tip-card__icon" />
      <span className="tip-card__text">
        <span className="tip-card__title">{title}</span>
        {children && <span className="tip-card__body">{children}</span>}
      </span>
      {onPress && <Icon name="chevronRight" size={18} className="tip-card__chevron" />}
    </Tag>
  );
}

/**
 * Guidance card: a grouped privacy, guidance or safety message. Top row: a filled purple icon beside
 * a near-black heading; the body sits below, full width. Flat lavender wash, 20px corners, no border
 * or shadow. For short hints tied to one field, use the field's hint.
 */
export function InfoCard({ icon = "info", title, children, id, className }) {
  return (
    <div className={cx("info-card", className)} id={id}>
      <p className="info-card__head">
        <Icon name={icon} size={20} className="info-card__icon" />
        <span className="info-card__title">{title}</span>
      </p>
      {children && <p className="info-card__body">{children}</p>}
    </div>
  );
}

const SETUP_STATUS = { done: "Done", active: "Up next", upcoming: "Not started" };

/**
 * Profile setup: one horizontal card per step, stacked. Each card reads "Step N of M", the step's
 * name and a short line, led by its filled icon, with the status at the end. status per step: done
 * (flat grey card, "Done" with a check), active (white card with a purple outline and an "Up next"
 * pill: the most prominent) or upcoming (white card with a hairline, muted). The active card is
 * aria-current="step" and every state is written out, not carried by colour alone.
 */
export function SetupProgress({ title, steps, className }) {
  const done = steps.filter((s) => s.status === "done").length;
  return (
    <section className={cx("setup-steps", className)} aria-label={title}>
      {title && (
        <header className="setup-steps__head">
          <h2 className="setup-steps__title">{title}</h2>
          <span className="setup-steps__count">
            {done} of {steps.length} done
          </span>
        </header>
      )}
      <ol className="setup-steps__list">
        {steps.map((step, i) => (
          <li key={step.label} className={cx("setup-step", `is-${step.status}`)} aria-current={step.status === "active" ? "step" : undefined}>
            <Icon name={step.icon} size={24} className="setup-step__icon" />
            <span className="setup-step__text">
              <span className="setup-step__eyebrow">
                Step {i + 1} of {steps.length}
              </span>
              <span className="setup-step__label">{step.label}</span>
              {step.detail && <span className="setup-step__detail">{step.detail}</span>}
            </span>
            <span className={cx("setup-step__status", step.status === "upcoming" && "visually-hidden")}>
              {step.status === "done" && <Icon name="check" size={18} />}
              {SETUP_STATUS[step.status]}
            </span>
          </li>
        ))}
      </ol>
    </section>
  );
}

/**
 * Profile section: the one card primitive every profile and Discover section is built from (prompt
 * answer, about me, shared interests, location). A white card with a hairline and soft shadow, a
 * quiet label title (the display serif is kept for the person's name and answers) and its content
 * below. No icon or mark beside the title.
 */
export function ProfileSection({ title, children, className, ...rest }) {
  return (
    <section className={cx("card", "profile-section", className)} {...rest}>
      <h2 className="profile-section__title">{title}</h2>
      {children}
    </section>
  );
}

/**
 * A prompt on someone's profile: the question is a quiet label and the answer, in the person's own
 * words, is the display serif. Same section shell as every other profile section.
 */
export function ProfilePrompt({ prompt, answer, className }) {
  return (
    <section className={cx("card", "profile-section", "profile-section--prompt", className)}>
      <h2 className="profile-section__title">{prompt}</h2>
      <p className="profile-section__answer">{answer}</p>
    </section>
  );
}

/** Interests you share with someone, on their profile: a ProfileSection of grey text pills. items: [{ label }]. */
export function SharedInterests({ title = "You both like", items, className }) {
  if (!items?.length) return null;
  return (
    <ProfileSection title={title} className={cx("shared-interests", className)}>
      <ul className="shared-interests__list">
        {items.map((item) => (
          <li key={item.label} className="chip chip--static shared-interests__pill">
            {item.label}
          </li>
        ))}
      </ul>
    </ProfileSection>
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
/** `reserved` holds the slot's space with nothing drawn (the Welcome hero). Drawn scenes use
    `Illustration` instead. */
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
      {children ?? <Icon name="image" size={28} className="image-placeholder__icon" />}
    </div>
  );
}

/** Photo slot in the profile grid. Empty slots are add buttons. */
export function PhotoSlot({ index, filled = false, tone = 0, main = false, uploading = false, onAdd, onRemove, onSelect }) {
  if (!filled) {
    return (
      <button type="button" className="photo-slot photo-slot--empty" aria-label={`Add photo ${index + 1}`} onClick={onAdd}>
        <Icon name="plus" size={24} />
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
          <Icon name="close" size={14} />
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
          <Icon name="info" size={14} /> {hint}
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
        <Icon name="close" size={26} />
      </button>
      <button type="button" className="action-bar__btn action-bar__btn--super" aria-label="Super like" onClick={onSuper} disabled={superDisabled}>
        <Icon name="star" size={22} />
      </button>
      <button type="button" className="action-bar__btn action-bar__btn--like" aria-label="Like" onClick={onLike}>
        <Icon name="heart" size={26} />
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

/**
 * Empty state: one clear next step when there is nothing to show. `art` names an Illustration scene
 * drawn above the title (`artSrc` swaps in supplied artwork at the same place); without art, a plain
 * filled glyph stands in.
 */
export function EmptyState({ icon = "sparkle", art, artSrc, title, children, action, onAction, tone = "neutral" }) {
  return (
    <div className={cx("empty-state", tone === "error" && "empty-state--error")}>
      {artSrc ? (
        <img className="illustration empty-state__art" src={artSrc} alt="" width="160" />
      ) : art ? (
        ILLUSTRATIONS[art] ? <IllustrationSlot id={art} width={ILLUSTRATIONS[art].fallback.startsWith("icon:") ? undefined : "160px"} className="empty-state__art" /> : <Illustration scene={art} className="empty-state__art" />
      ) : (
        <Icon name={icon} size={40} className="empty-state__icon" />
      )}
      <h3 className="empty-state__title">{title}</h3>
      {children && <p className="empty-state__body">{children}</p>}
      {action && (
        <button type="button" className={cx("btn btn--inline btn--sm", art || artSrc ? "btn--primary" : "btn--secondary")} onClick={onAction}>
          <span className="btn__label">{action}</span>
        </button>
      )}
    </div>
  );
}

/**
 * Completion feedback after a flow. tone: success (verified, signed in) | neutral (unmatched,
 * blocked) | danger. `art` names an Illustration scene drawn above the title: one composition, never
 * a badge stacked on a shape. Without art, a plain filled glyph in the tone's colour stands in.
 * Neutral outcomes never carry a success check.
 */
const RESULT_ICON = { success: "verified", neutral: "info", danger: "alert" };

export function ResultPanel({ tone = "success", art, icon, title, children, footer, compact = false }) {
  return (
    <div className={cx("result", `result--${tone}`, compact && "result--compact")}>
      {art ? (
        ILLUSTRATIONS[art] ? (
          <IllustrationSlot id={art} width={ILLUSTRATIONS[art].fallback.startsWith("icon:") ? undefined : `${compact ? 128 : 160}px`} className="result__art" />
        ) : (
          <Illustration scene={art} width={compact ? 128 : 160} className="result__art" />
        )
      ) : (
        <span className="result__icon" aria-hidden="true">
          <Icon name={icon ?? RESULT_ICON[tone]} size={44} />
        </span>
      )}
      <h2 className="result__title">{title}</h2>
      {children && <div className="result__body">{children}</div>}
      {footer && <div className="result__footer">{footer}</div>}
    </div>
  );
}
