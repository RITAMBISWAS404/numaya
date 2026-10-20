import { useCallback, useEffect, useState } from "react";

export function useCountdown(initialSeconds) {
  const [remaining, setRemaining] = useState(initialSeconds);

  useEffect(() => {
    if (remaining <= 0) return;
    const id = setTimeout(() => setRemaining((s) => s - 1), 1000);
    return () => clearTimeout(id);
  }, [remaining]);

  const restart = useCallback(() => setRemaining(initialSeconds), [initialSeconds]);
  return [remaining, restart];
}
