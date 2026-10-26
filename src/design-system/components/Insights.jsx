import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";

/**
 * Profile readiness: one restrained radial indicator with the score in the centre. `value` 0–100.
 * The ring is a progress meter (role="meter"), so assistive tech reads the score and its range.
 * `--value` exposes the score to CSS, so a theme can draw the same meter as a bar (the Tiimo
 * experiment's V9 has no circular UI).
 */
export function ReadinessMeter({ value, label = "Profile readiness", size = 112 }) {
  const r = 44;
  const c = 2 * Math.PI * r;
  return (
    <div className="readiness-meter" style={{ width: size, height: size, "--value": value }} role="meter" aria-label={label} aria-valuemin={0} aria-valuemax={100} aria-valuenow={value} aria-valuetext={`${value} out of 100`}>
      <svg viewBox="0 0 100 100" width={size} height={size} aria-hidden="true">
        <circle className="readiness-meter__track" cx="50" cy="50" r={r} />
        <circle className="readiness-meter__value" cx="50" cy="50" r={r} strokeDasharray={`${(c * value) / 100} ${c}`} transform="rotate(-90 50 50)" />
      </svg>
      <span className="readiness-meter__label" aria-hidden="true">
        <span className="readiness-meter__value-text">{value}</span>
        <span className="readiness-meter__unit">of 100</span>
      </span>
    </div>
  );
}

/** Thin progress bar with its numbers written out beside it. */
export function ProgressBar({ value, max, label }) {
  return (
    <span className="progress-bar" role="progressbar" aria-label={label} aria-valuemin={0} aria-valuemax={max} aria-valuenow={value}>
      <span className="progress-bar__fill" style={{ width: `${Math.min(100, (value / max) * 100)}%` }} />
    </span>
  );
}

/** Compact metric: a label, the value with its unit, and one line of context (baseline or range). */
export function MetricCard({ icon, label, value, detail, progress, className }) {
  return (
    <div className={cx("metric-card", className)}>
      <p className="metric-card__label">
        {icon && <Icon name={icon} size={18} className="metric-card__icon" />}
        {label}
      </p>
      <p className="metric-card__value">{value}</p>
      {progress && <ProgressBar {...progress} label={label} />}
      {detail && <p className="metric-card__detail">{detail}</p>}
    </div>
  );
}
