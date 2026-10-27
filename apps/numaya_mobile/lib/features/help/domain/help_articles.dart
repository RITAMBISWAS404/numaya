/// Help centre articles (F29, B-58). Written for Numaya from the research (official Bumble help
/// pages are the reference for what members need to know, not the wording). Product content, kept
/// in the domain until translation starts.
enum HelpArticleId {
  gettingStarted,
  verification,
  matchesExpiring,
  safetyTips,
  reporting,
  snooze,
  premium,
  deleting,
}

class HelpArticle {
  const HelpArticle(this.id, this.title, this.summary, this.sections);
  final HelpArticleId id;
  final String title;
  final String summary;
  final List<({String heading, String body})> sections;
}

const List<HelpArticle> kHelpArticles = [
  HelpArticle(
    HelpArticleId.gettingStarted,
    'Getting started',
    'How matching and messaging work',
    [
      (
        heading: 'How do I match with someone?',
        body:
            'Like the people you’re interested in on Home. When someone you liked likes you '
            'back, it’s a match and you can start talking.',
      ),
      (
        heading: 'Who can send the first message?',
        body:
            'Either of you. If they’ve set an Opening Move, you can answer it instead of '
            'starting from scratch.',
      ),
      (
        heading: 'What does “For you” show?',
        body:
            'A few people picked each day because you have the most in common. They refresh '
            'every 24 hours.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.verification,
    'Photo verification',
    'What the badge means and how to get it',
    [
      (
        heading: 'How do I verify my photos?',
        body:
            'Go to Profile › Verify my profile, copy the pose shown on screen and take a selfie. '
            'We compare it with your profile photos and add the badge when they match.',
      ),
      (
        heading: 'Why was my verification declined?',
        body:
            'Usually the pose didn’t match, the photo was dark or your face was covered. Try '
            'again in good light. After three tries, contact us and a person will help.',
      ),
      (
        heading: 'What does “Verified profiles only” do?',
        body:
            'It shows you only people who have verified their photos. You can turn it on in '
            'Filters.',
      ),
      (
        heading: 'In this demo',
        body: 'No camera is used and no one reviews the photo: the result is simulated.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.matchesExpiring,
    'Matches that expire',
    'The 24-hour window, Extend and Rematch',
    [
      (
        heading: 'Why do matches expire?',
        body:
            'A new match lasts 24 hours unless one of you sends a message. The ring around '
            'their photo shows the time left.',
      ),
      (
        heading: 'Can I get more time?',
        body:
            'Yes. Extend adds 24 hours: one free Extend a day, as many as you like with '
            'Premium. Expired matches can be brought back with Rematch, a Premium feature.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.safetyTips,
    'Safety tips for meeting',
    'Before and during a first date',
    [
      (
        heading: 'Before you meet',
        body:
            'Keep the conversation in the app until you feel comfortable. Never send money or '
            'share financial details.',
      ),
      (
        heading: 'On the day',
        body:
            'Meet in a public place, tell a friend where you’ll be and arrange your own way '
            'home.',
      ),
      (
        heading: 'If something feels wrong',
        body:
            'You can leave at any time. Block and report anyone who makes you feel unsafe; '
            'they won’t be told.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.reporting,
    'Reporting and blocking',
    'What happens when you report someone',
    [
      (
        heading: 'Will they know?',
        body: 'No. Reports are anonymous and blocking doesn’t notify anyone.',
      ),
      (
        heading: 'What happens next?',
        body: 'Our team reviews every report. You’ll find updates in the Help centre.',
      ),
      (
        heading: 'In this demo',
        body: 'Reports are saved on this device only. Nothing is sent or reviewed.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.snooze,
    'Taking a break with Snooze',
    'Hide your profile without losing anyone',
    [
      (
        heading: 'What does Snooze do?',
        body:
            'Your profile is hidden from new people for 24 hours, 72 hours, a week or until you '
            'turn it off. Your matches and conversations stay.',
      ),
      (
        heading: 'What about my matches?',
        body:
            'You can set an away status so they know why you’re quiet. New matches can still '
            'expire while you’re away.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.premium,
    'Premium and billing',
    'What’s included, cancelling and refunds',
    [
      (
        heading: 'What do I get?',
        body:
            'Advanced filters, Rematch, unlimited Extends, Incognito, Travel and extra '
            'SuperSwipes.',
      ),
      (
        heading: 'How do I cancel?',
        body:
            'Subscriptions are managed by your app store. Deleting your account doesn’t cancel '
            'one.',
      ),
      (
        heading: 'In this demo',
        body:
            'No store is connected. Plans and prices are illustrative and no payment is ever '
            'taken.',
      ),
    ],
  ),
  HelpArticle(
    HelpArticleId.deleting,
    'Deleting your account',
    'What’s removed and how to change your mind',
    [
      (
        heading: 'What happens when I delete?',
        body: 'Your profile, matches and messages are removed and nobody can see you.',
      ),
      (
        heading: 'Can I come back?',
        body:
            'For 28 days, signing in with the same number lets you restore everything. After '
            'that, the account is gone for good.',
      ),
      (
        heading: 'Subscriptions',
        body: 'Cancel any subscription in your app store first.',
      ),
    ],
  ),
];

HelpArticle helpArticle(HelpArticleId id) =>
    kHelpArticles.firstWhere((a) => a.id == id);
