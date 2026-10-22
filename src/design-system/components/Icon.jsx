import { AddIcon as L_AddIcon } from "@solar-icons/react/linear/add";
import { AltArrowDownIcon as L_AltArrowDownIcon } from "@solar-icons/react/linear/alt-arrow-down";
import { AltArrowLeftIcon as L_AltArrowLeftIcon } from "@solar-icons/react/linear/alt-arrow-left";
import { AltArrowRightIcon as L_AltArrowRightIcon } from "@solar-icons/react/linear/alt-arrow-right";
import { AltArrowUpIcon as L_AltArrowUpIcon } from "@solar-icons/react/linear/alt-arrow-up";
import { ArrowRightIcon as L_ArrowRightIcon } from "@solar-icons/react/linear/arrow-right";
import { ArrowUpIcon as L_ArrowUpIcon } from "@solar-icons/react/linear/arrow-up";
import { BackspaceIcon as L_BackspaceIcon } from "@solar-icons/react/linear/backspace";
import { BellIcon as L_BellIcon } from "@solar-icons/react/linear/bell";
import { CameraIcon as L_CameraIcon } from "@solar-icons/react/linear/camera";
import { ChatRoundIcon as L_ChatRoundIcon } from "@solar-icons/react/linear/chat-round";
import { CheckIcon as L_CheckIcon } from "@solar-icons/react/linear/check";
import { CloseIcon as L_CloseIcon } from "@solar-icons/react/linear/close";
import { CloudCrossIcon as L_CloudCrossIcon } from "@solar-icons/react/linear/cloud-cross";
import { CopyIcon as L_CopyIcon } from "@solar-icons/react/linear/copy";
import { DangerTriangleIcon as L_DangerTriangleIcon } from "@solar-icons/react/linear/danger-triangle";
import { EyeClosedIcon as L_EyeClosedIcon } from "@solar-icons/react/linear/eye-closed";
import { FlagIcon as L_FlagIcon } from "@solar-icons/react/linear/flag";
import { GalleryIcon as L_GalleryIcon } from "@solar-icons/react/linear/gallery";
import { HeartIcon as L_HeartIcon } from "@solar-icons/react/linear/heart";
import { InfoCircleIcon as L_InfoCircleIcon } from "@solar-icons/react/linear/info-circle";
import { LockKeyholeMinimalisticIcon as L_LockKeyholeMinimalisticIcon } from "@solar-icons/react/linear/lock-keyhole-minimalistic";
import { MagnifierIcon as L_MagnifierIcon } from "@solar-icons/react/linear/magnifier";
import { MapPointIcon as L_MapPointIcon } from "@solar-icons/react/linear/map-point";
import { MicrophoneIcon as L_MicrophoneIcon } from "@solar-icons/react/linear/microphone";
import { SettingsIcon as L_SettingsIcon } from "@solar-icons/react/linear/settings";
import { ShieldCheckIcon as L_ShieldCheckIcon } from "@solar-icons/react/linear/shield-check";
import { StarIcon as L_StarIcon } from "@solar-icons/react/linear/star";
import { StarsIcon as L_StarsIcon } from "@solar-icons/react/linear/stars";
import { Tuning2Icon as L_Tuning2Icon } from "@solar-icons/react/linear/tuning-2";
import { UndoLeftRoundIcon as L_UndoLeftRoundIcon } from "@solar-icons/react/linear/undo-left-round";
import { UserIcon as L_UserIcon } from "@solar-icons/react/linear/user";
import { VerifiedCheckIcon as L_VerifiedCheckIcon } from "@solar-icons/react/linear/verified-check";
import { ChatRoundIcon as B_ChatRoundIcon } from "@solar-icons/react/bold/chat-round";
import { CopyIcon as B_CopyIcon } from "@solar-icons/react/bold/copy";
import { HeartIcon as B_HeartIcon } from "@solar-icons/react/bold/heart";
import { MenuDotsIcon as B_MenuDotsIcon } from "@solar-icons/react/bold/menu-dots";
import { StarIcon as B_StarIcon } from "@solar-icons/react/bold/star";
import { UserIcon as B_UserIcon } from "@solar-icons/react/bold/user";

/**
 * Numaya icon wrapper over the Solar icon set (artwork by 480 Design, CC BY 4.0; see
 * THIRD_PARTY_NOTICES.md). One family only, imported per icon so the bundle carries only what is used.
 *
 * Semantic names stay stable; the Solar glyph behind each is chosen here. Weights:
 * - "regular": Solar Linear at a 1.5 stroke, for inactive, navigation and supporting icons.
 * - "bold": Solar Linear at a 2 stroke, for glyphs inside filled controls and at small sizes.
 * - "fill": Solar Bold, the filled drawing of the same symbol, for active and selected states (the
 *   current tab, a liked heart). Icons without a filled counterpart fall back to "bold".
 * `stroke` is kept for call-site compatibility: stroke >= 2 maps to "bold". A `strokeWidth` prop overrides
 * the weight's stroke for the rare glyph that must match a heavier neighbour (the Pass X).
 * Icons are decorative (aria-hidden); icon-only controls carry their own accessible label.
 */
const LINEAR = {
  chevronLeft: L_AltArrowLeftIcon,
  chevronRight: L_AltArrowRightIcon,
  chevronDown: L_AltArrowDownIcon,
  chevronUp: L_AltArrowUpIcon,
  arrowRight: L_ArrowRightIcon,
  arrowUp: L_ArrowUpIcon,
  check: L_CheckIcon,
  plus: L_AddIcon,
  close: L_CloseIcon,
  search: L_MagnifierIcon,
  lock: L_LockKeyholeMinimalisticIcon,
  heart: L_HeartIcon,
  star: L_StarIcon,
  delete: L_BackspaceIcon,
  message: L_ChatRoundIcon,
  shield: L_ShieldCheckIcon,
  verified: L_VerifiedCheckIcon,
  flag: L_FlagIcon,
  info: L_InfoCircleIcon,
  alert: L_DangerTriangleIcon,
  wifiOff: L_CloudCrossIcon,
  camera: L_CameraIcon,
  image: L_GalleryIcon,
  mic: L_MicrophoneIcon,
  send: L_ArrowUpIcon,
  more: B_MenuDotsIcon, // Solar Linear draws hollow dots; the solid drawing is the standard ellipsis
  filter: L_Tuning2Icon,
  settings: L_SettingsIcon,
  user: L_UserIcon,
  location: L_MapPointIcon,
  bell: L_BellIcon,
  eyeOff: L_EyeClosedIcon,
  undo: L_UndoLeftRoundIcon,
  sparkle: L_StarsIcon,
  cards: L_CopyIcon,
};

const FILLED = {
  heart: B_HeartIcon,
  star: B_StarIcon,
  message: B_ChatRoundIcon,
  user: B_UserIcon,
  cards: B_CopyIcon,
};

const STROKE = { regular: 1.5, bold: 2 };

export const ICON_NAMES = Object.keys(LINEAR);

export function Icon({ name, size = 24, stroke, strokeWidth, weight, className, ...rest }) {
  if (!LINEAR[name]) return null;
  const resolved = weight ?? (stroke !== undefined && stroke >= 2 ? "bold" : "regular");
  const filled = resolved === "fill" && FILLED[name];
  const Glyph = filled || LINEAR[name];
  return (
    <Glyph
      className={className}
      size={size}
      strokeWidth={filled ? undefined : strokeWidth ?? STROKE[resolved] ?? STROKE.bold}
      data-weight={filled ? "fill" : resolved === "regular" ? "regular" : "bold"}
      aria-hidden="true"
      focusable="false"
      {...rest}
    />
  );
}
