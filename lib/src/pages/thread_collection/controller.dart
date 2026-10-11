import 'package:flutter/material.dart';
import 'package:xs/src/apis/thread.dart';
import 'package:xs/src/pages/thread_collection/models/thread_collection_model.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class ThreadCollectionController extends LoadableController<dynamic>
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
        child: Text('综合'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('插画'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('COSPLAY'),
      ),
    ),
  ];

  late TabController tabController;
  final ValueNotifier<int> tabIndex = ValueNotifier(0);

  late final AnimationController animationController;

  @override
  void dispose() {
    super.dispose();
  }
}

class ThreadAllCollectionController extends LoadableController<List<Data>> {
  ThreadAllCollectionController() {
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
      debugPrint('ThreadAllCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await ThreadApi.getCollect(type: '', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadAllCollectionController-more');
      isLoading.value = (true);
      final response = await ThreadApi.getCollect(type: '', page: page.value);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadAllCollectionController-reload');
      final response = await ThreadApi.getCollect(type: '', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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

class ThreadArtworkCollectionController extends LoadableController<List<Data>> {
  ThreadArtworkCollectionController() {
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
      debugPrint('ThreadArtworkCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await ThreadApi.getCollect(type: 'artwork', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadArtworkCollectionController-more');
      isLoading.value = (true);
      final response =
          await ThreadApi.getCollect(type: 'artwork', page: page.value);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadArtworkCollectionController-reload');
      final response = await ThreadApi.getCollect(type: 'artwork', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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

class ThreadCosplayCollectionController extends LoadableController<List<Data>> {
  ThreadCosplayCollectionController() {
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
      debugPrint('ThreadCosplayCollectionController-get');
      change(null, status: LoadStatus.loading);
      final response = await ThreadApi.getCollect(type: 'cosplay', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadCosplayCollectionController-more');
      isLoading.value = (true);
      final response =
          await ThreadApi.getCollect(type: 'cosplay', page: page.value);
      final data = ThreadCollection.fromJson(response.data);
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
      debugPrint('ThreadCosplayCollectionController-reload');
      final response = await ThreadApi.getCollect(type: 'cosplay', page: 1);
      final data = ThreadCollection.fromJson(response.data);
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
