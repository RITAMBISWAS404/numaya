import { cx } from "../../lib/cx.js";
import { Button } from "./Button.jsx";
import { Icon } from "./Icon.jsx";

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
export function MatchCelebration({ names, title = "It’s a match", children }) {
  return (
    <div className="match">
      <div className="match__photos" role="img" aria-label={`Photos of ${names.join(" and ")} (placeholders)`}>
        <span className={cx("match__photo", "match__photo--left")}>
          <Icon name="image" size={28} />
        </span>
        <span className={cx("match__photo", "match__photo--right")}>
          <Icon name="image" size={28} />
        </span>
        {/* Two halves of a heart meet as the photos settle: the match moment, drawn as one mark. */}
        <span className="match__mark">
          <svg className="match__heart" viewBox="0 0 24 24" width="24" height="24" aria-hidden="true" focusable="false">
            <path className="match__half match__half--left" d="M12 20.5C6.2 15.7 3 12.8 3 9.2 3 6.6 5 4.6 7.5 4.6c1.8 0 3.4 1 4.5 2.4z" />
            <path className="match__half match__half--right" d="M12 20.5c5.8-4.8 9-7.7 9-11.3 0-2.6-2-4.6-4.5-4.6-1.8 0-3.4 1-4.5 2.4z" />
          </svg>
        </span>
      </div>
      <h2 className="match__title">{title}</h2>
      {children && <p className="match__body">{children}</p>}
    </div>
  );
}
