import { Icon, Wordmark } from "../design-system/index.js";
import { cx } from "../lib/cx.js";

const REFERENCES = [
  { label: "Bumble · Onboarding flow", href: "https://mobbin.com/flows/210aeea2-40d3-40ba-bb1b-49894c6d3122" },
  { label: "Meetup · Onboarding flow", href: "https://mobbin.com/flows/e35f43d2-bbfe-46dc-9c8d-f34cace68d08" },
  { label: "Tiimo · Typography", href: "https://mobbin.com/apps/tiimo-ios-92e196c8-3689-45c1-8869-449f9b7207c4/dc39e0c5-e9cb-4411-a8c4-75cc3a5e8169/screens" },
];

/** Desktop-only context panel beside the simulator. */
export function Brief({ steps, current, verified, onJump, onRestart }) {
  const currentIndex = steps.findIndex((s) => s.id === current);

  return (
    <aside className="brief" aria-label="About this prototype">
      <header className="brief__top">
        <Wordmark size="sm" />
        <span className="brief__tag">Onboarding study</span>
      </header>

      <div className="brief__main">
        <p className="brief__eyebrow">iOS prototype · 393 × 852</p>
        <h2 className="brief__title">From hello to verified, in three steps.</h2>
        <p className="brief__body">
          The opening of Numaya’s sign-up. The sequence follows Bumble’s iOS onboarding,
          spacing and components take their cues from Meetup, and the type from Tiimo.
        </p>

        <nav aria-label="Prototype steps">
          <ol className="brief__steps">
            {steps.map((step, i) => {
              const state =
                i === currentIndex
                  ? verified ? "done" : "current"
                  : i < currentIndex ? "done" : "upcoming";
              return (
                <li key={step.id}>
                  <button
                    type="button"
                    className={cx("brief-step", `is-${state}`)}
                    aria-current={i === currentIndex ? "step" : undefined}
                    onClick={() => onJump(step.id)}
                  >
                    <span className="brief-step__index">
                      {state === "done" ? <Icon name="check" size={14} stroke={2.4} /> : `0${i + 1}`}
                    </span>
                    <span className="brief-step__text">
                      <span className="brief-step__title">{step.title}</span>
                      <span className="brief-step__summary">{step.summary}</span>
                    </span>
                  </button>
                </li>
              );
            })}
          </ol>
        </nav>

        <button type="button" className="brief__restart" onClick={onRestart}>
          Start over
        </button>
      </div>

      <footer className="brief__footer">
        <p className="brief__hint">Type on your keyboard or tap the on-screen pad. The demo code arrives by “text”.</p>
        <ul className="brief__refs">
          {REFERENCES.map((ref) => (
            <li key={ref.href}>
              <a href={ref.href} target="_blank" rel="noreferrer">
                {ref.label}
                <Icon name="arrowRight" size={14} stroke={2} />
              </a>
            </li>
          ))}
        </ul>
        <p className="brief__hint brief__credit">
          Icons: <a href="https://www.figma.com/community/file/1166831539721848736" target="_blank" rel="noreferrer">Solar</a> by 480 Design, 
          <a href="https://creativecommons.org/licenses/by/4.0/" target="_blank" rel="noreferrer">CC BY 4.0</a>
        </p>
      </footer>
    </aside>
  );
}
