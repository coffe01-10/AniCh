import 'package:flutter/material.dart';

/// 需要 [TickerProvider]（TabController / AnimationController）的控制器
/// 实现该接口，由 [ControllerBuilder] 在生命周期内自动 attach/detach。
abstract class VsyncAttachable {
  void attach(TickerProvider vsync);
  void detach();
}

/// 替代原 GetX `GetBuilder`：在 StatefulWidget 生命周期内
/// 创建控制器、持有并在销毁时 `dispose`。
class ControllerBuilder<T extends ChangeNotifier> extends StatefulWidget {
  const ControllerBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  /// 控制器创建函数（每次 build 不会重复调用）。
  final T Function() create;

  /// 以控制器为参数的构建函数。
  final Widget Function(BuildContext context, T controller) builder;

  @override
  State<ControllerBuilder<T>> createState() => _ControllerBuilderState<T>();
}

class _ControllerBuilderState<T extends ChangeNotifier>
    extends State<ControllerBuilder<T>> with TickerProviderStateMixin {
  late final T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.create();
    final c = controller;
    if (c is VsyncAttachable) c.attach(this);
  }

  @override
  void dispose() {
    final c = controller;
    if (c is VsyncAttachable) c.detach();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 与旧 GetBuilder 语义一致：控制器每次 notifyListeners() 即重建。
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => widget.builder(context, controller),
    );
  }
}
