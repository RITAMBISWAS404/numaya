import { useState } from "react";
import { Avatar, ICON_NAMES, Icon, InfoCard, Wordmark } from "../design-system/index.js";
import { tokens, tokenByName } from "../design-system/tokens.js";
import { contrast } from "../lib/contrast.js";
import { Grid, Section, Specimen } from "./ui.jsx";

const semantic = (prefix) => tokens.filter((t) => t.layer === "semantic" && t.name.startsWith(prefix));
const WHITE = "#ffffff";

function ratio(a, b) {
  const r = contrast(a, b);
  return r ? `${r.toFixed(2)}:1` : "–";
}

function Swatch({ token }) {
  const value = token.resolved;
  const isHex = value.startsWith("#");
  return (
    <div className="sc-swatch">
      <span className="sc-swatch__chip" style={{ background: `var(${token.name})` }} />
      <span className="sc-swatch__text">
        <code className="sc-swatch__name">{token.name}</code>
        <span className="sc-swatch__value">
          {value}
          {isHex && <> · {ratio(value, WHITE)} on white</>}
        </span>
        {token.description && <span className="sc-swatch__desc">{token.description}</span>}
      </span>
    </div>
  );
}

const TYPE_ROLES = [
  ["hero", "display", "Fewer swipes. Better first dates."],
  ["display", "display", "Can we get your number, please?"],
  ["headline", "display", "You’re verified"],
  ["title-sm", "display", "Country or region"],
  ["title", "display", "Breakfast for dinner is the superior meal."],
  ["body", "text", "We only use phone numbers to make sure everyone on Numaya is real."],
  ["body-sm", "text", "Profiles built around conversation."],
  ["input", "text", "(415) 555-0132"],
  ["button", "text", "Create an account"],
  ["label", "text", "Phone number"],
  ["caption", "text", "We never share this with anyone."],
  ["micro", "text", "This prototype ends here."],
  ["eyebrow", "text", "LET’S DEBATE THIS"],
];

export function Foundations() {
  const [motionKey, setMotionKey] = useState(0);
  const brandHex = tokenByName["--color-brand"].resolved;

  return (
    <>
      <Section
        id="brand"
        title="Brand"
        intro="Numaya keeps its name, wordmark, Fraunces and Inter; the visual system, icons included, follows Meetup. The brand colour is Meetup's purple #7262C7 (sampled from the current iOS app): selected chips and pills, outgoing bubbles, SuperSwipe, send, progress, links and focus. White on it is 4.90:1. Primary actions, switches and checkboxes are ink. Meetup's secondary colours frame avatars, badges and illustrations, never text."
      >
        <Grid min={240}>
          <Specimen title="Wordmark" note="The Numaya mark in brand purple with an accent-rose dot">
            <Wordmark />
          </Specimen>
          <Specimen title="Brand fill + white text" note={`#7262C7 · white ${ratio(WHITE, brandHex)}`}>
            <span className="sc-pill-demo" style={{ background: "var(--color-brand)", color: "var(--color-on-brand)" }}>
              Jazz <Icon name="minus" size={18} />
            </span>
          </Specimen>
          <Specimen title="Brand text (links)" note={`--color-text-brand · ${ratio(tokenByName["--color-text-brand"].resolved, WHITE)} on white; deep purple on grey`}>
            <p className="sc-type-sample" style={{ color: "var(--color-text-brand)", fontWeight: 600 }}>
              See all
            </p>
          </Specimen>
          <Specimen title="Guidance card" note="The production InfoCard: light lavender wash (surface.brand), purple icon beside a near-black heading, body below">
            <InfoCard icon="lock" title="Your number stays private">
              We never share it, and it won’t be on your profile.
            </InfoCard>
          </Specimen>
          <Specimen title="Avatar framing" note="Initial avatars take a Meetup pastel by name">
            <span style={{ display: "flex", gap: 8 }}>
              {["Maya", "Sam", "Noor", "Jo"].map((n) => (
                <Avatar key={n} name={n} size="md" />
              ))}
            </span>
          </Specimen>
        </Grid>
      </Section>

      <Section id="color" title="Colour roles" intro="Semantic tokens only. Component CSS never references primitives or hex values.">
        {[
          ["Brand", "--color-brand"],
          ["Accent", "--color-accent"],
          ["Text", "--color-text"],
          ["Surface", "--color-surface"],
          ["Border and focus", "--color-border"],
          ["Feedback", "--color-danger"],
        ].map(([group, prefix]) => (
          <div key={group} className="sc-swatch-group">
            <h3 className="sc-subtitle">{group}</h3>
            <div className="sc-swatches">
              {(group === "Border and focus"
                ? [...semantic("--color-border"), ...semantic("--color-focus"), ...semantic("--color-overlay")]
                : group === "Feedback"
                  ? [...semantic("--color-danger"), ...semantic("--color-success"), ...semantic("--color-warning")]
                  : group === "Brand"
                    ? [...semantic("--color-brand"), tokenByName["--color-on-brand"]]
                    : semantic(prefix)
              ).map((t) => (
                <Swatch key={t.name} token={t} />
              ))}
            </div>
          </div>
        ))}
      </Section>

      <Section id="type" title="Typography" intro="Fraunces (display, regular weight) for expression; Inter for operation. Hierarchy comes from size and family, not weight.">
        <div className="sc-type-list">
          {TYPE_ROLES.map(([role, family, sample]) => (
            <div key={role} className="sc-type-row">
              <div className="sc-type-meta">
                <code>--type-{role}-*</code>
                <span>
                  {family === "display" ? "Fraunces" : "Inter"} · {tokenByName[`--type-${role}-size`].resolved} /{" "}
                  {tokenByName[`--type-${role}-line`].resolved} · {tokenByName[`--type-${role}-weight`].resolved}
                </span>
              </div>
              <p
                className="sc-type-sample"
                style={{
                  fontFamily: `var(--font-${family})`,
                  fontVariationSettings: family === "display" ? "var(--font-display-axes)" : undefined,
                  fontSize: `var(--type-${role}-size)`,
                  lineHeight: `var(--type-${role}-line)`,
                  fontWeight: `var(--type-${role}-weight)`,
                  letterSpacing: `var(--type-${role}-tracking)`,
                  textTransform: role === "eyebrow" ? "uppercase" : undefined,
                  color: role === "eyebrow" ? "var(--color-text-brand)" : undefined,
                }}
              >
                {sample}
              </p>
            </div>
          ))}
        </div>
      </Section>

      <Section id="space" title="Space, size and radius">
        <Grid min={300}>
          <Specimen title="Spacing scale" note="4-point grid · --space-*" wide>
            <div className="sc-scale">
              {semantic("--space-").map((t) => (
                <div key={t.name} className="sc-scale__row">
                  <code>{t.name}</code>
                  <span className="sc-scale__bar" style={{ width: `var(${t.name})` }} />
                  <span>{t.resolved}</span>
                </div>
              ))}
            </div>
          </Specimen>
          <Specimen title="Layout and sizes" note="Gutter, touch target, control and avatar sizes">
            <div className="sc-scale">
              {[...semantic("--layout-"), ...semantic("--size-")].map((t) => (
                <div key={t.name} className="sc-scale__row">
                  <code>{t.name}</code>
                  <span>{t.resolved}</span>
                </div>
              ))}
            </div>
          </Specimen>
          <Specimen title="Radius" note="--radius-*">
            <div className="sc-radius">
              {semantic("--radius-").map((t) => (
                <div key={t.name} className="sc-radius__item">
                  <span style={{ borderRadius: `var(${t.name})` }} />
                  <code>{t.name.replace("--radius-", "")}</code>
                </div>
              ))}
            </div>
          </Specimen>
        </Grid>
      </Section>

      <Section id="elevation" title="Elevation and surfaces">
        <div className="sc-elevation">
          {semantic("--shadow-").map((t) => (
            <div key={t.name} className="sc-elevation__item">
              <span style={{ boxShadow: `var(${t.name})` }} />
              <code>{t.name}</code>
              {t.description && <small>{t.description}</small>}
            </div>
          ))}
        </div>
      </Section>

      <Section id="motion" title="Motion" intro="Durations collapse under prefers-reduced-motion (fast/base → 1ms, slow → 120ms, push → 160ms); movement becomes fades.">
        <button type="button" className="btn btn--secondary btn--inline btn--sm" onClick={() => setMotionKey((k) => k + 1)}>
          <span className="btn__label">Replay</span>
        </button>
        <div className="sc-motion" key={motionKey}>
          {semantic("--motion-duration-").map((d) => (
            <div key={d.name} className="sc-motion__row">
              <code>
                {d.name} · {d.resolved}
              </code>
              <span className="sc-motion__track">
                <span className="sc-motion__dot" style={{ animationDuration: `var(${d.name})` }} />
              </span>
            </div>
          ))}
          <div className="sc-motion__easings">
            {semantic("--motion-ease-").map((e) => (
              <code key={e.name}>
                {e.name}: {e.resolved}
              </code>
            ))}
          </div>
        </div>
      </Section>

      <Section id="icons" title="Icons" intro="Material Symbols Rounded (Google, Apache 2.0), one family: weight 500, optical size 24, filled (FILL 1) by default. The unfilled drawing appears only where it marks a different state (inactive tabs beside the filled current tab). Extracted from the pinned official SVG set at build time; no icon font or remote request. Icon-only controls always carry an accessible label.">
        <div className="sc-icons">
          {ICON_NAMES.map((n) => (
            <div key={n} className="sc-icons__item">
              <Icon name={n} />
              <code>{n}</code>
            </div>
          ))}
        </div>
        <div className="sc-icons">
          {["outline"].map((w) =>
            ["heart", "message", "user", "cards", "settings", "bell"].map((n) => (
              <div key={w + n} className="sc-icons__item">
                <Icon name={n} weight={w} />
                <code>{n} · {w}</code>
              </div>
            )),
          )}
        </div>
      </Section>
    </>
  );
}
