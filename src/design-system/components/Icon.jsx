import { Airplane } from "@phosphor-icons/react/dist/csr/Airplane";
import { ArrowCounterClockwise } from "@phosphor-icons/react/dist/csr/ArrowCounterClockwise";
import { ArrowRight } from "@phosphor-icons/react/dist/csr/ArrowRight";
import { ArrowUp } from "@phosphor-icons/react/dist/csr/ArrowUp";
import { Backspace } from "@phosphor-icons/react/dist/csr/Backspace";
import { Bank } from "@phosphor-icons/react/dist/csr/Bank";
import { Bell } from "@phosphor-icons/react/dist/csr/Bell";
import { Camera } from "@phosphor-icons/react/dist/csr/Camera";
import { Cards } from "@phosphor-icons/react/dist/csr/Cards";
import { CaretDown } from "@phosphor-icons/react/dist/csr/CaretDown";
import { CaretLeft } from "@phosphor-icons/react/dist/csr/CaretLeft";
import { CaretRight } from "@phosphor-icons/react/dist/csr/CaretRight";
import { CaretUp } from "@phosphor-icons/react/dist/csr/CaretUp";
import { ChatCircle } from "@phosphor-icons/react/dist/csr/ChatCircle";
import { Check } from "@phosphor-icons/react/dist/csr/Check";
import { CookingPot } from "@phosphor-icons/react/dist/csr/CookingPot";
import { DiceFive } from "@phosphor-icons/react/dist/csr/DiceFive";
import { DotsThree } from "@phosphor-icons/react/dist/csr/DotsThree";
import { EyeSlash } from "@phosphor-icons/react/dist/csr/EyeSlash";
import { Feather } from "@phosphor-icons/react/dist/csr/Feather";
import { Flag } from "@phosphor-icons/react/dist/csr/Flag";
import { GearSix } from "@phosphor-icons/react/dist/csr/GearSix";
import { Heart } from "@phosphor-icons/react/dist/csr/Heart";
import { Image } from "@phosphor-icons/react/dist/csr/Image";
import { Info } from "@phosphor-icons/react/dist/csr/Info";
import { LockSimple } from "@phosphor-icons/react/dist/csr/LockSimple";
import { MagnifyingGlass } from "@phosphor-icons/react/dist/csr/MagnifyingGlass";
import { MapPin } from "@phosphor-icons/react/dist/csr/MapPin";
import { Microphone } from "@phosphor-icons/react/dist/csr/Microphone";
import { MinusCircle } from "@phosphor-icons/react/dist/csr/MinusCircle";
import { Mountains } from "@phosphor-icons/react/dist/csr/Mountains";
import { MusicNotes } from "@phosphor-icons/react/dist/csr/MusicNotes";
import { Palette } from "@phosphor-icons/react/dist/csr/Palette";
import { PersonSimpleRun } from "@phosphor-icons/react/dist/csr/PersonSimpleRun";
import { Plus } from "@phosphor-icons/react/dist/csr/Plus";
import { PlusCircle } from "@phosphor-icons/react/dist/csr/PlusCircle";
import { SealCheck } from "@phosphor-icons/react/dist/csr/SealCheck";
import { ShieldCheck } from "@phosphor-icons/react/dist/csr/ShieldCheck";
import { SlidersHorizontal } from "@phosphor-icons/react/dist/csr/SlidersHorizontal";
import { Sparkle } from "@phosphor-icons/react/dist/csr/Sparkle";
import { Star } from "@phosphor-icons/react/dist/csr/Star";
import { Trash } from "@phosphor-icons/react/dist/csr/Trash";
import { User } from "@phosphor-icons/react/dist/csr/User";
import { UserMinus } from "@phosphor-icons/react/dist/csr/UserMinus";
import { Warning } from "@phosphor-icons/react/dist/csr/Warning";
import { WifiSlash } from "@phosphor-icons/react/dist/csr/WifiSlash";
import { Wine } from "@phosphor-icons/react/dist/csr/Wine";
import { X } from "@phosphor-icons/react/dist/csr/X";

/**
 * Numaya icon wrapper over Phosphor Icons (MIT; see THIRD_PARTY_NOTICES.md), chosen as the closest
 * open match to the current Meetup iOS iconography: thin rounded line glyphs, the same glyph filled
 * in purple for the active state, and lavender-filled duotone spot icons. Meetup's own icon set is
 * proprietary and unpublished, so this is a stylistic match, not Meetup's assets. One family only,
 * imported per icon so the bundle carries only what is used.
 *
 * Semantic names stay stable; the Phosphor glyph behind each is chosen here. Weights:
 * - "regular" (default): Meetup's line style (tab bar, menus, list rows, chips, fields).
 * - "fill": active and emphasised states (current tab, Like and SuperSwipe, the match heart,
 *   verified seals).
 * - "bold": line glyphs inside small filled marks or next to heavy neighbours (badge checks, the
 *   Pass X). Legacy call sites passing stroke >= 2 or a heavy strokeWidth map here.
 * - "duotone": spot icons on guidance cards and empty states (Meetup's lavender-filled spot icons).
 * Icons are decorative (aria-hidden); icon-only controls carry their own accessible label.
 */
const GLYPHS = {
  chevronLeft: CaretLeft,
  chevronRight: CaretRight,
  chevronDown: CaretDown,
  chevronUp: CaretUp,
  arrowRight: ArrowRight,
  arrowUp: ArrowUp,
  check: Check,
  plus: Plus,
  plusCircle: PlusCircle,
  minusCircle: MinusCircle,
  close: X,
  search: MagnifyingGlass,
  lock: LockSimple,
  heart: Heart,
  star: Star,
  delete: Backspace,
  message: ChatCircle,
  shield: ShieldCheck,
  verified: SealCheck,
  flag: Flag,
  info: Info,
  alert: Warning,
  wifiOff: WifiSlash,
  camera: Camera,
  image: Image,
  mic: Microphone,
  send: ArrowUp,
  more: DotsThree,
  filter: SlidersHorizontal,
  settings: GearSix,
  user: User,
  userMinus: UserMinus,
  trash: Trash,
  location: MapPin,
  bell: Bell,
  eyeOff: EyeSlash,
  undo: ArrowCounterClockwise,
  sparkle: Sparkle,
  cards: Cards,
  wine: Wine,
  music: MusicNotes,
  cooking: CookingPot,
  hiking: Mountains,
  art: Palette,
  museum: Bank,
  running: PersonSimpleRun,
  games: DiceFive,
  plane: Airplane,
  pen: Feather,
};

/* Marks whose meaning is the filled drawing. */
const DEFAULT_WEIGHT = { verified: "fill", more: "bold" };

export const ICON_NAMES = Object.keys(GLYPHS);

export function Icon({ name, size = 24, stroke, strokeWidth, weight, className, ...rest }) {
  const Glyph = GLYPHS[name];
  if (!Glyph) return null;
  const heavy = (stroke !== undefined && stroke >= 2) || (strokeWidth !== undefined && strokeWidth >= 2.5);
  const resolved = weight ?? (heavy ? "bold" : DEFAULT_WEIGHT[name] ?? "regular");
  return (
    <Glyph
      className={className ? `icon ${className}` : "icon"}
      size={size}
      weight={resolved}
      data-icon={name}
      data-weight={resolved}
      aria-hidden="true"
      focusable="false"
      {...rest}
    />
  );
}
