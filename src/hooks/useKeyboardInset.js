import { useEffect } from "react";

/**
 * iOS Safari overlays the software keyboard instead of resizing the layout
 * viewport. Expose the covered height as --keyboard-inset so footers can
 * stay above it on real devices.
 */
export function useKeyboardInset(enabled, ref) {
  useEffect(() => {
    const vv = window.visualViewport;
    const el = ref.current;
    if (!enabled || !vv || !el) return;

    const update = () => {
      const inset = Math.max(0, window.innerHeight - vv.height - vv.offsetTop);
      el.style.setProperty("--keyboard-inset", `${Math.round(inset)}px`);
    };
    update();
    vv.addEventListener("resize", update);
    vv.addEventListener("scroll", update);
    return () => {
      vv.removeEventListener("resize", update);
      vv.removeEventListener("scroll", update);
      el.style.removeProperty("--keyboard-inset");
    };
  }, [enabled, ref]);
}
