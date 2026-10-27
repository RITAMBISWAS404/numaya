import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo Hub switch: behave as if the phone's "Remove animations" setting were on, so reduced
/// motion can be tried without changing system settings. Development builds only.
class DemoReduceMotionController extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool on) => state = on;
}

final demoReduceMotionProvider =
    NotifierProvider<DemoReduceMotionController, bool>(
      DemoReduceMotionController.new,
    );
