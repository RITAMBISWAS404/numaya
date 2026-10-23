import { act, fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useRef, useState } from "react";
import { describe, expect, it, vi } from "vitest";
import {
  Button,
  ChipGroup,
  CodeInput,
  Composer,
  Dialog,
  ActionBar,
  EmptyState,
  Fab,
  IllustrationPlaceholder,
  Icon,
  ProfileCard,
  IconButton,
  MessageBubble,
  OptionCards,
  PhoneField,
  PlanPicker,
  RangeSlider,
  SegmentedControl,
  TabBar,
  Sheet,
  Switch,
  TextField,
  VerifiedBadge,
} from "../../src/design-system/index.js";
import { DEFAULT_COUNTRY } from "../../src/data/countries.js";
import { Wordmark } from "../../src/design-system/index.js";
import { LOGO_SRC } from "../../src/design-system/components/Brand.jsx";

describe("actions", () => {
  it("Button loading disables the control and announces busy", () => {
    const onClick = vi.fn();
    render(
      <Button loading onClick={onClick}>
        Save
      </Button>,
    );
    const btn = screen.getByRole("button", { name: "Save" });
    expect(btn).toBeDisabled();
    expect(btn).toHaveAttribute("aria-busy", "true");
    fireEvent.click(btn);
    expect(onClick).not.toHaveBeenCalled();
  });

  it("Fab and IconButton expose accessible names", () => {
    render(
      <>
        <Fab label="Send code" disabled />
        <IconButton icon="close" label="Close" />
      </>,
    );
    expect(screen.getByRole("button", { name: "Send code" })).toBeDisabled();
    expect(screen.getByRole("button", { name: "Close" })).toBeEnabled();
  });
});

describe("fields", () => {
  it("TextField links its error and marks the input invalid", () => {
    render(<TextField label="Email" defaultValue="maya@" error="Enter a full email address." />);
    const input = screen.getByLabelText("Email");
    expect(input).toHaveAttribute("aria-invalid", "true");
    expect(input).toHaveAccessibleDescription("Enter a full email address.");
    expect(screen.getByRole("alert")).toHaveTextContent("Enter a full email address.");
  });

  it("PhoneField shows the formatted national number and the country", () => {
    render(<PhoneField country={DEFAULT_COUNTRY} digits="4155550132" onDigitsChange={() => {}} onCountryPress={() => {}} />);
    expect(screen.getByLabelText("Phone number")).toHaveValue("(415) 555-0132");
    expect(screen.getByRole("button", { name: /Country: United States, US \+1/ })).toBeInTheDocument();
  });

  it("CodeInput strips non-digits and caps the length", async () => {
    function Harness() {
      const [v, setV] = useState("");
      const ref = useRef(null);
      return <CodeInput ref={ref} id="c" value={v} onChange={setV} />;
    }
    const { container } = render(<Harness />);
    const input = container.querySelector("input");
    fireEvent.change(input, { target: { value: "12a3 45678" } });
    expect(input).toHaveValue("123456");
  });
});

describe("selection", () => {
  it("ChipGroup enforces its maximum and marks others unavailable", async () => {
    const user = userEvent.setup();
    function Harness() {
      const [v, setV] = useState(["Jazz"]);
      return <ChipGroup label="Interests" options={["Jazz", "Cooking", "Running"]} value={v} onChange={setV} max={2} />;
    }
    render(<Harness />);
    await user.click(screen.getByRole("button", { name: /Cooking/ }));
    expect(screen.getByRole("button", { name: /Cooking/ })).toHaveAttribute("aria-pressed", "true");
    const running = screen.getByRole("button", { name: /Running/ });
    expect(running).toHaveAttribute("aria-disabled", "true");
    await user.click(running);
    expect(running).toHaveAttribute("aria-pressed", "false");
    expect(screen.getByText("2/2 selected")).toBeInTheDocument();
  });

  it("Switch toggles and shows a status spinner while pending", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    const { rerender } = render(<Switch label="New messages" checked={false} onChange={onChange} />);
    await user.click(screen.getByRole("switch", { name: "New messages" }));
    expect(onChange).toHaveBeenCalledWith(true);
    rerender(<Switch label="New messages" checked={false} pending onChange={onChange} />);
    expect(screen.queryByRole("switch")).not.toBeInTheDocument();
    expect(screen.getByRole("status", { name: "Saving New messages" })).toBeInTheDocument();
  });

  it("OptionCards multi respects max", async () => {
    const user = userEvent.setup();
    function Harness() {
      const [v, setV] = useState(["a"]);
      return (
        <OptionCards
          mode="multi"
          max={1}
          value={v}
          onChange={setV}
          options={[
            { value: "a", label: "Alpha" },
            { value: "b", label: "Beta" },
          ]}
        />
      );
    }
    render(<Harness />);
    expect(screen.getByRole("checkbox", { name: "Beta" })).toBeDisabled();
    await user.click(screen.getByRole("checkbox", { name: "Alpha" }));
    expect(screen.getByRole("checkbox", { name: "Beta" })).toBeEnabled();
  });

  it("SegmentedControl moves with arrow keys", () => {
    function Harness() {
      const [v, setV] = useState("basic");
      return (
        <SegmentedControl
          label="Filters"
          value={v}
          onChange={setV}
          options={[
            { value: "basic", label: "Basic" },
            { value: "advanced", label: "Advanced" },
          ]}
        />
      );
    }
    render(<Harness />);
    fireEvent.keyDown(screen.getByRole("tablist"), { key: "ArrowRight" });
    expect(screen.getByRole("tab", { name: "Advanced" })).toHaveAttribute("aria-selected", "true");
  });

  it("RangeSlider thumbs never cross", () => {
    const onChange = vi.fn();
    render(<RangeSlider label="Age" min={18} max={80} value={[30, 40]} onChange={onChange} />);
    fireEvent.change(screen.getByLabelText("Minimum age"), { target: { value: "55" } });
    expect(onChange).toHaveBeenLastCalledWith([39, 40]);
  });

  it("PlanPicker is a radio group with explicit selection", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(
      <PlanPicker
        value="1m"
        onChange={onChange}
        plans={[
          { id: "1w", title: "1 week", price: "$9.99" },
          { id: "1m", title: "1 month", price: "$24.99" },
        ]}
      />,
    );
    expect(screen.getByRole("radio", { name: /1 month/ })).toBeChecked();
    await user.click(screen.getByText("1 week"));
    expect(onChange).toHaveBeenCalledWith("1w");
  });
});

describe("overlays", () => {
  it("Sheet focuses [data-autofocus], closes on Escape and restores focus", async () => {
    const user = userEvent.setup();
    function Harness() {
      const [open, setOpen] = useState(false);
      return (
        <>
          <button onClick={() => setOpen(true)}>Open</button>
          <Sheet open={open} onClose={() => setOpen(false)} label="Filters">
            <input aria-label="Search" data-autofocus />
          </Sheet>
        </>
      );
    }
    render(<Harness />);
    const trigger = screen.getByRole("button", { name: "Open" });
    await user.click(trigger);
    expect(screen.getByRole("dialog", { name: "Filters" })).toBeInTheDocument();
    expect(screen.getByLabelText("Search")).toHaveFocus();
    await user.keyboard("{Escape}");
    await act(() => new Promise((r) => setTimeout(r, 350)));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });

  it("Dialog gives the safe action initial focus", async () => {
    render(
      <Dialog open title="Delete your account?" tone="destructive" confirmLabel="Delete account" onConfirm={() => {}} onClose={() => {}}>
        This can’t be undone after 28 days.
      </Dialog>,
    );
    await act(() => new Promise((r) => setTimeout(r, 0)));
    expect(screen.getByRole("alertdialog", { name: "Delete your account?" })).toHaveAccessibleDescription(/28 days/);
    expect(screen.getByRole("button", { name: "Cancel" })).toHaveFocus();
  });
});

describe("chat", () => {
  it("Composer only sends trimmed, non-empty text; Shift+Enter does not send", async () => {
    const user = userEvent.setup();
    const onSend = vi.fn();
    function Harness() {
      const [v, setV] = useState("");
      return <Composer value={v} onChange={setV} onSend={onSend} />;
    }
    render(<Harness />);
    expect(screen.getByRole("button", { name: "Send" })).toBeDisabled();
    const box = screen.getByRole("textbox", { name: "Message" });
    await user.type(box, "  hi  ");
    await user.keyboard("{Shift>}{Enter}{/Shift}");
    expect(onSend).not.toHaveBeenCalled();
    await user.keyboard("{Enter}");
    expect(onSend).toHaveBeenCalledWith("hi");
  });

  it("a failed message offers retry and delete", async () => {
    const user = userEvent.setup();
    const onRetry = vi.fn();
    render(
      <MessageBubble from="me" status="failed" onRetry={onRetry} onDelete={() => {}}>
        Saturday?
      </MessageBubble>,
    );
    expect(screen.getByRole("alert")).toHaveTextContent("Not sent.");
    await user.click(screen.getByRole("button", { name: "Retry" }));
    expect(onRetry).toHaveBeenCalled();
  });
});

describe("identity", () => {
  it("VerifiedBadge always carries a text label", () => {
    render(<VerifiedBadge compact />);
    expect(screen.getByText("Verified")).toBeInTheDocument();
  });
});

describe("discovery card", () => {
  it("ProfileCard puts identity and actions on the photo and labels the photo stand-in honestly", async () => {
    const user = userEvent.setup();
    const onLike = vi.fn();
    const { container } = render(
      <ProfileCard name="Maya" age={29} verified details={[{ icon: "user", text: "Designer" }]} actions={<ActionBar onPass={() => {}} onSuper={() => {}} onLike={onLike} />} />,
    );
    expect(screen.getByRole("article", { name: "Maya, 29" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: /Maya, 29/ })).toBeInTheDocument();
    expect(screen.getByText("Verified")).toBeInTheDocument();
    expect(container.querySelector(".profile-card__media .profile-card__actions")).not.toBeNull();
    expect(screen.getByRole("img", { name: "Maya has not added a photo yet" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Like" }));
    expect(onLike).toHaveBeenCalled();
  });
});

describe("illustration slots", () => {
  it("reserve a decorative area that later accepts artwork without a layout change", () => {
    const { container, rerender } = render(<IllustrationPlaceholder id="match-empty" ratio="5 / 4" width="160px" />);
    const slot = container.querySelector("[data-illustration='match-empty']");
    expect(slot).toHaveAttribute("aria-hidden", "true");
    expect(slot.style.aspectRatio).toBe("5 / 4");
    rerender(<IllustrationPlaceholder id="match-empty" ratio="5 / 4" width="160px" src="/art/match-empty.svg" />);
    const img = container.querySelector("img[data-illustration='match-empty']");
    expect(img).toHaveAttribute("alt", "");
    expect(img.style.aspectRatio).toBe("5 / 4");
  });

  it("EmptyState swaps its glyph for a drawn scene, or supplied artwork", () => {
    const { container, rerender } = render(<EmptyState art="no-chats" title="Connections start here" />);
    expect(container.querySelector("svg.ill[data-scene='no-chats']")).not.toBeNull();
    expect(container.querySelector(".empty-state__icon")).toBeNull();
    rerender(<EmptyState art="no-chats" artSrc="/art/chats.svg" title="Connections start here" />);
    expect(container.querySelector("img.empty-state__art")).toHaveAttribute("alt", "");
    rerender(<EmptyState icon="filter" title="No one fits" />);
    expect(container.querySelector("svg.empty-state__icon[data-icon='filter']")).not.toBeNull();
  });

  it("every Illustration scene renders as one decorative svg sized to its canvas", async () => {
    const { Illustration, ILLUSTRATION_SCENES } = await import("../../src/design-system/index.js");
    for (const scene of ILLUSTRATION_SCENES) {
      const { container, unmount } = render(<Illustration scene={scene} />);
      const svg = container.querySelector("svg.ill");
      expect(svg).toHaveAttribute("aria-hidden", "true");
      const [, , w, h] = svg.getAttribute("viewBox").split(" ").map(Number);
      expect(Number(svg.getAttribute("height"))).toBeCloseTo((Number(svg.getAttribute("width")) * h) / w);
      unmount();
    }
    expect(render(<Illustration scene="nope" />).container.firstChild).toBeNull();
  });
});

describe("expressive details", () => {
  it("headlines carry no coloured-word emphasis component any more", async () => {
    const ds = await import("../../src/design-system/index.js");
    expect(ds.Emphasis).toBeUndefined();
  });

  it("the design system no longer exports a decorative ribbon", async () => {
    const ds = await import("../../src/design-system/index.js");
    expect(ds.Ribbon).toBeUndefined();
  });
});

describe("icons and navigation", () => {
  it("Icon renders Material Symbols Rounded, filled by default, outline only on request", () => {
    const { container } = render(
      <>
        <Icon name="heart" />
        <Icon name="check" stroke={2.4} />
        <Icon name="message" weight="outline" />
        <Icon name="plus" />
        <Icon name="doesNotExist" />
      </>,
    );
    const svgs = [...container.querySelectorAll("svg")];
    expect(svgs).toHaveLength(4);
    svgs.forEach((s) => expect(s).toHaveAttribute("aria-hidden", "true"));
    svgs.forEach((s) => expect(s.getAttribute("viewBox")).toBe("0 -960 960 960"));
    expect(svgs.map((s) => `${s.dataset.icon}:${s.dataset.fill}`)).toEqual(["heart:1", "check:1", "message:0", "plus:1"]);
    // The outline drawing differs from the filled one.
    const { container: c2 } = render(<Icon name="message" />);
    expect(c2.querySelector("path").getAttribute("d")).not.toBe(svgs[2].querySelector("path").getAttribute("d"));
  });

  it("one icon family: no Solar, Phosphor, Lucide or other icon package is installed or imported", async () => {
    const { readFileSync, readdirSync } = await import("node:fs");
    const pkg = JSON.parse(readFileSync("package.json", "utf8"));
    const deps = Object.keys({ ...pkg.dependencies, ...pkg.devDependencies });
    expect(deps.filter((d) => /solar|phosphor|lucide|heroicons|tabler|feather|fontawesome/i.test(d))).toEqual([]);
    expect(pkg.devDependencies["@material-symbols/svg-500"]).toMatch(/^\d+\.\d+\.\d+$/);
    const src = readdirSync("src", { recursive: true }).filter((f) => /\.(jsx?|css)$/.test(f));
    for (const f of src) expect(readFileSync(`src/${f}`, "utf8"), f).not.toMatch(/@solar-icons|@phosphor-icons|lucide-react/);
  });

  it("TabBar marks the current tab, reports changes and labels badges", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(
      <TabBar
        current="discover"
        onChange={onChange}
        items={[
          { id: "discover", label: "Discover", icon: "cards" },
          { id: "chats", label: "Chats", icon: "message", badge: 3 },
        ]}
      />,
    );
    expect(screen.getByRole("button", { name: /Discover/ })).toHaveAttribute("aria-current", "page");
    expect(screen.getByLabelText("3 new in Chats")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: /Chats/ }));
    expect(onChange).toHaveBeenCalledWith("chats");
  });
});

describe("brand and illustration slots", () => {
  it("Wordmark renders the built-in mark until the supplied logo is set, then the asset unrecoloured", () => {
    expect(LOGO_SRC).toBeNull(); // the supplied logo has not been added yet (see the UI map)
    const { container, rerender } = render(<Wordmark />);
    expect(container.querySelector("svg")).not.toBeNull();
    rerender(<Wordmark src="/brand/numaya-logo.svg" size="sm" />);
    const img = screen.getByRole("img", { name: "Numaya" });
    expect(img).toHaveAttribute("src", "/brand/numaya-logo.svg");
    expect(img.style.height).toBe("22px");
    expect(img.style.width).toBe("auto");
  });

  it("the reserved hero slot draws nothing and stays decorative", () => {
    const { container } = render(<IllustrationPlaceholder id="welcome-hero" reserved />);
    const el = container.querySelector("[data-illustration='welcome-hero']");
    expect(el).toHaveClass("illustration--reserved");
    expect(el).toHaveAttribute("aria-hidden", "true");
  });

  it("the verified mark is one Material seal glyph, not a check on a disc", async () => {
    const { VerifiedBadge, Avatar } = await import("../../src/design-system/index.js");
    const { container } = render(<><VerifiedBadge /><Avatar name="Maya" verified /></>);
    expect(container.querySelectorAll("svg[data-icon='verified']")).toHaveLength(2);
    expect(container.querySelector("[data-icon='check']")).toBeNull();
  });
});


describe("core screen components", () => {
  it("ResultPanel draws one illustration scene and never stacks a badge on a shape", async () => {
    const { ResultPanel, ILLUSTRATION_SCENES } = await import("../../src/design-system/index.js");
    expect(ILLUSTRATION_SCENES).toEqual(expect.arrayContaining(["verified", "unmatched", "blocked"]));
    const { container } = render(<ResultPanel art="verified" title="You’re verified" />);
    const art = container.querySelectorAll("svg.result__art");
    expect(art).toHaveLength(1);
    expect(art[0]).toHaveAttribute("data-scene", "verified");
    expect(art[0]).toHaveAttribute("aria-hidden", "true");
    expect(container.querySelector(".result__badge, .result__shape, [data-icon]")).toBeNull();
  });

  it("neutral outcomes carry no success check or brand fill", async () => {
    const { ResultPanel } = await import("../../src/design-system/index.js");
    for (const art of ["unmatched", "blocked", undefined]) {
      const { container, unmount } = render(<ResultPanel tone="neutral" art={art} title="Done" />);
      expect(container.querySelector("[data-icon='check'], [data-icon='verified'], .ill__brand")).toBeNull();
      unmount();
    }
  });

  it("SetupProgress renders one horizontal card per step with Step N of M and a written status", async () => {
    const { SetupProgress } = await import("../../src/design-system/index.js");
    const { container } = render(
      <SetupProgress
        title="Your profile"
        steps={[
          { label: "The basics", icon: "user", status: "done" },
          { label: "Interests", icon: "interests", status: "active" },
          { label: "Photos", icon: "camera", status: "upcoming" },
        ]}
      />,
    );
    const steps = container.querySelectorAll("li.setup-step");
    expect(steps).toHaveLength(3);
    expect([...steps].map((s) => s.querySelector(".setup-step__eyebrow").textContent)).toEqual(["Step 1 of 3", "Step 2 of 3", "Step 3 of 3"]);
    expect(steps[0]).toHaveTextContent("Done");
    expect(steps[1]).toHaveAttribute("aria-current", "step");
    expect(steps[1]).toHaveTextContent("Up next");
    expect(steps[2]).toHaveTextContent("Not started");
    expect([...steps].every((s) => s.querySelectorAll(".setup-step__icon").length === 1)).toBe(true);
    expect(screen.getByText("1 of 3 done")).toBeInTheDocument();
  });

  it("SharedInterests is a ProfileSection with text-only pills and no heart", async () => {
    const { SharedInterests } = await import("../../src/design-system/index.js");
    const { container } = render(<SharedInterests items={[{ label: "Jazz" }, { label: "A very long shared interest label" }]} />);
    const card = container.querySelector("section");
    expect(card).toHaveClass("profile-section", "shared-interests");
    expect(card.querySelector("svg")).toBeNull();
    expect(screen.getByRole("heading", { name: "You both like" })).toBeInTheDocument();
  });

  it("InfoCard puts the icon beside the heading and the body below", async () => {
    const { InfoCard } = await import("../../src/design-system/index.js");
    const { container } = render(<InfoCard icon="lock" title="Private">Body copy</InfoCard>);
    const head = container.querySelector(".info-card__head");
    expect(head.querySelector("svg[data-icon='lock']")).not.toBeNull();
    expect(head).toHaveTextContent("Private");
    expect(head.nextElementSibling).toHaveClass("info-card__body");
  });

  it("Composer keeps Enter-to-send, Shift+Enter newline and a disabled state", async () => {
    const { Composer } = await import("../../src/design-system/index.js");
    const onSend = vi.fn();
    function Harness({ disabled }) {
      const [v, setV] = useState("");
      return <Composer value={v} onChange={setV} onSend={onSend} disabled={disabled} />;
    }
    const { container, rerender } = render(<Harness />);
    const box = screen.getByRole("textbox", { name: "Message" });
    await userEvent.type(box, "Hi{Shift>}{Enter}{/Shift}there");
    expect(box.value).toBe("Hi\nthere");
    await userEvent.type(box, "{Enter}");
    expect(onSend).toHaveBeenCalledWith("Hi\nthere");
    rerender(<Harness disabled />);
    expect(container.querySelector(".composer")).toHaveClass("is-disabled");
    expect(screen.getByRole("button", { name: "Send" })).toBeDisabled();
  });
});

describe("match screen and illustration slots", () => {
  it("OrganicPortrait uses the real photo when there is one, else the avatar fallback", async () => {
    const { OrganicPortrait } = await import("../../src/design-system/index.js");
    const { container, rerender } = render(<OrganicPortrait name="Maya" src="/photos/maya.jpg" />);
    expect(screen.getByRole("img", { name: "Photo of Maya" })).toBeInTheDocument();
    expect(container.querySelector("img")).toHaveAttribute("src", "/photos/maya.jpg");
    rerender(<OrganicPortrait name="Maya" />);
    expect(container.querySelector("img")).toBeNull();
    expect(screen.getByRole("img", { name: "Maya has not added a photo yet" })).toHaveTextContent("M");
  });

  it("IllustrationSlot keeps its ratio and shows the registered fallback until the PNG exists", async () => {
    const { IllustrationSlot, ILLUSTRATIONS, illustrationSrc } = await import("../../src/design-system/index.js");
    expect(illustrationSrc("match-hands-heart")).toBeNull();
    const { container } = render(<IllustrationSlot id="match-hands-heart" />);
    const slot = container.querySelector("[data-illustration='match-hands-heart']");
    expect(slot).toHaveAttribute("data-asset", "numaya-match-hands-heart.png");
    expect(slot).toHaveAttribute("data-status", "fallback");
    expect(slot).toHaveAttribute("aria-hidden", "true");
    expect(slot.style.aspectRatio).toBe(ILLUSTRATIONS["match-hands-heart"].ratio);
    expect(slot.querySelector("img")).toBeNull();
    expect(render(<IllustrationSlot id="does-not-exist" />).container.firstChild).toBeNull();
  });

  it("every registered asset has one canonical numaya-*.png name", async () => {
    const { ILLUSTRATIONS } = await import("../../src/design-system/index.js");
    const files = Object.values(ILLUSTRATIONS).map((e) => e.file);
    expect(new Set(files).size).toBe(files.length);
    expect(files.every((f) => /^numaya-[a-z0-9]+(-[a-z0-9]+)*\.png$/.test(f))).toBe(true);
  });
});
