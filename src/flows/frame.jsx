// Shared scaffold for every flow screen: top area, scrolling body, footer and the five-section tab bar.
import { useEffect, useRef, useState } from "react";
import { TabBar } from "../design-system/index.js";
import { pendingLikes, unreadCount } from "./model.js";
import { useStore } from "./store.js";

/* The five sections, in the PRD's order. Screen ids stay stable for deep links: Home is the
   `discovery` screen and Messages is `chats`. */
export const TABS = [
  { id: "home", label: "Home", icon: "home", screen: "discovery" },
  { id: "activity", label: "Activity", icon: "event", screen: "activity" },
  { id: "likes", label: "Likes", icon: "heart", screen: "likes" },
  { id: "messages", label: "Messages", icon: "message", screen: "chats" },
  { id: "profile", label: "Profile", icon: "user", screen: "profile" },
];

const FOCUSABLE = "a[href], button, input, select, textarea, [tabindex]:not([tabindex='-1'])";

/** A body that scrolls but holds nothing focusable (e.g. the setup intro on a small phone) becomes a
    tab stop itself, so keyboard users can still scroll it. */
function useScrollableFocus(ref) {
  useEffect(() => {
    const el = ref.current;
    if (!el || typeof ResizeObserver === "undefined") return;
    const update = () => {
      const needs = el.scrollHeight > el.clientHeight + 1 && !el.querySelector(FOCUSABLE);
      if (needs) el.setAttribute("tabindex", "0");
      else el.removeAttribute("tabindex");
    };
    const ro = new ResizeObserver(update);
    ro.observe(el);
    if (el.firstElementChild) ro.observe(el.firstElementChild);
    update();
    return () => ro.disconnect();
  }, [ref]);
}

/** Tab badges come from real state: pending likes and unread messages. */
function MainTabs({ current, go }) {
  const [state] = useStore();
  const unread = Object.keys(state.threads).reduce((n, id) => (state.ended[id] ? n : n + unreadCount(state, id)), 0);
  const badges = { likes: pendingLikes(state), messages: unread };
  return <TabBar items={TABS.map((t) => ({ ...t, badge: badges[t.id] }))} current={current} onChange={(id) => go(TABS.find((t) => t.id === id).screen)} />;
}

/** Shared screen scaffold inside a preview frame. `tab` names the current section. */
export function Frame({ top, footer, tab, go, children, tone, kind, onBodyScroll, bodyRef }) {
  const ownRef = useRef(null);
  const ref = bodyRef ?? ownRef;
  useScrollableFocus(ref);
  return (
    <div className={`fl-screen${tone ? ` fl-screen--${tone}` : ""}${kind ? ` fl-screen--${kind}` : ""}`}>
      {top}
      <div className="fl-screen__body" onScroll={onBodyScroll} ref={ref}>
        {children}
      </div>
      {footer && <div className="fl-screen__footer">{footer}</div>}
      {tab && <MainTabs current={tab} go={go} />}
    </div>
  );
}

/** Short-lived toast message. */
export function useFlash(ms = 1400) {
  const [msg, setMsg] = useState(null);
  useEffect(() => {
    if (!msg) return;
    const id = setTimeout(() => setMsg(null), ms);
    return () => clearTimeout(id);
  }, [msg, ms]);
  return [msg, setMsg];
}
