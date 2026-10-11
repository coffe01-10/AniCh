import 'package:flutter/material.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/protobuf/list.pb.dart';
import 'package:xs/src/apis/search.dart';
import 'package:xs/src/pages/search/models/search_type.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class SearchPageController extends LoadableController<dynamic>
    implements VsyncAttachable {
  SearchPageController({required this.searchType, required String keyword}) {
    this.keyword.value = keyword;
    _init();
  }
  TickerProvider? _vsync;

  @override
  void attach(TickerProvider vsync) {
    _vsync = vsync;
    tabController = TabController(
        vsync: vsync, length: tabs.length, initialIndex: searchType.index);
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
        child: Text('图片'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('番剧'),
      ),
    ),
  ];

  late TabController tabController;
  final ValueNotifier<int> tabIndex = ValueNotifier(1);

  late final AnimationController animationController;

  late SearchType searchType;
  final ValueNotifier<String> keyword = ValueNotifier('');

  void _init() {}

  @override
  void dispose() {
    super.dispose();
  }
}

class SearchBangumiController
    extends LoadableController<List<bangumi_list_item_>> {
  SearchBangumiController(this.keyword);
  List<bangumi_list_item_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  String keyword;

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('SearchBangumiController-get');
      change(result, status: LoadStatus.loading);
      final response = await SearchApi.searchBangumi(keyword: keyword);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('SearchBangumiController-more');
      isLoading.value = (true);
      final response =
          await SearchApi.searchBangumi(keyword: keyword, skip: result.last.id);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('SearchBangumiController-reload');
      final response = await SearchApi.searchBangumi(keyword: keyword);
      final data = bangumi_list_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class SearchPictureController
    extends LoadableController<List<thread_list_data_>> {
  SearchPictureController(this.keyword);
  List<thread_list_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  String keyword;

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('SearchPictureController-get');
      change(result, status: LoadStatus.loading);
      final response = await SearchApi.searchPicture(keyword: keyword);
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
      debugPrint('SearchPictureController-more');
      isLoading.value = (true);
      final response =
          await SearchApi.searchPicture(keyword: keyword, skip: result.last.id);
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
      debugPrint('SearchPictureController-reload');
      final response = await SearchApi.searchPicture(keyword: keyword);
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
