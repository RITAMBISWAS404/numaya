import { useRef } from "react";
import { cx } from "../lib/cx.js";
import { useDevice } from "./DeviceContext.jsx";
import { Icon } from "./Icon.jsx";

const KEYS = [
  ["1", ""],
  ["2", "ABC"],
  ["3", "DEF"],
  ["4", "GHI"],
  ["5", "JKL"],
  ["6", "MNO"],
  ["7", "PQRS"],
  ["8", "TUV"],
  ["9", "WXYZ"],
];

// Keeps focus (and the caret) in the field the pad is typing into.
const keepFocus = (e) => e.preventDefault();

/**
 * Simulated iOS number pad, shown only inside the desktop simulator.
 * It mirrors the system keyboard, so it is hidden from assistive tech;
 * the focused input remains the real, typeable control.
 */
export function Keypad() {
  const { keypad, handlersRef } = useDevice();
  const lastConfig = useRef(null);
  if (keypad) lastConfig.current = keypad;
  const config = keypad ?? lastConfig.current;

  const call = (name, arg) => handlersRef.current?.current?.[name]?.(arg);
  const suggestion = config?.suggestion;

  return (
    <div className={cx("keypad", keypad && "is-visible")} aria-hidden="true">
      <div className="keypad__bar">
        {suggestion && (
          <button
            type="button"
            tabIndex={-1}
            className="keypad__suggestion"
            onPointerDown={keepFocus}
            onClick={() => call("onSuggestion")}
          >
            <span className="keypad__suggestion-label">From Messages</span>
            <span className="keypad__suggestion-code">{suggestion}</span>
          </button>
        )}
      </div>
      <div className="keypad__grid">
        {KEYS.map(([digit, letters]) => (
          <button
            key={digit}
            type="button"
            tabIndex={-1}
            className="keypad__key"
            onPointerDown={keepFocus}
            onClick={() => call("onDigit", digit)}
          >
            <span className="keypad__digit">{digit}</span>
            <span className="keypad__letters">{letters}</span>
          </button>
        ))}
        <span className="keypad__key keypad__key--blank">
          {config?.variant === "phone" ? "+ * #" : ""}
        </span>
        <button
          type="button"
          tabIndex={-1}
          className="keypad__key keypad__key--zero"
          onPointerDown={keepFocus}
          onClick={() => call("onDigit", "0")}
        >
          <span className="keypad__digit">0</span>
        </button>
        <button
          type="button"
          tabIndex={-1}
          className="keypad__key keypad__key--fn"
          onPointerDown={keepFocus}
          onClick={() => call("onDelete")}
        >
          <Icon name="delete" size={26} stroke={1.6} />
        </button>
      </div>
    </div>
  );
}
