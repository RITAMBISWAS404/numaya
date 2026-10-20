import { createContext, useContext } from "react";
import { createPortal } from "react-dom";

// undefined: no provider (render into document.body). null: provider not mounted yet.
const OverlayRootContext = createContext(undefined);

/** Scopes overlays (sheets, toasts, dialogs) to a container, e.g. a device frame. */
export function OverlayRootProvider({ root, children }) {
  return <OverlayRootContext.Provider value={root}>{children}</OverlayRootContext.Provider>;
}

export function Portal({ children }) {
  const root = useContext(OverlayRootContext);
  if (root === null) return null;
  if (root === undefined) return typeof document === "undefined" ? null : createPortal(children, document.body);
  return createPortal(children, root);
}
