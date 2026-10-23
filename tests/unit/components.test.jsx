import { act, fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useRef, useState } from "react";
import { describe, expect, it, vi } from "vitest";
import {
  Button,
  ChipGroup,
  Emphasis,
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

  it("EmptyState swaps its icon for a named illustration slot", () => {
    const { container } = render(<EmptyState art="chats-empty" title="Connections start here" />);
    expect(container.querySelector("[data-illustration='chats-empty']")).not.toBeNull();
    expect(container.querySelector(".empty-state__icon")).toBeNull();
  });
});

describe("expressive details", () => {
  it("Emphasis keeps its words as readable text", () => {
    const { container } = render(
      <h1>
        Fewer swipes. <Emphasis>Better</Emphasis> first dates.
      </h1>,
    );
    expect(screen.getByRole("heading")).toHaveTextContent("Fewer swipes. Better first dates.");
    expect(container.querySelector("em.emphasis")).toHaveTextContent("Better");
  });

  it("the design system no longer exports a decorative ribbon", async () => {
    const ds = await import("../../src/design-system/index.js");
    expect(ds.Ribbon).toBeUndefined();
  });
});

describe("icons and navigation", () => {
  it("Icon renders decorative Phosphor glyphs in the requested weight, and ignores unknown names", () => {
    const { container } = render(
      <>
        <Icon name="heart" weight="fill" />
        <Icon name="check" stroke={2.4} />
        <Icon name="message" />
        <Icon name="lock" weight="duotone" />
        <Icon name="verified" />
        <Icon name="doesNotExist" />
      </>,
    );
    const svgs = [...container.querySelectorAll("svg")];
    expect(svgs).toHaveLength(5);
    svgs.forEach((s) => expect(s).toHaveAttribute("aria-hidden", "true"));
    svgs.forEach((s) => expect(s.getAttribute("class")).toMatch(/\bicon\b/));
    expect(svgs.map((s) => `${s.dataset.icon}:${s.dataset.weight}`)).toEqual(["heart:fill", "check:bold", "message:regular", "lock:duotone", "verified:fill"]);
    // Phosphor draws every weight on a 256 grid; Solar (24) is gone.
    svgs.forEach((s) => expect(s.getAttribute("viewBox")).toBe("0 0 256 256"));
    // Duotone carries the lavender-ready translucent layer.
    expect(svgs[3].querySelector("[opacity]")).not.toBeNull();
  });

  it("no Solar icon package is installed or imported", async () => {
    const { readFileSync, readdirSync } = await import("node:fs");
    expect(JSON.parse(readFileSync("package.json", "utf8")).dependencies["@solar-icons/react"]).toBeUndefined();
    const src = readdirSync("src", { recursive: true }).filter((f) => /\.(jsx?|css)$/.test(f));
    for (const f of src) expect(readFileSync(`src/${f}`, "utf8"), f).not.toMatch(/@solar-icons/);
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
