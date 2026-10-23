import { cx } from "../../lib/cx.js";

/*
 * Original spot illustrations, drawn for Numaya (no third-party artwork). Each scene is one
 * composition on a 160 x 120 canvas (spots: 80 x 80): ink outlines, white paper, a ground shadow and at most one or
 * two accent marks. Colours come from semantic tokens via the .ill__* classes (content.css), so the
 * scenes follow the palette. Scenes are decorative: the surrounding title and copy carry the meaning.
 */
const SCENES = {
  /* Phone verified: the code message arrived and checked out. Brand purple, one sparkle. */
  verified: (
    <>
      <ellipse className="ill__wash" cx="80" cy="109" rx="50" ry="6" />
      <circle className="ill__promo" cx="120" cy="38" r="15" />
      <path className="ill__yellow" d="M36 24l2.4 6.2L45 33l-6.6 2.6L36 42l-2.4-6.4L27 33l6.6-2.8z" />
      <rect className="ill__paper ill__ink" x="54" y="12" width="52" height="92" rx="12" />
      <path className="ill__ink ill__open" d="M74 22h12" />
      <path className="ill__brand" d="M68 36h24a6 6 0 0 1 6 6v14a6 6 0 0 1-6 6H77l-7 6v-6h-2a6 6 0 0 1-6-6V42a6 6 0 0 1 6-6z" />
      <path className="ill__on-brand ill__open" d="M73 49l5 5 9-9" />
      <rect className="ill__soft" x="63" y="78" width="34" height="5" rx="2.5" />
      <rect className="ill__soft" x="63" y="88" width="22" height="5" rx="2.5" />
    </>
  ),
  /* Unmatched: two conversations that have drifted apart. Neutrals only, no celebration. */
  unmatched: (
    <>
      <ellipse className="ill__ground" cx="80" cy="109" rx="56" ry="6" />
      <path className="ill__paper ill__ink" d="M26 22h40a10 10 0 0 1 10 10v18a10 10 0 0 1-10 10H42l-10 9v-9h-6a10 10 0 0 1-10-10V32a10 10 0 0 1 10-10z" />
      <rect className="ill__soft" x="27" y="34" width="36" height="5" rx="2.5" />
      <rect className="ill__soft" x="27" y="44" width="24" height="5" rx="2.5" />
      <path className="ill__muted" d="M94 48h40a10 10 0 0 1 10 10v18a10 10 0 0 1-10 10h-6v9l-10-9H94a10 10 0 0 1-10-10V58a10 10 0 0 1 10-10z" />
      <rect className="ill__paper" x="96" y="60" width="34" height="5" rx="2.5" />
      <rect className="ill__paper" x="96" y="70" width="20" height="5" rx="2.5" />
    </>
  ),
  /* Blocked and reported: a shield carrying a report flag. Neutrals only. */
  blocked: (
    <>
      <ellipse className="ill__ground" cx="80" cy="110" rx="48" ry="6" />
      <path className="ill__muted" d="M18 44h20a8 8 0 0 1 8 8v6a8 8 0 0 1-8 8h-2v7l-8-7H18a8 8 0 0 1-8-8v-6a8 8 0 0 1 8-8z" />
      <path className="ill__paper ill__ink" d="M84 14l34 12v26c0 22-14 38-34 47-20-9-34-25-34-47V26z" />
      <path className="ill__ink ill__open" d="M74 38v42" />
      <path className="ill__strong" d="M74 40h24l-6 9 6 9H74z" />
    </>
  ),
  /* Discover, seen everyone: a small fanned stack of profile cards, the front one still to come. */
  "seen-everyone": (
    <>
      <ellipse className="ill__ground" cx="80" cy="109" rx="52" ry="6" />
      <rect className="ill__muted" x="56" y="20" width="48" height="74" rx="10" transform="translate(-14 4) rotate(-12 80 57)" />
      <rect className="ill__promo" x="56" y="20" width="48" height="74" rx="10" transform="translate(14 2) rotate(10 80 57)" />
      <rect className="ill__paper ill__ink" x="56" y="20" width="48" height="74" rx="10" />
      <circle className="ill__soft" cx="80" cy="47" r="10" />
      <path className="ill__soft" d="M64 80a16 16 0 0 1 32 0z" />
      <path className="ill__yellow" d="M126 22l2.2 5.6L134 30l-5.8 2.2L126 38l-2.2-5.8L118 30l5.8-2.4z" />
    </>
  ),
  /* Discover paused: a crescent moon and a quiet "z". A guilt-free break. */
  paused: (
    <>
      <path className="ill__promo ill__ink" d="M90 22a34 34 0 1 0 22 58a28 28 0 1 1-22-58z" />
      <path className="ill__ink ill__open" d="M112 26h12l-12 12h12" />
      <path className="ill__ink ill__open" d="M130 50h7l-7 7h7" />
      <path className="ill__yellow" d="M38 30l2 5 5 2-5 2-2 5-2-5-5-2 5-2z" />
      <circle className="ill__muted" cx="44" cy="84" r="2.5" />
      <circle className="ill__muted" cx="128" cy="92" r="2.5" />
    </>
  ),
  /* No new match yet: two paper planes on curving paths, heading towards each other. */
  "no-match": (
    <>
      <path className="ill__trail" d="M12 100C30 98 40 86 48 74" />
      <path className="ill__trail" d="M148 20C132 24 122 34 114 44" />
      <path className="ill__paper ill__ink" d="M46 76l30-22-10 34-7-10z" />
      <path className="ill__ink ill__open" d="M59 78l17-24" />
      <path className="ill__brand ill__ink" d="M116 42l-30 20 10-32 7 9z" />
      <path className="ill__ink ill__open" d="M103 39L86 62" />
      <circle className="ill__yellow" cx="81" cy="58" r="3" />
    </>
  ),
  /* Chats empty: a conversation waiting for its first message. */
  "no-chats": (
    <>
      <ellipse className="ill__ground" cx="80" cy="109" rx="52" ry="6" />
      <path className="ill__wash" d="M98 16h30a8 8 0 0 1 8 8v14a8 8 0 0 1-8 8h-4v7l-8-7H98a8 8 0 0 1-8-8V24a8 8 0 0 1 8-8z" />
      <path className="ill__paper ill__ink" d="M40 38h58a12 12 0 0 1 12 12v22a12 12 0 0 1-12 12H62l-14 12V84h-8a12 12 0 0 1-12-12V50a12 12 0 0 1 12-12z" />
      <circle className="ill__muted" cx="54" cy="61" r="5" />
      <circle className="ill__muted" cx="69" cy="61" r="5" />
      <circle className="ill__brand" cx="84" cy="61" r="5" />
    </>
  ),
  /* Spot, The basics: a "hello" name tag (square canvas). */
  hello: {
    viewBox: "0 0 80 80",
    art: (
      <>
        <rect className="ill__paper" x="10" y="16" width="60" height="50" rx="8" />
        <path className="ill__brand" d="M18 16h44a8 8 0 0 1 8 8v8H10v-8a8 8 0 0 1 8-8z" />
        <rect className="ill__ink ill__open" x="10" y="16" width="60" height="50" rx="8" />
        <path className="ill__ink ill__open" d="M10 32h60" />
        <rect className="ill__soft" x="20" y="44" width="40" height="6" rx="3" />
        <rect className="ill__on-brand-fill" x="26" y="22" width="28" height="4" rx="2" />
      </>
    ),
  },
  /* Spot, Interests: a record and a small peak, things people love. */
  interests: {
    viewBox: "0 0 80 80",
    art: (
      <>
        <path className="ill__promo ill__ink" d="M40 66l16-34 18 34z" />
        <circle className="ill__paper ill__ink" cx="30" cy="44" r="20" />
        <circle className="ill__soft" cx="30" cy="44" r="12" />
        <circle className="ill__brand" cx="30" cy="44" r="4.5" />
        <path className="ill__yellow" d="M64 10l2 5 5 2-5 2-2 5-2-5-5-2 5-2z" />
      </>
    ),
  },
};

export const ILLUSTRATION_SCENES = Object.keys(SCENES);

/**
 * Spot illustration. scene: one of ILLUSTRATION_SCENES. Outcome and empty-state scenes are 4:3
 * (160 x 120); `hello` and `interests` are square spots. width in px; height follows the canvas.
 */
export function Illustration({ scene, width, className }) {
  const entry = SCENES[scene];
  if (!entry) return null;
  const { viewBox = "0 0 160 120", art = entry } = entry.art ? entry : {};
  const [, , vw, vh] = viewBox.split(" ").map(Number);
  const w = width ?? vw;
  return (
    <svg
      className={cx("ill", className)}
      data-scene={scene}
      viewBox={viewBox}
      width={w}
      height={(w * vh) / vw}
      aria-hidden="true"
      focusable="false"
    >
      {art}
    </svg>
  );
}
