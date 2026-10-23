import { cx } from "../../lib/cx.js";
import { ILLUSTRATIONS, illustrationSrc } from "../illustrations/registry.js";
import { Illustration } from "./Illustration.jsx";
import { Icon } from "./Icon.jsx";

/** Two halves of a heart that join: the Match screen's fallback until the hands artwork arrives. */
export function MatchHeart({ size = 56 }) {
  return (
    <svg className="match-heart" viewBox="0 0 24 24" width={size} height={size} aria-hidden="true" focusable="false">
      <path className="match-heart__half match-heart__half--left" d="M12 20.5C6.2 15.7 3 12.8 3 9.2 3 6.6 5 4.6 7.5 4.6c1.8 0 3.4 1 4.5 2.4z" />
      <path className="match-heart__half match-heart__half--right" d="M12 20.5c5.8-4.8 9-7.7 9-11.3 0-2.6-2-4.6-4.5-4.6-1.8 0-3.4 1-4.5 2.4z" />
    </svg>
  );
}

/**
 * A registered illustration slot (see illustrations/registry.js). Keeps the slot's aspect ratio so
 * the layout is the same before and after the PNG is supplied, and shows the registered fallback
 * until then. Always decorative: the copy beside it carries the meaning.
 */
export function IllustrationSlot({ id, width, className }) {
  const entry = ILLUSTRATIONS[id];
  if (!entry) return null;
  const src = illustrationSrc(id);
  // Icon fallbacks keep today's compact layout; the slot takes its ratio once the PNG exists.
  if (!src && entry.fallback.startsWith("icon:")) {
    return (
      <span className={cx("illustration-slot", "illustration-slot--icon", className)} data-illustration={id} data-asset={entry.file} data-status="fallback" aria-hidden="true">
        <Icon name={entry.fallback.slice(5)} size={40} />
      </span>
    );
  }
  return (
    <div
      className={cx("illustration-slot", !src && "illustration-slot--fallback", className)}
      style={{ aspectRatio: entry.ratio, width }}
      data-illustration={id}
      data-asset={entry.file}
      data-status={src ? "asset" : "fallback"}
      aria-hidden="true"
    >
      {src ? (
        <img className="illustration-slot__img" src={src} alt="" style={{ objectFit: entry.fit }} />
      ) : entry.fallback === "heart" ? (
        <MatchHeart size={64} />
      ) : entry.fallback === "reserved" ? null : (
        <Illustration scene={entry.fallback} className="illustration-slot__scene" />
      )}
    </div>
  );
}
