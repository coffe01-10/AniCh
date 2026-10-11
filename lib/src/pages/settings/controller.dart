import 'package:flutter/material.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class ThemeSettingsPageController extends LoadableController<dynamic>
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

  @override
  void dispose() {
    super.dispose();
  }
}

class AccountSettingsPageController extends LoadableController<dynamic>
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

  @override
  void dispose() {
    super.dispose();
  }
}

class DanmakuSettingsPageController extends LoadableController<dynamic>
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

  @override
  void dispose() {
    super.dispose();
  }
}

class PlayHistorySettingsPageController extends LoadableController<dynamic>
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

  @override
  void dispose() {
    super.dispose();
  }
}

class InfoSettingsPageController extends LoadableController<dynamic>
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

  @override
  void dispose() {
    super.dispose();
  }
}
