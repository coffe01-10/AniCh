import 'package:flutter/material.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiController extends LoadableController<dynamic>
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
        child: Text('最近更新'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('索引'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('分类'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('标签'),
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

class BangumiIndexController
    extends LoadableController<List<bangumi_list_item_>> {
  BangumiIndexController() {
    _init();
  }

  List<bangumi_list_item_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Map<String, String> typeList = {
    '': '类型',
    'tv': '正篇',
    'movie': '剧场版',
    'ova': '特别篇'
  };

  Map<String, String> langList = {
    '': '语言',
    'ja': '日语',
    'zh': '国语',
    'en': '英语',
    'ko': '韩语',
    'other': '其他'
  };

  Map<String, String> yearList = {
    '': '年份',
  };

  final ValueNotifier<String> typeSelect = ValueNotifier('');
  final ValueNotifier<String> langSelect = ValueNotifier('');
  final ValueNotifier<String> yearSelect = ValueNotifier('');
  final ValueNotifier<String> typeSelected = ValueNotifier('');
  final ValueNotifier<String> langSelected = ValueNotifier('');
  final ValueNotifier<String> yearSelected = ValueNotifier('');

  void _init() {
    // 创建年份
    int currentYear = DateTime.now().year;
    List<String>.generate(35, (i) {
      String year = (currentYear - i).toString();
      yearList[year] = '$year年';
      return year;
    });

    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiIndexController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiList();
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 筛选
  void filter() async {
    try {
      typeSelected.value = (typeSelect.value);
      langSelected.value = (langSelect.value);
      yearSelected.value = (yearSelect.value);
      debugPrint('BangumiIndexController-filter');
      result.clear();
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiList(
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
    isLoading.value = (false);
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('BangumiIndexController-more');
      isLoading.value = (true);
      final response = await BangumiApi.getBangumiList(
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value,
          skip: result.last.id);
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
      debugPrint('BangumiIndexController-reload');
      final response = await BangumiApi.getBangumiList(
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value);
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

class BangumiGenreController extends LoadableController<List<Tag>> {
  BangumiGenreController() {
    _init();
  }

  List<Tag> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiGenreController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getTags(type: 'genre');
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('BangumiGenreController-more');
      isLoading.value = (true);
      final response =
          await BangumiApi.getTags(type: 'genre', skip: result.length);
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiGenreController-reload');
      final response = await BangumiApi.getTags(type: 'genre');
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.clear();
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiMarkController extends LoadableController<List<Tag>> {
  BangumiMarkController() {
    _init();
  }

  List<Tag> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiMarkController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getTags(type: 'mark');
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('BangumiMarkController-more');
      isLoading.value = (true);
      final response =
          await BangumiApi.getTags(type: 'mark', skip: result.length);
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiMarkController-reload');
      final response = await BangumiApi.getTags(type: 'mark');
      List<Tag> tagsList =
          List<Tag>.from(response.data.map((e) => Tag.fromJson(e)));
      result.clear();
      result.addAll(tagsList);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class Tag {
  String? name;
  int? count;
  String? image;

  Tag({
    this.name,
    this.count,
    this.image,
  });
  Tag.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    count = json['count']?.toInt();
    image = json['image']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['count'] = count;
    data['image'] = image;
    return data;
  }
}

class BangumiLatestController
    extends LoadableController<List<bangumi_latest_item_>> {
  BangumiLatestController() {
    _init();
  }

  List<bangumi_latest_item_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiLatestController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiLatest();
      final data = bangumi_latest_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiLatestController-reload');
      final response = await BangumiApi.getBangumiLatest();
      final data = bangumi_latest_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
