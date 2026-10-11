import 'package:flutter/material.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class ProfilePageController extends LoadableController<dynamic>
    implements VsyncAttachable {
  TickerProvider? _vsync;

  @override
  void attach(TickerProvider vsync) {
    _vsync = vsync;
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void detach() {
    animationController.dispose();
  }

  late final AnimationController animationController;
}
