import { useState } from "react";
import { OverlayRootProvider, Wordmark } from "../design-system/index.js";
import { cx } from "../lib/cx.js";
import * as S from "./screens.jsx";
import * as A from "./activity.jsx";
import * as H from "./activity-host.jsx";
import * as L from "./likes.jsx";
import { StoreProvider } from "./store.js";

export const SCREENS = [
  { id: "intro", flow: "Onboarding", title: "Verified → profile setup", Component: S.SetupIntro },
  { id: "basics", flow: "Profile creation", title: "The basics", Component: S.Basics },
  { id: "interests", flow: "Profile creation", title: "Interests and prompts", Component: S.InterestsPrompts },
  { id: "photos", flow: "Profile creation", title: "Photos", Component: S.Photos },
  { id: "discovery", flow: "Home", title: "Profile card, like / pass", Component: S.Discovery },
  { id: "match", flow: "Matching", title: "It’s a match", Component: S.Match },
  { id: "activity", flow: "Activity", title: "Explore activities", Component: A.ActivityExplore },
  { id: "activity-detail", flow: "Activity", title: "Activity details", Component: A.ActivityDetail },
  { id: "activity-people", flow: "Activity", title: "Guests and requests", Component: A.ActivityPeople },
  { id: "activity-form", flow: "Activity", title: "Create or edit an activity", Component: H.ActivityForm },
  { id: "my-activities", flow: "Activity", title: "My activities", Component: H.MyActivities },
  { id: "likes", flow: "Likes", title: "People who liked you", Component: L.Likes },
  { id: "like-profile", flow: "Likes", title: "Like back or pass", Component: L.LikeProfile },
  { id: "chats", flow: "Messages", title: "Conversations", Component: S.Chats },
  { id: "chat", flow: "Messages + safety", title: "Chat, report and block", Component: S.Chat },
  { id: "profile", flow: "Profile", title: "My profile", Component: S.MyProfile },
  { id: "edit", flow: "Profile", title: "Edit profile and preview", Component: S.EditProfile },
  { id: "prompt", flow: "Profile", title: "Edit prompt", Component: S.PromptEditor },
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

/** The screen requested with `?screen=<id>`, if it exists. */
function requestedScreen() {
  const id = new URLSearchParams(window.location.search).get("screen");
  return SCREENS.some((s) => s.id === id) ? id : null;
}

/**
 * Single-screen mode (`flows.html?screen=<id>`): one screen fills the viewport, like the app on a
 * phone, and navigation inside it moves to the next screen (the URL follows). Used for the
 * screenshot gallery and for trying a flow end to end on a device.
 */
function SingleScreen({ initial }) {
  const [id, setId] = useState(initial);
  const go = (next) => {
    setId(next);
    window.history.replaceState(null, "", `?screen=${next}`);
  };
  const screen = SCREENS.find((s) => s.id === id);
  return (
    <StoreProvider>
      <div className="fl-single">
        <PreviewFrame key={screen.id} screen={screen} active={false} go={go} />
      </div>
    </StoreProvider>
  );
}

export function Flows() {
  const single = requestedScreen();
  return single ? <SingleScreen initial={single} /> : <Gallery />;
}

function Gallery() {
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
        Icons: <a href="https://fonts.google.com/icons" target="_blank" rel="noreferrer">Material Symbols</a> by Google, Apache 2.0. Fonts: Fraunces and Inter, SIL OFL.
      </footer>
    </div>
    </StoreProvider>
  );
}
