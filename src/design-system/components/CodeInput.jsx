import { forwardRef, useState } from "react";
import { cx } from "../../lib/cx.js";

/**
 * One-time-code input rendered as cells (3 + 3 by default). A single real
 * input captures typing, paste and OS one-time-code autofill.
 * status: idle | checking | error | success
 */
export const CodeInput = forwardRef(function CodeInput(
  { value, onChange, length = 6, status = "idle", inputMode = "numeric", id = "code-input", labelledBy, describedBy, group = 3 },
  ref,
) {
  const [focused, setFocused] = useState(false);
  const activeIndex = Math.min(value.length, length - 1);
  const showCaret = focused && status === "idle";

  return (
    <div
      className={cx("code", !group && "code--ungrouped", `is-${status}`, focused && "is-focused")}
      style={{ "--code-length": length, "--code-group": group }}
      onClick={() => ref?.current?.focus({ preventScroll: true })}
    >
      <input
        ref={ref}
        id={id}
        className="code__input"
        type="text"
        inputMode={inputMode}
        autoComplete="one-time-code"
        pattern="[0-9]*"
        maxLength={length}
        value={value}
        disabled={status === "success"}
        aria-labelledby={labelledBy}
        aria-describedby={describedBy}
        aria-invalid={status === "error" || undefined}
        onChange={(e) => onChange(e.target.value.replace(/\D/g, "").slice(0, length))}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
      />
      {Array.from({ length }, (_, i) => (
        <span
          key={i}
          aria-hidden="true"
          style={{ "--i": i }}
          className={cx(
            "code__cell",
            group && i === group && "code__cell--group-start",
            i < value.length && "is-filled",
            showCaret && i === activeIndex && "is-active",
          )}
        >
          {value[i] ?? ""}
          {showCaret && i === activeIndex && i >= value.length && <span className="code__caret" />}
        </span>
      ))}
    </div>
  );
});
