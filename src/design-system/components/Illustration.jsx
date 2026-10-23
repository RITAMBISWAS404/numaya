import { cx } from "../../lib/cx.js";

/*
 * Original spot illustrations, drawn for Numaya (no third-party artwork). Each scene is one
 * composition on a 160 x 120 canvas: ink outlines, white paper, a ground shadow and at most one or
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
};

export const ILLUSTRATION_SCENES = Object.keys(SCENES);

/** Spot illustration. scene: one of ILLUSTRATION_SCENES. width in px (height follows 4:3). */
export function Illustration({ scene, width = 160, className }) {
  const art = SCENES[scene];
  if (!art) return null;
  return (
    <svg
      className={cx("ill", className)}
      data-scene={scene}
      viewBox="0 0 160 120"
      width={width}
      height={(width * 3) / 4}
      aria-hidden="true"
      focusable="false"
    >
      {art}
    </svg>
  );
}
