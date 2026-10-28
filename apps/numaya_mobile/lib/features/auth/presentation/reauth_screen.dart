import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/session_controller.dart';
import '../application/session_expiry.dart';
import '../domain/auth_repository.dart';
import 'auth_copy.dart';
import 'verify_screen.dart';

/// "Please sign in again" (states-and-recovery §3, Session expired). Pushed over whatever screen
/// was open, so confirming the number with a code pops back to it with nothing lost. Back can't
/// skip it: the only ways out are signing in again or signing out.
class ReauthScreen extends ConsumerStatefulWidget {
  const ReauthScreen({super.key});

  @override
  ConsumerState<ReauthScreen> createState() => _ReauthScreenState();
}

class _ReauthScreenState extends ConsumerState<ReauthScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  VerificationRequest? _request;
  AuthFailure? _failure;
  bool _busy = false;
  bool _done = false;
  Timer? _clearTimer;

  @override
  void initState() {
    super.initState();
    _code.addListener(() {
      if (_code.text.length < 6 && _failure is IncorrectCode) {
        setState(() => _failure = null);
      }
    });
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    _code.clear();
    try {
      final request = await ref
          .read(authRepositoryProvider)
          .requestCode(session.phone, AuthIntent.signIn);
      if (!mounted) return;
      setState(() => _request = request);
      _focus.requestFocus();
    } on AuthFailure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(String code) async {
    final request = _request;
    if (request == null || code.length != 6 || _busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyCode(request, code);
      if (!mounted) return;
      setState(() => _done = true);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      final l10n = context.l10n;
      ref.read(sessionExpiryProvider.notifier).clear();
      context.pop();
      NumayaToast.show(context, l10n.reauthDone, aboveFooter: false);
    } on AuthFailure catch (f) {
      if (!mounted) return;
      setState(() {
        _failure = f;
        if (f is CodeExpired) _request = null;
      });
      if (f is IncorrectCode) {
        _clearTimer = Timer(const Duration(milliseconds: 650), () {
          if (mounted) _code.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    ref.read(sessionExpiryProvider.notifier).clear();
    await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = ref.watch(sessionProvider)?.phone.display ?? '';
    final demo = ref.watch(demoAuthProvider);
    final request = _request;
    final codeState = _done
        ? CodeInputState.success
        : _busy && request != null
        ? CodeInputState.checking
        : _failure != null
        ? CodeInputState.error
        : CodeInputState.idle;
    return PopScope(
      canPop: false,
      child: NumayaScreen(
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (request == null)
              NumayaButton(
                label: l10n.reauthSend,
                loading: _busy,
                onPressed: _busy ? null : _send,
              ),
            const SizedBox(height: AppSpacing.s2),
            NumayaButton(
              label: l10n.reauthSignOut,
              variant: NumayaButtonVariant.quiet,
              onPressed: _busy ? null : _signOut,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.s10),
            Semantics(
              header: true,
              child: Text(l10n.reauthTitle, style: AppTypography.pageTitle),
            ),
            const SizedBox(height: AppLayout.headingGap),
            Text(
              l10n.reauthBody(phone),
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            if (request != null) ...[
              const SizedBox(height: AppSpacing.s6),
              if (demo != null)
                DemoMessageBanner(
                  demo: demo,
                  requestId: request.id,
                  onTap: (m) => _code.value = TextEditingValue(
                    text: m.code,
                    selection: TextSelection.collapsed(offset: m.code.length),
                  ),
                ),
              CodeInput(
                controller: _code,
                focusNode: _focus,
                label: l10n.verifyCodeLabel,
                state: codeState,
                onCompleted: _verify,
                autofocus: true,
              ),
            ],
            if (_failure != null) ...[
              const SizedBox(height: AppSpacing.s3),
              FieldNote(
                authFailureMessage(l10n, _failure!),
                tone: FieldNoteTone.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
