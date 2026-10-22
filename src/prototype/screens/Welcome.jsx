import { useEffect, useState } from "react";
import { Avatar, Button, Icon, Marker, Ribbon, Screen, Toast, Wordmark } from "../../design-system/index.js";
import { cx } from "../../lib/cx.js";

const PROMPTS = [
  { id: "date", label: "A perfect first date", answer: "Natural wine, a record shop, and nowhere to be after." },
  { id: "good-at", label: "I’m weirdly good at", answer: "Remembering the name of every dog I’ve ever met." },
  {
    id: "debate",
    label: "Let’s debate this",
    answer: "Breakfast for dinner is the superior meal.",
    person: { initial: "M", name: "Maya", meta: "29 · 2 km away" },
  },
];

export function Welcome({ active, onCreate, onSignIn }) {
  const [notice, setNotice] = useState(null);

  useEffect(() => {
    if (!notice) return;
    const id = setTimeout(() => setNotice(null), 1800);
    return () => clearTimeout(id);
  }, [notice]);

  const openDoc = (name) => (e) => {
    e.preventDefault();
    setNotice(`${name} opens in your browser`);
  };

  return (
    <Screen tone="brand" className="welcome" aria-labelledby="welcome-title">
      <div className="welcome__hero">
        <Ribbon variant="welcome" />
        <div className="welcome__lockup">
          <Wordmark />
        </div>
        <PromptStack />
      </div>

      <div className="welcome__panel">
        <h1 id="welcome-title" className="welcome__title">
          Fewer swipes.
          <br />
          <Marker className="welcome__emphasis">Better</Marker> first dates.
        </h1>
        <p className="welcome__lede">
          Profiles built around conversation, so the right person knows what to say.
        </p>
        <div className="welcome__actions">
          <Button variant="primary" onClick={onCreate}>
            Create an account
          </Button>
          <Button variant="quiet" onClick={onSignIn}>
            I have an account
          </Button>
        </div>
        <p className="legal">
          By signing up, you agree to our{" "}
          <a href="#terms" onClick={openDoc("Terms")}>Terms</a>. See how we use your data in our{" "}
          <a href="#privacy" onClick={openDoc("Privacy Policy")}>Privacy Policy</a>.
        </p>
      </div>

      {active && (
        <Toast open={Boolean(notice)} placement="bottom">
          {notice}
        </Toast>
      )}
    </Screen>
  );
}

function PromptStack() {
  const [liked, setLiked] = useState(false);

  return (
    <div className="prompt-stack">
      {PROMPTS.map((prompt, index) => (
        <article
          key={prompt.id}
          className={cx("prompt-card", `prompt-card--${index + 1}`)}
          aria-hidden={prompt.person ? undefined : "true"}
        >
          <p className="prompt-card__label">{prompt.label}</p>
          <p className="prompt-card__answer">{prompt.answer}</p>
          {prompt.person && (
            <footer className="prompt-card__footer">
              <Avatar name={prompt.person.name} size="sm" decorative />
              <span className="prompt-card__person">
                <span className="prompt-card__name">{prompt.person.name}</span>
                <span className="prompt-card__meta">{prompt.person.meta}</span>
              </span>
              <button
                type="button"
                className={cx("like-button", liked && "is-liked")}
                aria-pressed={liked}
                aria-label={liked ? "Unlike this prompt" : "Like this prompt"}
                onClick={() => setLiked((v) => !v)}
              >
                <Icon name="heart" size={20} weight={liked ? "fill" : "regular"} />
              </button>
            </footer>
          )}
        </article>
      ))}
    </div>
  );
}
