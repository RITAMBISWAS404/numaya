import { cx } from "../../lib/cx.js";
import { Badge, ImagePlaceholder, VerifiedBadge } from "./Content.jsx";

/**
 * Person tile for grids (Likes): a portrait (photo placeholder until photography exists), name and
 * age, one line of context, and an optional status badge. The whole tile opens the profile.
 */
export function PersonTile({ name, age, verified = false, caption, badge, tone = 0, onOpen, className }) {
  return (
    <button type="button" className={cx("person-tile", className)} onClick={onOpen}>
      <ImagePlaceholder tone={tone} ratio="3 / 4" className="person-tile__photo">
        {badge && (
          <span className="person-tile__badge">
            <Badge tone={badge.tone} icon={badge.icon}>
              {badge.label}
            </Badge>
          </span>
        )}
      </ImagePlaceholder>
      <span className="person-tile__name">
        {name}, {age}
        {verified && <VerifiedBadge compact />}
      </span>
      {caption && <span className="person-tile__caption">{caption}</span>}
    </button>
  );
}
