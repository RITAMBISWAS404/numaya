import { useEffect, useState } from "react";
import { Wordmark } from "../design-system/index.js";
import { tokens } from "../design-system/tokens.js";
import { cx } from "../lib/cx.js";
import { Components } from "./Components.jsx";
import { Foundations } from "./Foundations.jsx";
import { Recipes } from "./Recipes.jsx";

const NAV = [
  ["Foundations", [["brand", "Brand"], ["color", "Colour"], ["type", "Typography"], ["space", "Space and radius"], ["elevation", "Elevation"], ["motion", "Motion"], ["icons", "Icons"]]],
  ["Components", [["actions", "Actions"], ["inputs", "Inputs"], ["selection", "Selection"], ["identity", "Identity"], ["surfaces", "Surfaces"], ["profile", "Profile"], ["navigation", "Navigation"], ["feedback", "Feedback"], ["overlays", "Overlays"], ["chat", "Chat"], ["commerce", "Premium"]]],
  ["Patterns", [["recipes", "Interaction recipes"]]],
];

function useActiveSection(ids) {
  const [active, setActive] = useState(ids[0]);
  useEffect(() => {
    const io = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter((e) => e.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
        if (visible[0]) setActive(visible[0].target.id);
      },
      { rootMargin: "-10% 0px -70% 0px" },
    );
    ids.forEach((id) => {
      const el = document.getElementById(id);
      if (el) io.observe(el);
    });
    return () => io.disconnect();
  }, [ids]);
  return active;
}

const ALL_IDS = NAV.flatMap(([, items]) => items.map(([id]) => id));

export function Showcase() {
  const active = useActiveSection(ALL_IDS);
  return (
    <div className="sc">
      <aside className="sc-nav" aria-label="Design system sections">
        <div className="sc-nav__brand">
          <Wordmark size="sm" />
          <span className="sc-nav__tag">Design system</span>
        </div>
        <nav>
          {NAV.map(([group, items]) => (
            <div key={group} className="sc-nav__group">
              <p className="sc-nav__group-title">{group}</p>
              <ul>
                {items.map(([id, label]) => (
                  <li key={id}>
                    <a href={`#${id}`} className={cx("sc-nav__link", active === id && "is-active")} aria-current={active === id ? "location" : undefined}>
                      {label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </nav>
        <p className="sc-nav__meta">
          {tokens.length} tokens · <a href="./">Onboarding prototype</a>
        </p>
      </aside>
      <main className="sc-main">
        <header className="sc-hero">
          <p className="screen-header__eyebrow">Numaya · Design system</p>
          <h1 className="sc-hero__title">Foundations, components and recipes</h1>
          <p className="sc-hero__lede">
            A verification surface for the system, not a product screen. Everything here is built from{" "}
            <code>tokens/numaya.tokens.json</code> and <code>src/design-system</code>.
          </p>
        </header>
        <Foundations />
        <Components />
        <Recipes />
      </main>
    </div>
  );
}
