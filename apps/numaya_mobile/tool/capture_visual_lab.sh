#!/usr/bin/env bash
# Captures the Visual Lab V2 gallery from a running Android emulator: real `adb screencap`
# stills and `adb shell screenrecord` clips. Usage: tool/capture_visual_lab.sh <device> <out-dir>
# Drives integration_test/visual_lab_gallery_test.dart; writes shots.tsv and clips.tsv.
set -u
# Git Bash on Windows rewrites /sdcard/... arguments into Windows paths; keep them as given.
export MSYS_NO_PATHCONV=1
DEVICE="${1:?device id}"
OUT="${2:?output dir}"
ADB="${ADB:-adb}"
APP=com.numaya.numaya_mobile
mkdir -p "$OUT/shots" "$OUT/clips"
printf 'file\tgroup\tvariant\tkind\ttextScale\tfixture\tlabel\n' > "$OUT/shots.tsv"
printf 'file\tinteraction\tmotion\n' > "$OUT/clips.tsv"
ack() { "$ADB" -s "$DEVICE" shell run-as "$APP" touch cache/ui_review_ack; }
flutter test integration_test/visual_lab_gallery_test.dart -d "$DEVICE" ${ONLY:+--dart-define=ONLY=$ONLY} 2>&1 | tee "${RAW:-/dev/null}" | while IFS= read -r line; do
  case "$line" in
    *@@CAP@@*)
      rest="${line#*@@CAP@@|}"
      IFS='|' read -r file group variant kind scale fixture label <<< "$rest"
      "$ADB" -s "$DEVICE" exec-out screencap -p > "$OUT/shots/$file"
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$file" "$group" "$variant" "$kind" "$scale" "$fixture" "$label" >> "$OUT/shots.tsv"
      ack
      ;;
    *@@REC@@*)
      rest="${line#*@@REC@@|}"
      what="${rest%%|*}"; name="${rest#*|}"
      if [ "$what" = start ]; then
        "$ADB" -s "$DEVICE" shell rm -f "/sdcard/vl_$name.mp4"
        ("$ADB" -s "$DEVICE" shell screenrecord --bit-rate 6000000 --time-limit 30 "/sdcard/vl_$name.mp4" >/dev/null 2>&1 &)
        sleep 1
      else
        "$ADB" -s "$DEVICE" shell pkill -INT screenrecord
        sleep 2
        "$ADB" -s "$DEVICE" pull "/sdcard/vl_$name.mp4" "$OUT/clips/$name.mp4" >/dev/null 2>&1
        "$ADB" -s "$DEVICE" shell rm -f "/sdcard/vl_$name.mp4"
        printf '%s.mp4\t%s\t%s\n' "$name" "${name%%__*}" "${name##*__}" >> "$OUT/clips.tsv"
      fi
      ack
      ;;
    *@@SKIP@@*|*@@MISS@@*) echo "$line" | tee -a "$OUT/skipped.txt" ;;
    *@@DONE@@*|*"All tests passed"*|*"Some tests failed"*|*EXCEPTION*) echo "$line" ;;
  esac
done
