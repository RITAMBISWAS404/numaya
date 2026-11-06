# V4: checks that need a real device

Nothing here was run on a phone. Every V4 result comes from the Linux Flutter widget harness.

## Android (emulator or phone)
1. **Keyboard.** On the forms (setup name and bio, phone, The basics, Contact support, New event, chat), check:
   - the field stays visible while the keyboard animates;
   - the IME action submits;
   - the inline footer at max font size is reachable.
2. **Back and predictive back** (Android 14+) on Filters, the chat menu, Unmatch and Block, and the match screen. Back should close the top sheet only.
3. **TalkBack** on Profile (Current and EXP-002 A/B/C), the match screen (all four), Messages empty (EXP-003) and Settings at max font. Check reading order, roles, and that each row's value is read with its label.
4. **Missing photo (V4-01).** Choose a photo, delete it from storage, reopen Profile and the chat attachment viewer.
5. **Max system font on a 320pt-class phone (V4-02).** Settings, Notifications, Edit profile and The basics: words must stay whole.
6. **Performance.** Run profile mode with DevTools on: Discover swipe, chat scroll with a long thread, and sheet open/close. No performance claim is made from the harness.
7. **Remove animations (reduced motion).** Match screen and sheets.
8. **Experiment Lab.** "Copy my choices" (clipboard).

## Also outstanding
- Real photos instead of placeholders, especially for EXP-001 A/B and EXP-002 A.
- Regenerating the `screenshots` goldens on the target platform.
- iOS / VoiceOver: there is no iOS target in this environment.
