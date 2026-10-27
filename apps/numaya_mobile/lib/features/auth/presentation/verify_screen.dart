import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../application/session_controller.dart';
import '../application/verification_controller.dart';
import '../data/demo_auth_repository.dart';
import '../domain/auth_repository.dart';
import 'auth_copy.dart';

/// B-07 Verify code: six cells, auto-check on the sixth digit, resend after 30 seconds.
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _ticker;
  Timer? _clearTimer;
  ToastHandle? _toast;

  @override
  void initState() {
    super.initState();
    _startTicker();
    _code.addListener(_onEdit);
  }

  /// Redraws the resend countdown every second; stops once resend is available.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final request = ref.read(verificationProvider).request;
      final now = ref.read(clockProvider)();
      if (request != null && !now.isBefore(request.resendAvailableAt)) {
        timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _clearTimer?.cancel();
    _toast?.close();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onEdit() {
    if (_code.text.length < 6) {
      ref.read(verificationProvider.notifier).editing();
    }
    setState(() {});
  }

  Future<void> _verify(String code) async {
    if (code.length != 6) return;
    _toast = NumayaToast.show(
      context,
      context.l10n.verifyChecking,
      busy: true,
      duration: null,
    );
    final session = await ref.read(verificationProvider.notifier).verify(code);
    _toast?.close();
    _toast = null;
    if (!mounted) return;
    final status = ref.read(verificationProvider).status;
    if (status == VerificationStatus.incorrect) {
      // Keep the wrong code visible briefly, then clear it for the next try (as the web does).
      _clearTimer = Timer(const Duration(milliseconds: 650), () {
        if (mounted) _code.clear();
      });
    }
    if (session != null) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (mounted) await _handOver(session);
    }
  }

  Future<void> _handOver(AuthSession session) async {
    final l10n = context.l10n;
    if (session.restorableUntil != null) {
      context.go(Routes.restore);
      return;
    }
    if (session.hasProfile) {
      await ref.read(onboardingProvider.notifier).restore();
      if (!mounted) return;
      context.go(Routes.home);
      NumayaToast.show(context, l10n.signedIn, aboveFooter: false);
      return;
    }
    final request = ref.read(verificationProvider).request;
    if (request?.intent == AuthIntent.signIn) {
      final create = await showNumayaSheet<bool>(
        context: context,
        title: l10n.noAccountTitle,
        closeLabel: l10n.close,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.noAccountBody,
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.s6),
            NumayaButton(
              label: l10n.noAccountCreate,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 6),
            NumayaButton(
              label: l10n.noAccountOtherNumber,
              variant: NumayaButtonVariant.quiet,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (create != true) {
        context.pop();
        ref.read(sessionProvider.notifier).discardUnfinished();
        return;
      }
    }
    context.go(Routes.setup);
  }

  Future<void> _resend() async {
    final l10n = context.l10n;
    _code.clear();
    final sent = await ref.read(verificationProvider.notifier).resend();
    if (sent && mounted) {
      _startTicker();
      NumayaToast.show(context, l10n.verifyResent);
    }
  }

  void _fillFromDemo(DemoMessage message) {
    _code.value = TextEditingValue(
      text: message.code,
      selection: TextSelection.collapsed(offset: message.code.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(verificationProvider);
    final request = state.request;
    if (request == null) return const SizedBox.shrink();
    final demo = ref.watch(demoAuthProvider);
    final now = ref.watch(clockProvider)();
    final wait = request.resendAvailableAt.difference(now);
    final seconds = wait.isNegative ? 0 : (wait.inMilliseconds / 1000).ceil();
    final signUp = request.intent == AuthIntent.signUp;
    final number = request.phone.display;
    final lede = l10n.verifyLede(number);
    final split = lede.indexOf(number);

    final codeState = switch (state.status) {
      VerificationStatus.checking => CodeInputState.checking,
      VerificationStatus.incorrect ||
      VerificationStatus.expired => CodeInputState.error,
      VerificationStatus.success => CodeInputState.success,
      VerificationStatus.entering => CodeInputState.idle,
    };
    final (String? note, FieldNoteTone tone) = switch (state.status) {
      VerificationStatus.incorrect => (
        l10n.verifyIncorrect,
        FieldNoteTone.error,
      ),
      VerificationStatus.expired => (l10n.verifyExpired, FieldNoteTone.error),
      VerificationStatus.success => (l10n.verifySuccess, FieldNoteTone.success),
      _ when state.failure != null => (
        authFailureMessage(l10n, state.failure!),
        FieldNoteTone.error,
      ),
      _ => (null, FieldNoteTone.neutral),
    };
    final locked =
        state.status == VerificationStatus.checking ||
        state.status == VerificationStatus.success;

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: locked ? null : () => context.pop(),
        backLabel: l10n.back,
        step: signUp ? SignUpProgress.verify : null,
        steps: signUp ? SignUpProgress.total : null,
      ),
      footer: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  l10n.verifyDidntGet,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (seconds > 0)
                  Semantics(
                    liveRegion: false,
                    child: Text(
                      l10n.verifyResendIn(
                        '0:${seconds.toString().padLeft(2, '0')}',
                      ),
                      style: AppTypography.weight(
                        AppTypography.bodySm,
                        AppTypography.semibold,
                      ),
                    ),
                  )
                else
                  TextLink(
                    label: l10n.verifyResend,
                    style: AppTypography.bodySm,
                    onPressed: locked || state.resending ? null : _resend,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          NumayaFab(
            semanticLabel: l10n.verifySubmit,
            loading: state.status == VerificationStatus.checking,
            onPressed:
                _code.text.length == 6 &&
                    state.status == VerificationStatus.entering
                ? () => _verify(_code.text)
                : null,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (demo != null)
            _DemoMessageBanner(
              demo: demo,
              requestId: request.id,
              onTap: locked ? null : _fillFromDemo,
            ),
          ScreenHeader(
            title: l10n.verifyTitle,
            ledeWidget: Text.rich(
              TextSpan(
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
                children: split < 0
                    ? [TextSpan(text: lede)]
                    : [
                        TextSpan(text: lede.substring(0, split)),
                        TextSpan(
                          text: number,
                          style: AppTypography.weight(
                            AppTypography.body,
                            AppTypography.semibold,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                        TextSpan(text: lede.substring(split + number.length)),
                      ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: l10n.verifyChangeNumber,
              onPressed: locked ? null : () => context.pop(),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          FieldLabel(l10n.verifyCodeLabel),
          const SizedBox(height: AppSpacing.s2),
          CodeInput(
            controller: _code,
            focusNode: _focus,
            label: l10n.verifyCodeLabel,
            state: codeState,
            onCompleted: _verify,
          ),
          if (note != null) ...[
            const SizedBox(height: AppSpacing.s3),
            FieldNote(note, tone: tone),
          ],
        ],
      ),
    );
  }
}

/// Development builds only: shows the code the demo service "texted", like an SMS notification.
/// Tapping it fills the code, as SMS autofill would.
class _DemoMessageBanner extends StatelessWidget {
  const _DemoMessageBanner({
    required this.demo,
    required this.requestId,
    required this.onTap,
  });

  final DemoAuthRepository demo;
  final String requestId;
  final ValueChanged<DemoMessage>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<DemoMessage>(
      stream: demo.inbox,
      initialData: demo.latestMessage,
      builder: (context, snapshot) {
        final message = snapshot.data;
        if (message == null || message.requestId != requestId) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s2),
          child: Pressable(
            onTap: onTap == null ? null : () => onTap!(message),
            semanticLabel:
                '${l10n.demoMessageTitle}. ${l10n.demoMessageBody(message.code)}',
            excludeChildSemantics: true,
            pressedScale: 0.99,
            borderRadius: AppRadii.all(AppRadii.card),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.all(AppRadii.card),
                boxShadow: AppElevation.lg,
              ),
              child: Row(
                children: [
                  const BrandMark(size: 28),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.demoMessageTitle,
                          style: AppTypography.weight(
                            AppTypography.caption,
                            AppTypography.semibold,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          l10n.demoMessageBody(message.code),
                          style: AppTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
