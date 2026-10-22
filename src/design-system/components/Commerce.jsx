import { useId } from "react";
import { cx } from "../../lib/cx.js";
import { Icon } from "./Icon.jsx";

/**
 * Selectable subscription plans (radio group). Plans: { id, title, price, unit?, note?, ribbon? }.
 * Never pre-select the most expensive plan; selection is always explicit and visible.
 */
export function PlanPicker({ label = "Choose a plan", plans, value, onChange }) {
  const name = useId();
  return (
    <fieldset className="plan-picker">
      <legend className="visually-hidden">{label}</legend>
      {plans.map((p) => (
        <label key={p.id} className={cx("plan-card", value === p.id && "is-selected")}>
          <input
            type="radio"
            name={name}
            value={p.id}
            checked={value === p.id}
            onChange={() => onChange(p.id)}
            className="visually-hidden"
          />
          {p.ribbon && <span className="plan-card__ribbon">{p.ribbon}</span>}
          <span className="plan-card__title">{p.title}</span>
          <span className="plan-card__price">{p.price}</span>
          {p.unit && <span className="plan-card__unit">{p.unit}</span>}
          {p.note && <span className="plan-card__note">{p.note}</span>}
          <span className="plan-card__check" aria-hidden="true">
            <Icon name="check" size={11} stroke={3} />
          </span>
        </label>
      ))}
    </fieldset>
  );
}

/** Feature × tier comparison. rows: [{ feature, tiers: [bool|string, ...] }]. */
export function ComparisonTable({ tiers, rows, caption = "Compare plans" }) {
  return (
    <table className="comparison">
      <caption className="visually-hidden">{caption}</caption>
      <thead>
        <tr>
          <th scope="col" className="comparison__feature">
            What you get
          </th>
          {tiers.map((t) => (
            <th key={t} scope="col">
              {t}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.feature}>
            <th scope="row" className="comparison__feature">
              {r.feature}
            </th>
            {r.tiers.map((v, i) => (
              <td key={tiers[i]}>
                {v === true ? (
                  <>
                    <Icon name="check" size={18} stroke={2.2} className="comparison__yes" />
                    <span className="visually-hidden">Included</span>
                  </>
                ) : v === false ? (
                  <span className="comparison__no">
                    <span aria-hidden="true">–</span>
                    <span className="visually-hidden">Not included</span>
                  </span>
                ) : (
                  v
                )}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/** Store-required subscription terms. Always visible near the purchase action. */
export function LegalText({ children }) {
  return <p className="legal-text">{children}</p>;
}
