import { ArrowCounterClockwise } from "@phosphor-icons/react/dist/csr/ArrowCounterClockwise";
import { ArrowRight } from "@phosphor-icons/react/dist/csr/ArrowRight";
import { ArrowUp } from "@phosphor-icons/react/dist/csr/ArrowUp";
import { Backspace } from "@phosphor-icons/react/dist/csr/Backspace";
import { Bell } from "@phosphor-icons/react/dist/csr/Bell";
import { Camera } from "@phosphor-icons/react/dist/csr/Camera";
import { Cards } from "@phosphor-icons/react/dist/csr/Cards";
import { CaretDown } from "@phosphor-icons/react/dist/csr/CaretDown";
import { CaretLeft } from "@phosphor-icons/react/dist/csr/CaretLeft";
import { CaretRight } from "@phosphor-icons/react/dist/csr/CaretRight";
import { CaretUp } from "@phosphor-icons/react/dist/csr/CaretUp";
import { ChatCircle } from "@phosphor-icons/react/dist/csr/ChatCircle";
import { Check } from "@phosphor-icons/react/dist/csr/Check";
import { DotsThree } from "@phosphor-icons/react/dist/csr/DotsThree";
import { EyeSlash } from "@phosphor-icons/react/dist/csr/EyeSlash";
import { Flag } from "@phosphor-icons/react/dist/csr/Flag";
import { GearSix } from "@phosphor-icons/react/dist/csr/GearSix";
import { Heart } from "@phosphor-icons/react/dist/csr/Heart";
import { Image } from "@phosphor-icons/react/dist/csr/Image";
import { Info } from "@phosphor-icons/react/dist/csr/Info";
import { Lock } from "@phosphor-icons/react/dist/csr/Lock";
import { MagnifyingGlass } from "@phosphor-icons/react/dist/csr/MagnifyingGlass";
import { MapPin } from "@phosphor-icons/react/dist/csr/MapPin";
import { Microphone } from "@phosphor-icons/react/dist/csr/Microphone";
import { PaperPlaneTilt } from "@phosphor-icons/react/dist/csr/PaperPlaneTilt";
import { Plus } from "@phosphor-icons/react/dist/csr/Plus";
import { SealCheck } from "@phosphor-icons/react/dist/csr/SealCheck";
import { ShieldCheck } from "@phosphor-icons/react/dist/csr/ShieldCheck";
import { SlidersHorizontal } from "@phosphor-icons/react/dist/csr/SlidersHorizontal";
import { Sparkle } from "@phosphor-icons/react/dist/csr/Sparkle";
import { Star } from "@phosphor-icons/react/dist/csr/Star";
import { User } from "@phosphor-icons/react/dist/csr/User";
import { Warning } from "@phosphor-icons/react/dist/csr/Warning";
import { WifiSlash } from "@phosphor-icons/react/dist/csr/WifiSlash";
import { X } from "@phosphor-icons/react/dist/csr/X";

/**
 * Numaya icon wrapper over Phosphor Icons (one family only; icons are imported individually so
 * the bundle only carries what is used).
 *
 * Weights: "regular" for inactive and secondary icons, "bold" for icons inside filled controls
 * and small sizes, "fill" selectively for active states (the active tab, a liked heart).
 * `stroke` is kept for call-site compatibility: stroke >= 2 maps to "bold".
 * Icons are decorative (aria-hidden); icon-only controls carry their own accessible label.
 */
const ICONS = {
  chevronLeft: CaretLeft,
  chevronRight: CaretRight,
  chevronDown: CaretDown,
  chevronUp: CaretUp,
  arrowRight: ArrowRight,
  arrowUp: ArrowUp,
  check: Check,
  plus: Plus,
  close: X,
  search: MagnifyingGlass,
  lock: Lock,
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
  send: PaperPlaneTilt,
  more: DotsThree,
  filter: SlidersHorizontal,
  settings: GearSix,
  user: User,
  location: MapPin,
  bell: Bell,
  eyeOff: EyeSlash,
  undo: ArrowCounterClockwise,
  sparkle: Sparkle,
  cards: Cards,
};

export const ICON_NAMES = Object.keys(ICONS);

export function Icon({ name, size = 24, stroke, weight, className, ...rest }) {
  const Glyph = ICONS[name];
  if (!Glyph) return null;
  const resolved = weight ?? (stroke !== undefined && stroke >= 2 ? "bold" : "regular");
  return <Glyph className={className} size={size} weight={resolved} aria-hidden="true" focusable="false" {...rest} />;
}
