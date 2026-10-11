import 'package:flutter/material.dart';

/// 应用根 [Navigator] 的 key。
///
/// 原项目大量使用 GetX 的无 context 弹窗/路由 API
/// （`Get.dialog`、`Get.back` 等）。重写后统一改为通过该 key
/// 取得根 `NavigatorState`/`BuildContext`，保持相同的调用形态。
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// 根 Navigator 对应的 [BuildContext]。
///
/// 仅在 MaterialApp 完成首帧构建后可用。
BuildContext get appContext {
  final context = appNavigatorKey.currentContext;
  if (context == null) {
    throw StateError('根 Navigator 尚未挂载，无法取得 appContext');
  }
  return context;
}

/// 根 NavigatorState（可能未挂载）。
NavigatorState? get appNavigator => appNavigatorKey.currentState;
