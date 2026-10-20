import { useCallback, useEffect, useState } from "react";
import { DeviceProvider } from "./components/DeviceContext.jsx";
import { DeviceViewport, Simulator } from "./components/Device.jsx";
import { Brief } from "./components/Brief.jsx";
import { DEFAULT_COUNTRY, digitCount } from "./data/countries.js";
import { DEVICE_QUERY, useMediaQuery } from "./hooks/useMediaQuery.js";
import { PhoneNumber } from "./screens/PhoneNumber.jsx";
import { VerifyCode } from "./screens/VerifyCode.jsx";
import { Welcome } from "./screens/Welcome.jsx";

export const STEPS = [
  { id: "welcome", title: "Welcome", summary: "Join or sign in" },
  { id: "phone", title: "Phone number", summary: "Country, number, reassurance" },
  { id: "verify", title: "Verification", summary: "Six-digit code with autofill" },
];
const ORDER = STEPS.map((s) => s.id);
const SAMPLE_NUMBER = "4155550132";
const TRANSITION_MS = 520;

const newCode = () => String(Math.floor(100000 + Math.random() * 900000));

function useNavigator(initial) {
  const [nav, setNav] = useState({ current: initial, leaving: null, direction: "forward", id: 0 });

  const navigate = useCallback((to) => {
    setNav((n) =>
      n.current === to
        ? n
        : {
            current: to,
            leaving: n.current,
            direction: ORDER.indexOf(to) > ORDER.indexOf(n.current) ? "forward" : "back",
            id: n.id + 1,
          },
    );
  }, []);

  useEffect(() => {
    if (!nav.leaving) return;
    const id = setTimeout(
      () => setNav((n) => (n.id === nav.id ? { ...n, leaving: null } : n)),
      TRANSITION_MS,
    );
    return () => clearTimeout(id);
  }, [nav.leaving, nav.id]);

  return [nav, navigate];
}

export function App() {
  const isDevice = useMediaQuery(DEVICE_QUERY);
  const [nav, navigate] = useNavigator("welcome");

  const [intent, setIntent] = useState("signup");
  const [country, setCountry] = useState(DEFAULT_COUNTRY);
  const [digits, setDigits] = useState("");
  const [code, setCode] = useState(null);
  const [verified, setVerified] = useState(false);

  const start = (nextIntent) => {
    setIntent(nextIntent);
    navigate("phone");
  };

  const sendCode = () => {
    setCode(newCode());
    setVerified(false);
    navigate("verify");
  };

  const restart = () => {
    setDigits("");
    setCode(null);
    setVerified(false);
    setIntent("signup");
    navigate("welcome");
  };

  // The brief lets reviewers jump straight to any step with sensible data.
  const jumpTo = (id) => {
    if (id === "welcome") return restart();
    setVerified(false);
    if (id === "verify") {
      if (digits.length !== digitCount(country)) {
        setCountry(DEFAULT_COUNTRY);
        setDigits(SAMPLE_NUMBER);
      }
      setCode(newCode());
    }
    navigate(id);
  };

  const renderScreen = (id, active) => {
    switch (id) {
      case "welcome":
        return (
          <Welcome active={active} onCreate={() => start("signup")} onSignIn={() => start("signin")} />
        );
      case "phone":
        return (
          <PhoneNumber
            active={active}
            intent={intent}
            country={country}
            digits={digits}
            onCountryChange={setCountry}
            onDigitsChange={setDigits}
            onBack={() => navigate("welcome")}
            onSubmit={sendCode}
          />
        );
      case "verify":
        return (
          <VerifyCode
            active={active}
            intent={intent}
            country={country}
            digits={digits}
            code={code}
            onBack={() => navigate("phone")}
            onChangeNumber={() => navigate("phone")}
            onResend={() => setCode(newCode())}
            onVerified={() => setVerified(true)}
            onRestart={restart}
          />
        );
      default:
        return null;
    }
  };

  const layers = nav.leaving ? [nav.leaving, nav.current] : [nav.current];
  const flow = (
    <DeviceViewport>
      {layers.map((id) => {
        const isCurrent = id === nav.current;
        const role = nav.leaving ? (isCurrent ? "enter" : "leave") : "idle";
        return (
          <div
            key={id}
            className="layer"
            data-role={role}
            data-direction={nav.direction}
            inert={!isCurrent}
          >
            {renderScreen(id, isCurrent)}
          </div>
        );
      })}
    </DeviceViewport>
  );

  return (
    <DeviceProvider isDevice={isDevice}>
      {isDevice ? (
        flow
      ) : (
        <main className="presentation">
          <Brief steps={STEPS} current={nav.current} verified={verified} onJump={jumpTo} onRestart={restart} />
          <Simulator>{flow}</Simulator>
        </main>
      )}
    </DeviceProvider>
  );
}
