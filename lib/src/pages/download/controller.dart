import 'package:flutter/material.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class DownloadPageController extends LoadableController<dynamic>
    implements VsyncAttachable {
  TickerProvider? _vsync;

  @override
  void attach(TickerProvider vsync) {
    _vsync = vsync;
    tabController =
        TabController(vsync: vsync, length: tabs.length, initialIndex: 0);
    tabController.addListener(() {
      tabIndex.value = (tabController.index);
    });
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void detach() {
    tabController.dispose();
    animationController.dispose();
  }

  // 导航栏
  final List<Tab> tabs = <Tab>[
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('正在下载'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('下载完成'),
      ),
    )
  ];

  late TabController tabController;
  final ValueNotifier<int> tabIndex = ValueNotifier(0);

  late final AnimationController animationController;

  @override
  void dispose() {
    super.dispose();
  }
}
