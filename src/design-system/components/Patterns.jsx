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
      <span className="primer__icon" aria-hidden="true">
        <Icon name={icon} size={28} stroke={1.9} />
      </span>
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
        <span className="match__mark">
          <Icon name="heart" size={22} stroke={2} />
        </span>
      </div>
      <h2 className="match__title">{title}</h2>
      {children && <p className="match__body">{children}</p>}
    </div>
  );
}
