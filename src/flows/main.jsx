import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "../design-system/index.css";
import "./flows.css";
import "./theme-tiimo.css";
import "./theme-withings.css";
import { Flows } from "./Flows.jsx";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <Flows />
  </StrictMode>,
);
