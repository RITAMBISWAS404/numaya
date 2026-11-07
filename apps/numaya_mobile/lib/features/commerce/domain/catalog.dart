import 'package:flutter/foundation.dart';

/// The commercial catalog and allowance policy (PRD 01 and 06). In a live build it is served by the
/// backend ("configurable server catalog, never hard-code economic policy in widgets"); the demo
/// ships [kProvisionalCatalog]. Widgets read numbers only from here.
///
/// Prices are the PRD's provisional India hypotheses. They are NOT researched competitor prices or
/// approved store products, and no store product exists for them: [Catalog.billingLive] is false in
/// every build of this app, and the UI says so wherever a price is shown.
enum ProductKind {
  premiumWeekly,
  premiumMonthly,
  premiumYearly,
  complimentPack,
  streakRecovery,
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.kind,
    required this.pricePaise,
    this.billingDays,
    this.credits = 0,
  });

  /// The store product id the live catalog would carry (placeholder until store setup).
  final String id;
  final ProductKind kind;

  /// Price in paise (INR 1 = 100 paise), tax-inclusive as the store would display it.
  final int pricePaise;

  /// For subscriptions: the billing term in days (renews automatically at the same price).
  final int? billingDays;

  /// For the Compliment pack: credits granted on a verified purchase.
  final int credits;

  bool get isSubscription => billingDays != null;
}

@immutable
class AllowancePolicy {
  const AllowancePolicy({
    this.freeLikesPerDay = 5,
    this.premiumLikesPerDay = 15,
    this.freeExtensionsPerWeek = 1,
    this.premiumExtensionsPerDay = 1,
    this.extensionHours = 24,
    this.matchWindowHours = 24,
    this.archiveAfterDays = 7,
    this.welcomeCredits = 3,
    this.earnedCap = 5,
    this.premiumWeeklyCredits = 3,
    this.complimentMaxLength = 150,
    this.streakCycleDays = 7,
    this.streakRewardCredits = 1,
    this.streakDecisionsPerDay = 3,
    this.recoveryWindowHours = 48,
    this.insightsSampleThreshold = 20,
  });

  final int freeLikesPerDay;
  final int premiumLikesPerDay;
  final int freeExtensionsPerWeek;
  final int premiumExtensionsPerDay;
  final int extensionHours;
  final int matchWindowHours;

  /// Days without a genuine accepted message before a started conversation moves to Archive.
  final int archiveAfterDays;
  final int welcomeCredits;

  /// Cap on the earned bank (welcome + streak rewards). Weekly and purchased credits are separate.
  final int earnedCap;
  final int premiumWeeklyCredits;
  final int complimentMaxLength;
  final int streakCycleDays;
  final int streakRewardCredits;

  /// Distinct profile decisions (like or pass) that make a streak day.
  final int streakDecisionsPerDay;
  final int recoveryWindowHours;

  /// Distinct qualified exposures below which a rate is labelled "low sample" (PRD 04 heuristic).
  final int insightsSampleThreshold;

  int likesPerDay({required bool premium}) =>
      premium ? premiumLikesPerDay : freeLikesPerDay;
}

@immutable
class Catalog {
  const Catalog({
    required this.products,
    this.policy = const AllowancePolicy(),
    this.currency = 'INR',
    this.provisional = true,
    this.billingLive = false,
  });

  final List<Product> products;
  final AllowancePolicy policy;
  final String currency;

  /// True while prices are hypotheses awaiting validation (PRD 06).
  final bool provisional;

  /// True only when real store billing with server verification is configured. Never true here.
  final bool billingLive;

  Product product(ProductKind kind) =>
      products.firstWhere((p) => p.kind == kind);

  List<Product> get plans => [
    for (final p in products)
      if (p.isSubscription) p,
  ];
}

/// PRD 06 provisional prices: Premium weekly INR 99, monthly INR 299, yearly INR 1,999; three
/// Compliments INR 79; one eligible streak recovery INR 19.
const Catalog kProvisionalCatalog = Catalog(
  products: [
    Product(
      id: 'numaya_premium_weekly',
      kind: ProductKind.premiumWeekly,
      pricePaise: 9900,
      billingDays: 7,
    ),
    Product(
      id: 'numaya_premium_monthly',
      kind: ProductKind.premiumMonthly,
      pricePaise: 29900,
      billingDays: 30,
    ),
    Product(
      id: 'numaya_premium_yearly',
      kind: ProductKind.premiumYearly,
      pricePaise: 199900,
      billingDays: 365,
    ),
    Product(
      id: 'numaya_compliments_3',
      kind: ProductKind.complimentPack,
      pricePaise: 7900,
      credits: 3,
    ),
    Product(
      id: 'numaya_streak_recovery',
      kind: ProductKind.streakRecovery,
      pricePaise: 1900,
    ),
  ],
);

/// "₹99", "₹1,999" (Indian digit grouping), "₹79.50" when there are paise.
String formatInr(int paise) {
  final rupees = paise ~/ 100;
  final rest = paise % 100;
  final digits = rupees.toString();
  String grouped;
  if (digits.length <= 3) {
    grouped = digits;
  } else {
    final last3 = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    grouped = '${parts.join(',')},$last3';
  }
  return rest == 0
      ? '₹$grouped'
      : '₹$grouped.${rest.toString().padLeft(2, '0')}';
}
