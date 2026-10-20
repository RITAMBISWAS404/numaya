import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./design-system/index.css";
import "./prototype/styles/presentation.css";
import "./prototype/styles/device.css";
import "./prototype/styles/screens.css";
import { App } from "./prototype/App.jsx";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
