import 'package:flutter/material.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/pages/bangumi_collection/models/bangumi_collection_model.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiCollectionController extends LoadableController<dynamic>
    implements VsyncAttachable {
  TickerProvider? _vsync;

  @override
  void attach(TickerProvider vsync) {
    _vsync = vsync;
    tabController =
        TabController(vsync: vsync, length: tabs.length, initialIndex: 1);
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
        child: Text('我想看的'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('我在看的'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('我看过的'),
      ),
    ),
  ];

  late TabController tabController;
  final ValueNotifier<int> tabIndex = ValueNotifier(1);

  late final AnimationController animationController;

  @override
  void dispose() {
    super.dispose();
  }
}

class BangumiWishCollectionController extends LoadableController<List<Data>> {
  BangumiWishCollectionController() {
    _init();
  }

  List<Data> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> page = ValueNotifier(1);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiWishCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCollect(type: 'wish', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      if (page.value < 1) {
        return;
      }
      debugPrint('BangumiWishCollectionController-more');
      isLoading.value = (true);
      final response =
          await BangumiApi.getCollect(type: 'wish', page: page.value);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiWishCollectionController-reload');
      final response = await BangumiApi.getCollect(type: 'wish', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.clear();
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiWatchCollectionController extends LoadableController<List<Data>> {
  BangumiWatchCollectionController() {
    _init();
  }

  List<Data> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> page = ValueNotifier(1);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiWatchCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCollect(type: 'watch', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      if (page.value < 1) {
        return;
      }
      debugPrint('BangumiWatchCollectionController-more');
      isLoading.value = (true);
      final response =
          await BangumiApi.getCollect(type: 'watch', page: page.value);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiWatchCollectionController-reload');
      final response = await BangumiApi.getCollect(type: 'watch', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.clear();
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiWatchedCollectionController
    extends LoadableController<List<Data>> {
  BangumiWatchedCollectionController() {
    _init();
  }

  List<Data> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> page = ValueNotifier(1);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiWatchedCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCollect(type: 'watched', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      if (page.value < 1) {
        return;
      }
      debugPrint('BangumiWatchedCollectionController-more');
      isLoading.value = (true);
      final response =
          await BangumiApi.getCollect(type: 'watched', page: page.value);
      final data = BangumiCollection.fromJson(response.data);
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiWatchedCollectionController-reload');
      final response = await BangumiApi.getCollect(type: 'watched', page: 1);
      final data = BangumiCollection.fromJson(response.data);
      result.clear();
      result.addAll(data.body!.data as Iterable<Data>);
      page.value =
          ((data.body?.next as bool ? data.body!.next : 0) as int?) ?? 0;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
