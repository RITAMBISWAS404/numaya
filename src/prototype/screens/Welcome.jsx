import { useEffect, useState } from "react";
import { Button, Emphasis, IllustrationPlaceholder, Ribbon, Screen, Toast, Wordmark } from "../../design-system/index.js";

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
        <IllustrationPlaceholder id="welcome-hero" ratio="1 / 1" className="welcome__art" />
      </div>

      <div className="welcome__panel">
        <h1 id="welcome-title" className="welcome__title">
          Fewer swipes.
          <br />
          <Emphasis className="welcome__emphasis">Better</Emphasis> first dates.
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
