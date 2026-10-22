import { useState } from "react";
import { OverlayRootProvider, Wordmark } from "../design-system/index.js";
import { cx } from "../lib/cx.js";
import * as S from "./screens.jsx";
import { StoreProvider } from "./store.js";

export const SCREENS = [
  { id: "intro", flow: "Onboarding", title: "Verified → profile setup", Component: S.SetupIntro },
  { id: "basics", flow: "Profile creation", title: "The basics", Component: S.Basics },
  { id: "interests", flow: "Profile creation", title: "Interests and prompts", Component: S.InterestsPrompts },
  { id: "photos", flow: "Profile creation", title: "Photos", Component: S.Photos },
  { id: "discovery", flow: "Discovery", title: "Profile card, like / pass", Component: S.Discovery },
  { id: "match", flow: "Matching", title: "It’s a match", Component: S.Match },
  { id: "chats", flow: "Messaging", title: "Conversations", Component: S.Chats },
  { id: "chat", flow: "Messaging + safety", title: "Chat, report and block", Component: S.Chat },
  { id: "profile", flow: "Profile", title: "My profile", Component: S.MyProfile },
  { id: "settings", flow: "Settings", title: "Preferences and privacy", Component: S.Settings },
];

function PreviewFrame({ screen, active, go }) {
  const [root, setRoot] = useState(null);
  const { Component } = screen;
  return (
    <figure id={screen.id} className={cx("fl-frame", active && "is-active")}>
      <figcaption className="fl-frame__caption">
        <span className="fl-frame__flow">{screen.flow}</span>
        <span className="fl-frame__title">{screen.title}</span>
      </figcaption>
      <div className="fl-frame__screen">
        <OverlayRootProvider root={root}>
          <Component go={go} />
        </OverlayRootProvider>
        <div className="fl-frame__overlay" ref={setRoot} />
      </div>
    </figure>
  );
}

export function Flows() {
  const [active, setActive] = useState(null);
  const go = (id) => {
    setActive(id);
    document.getElementById(id)?.scrollIntoView({ behavior: "smooth", block: "center", inline: "center" });
    setTimeout(() => setActive(null), 1400);
  };
  return (
    <StoreProvider>
    <div className="fl">
      <header className="fl-top">
        <div className="fl-top__brand">
          <Wordmark size="sm" />
          <span className="fl-top__tag">Product flow previews</span>
        </div>
        <nav className="fl-nav" aria-label="Screens">
          <a className="fl-nav__link" href="./">Onboarding prototype</a>
          {SCREENS.map((s, i) => (
            <a key={s.id} className="fl-nav__link" href={`#${s.id}`} onClick={(e) => { e.preventDefault(); go(s.id); }}>
              {String(i + 1).padStart(2, "0")} {s.title}
            </a>
          ))}
          <a className="fl-nav__link" href="./showcase.html">Design system</a>
        </nav>
      </header>
      <main className="fl-gallery">
        {SCREENS.map((s) => (
          <PreviewFrame key={s.id} screen={s} active={active === s.id} go={go} />
        ))}
      </main>
      <footer className="fl-credits">
        Icons: <a href="https://www.figma.com/community/file/1166831539721848736" target="_blank" rel="noreferrer">Solar</a> by 480 Design, 
        <a href="https://creativecommons.org/licenses/by/4.0/" target="_blank" rel="noreferrer">CC BY 4.0</a>. Fonts: Fraunces and Inter, SIL OFL.
      </footer>
    </div>
    </StoreProvider>
  );
}
