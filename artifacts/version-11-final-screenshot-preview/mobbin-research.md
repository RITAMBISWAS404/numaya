# V11 research: profile prompts (Mobbin)

## Couple could not be inspected

The brief asked for the Couple iOS app
(`mobbin.com/apps/couple-ios-6e0e7b43-3dcb-4d5d-9cb4-4d9d3c73e0ef`). I couldn't retrieve any Couple
screen, so nothing below describes Couple, and none of its details are invented.

**Direct link.** The app page can't be opened from this environment: a direct fetch failed with a
DNS error (`getaddrinfo ENOTFOUND mobbin.com`). The Mobbin connector only searches; it can't open an
app page by ID.

**Search.** Five searches through the connector (iOS) returned no screen from an app named Couple:

| Tool | Query |
|---|---|
| `search_screens` (deep) | "Couple dating app profile screen with prompts" |
| `search_screens` (standard) | "Couple profile" |
| `search_flows` | "Couple app profile" |
| `search_screens` (deep) | "Couple app user profile with prompt answers" |
| `search_screens` (standard) | "Couple dating app profile about me section" |

What came back:
- other dating apps: Tinder, Hinge, Bumble, Badoo, Coffee Meets Bagel, Lex, happn, Plenty of Fish;
- relationship apps (Paired, Moonly, pillowtalk);
- unrelated apps.

**What I used instead.** As the brief allows, I used the comparable dating-app profile and prompt
screens those searches did return. I looked at each image, not just its metadata.

## Screens inspected

| Screen | What it shows |
|---|---|
| [Tinder, profile](https://mobbin.com/screens/91cf59da-9b05-435c-b525-7fd774ce5b5a) | Each section has a small icon before a small, bold grey heading ("Essentials", "Interests", and "You'd never guess that I…" for the prompt). The prompt's answer below is the largest text in the section. Sections are separated by white space and a soft change of background, not heavy cards. |
| [Coffee Meets Bagel, edit prompts](https://mobbin.com/screens/45d7b220-3e45-4a66-b85b-82f0aa81d65c) | Several prompts stacked as large, separate cards. The question is in the brand colour, the answer in large bold text, with an edit pencil and a reorder handle. Four elevated cards in a row feel heavy. |
| [Badoo, profile questions](https://mobbin.com/screens/5d30c2b7-f9ec-4ef4-b56d-b3383e042bf8) | Three question/answer pairs: the question small and grey, the answer below in regular text, each row with a chevron to edit. Compact and scannable, but every answer has the same weight. |
| [Lex, edit profile prompts](https://mobbin.com/screens/4a481a36-842a-4774-8756-04bd4e002ff5) | Prompts as one list with hairline dividers: a grey label ("About me", "Ask me about") above the answer. Unanswered prompts are shown as "Not Answered". |
| [Hinge, write your profile answers](https://mobbin.com/screens/cc592105-e399-46da-889a-cdf071d7ec8e) | Exactly three prompt slots ("3 answers required"), each "Select a Prompt / And write your own answer". |
| [Bumble, Opening Moves](https://mobbin.com/screens/94a0fea1-5a42-4982-8ff5-1d55fc2727c9) | Up to three prompts as compact rows; an empty third slot is an "Add" row, not placeholder text. |
| [BlaBlaCar, about a member](https://mobbin.com/screens/ebbe112f-e2be-42e8-bc82-1b5be3dcfe79) | Small neutral line icons beside short statements, all one size and stroke. |

## What these screens agree on

1. **The question is a small label; the answer is the content.** Every app sets the question
   smaller and quieter than the answer.
2. **Several prompts work as one set.** The calmer screens (Lex, Badoo) keep them in one list with
   dividers. The heavier ones (Coffee Meets Bagel) stack a card per prompt.
3. **Three is the common number.** Hinge requires three answers, and Bumble allows up to three.
4. **A small icon before a heading helps scanning** (Tinder). It works because it is small, the same
   size every time, and sits beside the heading, not the answer.
5. **Unanswered prompts are not shown on a profile as content.** Editors show an empty slot or "Not
   Answered" (Lex, Hinge, Bumble). No app fills a gap with sample text.

## What V11 adapts

- **The prompt mark.** A 22px speech-bubble mark sits before the question, like Tinder's section
  icon. It is Numaya's own: the brand purple on the one light-purple tint, and only on prompts. It
  replaces V10's decorative closing quotation mark.
- **The hierarchy.** The question stays a small heading; the answer stays the largest text, in
  Numaya's display face.
- **Up to three prompts in one set.** When a profile has more than one answered prompt, they share
  one outlined module, divided by hairlines inset to the text (as in Lex), not a stack of cards (as
  in Coffee Meets Bagel). One prompt stays the single card.
- **No placeholders.** Only answered prompts are shown, at most three, in order. Today every profile
  holds one prompt, so every screen shows exactly one.

## What stays Numaya's own

- The display serif for answers, and the monochrome surfaces with purple as the one accent.
- The outlined white module for your own prompt, and direct content for someone else's.
- The prompt editor's flow: pick a question, write the answer, save.
- No brand-coloured question text (Coffee Meets Bagel's purple questions would compete with the
  primary actions), no grey answers (Badoo), no per-card elevation.
