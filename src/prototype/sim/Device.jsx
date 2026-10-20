import { useLayoutEffect, useRef, useState } from "react";
import { OverlayRootProvider } from "../../design-system/index.js";
import { cx } from "../../lib/cx.js";
import { useKeyboardInset } from "../../lib/hooks/useKeyboardInset.js";
import { useDevice } from "./DeviceContext.jsx";
import { Keypad } from "./Keypad.jsx";

// iPhone 15 / 16 Pro logical resolution plus bezel and titanium band.
const SCREEN_W = 393;
const SCREEN_H = 852;
const FRAME_W = SCREEN_W + 28;
const FRAME_H = SCREEN_H + 28;
const STAGE_PADDING = 32;

/** Everything that sits inside the glass: screens, keypad, overlays, chrome. */
export function DeviceViewport({ children }) {
  const { isDevice, overlayRoot, setOverlayRoot } = useDevice();
  const ref = useRef(null);
  useKeyboardInset(isDevice, ref);

  return (
    <div ref={ref} className={cx("viewport", isDevice ? "viewport--device" : "viewport--sim")}>
      <OverlayRootProvider root={overlayRoot}>
        <div className="viewport__stage">{children}</div>
      </OverlayRootProvider>
      {!isDevice && <Keypad />}
      <div className="viewport__overlay" ref={setOverlayRoot} />
      {!isDevice && <StatusBar />}
      {!isDevice && <span className="viewport__home-indicator" aria-hidden="true" />}
    </div>
  );
}

/** Desktop presentation: a scaled iPhone frame that always fits its stage. */
export function Simulator({ children }) {
  const hostRef = useRef(null);
  const [scale, setScale] = useState(1);

  useLayoutEffect(() => {
    const el = hostRef.current;
    const ro = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      const next = Math.min(
        1,
        (height - STAGE_PADDING * 2) / FRAME_H,
        (width - STAGE_PADDING * 2) / FRAME_W,
      );
      setScale(Math.max(0.5, Math.round(next * 1000) / 1000));
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  return (
    <div className="simulator" ref={hostRef}>
      <div className="device-frame" style={{ zoom: scale }}>
        <span className="device-frame__button device-frame__button--action" />
        <span className="device-frame__button device-frame__button--vol-up" />
        <span className="device-frame__button device-frame__button--vol-down" />
        <span className="device-frame__button device-frame__button--power" />
        <div className="device-frame__bezel">
          <div className="device-frame__screen">{children}</div>
          <span className="device-frame__island" aria-hidden="true" />
        </div>
      </div>
    </div>
  );
}

function StatusBar() {
  return (
    <div className="status-bar" aria-hidden="true">
      <span className="status-bar__time">9:41</span>
      <span className="status-bar__icons">
        <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor">
          <rect x="0" y="7.5" width="3" height="4.5" rx="1" />
          <rect x="5" y="5" width="3" height="7" rx="1" />
          <rect x="10" y="2.5" width="3" height="9.5" rx="1" />
          <rect x="15" y="0" width="3" height="12" rx="1" />
        </svg>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="currentColor">
          <path d="M8 2.4c2.3 0 4.4.9 6 2.4l1.2-1.2A10.1 10.1 0 0 0 8 .7C5.2.7 2.7 1.8.8 3.6L2 4.8c1.6-1.5 3.7-2.4 6-2.4Z" />
          <path d="M8 5.8c1.4 0 2.6.5 3.6 1.4l1.2-1.2A6.9 6.9 0 0 0 8 4.1 6.9 6.9 0 0 0 3.2 6l1.2 1.2c1-.9 2.2-1.4 3.6-1.4Z" />
          <path d="M8 9.2c.5 0 .9.2 1.2.5L8 11 6.8 9.7c.3-.3.7-.5 1.2-.5Z" />
        </svg>
        <svg width="27" height="13" viewBox="0 0 27 13" fill="none">
          <rect x="0.5" y="0.5" width="23" height="12" rx="3.8" stroke="currentColor" opacity="0.4" />
          <rect x="2" y="2" width="20" height="9" rx="2.5" fill="currentColor" />
          <path d="M25 4.5v4c.8-.3 1.4-1.1 1.4-2s-.6-1.7-1.4-2Z" fill="currentColor" opacity="0.45" />
        </svg>
      </span>
    </div>
  );
}
