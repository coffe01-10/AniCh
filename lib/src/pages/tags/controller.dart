import 'package:flutter/material.dart';
import 'package:xs/protobuf/list.pb.dart';
import 'package:xs/src/apis/tags.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class TagsController extends LoadableController<dynamic>
    implements VsyncAttachable {
  TagsController(String tag) : tag = ValueNotifier(tag);

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

  late final ValueNotifier<String> tag;
  tag_info_body_ result = tag_info_body_();

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

  void _init() {
    getInfo();
  }

  // 获取数据
  void getInfo() async {
    try {
      debugPrint('TagsController-getInfo');
      change(result, status: LoadStatus.loading);
      final response =
          await TagsApi.getInfo(tag: Uri.encodeComponent(tag.value));
      final data = tag_info_.fromBuffer(response.data);
      result = data.body;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }
}

class TagsAllController extends LoadableController<List<thread_list_data_>> {
  TagsAllController(String tag) : tag = ValueNotifier(tag) {
    _init();
  }

  late final ValueNotifier<String> tag;
  List<thread_list_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('TagsAllController-get');
      change(result, status: LoadStatus.loading);
      final response =
          await TagsApi.getList(tag: tag.value, type: 'all', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('TagsAllController-more');
      isLoading.value = (true);
      final response = await TagsApi.getList(
          tag: tag.value, type: 'all', sort: -1, skip: result.last.id);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('TagsAllController-reload');
      final response =
          await TagsApi.getList(tag: tag.value, type: 'all', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class TagsArtworkController
    extends LoadableController<List<thread_list_data_>> {
  TagsArtworkController(String tag) : tag = ValueNotifier(tag) {
    _init();
  }

  late final ValueNotifier<String> tag;
  List<thread_list_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('TagsArtworkController-get');
      change(result, status: LoadStatus.loading);
      final response =
          await TagsApi.getList(tag: tag.value, type: 'artwork', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('TagsArtworkController-more');
      isLoading.value = (true);
      final response = await TagsApi.getList(
          tag: tag.value, type: 'artwork', sort: -1, skip: result.last.id);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('TagsArtworkController-reload');
      final response =
          await TagsApi.getList(tag: tag.value, type: 'artwork', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class TagsCosplayController
    extends LoadableController<List<thread_list_data_>> {
  TagsCosplayController(String tag) : tag = ValueNotifier(tag) {
    _init();
  }

  late final ValueNotifier<String> tag;
  List<thread_list_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('TagsCosplayController-get');
      change(result, status: LoadStatus.loading);
      final response =
          await TagsApi.getList(tag: tag.value, type: 'cosplay', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('TagsCosplayController-more');
      isLoading.value = (true);
      final response = await TagsApi.getList(
          tag: tag.value, type: 'cosplay', sort: -1, skip: result.last.id);
      final data = thread_list_.fromBuffer(response.data);
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('TagsCosplayController-reload');
      final response =
          await TagsApi.getList(tag: tag.value, type: 'cosplay', sort: -1);
      final data = thread_list_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.body.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
