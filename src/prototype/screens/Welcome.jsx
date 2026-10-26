import { useEffect, useState } from "react";
import { Button, IllustrationSlot, Screen, Toast, Wordmark } from "../../design-system/index.js";
import { experimentTheme, themeClassName } from "../../lib/theme.js";

/* Tiimo-inspired experiment only: interests as tinted emoji stickers in the reserved hero (the
   artwork slot itself stays empty). Decorative. */
const STICKERS = [
  { emoji: "🍷", tone: "peach" },
  { emoji: "🎷", tone: "lilac" },
  { emoji: "📷", tone: "sky" },
  { emoji: "🧗", tone: "mint" },
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

  const themed = themeClassName(experimentTheme());
  return (
    <Screen tone="brand" className={themed ? `welcome ${themed}` : "welcome"} aria-labelledby="welcome-title">
      {/* Brand header: sets the left axis the headline, lede and actions share. */}
      <header className="welcome__brand">
        <Wordmark />
      </header>

      {/* Reserved for the multi-illustration hero composition (docs/numaya-illustration-map.md):
          the space is held, but nothing is drawn until the artwork is supplied. */}
      <div className="welcome__hero">
        <IllustrationSlot id="welcome-hero" className="welcome__art" />
        {themed && (
          <ul className="welcome__stickers" aria-hidden="true">
            {STICKERS.map((s) => (
              <li key={s.emoji} className="welcome__sticker" data-tone={s.tone}>
                {s.emoji}
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="welcome__panel">
        <h1 id="welcome-title" className="welcome__title">
          Fewer swipes.
          <br />
          Better first dates.
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
