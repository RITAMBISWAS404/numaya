import { useState } from "react";
import { ICON_NAMES, Icon, Marker } from "../design-system/index.js";
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
        intro="The Numaya pink #F770E3 is the identity. It appears at its exact value on marks, progress, selection, verification and like/send fills. Anything placed on a solid pink fill is dark ink: white on it is only 2.51:1."
      >
        <Grid min={240}>
          <Specimen title="Brand fill + ink glyph" note={`#F770E3 · ink ${ratio(tokenByName["--color-on-brand"].resolved, brandHex)}`}>
            <span className="sc-brand-demo">
              <span className="sc-brand-demo__mark">
                <Icon name="check" size={28} stroke={2.75} />
              </span>
            </span>
          </Specimen>
          <Specimen title="Brand fill + ink label" note={`--color-on-brand on --color-brand · ${ratio(tokenByName["--color-on-brand"].resolved, brandHex)}`}>
            <span className="sc-pill-demo" style={{ background: "var(--color-brand)", color: "var(--color-on-brand)" }}>
              Say hello
            </span>
          </Specimen>
          <Specimen title="Brand emphasis in a headline" note={`Marker · ink on --color-brand-marker · ${ratio(tokenByName["--color-text-primary"].resolved, tokenByName["--color-brand-marker"].resolved)} · hero headlines only, one word`}>
            <p className="sc-type-sample" style={{ fontFamily: "var(--font-display)", fontSize: 34 }}>
              <Marker>Better</Marker>
            </p>
          </Specimen>
          <Specimen title="Brand text at body size" note={`--color-text-brand is ink · ${ratio(tokenByName["--color-text-brand"].resolved, WHITE)} · pink text fails on white`}>
            <p className="sc-type-sample" style={{ color: "var(--color-text-brand)", fontWeight: 600 }}>
              Change number
            </p>
          </Specimen>
          <Specimen title="Never" note="White content on a solid brand fill" tone="soft">
            <span className="sc-pill-demo sc-pill-demo--never" style={{ background: "var(--color-brand)", color: "var(--color-text-on-inverse)", boxShadow: "none" }}>
              <Icon name="close" size={16} stroke={2.4} /> White on #F770E3
            </span>
          </Specimen>
        </Grid>
      </Section>

      <Section id="color" title="Colour roles" intro="Semantic tokens only. Component CSS never references primitives or hex values.">
        {[
          ["Brand", "--color-brand"],
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

      <Section id="icons" title="Icons" intro="Solar icons (by 480 Design, CC BY 4.0), one family. Linear at a 1.5 stroke for inactive and secondary icons, a 2 stroke inside filled controls and at small sizes, Solar Bold (the filled drawing of the same symbol) for active states such as the current tab or a liked heart. Icon-only controls always carry an accessible label.">
        <div className="sc-icons">
          {ICON_NAMES.map((n) => (
            <div key={n} className="sc-icons__item">
              <Icon name={n} />
              <code>{n}</code>
            </div>
          ))}
        </div>
      </Section>
    </>
  );
}
