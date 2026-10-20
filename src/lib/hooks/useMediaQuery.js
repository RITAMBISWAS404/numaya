import { useSyncExternalStore } from "react";

export function useMediaQuery(query) {
  return useSyncExternalStore(
    (onChange) => {
      const mql = window.matchMedia(query);
      mql.addEventListener("change", onChange);
      return () => mql.removeEventListener("change", onChange);
    },
    () => window.matchMedia(query).matches,
    () => false,
  );
}

/** Real phones get the bare app; everything wider gets the simulator. */
export const DEVICE_QUERY = "(max-width: 520px), (max-height: 520px) and (pointer: coarse)";
