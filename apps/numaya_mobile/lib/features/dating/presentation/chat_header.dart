import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/sample_people.dart';
import 'person_profile.dart';

/// The shared-element tag joining a conversation row's avatar to the open conversation's header.
String chatAvatarHeroTag(String personId) => 'chat-avatar-$personId';

/// A conversation's header (WhatsApp-style): back, avatar and name that open the profile, and the
/// conversation menu. Shared by the chat and a Compliment that has not been answered yet, so the
/// two read as one place.
class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.person,
    required this.onBack,
    required this.onMenu,
  });

  final SamplePerson person;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: AppSizes.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.barPadding,
          vertical: AppSpacing.s1,
        ),
        child: Row(
          children: [
            NavIconButton(
              icon: NumayaIcons.chevronLeft,
              label: l10n.backToMessages,
              style: NavButtonStyle.plain,
              onPressed: onBack,
            ),
            const SizedBox(width: AppSpacing.s2),
            Expanded(
              child: Pressable(
                onTap: () => context.push('${Routes.person}/${person.id}'),
                semanticLabel: l10n.viewProfile(person.name),
                excludeChildSemantics: true,
                pressedScale: 1,
                child: Row(
                  children: [
                    Hero(
                      tag: chatAvatarHeroTag(person.id),
                      child: InitialsAvatar(
                        initial: person.initial,
                        size: 40,
                        image: personAvatarImage(person),
                        imageAlignment: personAvatarFocus(person),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    // One line, as the app bar holds it at any text size.
                    Flexible(
                      child: NameWithBadge(
                        name: person.name,
                        verified: person.verified,
                        verifiedLabel: l10n.photoVerifiedLabel,
                        style: AppTypography.appBarTitle,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NavIconButton(
              icon: NumayaIcons.more,
              label: l10n.conversationOptions,
              onPressed: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}
