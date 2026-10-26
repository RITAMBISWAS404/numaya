// Likes: people who liked you, with filters, and a profile view to like back or pass.
import { useState } from "react";
import {
  Button,
  EmptyState,
  FilterChips,
  Icon,
  ImagePlaceholder,
  InfoCard,
  PersonTile,
  ProfileCard,
  ProfilePrompt,
  ProfileSection,
  SharedInterests,
  Toast,
  TopBar,
} from "../design-system/index.js";
import { ACTIVITIES, INTEREST_MARKS, PEOPLE } from "./data.js";
import { Frame, useFlash } from "./frame.jsx";
import { LIKE_FILTERS, likesList, promptsOf } from "./model.js";
import { useStore } from "./store.js";

const EMPTY = {
  all: ["No new likes right now", "When someone likes your profile or finds you at an activity, they’ll show up here.", "Go to Home"],
  activity: ["No likes from activities yet", "People you meet at activities can like you from the guest list. Join one to start.", "Explore activities"],
  new: ["Nothing new today", "Likes from the last 24 hours show here.", "See all likes"],
  nearby: ["No likes nearby", "Nearby means within 5 km of you.", "See all likes"],
};

/** "Liked you at Parkrun and pastries" or "Liked your profile". */
export const likeContext = (l) => (l.via === "activity" ? `Liked you at ${ACTIVITIES[l.activity]?.title ?? "an activity"}` : "Liked your profile");

export function Likes({ go }) {
  const [state, dispatch] = useStore();
  const [filter, setFilter] = useState("all");
  const list = likesList(state, filter);
  const counts = Object.fromEntries(LIKE_FILTERS.map((f) => [f.id, likesList(state, f.id).length]));
  const open = (id) => {
    dispatch({ type: "openLike", id });
    go("like-profile");
  };
  const [title, body, action] = EMPTY[filter];
  return (
    <Frame tone="page" top={<TopBar largeTitle="Likes" />} tab="likes" go={go}>
      <div className="fl-stack fl-gap-md fl-sections">
        <p className="fl-caption">People who liked you. Like them back to match.</p>
        <FilterChips label="Filter likes" value={filter} onChange={setFilter} options={LIKE_FILTERS.map((f) => ({ ...f, count: counts[f.id] }))} />
        {list.length ? (
          <ul className="fl-tile-grid" aria-label={`${list.length} likes`}>
            {list.map((l) => {
              const p = PEOPLE[l.person];
              return (
                <li key={l.person}>
                  <PersonTile
                    name={p.name}
                    age={p.age}
                    verified={p.verified}
                    tone={p.tone}
                    caption={`${likeContext(l)}${p.distanceKm != null ? ` · about ${p.distanceKm} km` : ""}`}
                    badge={l.matched ? { tone: "success", icon: "check", label: "Matched" } : l.isNew ? { tone: "brand", icon: "star", label: "New" } : null}
                    onOpen={() => open(l.person)}
                  />
                </li>
              );
            })}
          </ul>
        ) : (
          <EmptyState art={filter === "all" ? "empty-likes" : undefined} icon={filter === "nearby" ? "nearby" : filter === "activity" ? "event" : "heart"} title={title} action={action} onAction={() => (filter === "all" ? go("discovery") : filter === "activity" ? go("activity") : setFilter("all"))}>
            {body}
          </EmptyState>
        )}
      </div>
    </Frame>
  );
}

export function LikeProfile({ go }) {
  const [state, dispatch] = useStore();
  const id = state.activeLike;
  const person = PEOPLE[id];
  const like = likesList(state).find((l) => l.person === id);
  const handled = state.likesHandled[id];
  const [toast, flash] = useFlash();
  if (!person) return null;
  const matched = state.matches.includes(id);
  return (
    <Frame
      tone="page"
      top={<TopBar onBack={() => go("likes")} title={person.name} />}
      footer={
        matched ? (
          <div className="fl-stack fl-stack--full">
            <Button icon="message" onClick={() => { dispatch({ type: "openChat", id }); go("chat"); }}>
              Message {person.name}
            </Button>
          </div>
        ) : handled ? (
          <p className="fl-caption fl-center">You passed on {person.name}.</p>
        ) : (
          <div className="fl-row">
            <Button
              variant="secondary"
              icon="close"
              onClick={() => {
                dispatch({ type: "likeBack", id, liked: false });
                flash(`You passed on ${person.name}`);
                setTimeout(() => go("likes"), 700);
              }}
            >
              Pass
            </Button>
            <Button
              icon="heart"
              onClick={() => {
                dispatch({ type: "likeBack", id, liked: true });
                go("match");
              }}
            >
              Like back
            </Button>
          </div>
        )
      }
    >
      <div className="fl-pf">
        {like && (
          <InfoCard icon={like.via === "activity" ? "event" : "heart"} title={likeContext(like)}>
            {matched ? "You’ve already matched, so this like is handled." : "Like them back to match and start chatting, or pass and they won’t be told."}
          </InfoCard>
        )}
        <ProfileCard name={person.name} age={person.age} verified={person.verified} details={person.details ?? []} />
        {promptsOf(person).map((p) => (
          <ProfilePrompt key={p.q} prompt={p.q} answer={p.a} />
        ))}
        <SharedInterests items={person.shared?.map((label) => ({ label, mark: INTEREST_MARKS[label] }))} />
        {person.distanceKm != null && (
          <ProfileSection title="Location">
            <p className="fl-pf__meta">
              <Icon name="location" size={20} /> About {person.distanceKm} km away
            </p>
          </ProfileSection>
        )}
        {(person.photoCount ?? 0) > 1 && <ImagePlaceholder tone={0} ratio="4 / 5" className="fl-pf__photo" label={`${person.name}, photo 2 (placeholder)`} />}
      </div>
      <Toast open={Boolean(toast)} placement="bottom" icon="check">
        {toast}
      </Toast>
    </Frame>
  );
}
