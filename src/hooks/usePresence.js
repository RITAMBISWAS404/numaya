import { useEffect, useState } from "react";

/** Keeps an element mounted for `exitMs` after it closes so it can animate out. */
export function usePresence(open, exitMs = 280) {
  const [mounted, setMounted] = useState(open);

  useEffect(() => {
    if (open) {
      setMounted(true);
      return;
    }
    const id = setTimeout(() => setMounted(false), exitMs);
    return () => clearTimeout(id);
  }, [open, exitMs]);

  return mounted;
}
