import { useId } from "react";
import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";
import { Spinner } from "./Button.jsx";

/**
 * Chip. kind: "toggle" (aria-pressed), "remove" (removable value), "static" (display).
 * `unavailable` = quota reached; still focusable, announced, not toggleable.
 */
export function Chip({ kind = "toggle", selected = false, unavailable = false, icon, onToggle, onRemove, children, className }) {
  if (kind === "static") {
    return (
      <span className={cx("chip", "chip--static", className)}>
        {icon && <Icon name={icon} size={16} />}
        {children}
      </span>
    );
  }
  if (kind === "remove") {
    return (
      <span className={cx("chip", "is-selected", className)}>
        {children}
        <button type="button" className="chip__remove" aria-label={`Remove ${children}`} onClick={onRemove}>
          <Icon name="close" size={14} stroke={2.2} />
        </button>
      </span>
    );
  }
  return (
    <button
      type="button"
      className={cx("chip", selected && "is-selected", unavailable && !selected && "is-unavailable", className)}
      aria-pressed={selected}
      aria-disabled={unavailable && !selected ? true : undefined}
      onClick={() => {
        if (unavailable && !selected) return;
        onToggle?.(!selected);
      }}
    >
      {icon && <Icon name={icon} size={16} className="chip__icon" />}
      {children}
      <Icon name={selected ? "check" : "plus"} size={14} stroke={2.2} className="chip__affordance" />
    </button>
  );
}

/** Multi- or single-select chips with an optional maximum. */
export function ChipGroup({ label, options, value, onChange, max, single = false, icons }) {
  const labelId = useId();
  const atMax = max != null && value.length >= max;
  const toggle = (opt, next) => {
    if (single) return onChange(next ? [opt] : []);
    onChange(next ? [...value, opt] : value.filter((v) => v !== opt));
  };
  return (
    <div className="chip-group" role="group" aria-labelledby={label ? labelId : undefined}>
      {label && (
        <p id={labelId} className="chip-group__label">
          {label}
          {max != null && (
            <span className="chip-group__count">
              {value.length}/{max} selected
            </span>
          )}
        </p>
      )}
      <div className="chip-group__items">
        {options.map((opt) => (
          <Chip
            key={opt}
            icon={icons?.[opt]}
            selected={value.includes(opt)}
            unavailable={!single && atMax}
            onToggle={(next) => toggle(opt, next)}
          >
            {opt}
          </Chip>
        ))}
      </div>
    </div>
  );
}

/** On/off switch. `pending` shows a spinner while a change saves. */
export function Switch({ checked, onChange, label, description, pending = false, disabled = false, id }) {
  const autoId = useId();
  const inputId = id ?? autoId;
  const descId = `${inputId}-desc`;
  return (
    <div className={cx("switch-row", disabled && "is-disabled")}>
      <label className="switch-row__text" htmlFor={inputId}>
        <span className="switch-row__label">{label}</span>
        {description && (
          <span id={descId} className="switch-row__description">
            {description}
          </span>
        )}
      </label>
      {pending ? (
        <Spinner size="sm" label={`Saving ${label}`} className="switch-row__spinner" />
      ) : (
        <input
          id={inputId}
          type="checkbox"
          role="switch"
          className="switch"
          checked={checked}
          disabled={disabled}
          aria-describedby={description ? descId : undefined}
          onChange={(e) => onChange?.(e.target.checked)}
        />
      )}
    </div>
  );
}

function ChoiceControl({ type, checked, onChange, label, description, name, value, disabled, card = false }) {
  const id = useId();
  return (
    <label className={cx(card ? "option-card" : "choice", checked && "is-selected", disabled && "is-disabled")} htmlFor={id}>
      <span className="choice__text">
        <span className="choice__label">{label}</span>
        {description && <span className="choice__description">{description}</span>}
      </span>
      <input
        id={id}
        type={type}
        name={name}
        value={value}
        className={cx("choice__input", `choice__input--${type}`)}
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange?.(e.target.checked)}
      />
    </label>
  );
}

export function Checkbox(props) {
  return <ChoiceControl type="checkbox" {...props} />;
}

export function Radio(props) {
  return <ChoiceControl type="radio" {...props} />;
}

/**
 * Option list as cards. mode: "single" (radio group) or "multi" (checkboxes, optional max).
 * options: [{ value, label, description? }]
 */
export function OptionCards({ legend, options, value, onChange, mode = "single", max, name }) {
  const autoName = useId();
  const selected = mode === "single" ? [value] : value;
  const atMax = mode === "multi" && max != null && value.length >= max;
  return (
    <fieldset className="option-cards">
      {legend && <legend className="option-cards__legend">{legend}</legend>}
      {options.map((opt) => {
        const isOn = selected.includes(opt.value);
        const Control = mode === "single" ? Radio : Checkbox;
        return (
          <Control
            key={opt.value}
            card
            name={name ?? autoName}
            value={opt.value}
            label={opt.label}
            description={opt.description}
            checked={isOn}
            disabled={atMax && !isOn}
            onChange={(on) => {
              if (mode === "single") onChange(opt.value);
              else onChange(on ? [...value, opt.value] : value.filter((v) => v !== opt.value));
            }}
          />
        );
      })}
    </fieldset>
  );
}

/** Two or three mutually exclusive views. Arrow keys move selection. */
export function SegmentedControl({ label, options, value, onChange }) {
  const onKeyDown = (e) => {
    const i = options.findIndex((o) => o.value === value);
    if (e.key === "ArrowRight") onChange(options[(i + 1) % options.length].value);
    if (e.key === "ArrowLeft") onChange(options[(i - 1 + options.length) % options.length].value);
  };
  return (
    <div className="segmented" role="tablist" aria-label={label} onKeyDown={onKeyDown}>
      {options.map((o) => (
        <button
          key={o.value}
          type="button"
          role="tab"
          aria-selected={o.value === value}
          tabIndex={o.value === value ? 0 : -1}
          className={cx("segmented__item", o.value === value && "is-selected")}
          onClick={() => onChange(o.value)}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}

/** Single-value slider with a value summary. */
export function Slider({ label, min, max, step = 1, value, onChange, format = String }) {
  const id = useId();
  const pct = ((value - min) / (max - min)) * 100;
  return (
    <div className="slider">
      <div className="slider__header">
        <label htmlFor={id} className="slider__label">
          {label}
        </label>
        <output htmlFor={id} className="slider__value">
          {format(value)}
        </output>
      </div>
      <div className="slider__track" style={{ "--from": "0%", "--to": `${pct}%` }}>
        <input
          id={id}
          type="range"
          min={min}
          max={max}
          step={step}
          value={value}
          aria-valuetext={format(value)}
          onChange={(e) => onChange(Number(e.target.value))}
        />
      </div>
    </div>
  );
}

/** Dual-thumb range (age, height). Thumbs cannot cross; minGap keeps them apart. */
export function RangeSlider({ label, min, max, step = 1, value: [lo, hi], onChange, minGap = 1, format = String }) {
  const id = useId();
  const pct = (v) => ((v - min) / (max - min)) * 100;
  return (
    <div className="slider" role="group" aria-labelledby={id}>
      <div className="slider__header">
        <span id={id} className="slider__label">
          {label}
        </span>
        <span className="slider__value">
          {format(lo)} – {format(hi)}
        </span>
      </div>
      <div className="slider__track slider__track--range" style={{ "--from": `${pct(lo)}%`, "--to": `${pct(hi)}%` }}>
        <input
          type="range"
          aria-label={`Minimum ${label.toLowerCase()}`}
          min={min}
          max={max}
          step={step}
          value={lo}
          aria-valuetext={format(lo)}
          onChange={(e) => onChange([Math.min(Number(e.target.value), hi - minGap), hi])}
        />
        <input
          type="range"
          aria-label={`Maximum ${label.toLowerCase()}`}
          min={min}
          max={max}
          step={step}
          value={hi}
          aria-valuetext={format(hi)}
          onChange={(e) => onChange([lo, Math.max(Number(e.target.value), lo + minGap)])}
        />
      </div>
    </div>
  );
}
