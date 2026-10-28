import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/account_prefs.dart';

/// Recovery email (B-09, U-11): add, change or remove the address support would use if the
/// number is lost. Checked on Save, not while typing.
Future<void> showRecoveryEmailSheet(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final current = ref.read(accountPrefsProvider).recoveryEmail;
  final result = await showNumayaSheet<_EmailResult>(
    context: context,
    title: l10n.recoveryEmailLabel,
    closeLabel: l10n.cancel,
    builder: (context) => _EmailForm(initial: current ?? ''),
  );
  if (result == null || !context.mounted) return;
  ref.read(accountPrefsProvider.notifier).setRecoveryEmail(result.email);
  NumayaToast.show(
    context,
    result.email == null ? l10n.recoveryEmailRemoved : l10n.recoveryEmailSaved,
  );
}

class _EmailResult {
  const _EmailResult(this.email);
  final String? email;
}

class _EmailForm extends StatefulWidget {
  const _EmailForm({required this.initial});

  final String initial;

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  late final _text = TextEditingController(text: widget.initial)
    ..addListener(_edited);
  String? _error;

  void _edited() => setState(() => _error = null);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final value = _text.text.trim();
    if (!isValidEmail(value)) {
      setState(() => _error = context.l10n.recoveryEmailInvalid);
      return;
    }
    Navigator.of(context).pop(_EmailResult(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = _text.text.trim();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recoveryEmailBody,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppLayout.fieldGap),
          NumayaTextField(
            label: l10n.recoveryEmailLabel,
            controller: _text,
            autofocus: true,
            error: _error,
            placeholder: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            l10n.recoveryEmailDemo,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s5),
          NumayaButton(
            label: l10n.save,
            onPressed: value.isEmpty || value == widget.initial ? null : _save,
          ),
          if (widget.initial.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s3),
            NumayaButton(
              label: l10n.recoveryEmailRemove,
              variant: NumayaButtonVariant.secondary,
              onPressed: () =>
                  Navigator.of(context).pop(const _EmailResult(null)),
            ),
          ],
        ],
      ),
    );
  }
}
