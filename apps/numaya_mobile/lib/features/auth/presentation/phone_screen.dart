import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/phone_entry_controller.dart';
import '../domain/auth_repository.dart';
import '../domain/country.dart';
import 'auth_copy.dart';
import 'country_sheet.dart';

/// B-04 Phone number. Next stays disabled until the number is complete for the country.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, required this.intent});

  final AuthIntent intent;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  late final TextEditingController _number;
  final _focus = FocusNode();
  ToastHandle? _toast;

  @override
  void initState() {
    super.initState();
    final phone = ref.read(phoneEntryProvider).phone;
    _number = TextEditingController(
      text: phone.country.formatNational(phone.digits),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(phoneEntryProvider.notifier).setIntent(widget.intent);
      }
    });
  }

  @override
  void dispose() {
    _toast?.close();
    _number.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _syncField() {
    final phone = ref.read(phoneEntryProvider).phone;
    final text = phone.country.formatNational(phone.digits);
    _number.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _pickCountry() async {
    final current = ref.read(phoneEntryProvider).phone.country;
    final picked = await showCountrySheet(context, selected: current);
    if (picked == null || !mounted) return;
    ref.read(phoneEntryProvider.notifier).setCountry(picked);
    _syncField();
    _focus.requestFocus();
  }

  Future<void> _submit() async {
    final notifier = ref.read(phoneEntryProvider.notifier);
    if (!ref.read(phoneEntryProvider).canSubmit) return;
    _toast = NumayaToast.show(
      context,
      context.l10n.phoneSending,
      busy: true,
      duration: null,
    );
    final ok = await notifier.submit();
    _toast?.close();
    _toast = null;
    if (ok && mounted) unawaited(context.push(Routes.verify));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(phoneEntryProvider);
    final signIn = widget.intent == AuthIntent.signIn;
    final country = state.phone.country;

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        step: signIn ? null : SignUpProgress.phone,
        steps: signIn ? null : SignUpProgress.total,
      ),
      footer: Row(
        children: [
          const Spacer(),
          NumayaFab(
            semanticLabel: l10n.phoneSendCode,
            loading: state.submitting,
            onPressed: state.canSubmit ? _submit : null,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: signIn ? l10n.phoneTitleSignIn : l10n.phoneTitleSignUp,
            lede: signIn ? l10n.phoneLedeSignIn : l10n.phoneLedeSignUp,
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        l10n.phoneCountryLabel,
                        style: AppTypography.label,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    _CountryButton(
                      country: country,
                      enabled: !state.submitting,
                      label: l10n.phoneCountryButton(
                        country.name,
                        country.dialCode,
                      ),
                      onTap: _pickCountry,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NumayaTextField(
                  label: l10n.phoneNumberLabel,
                  controller: _number,
                  focusNode: _focus,
                  autofocus: true,
                  enabled: !state.submitting,
                  placeholder: country.placeholder,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [_NationalNumberFormatter(country)],
                  onChanged: (text) =>
                      ref.read(phoneEntryProvider.notifier).setDigits(text),
                  onSubmitted: (_) => _submit(),
                  semanticsIdentifier: 'phone-number',
                ),
              ),
            ],
          ),
          if (state.failure != null) ...[
            const SizedBox(height: AppSpacing.s3),
            FieldNote(
              authFailureMessage(l10n, state.failure!),
              tone: FieldNoteTone.error,
            ),
          ],
          const SizedBox(height: AppSpacing.s5),
          InfoCard(
            icon: NumayaIcons.lock,
            title: l10n.phonePrivacyTitle,
            body: l10n.phonePrivacyBody,
          ),
        ],
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({
    required this.country,
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  final Country country;
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      semanticLabel: label,
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.md),
      child: InputSurface(
        disabled: !enabled,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
        child: Row(
          children: [
            CountryCodeBadge(country.iso),
            const SizedBox(width: AppSpacing.s2),
            // Long dial codes (+971) scale down instead of overflowing the 120pt selector.
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('+${country.dialCode}', style: AppTypography.input),
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            const NumayaIcon(
              NumayaIcons.chevronDown,
              size: AppSizes.iconMd,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps digits only, caps them at the country's length and shows them in its format.
class _NationalNumberFormatter extends TextInputFormatter {
  _NationalNumberFormatter(this.country);
  final Country country;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Deleting a separator alone would change nothing: delete the digit before it instead.
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > country.digitCount) {
      digits = digits.substring(0, country.digitCount);
    }
    final text = country.formatNational(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
