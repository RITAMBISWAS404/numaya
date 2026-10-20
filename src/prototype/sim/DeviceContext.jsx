import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useId,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
} from "react";

const DeviceContext = createContext(null);

export function DeviceProvider({ isDevice, children }) {
  const [overlayRoot, setOverlayRoot] = useState(null);
  const [keypad, setKeypad] = useState(null);
  const handlersRef = useRef(null);

  const showKeypad = useCallback((owner, config) => setKeypad({ owner, ...config }), []);
  const releaseKeypad = useCallback(
    (owner) => setKeypad((k) => (k && k.owner === owner ? null : k)),
    [],
  );

  const value = useMemo(
    () => ({ isDevice, overlayRoot, setOverlayRoot, keypad, showKeypad, releaseKeypad, handlersRef }),
    [isDevice, overlayRoot, keypad, showKeypad, releaseKeypad],
  );

  return <DeviceContext.Provider value={value}>{children}</DeviceContext.Provider>;
}

export function useDevice() {
  return useContext(DeviceContext);
}

/**
 * Lets the active screen drive the shared on-screen number pad. The pad lives
 * outside the screen layers so it stays put while screens push past it, the
 * way the iOS keyboard does. Returns whether the simulated pad is in use.
 */
export function useKeypad(active, { variant, suggestion = null, onDigit, onDelete, onSuggestion }) {
  const { isDevice, showKeypad, releaseKeypad, handlersRef } = useDevice();
  const owner = useId();
  const enabled = active && !isDevice;
  const latest = useRef(null);
  latest.current = { onDigit, onDelete, onSuggestion };

  useLayoutEffect(() => {
    if (enabled) handlersRef.current = latest;
  });

  useEffect(() => {
    if (!enabled) return;
    showKeypad(owner, { variant, suggestion });
    return () => releaseKeypad(owner);
  }, [enabled, variant, suggestion, owner, showKeypad, releaseKeypad]);

  return enabled;
}
