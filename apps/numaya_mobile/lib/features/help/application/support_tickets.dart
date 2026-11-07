import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// A support or appeal request (S43). In the demo it stays on this device and is labelled as not
/// sent to a team; a live build posts it to the support queue and reads its status back.
@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.topic,
    required this.at,
    this.appeal = false,
  });

  final String id;
  final String topic;
  final DateTime at;
  final bool appeal;
}

class SupportTicketsController extends Notifier<List<SupportTicket>> {
  @override
  List<SupportTicket> build() => const [];

  SupportTicket add(String topic, {bool appeal = false}) {
    final t = SupportTicket(
      id: 'T-${1001 + state.length}',
      topic: topic,
      at: ref.read(clockProvider)(),
      appeal: appeal,
    );
    state = [...state, t];
    return t;
  }
}

final supportTicketsProvider =
    NotifierProvider<SupportTicketsController, List<SupportTicket>>(
      SupportTicketsController.new,
    );
