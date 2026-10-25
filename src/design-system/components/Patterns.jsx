import { cx } from "../../lib/cx.js";
import { markAttrs } from "../../lib/theme.js";
import { Button } from "./Button.jsx";
import { Icon } from "./Icon.jsx";
import { Avatar, avatarTone } from "./Content.jsx";

/**
 * Explains a device permission before the OS prompt. Primary asks; secondary defers.
 * When the permission was denied, pass `denied` to switch to the Settings recovery copy.
 */
export function PermissionPrimer({ icon, title, children, allowLabel = "Allow", deferLabel = "Not now", denied = false, onAllow, onDefer, onOpenSettings }) {
  return (
    <div className="primer">
      <Icon name={icon} size={40} className="primer__icon" />
      <h2 className="primer__title">{title}</h2>
      <div className="primer__body">{children}</div>
      <div className="primer__actions">
        {denied ? (
          <Button variant="primary" onClick={onOpenSettings}>
            Open Settings
          </Button>
        ) : (
          <Button variant="primary" onClick={onAllow}>
            {allowLabel}
          </Button>
        )}
        <Button variant="quiet" onClick={onDefer}>
          {deferLabel}
        </Button>
      </div>
    </div>
  );
}

/**
 * Two tilted photos with a centre brand mark, title and supporting line (Bumble "What a match!").
 * Photo areas are neutral placeholders until profile photography is supplied. Composer sits below.
 */
/* Organic photo frame: a ten-lobed scallop (the sketch's "fun shape"), drawn once as a path and
   used both as the photo mask and as the slowly turning lavender backdrop behind it. */
function scallop(lobes, radius, depth, steps = 160) {
  const pts = Array.from({ length: steps }, (_, i) => {
    const t = (2 * Math.PI * i) / steps;
    const r = radius + depth * Math.cos(lobes * t);
    return `${(50 + r * Math.cos(t)).toFixed(2)} ${(50 + r * Math.sin(t)).toFixed(2)}`;
  });
  return `M${pts.join("L")}Z`;
}
const FRAME = scallop(10, 46.5, 3);
const FRAME_MASK = `url("data:image/svg+xml,${encodeURIComponent(`<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='${FRAME}'/></svg>`)}")`;

/**
 * A person's photo inside the organic frame. `src` is their real profile photo; without one, the
 * shared avatar fallback (their initial on their pastel) fills the frame. Never an invented portrait.
 */
export function OrganicPortrait({ name, src, className }) {
  return (
    <div className={cx("organic-portrait", className)} role="img" aria-label={src ? `Photo of ${name}` : `${name} has not added a photo yet`}>
      <svg className="organic-portrait__backdrop" viewBox="0 0 100 100" aria-hidden="true" focusable="false">
        <path d={FRAME} />
      </svg>
      <div className="organic-portrait__photo" style={{ WebkitMaskImage: FRAME_MASK, maskImage: FRAME_MASK }}>
        {src ? (
          <img src={src} alt="" />
        ) : (
          <span className={cx("organic-portrait__fallback", `avatar--tone-${avatarTone(name)}`)} aria-hidden="true">
            {name?.trim()?.[0]?.toUpperCase()}
          </span>
        )}
      </div>
    </div>
  );
}

/**
 * The match moment (reference: the Numaya sketch): heading, the matched person's photo in the
 * organic frame (with `you` overlapping its edge, so the moment shows the pair), one line of copy,
 * what the two of you really share (`shared`, optional) and the illustration slot. White page;
 * purple stays in the frame backdrop, the shared pills and the artwork. Actions (message, keep
 * browsing) belong to the screen's footer.
 */
export function MatchCelebration({ name, src, you, shared, marks, title = "It’s a match!", illustration, children }) {
  return (
    <div className="match">
      <h1 className="match__title">{title}</h1>
      {/* The pair: the matched person in the organic frame, you overlapping its edge. */}
      <div className="match__pair">
        <OrganicPortrait name={name} src={src} className="match__portrait" />
        {you && <Avatar name={you.name} src={you.src} size="lg" className="match__you" />}
      </div>
      {children && <p className="match__body">{children}</p>}
      {shared?.length > 0 && (
        <div className="match__shared">
          <span className="match__shared-label" id="match-shared-label">
            You both like
          </span>
          <ul className="match__shared-list" aria-labelledby="match-shared-label">
            {shared.map((s) => (
              <li key={s} className="chip chip--static match__shared-chip" {...markAttrs(marks?.[s])}>
                {s}
              </li>
            ))}
          </ul>
        </div>
      )}
      {illustration && <div className="match__art">{illustration}</div>}
    </div>
  );
}
