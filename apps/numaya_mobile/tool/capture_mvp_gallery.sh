#!/usr/bin/env bash
# Captures the MVP PRD screen gallery from a running Android emulator (real device screenshots).
# Usage: tool/capture_mvp_gallery.sh <device-id> <output-dir>
# Runs integration_test/mvp_gallery_test.dart; on each @@CAP@@ marker takes `adb screencap` and
# acknowledges through the app's cache so the test moves on. Writes index.tsv beside the images.
set -u
DEVICE="${1:?device id}"
OUT="${2:?output dir}"
ADB="${ADB:-adb}"
APP=com.numaya.numaya_mobile
mkdir -p "$OUT"
printf 'file\tS-ID\tstate\n' > "$OUT/index.tsv"
flutter test integration_test/mvp_gallery_test.dart -d "$DEVICE" 2>&1 | tee "${RAW:-/dev/null}" | while IFS= read -r line; do
  case "$line" in
    *@@CAP@@*)
      rest="${line#*@@CAP@@|}"
      file="${rest%%|*}"; rest="${rest#*|}"
      sid="${rest%%|*}"; state="${rest#*|}"
      "$ADB" -s "$DEVICE" exec-out screencap -p > "$OUT/$file"
      printf '%s\t%s\t%s\n' "$file" "$sid" "$state" >> "$OUT/index.tsv"
      "$ADB" -s "$DEVICE" shell run-as "$APP" touch cache/ui_review_ack
      echo "captured $file"
      ;;
    *@@SKIP@@*|*@@MISS@@*) echo "$line" | tee -a "$OUT/skipped.txt" ;;
    *"All tests passed"*|*"Some tests failed"*|*EXCEPTION*) echo "$line" ;;
  esac
done
