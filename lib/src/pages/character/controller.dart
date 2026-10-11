import 'package:flutter/material.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/pages/character/models/character_bangumi_model.dart';
import 'package:xs/src/pages/character/models/character_model.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class CharacterController extends LoadableController<dynamic>
    implements VsyncAttachable {
  CharacterController(int id) {
    this.id.value = id;
    _init();
  }

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

  final ValueNotifier<int> id = ValueNotifier(0);
  Character result = Character();

  // 导航栏
  final List<Tab> tabs = <Tab>[
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('出演'),
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
      debugPrint('CharacterController-getInfo');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCharacter(id: id.value);
      final data = Character.fromJson(response.data);
      result = data;
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }
}

class CharacterIndexController extends LoadableController<List<Data>> {
  CharacterIndexController(int id) {
    this.id.value = id;
    _init();
  }

  final ValueNotifier<int> id = ValueNotifier(0);
  List<Data> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('CharacterIndexController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCharacterBangumi(id: id.value);
      final data = CharacterBangumi.fromJson(response.data);
      result.addAll(data.data as Iterable<Data>);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('CharacterIndexController-more');
      isLoading.value = (true);
      final response = await BangumiApi.getCharacterBangumi(
          id: id.value, skip: result.length);
      final data = CharacterBangumi.fromJson(response.data);
      result.addAll(data.data as Iterable<Data>);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('CharacterIndexController-reload');
      final response = await BangumiApi.getCharacterBangumi(id: id.value);
      final data = CharacterBangumi.fromJson(response.data);
      result.clear();
      result.addAll(data.data as Iterable<Data>);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
