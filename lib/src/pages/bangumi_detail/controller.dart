import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/pages/bangumi_detail/models/bangumi_detail_model.dart';
import 'package:xs/src/utils/account.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/utils.dart';
import 'package:xs/src/widgets/settings/settings_action.dart';
import 'package:xs/src/widgets/settings/settings_card.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiDetailController extends LoadableController<BangumiDetailModel>
    implements VsyncAttachable {
  BangumiDetailController({required int id, BangumiDetailModel? data}) {
    this.id.value = id;
    this.data = data;
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

  // 导航栏
  final List<Tab> tabs = <Tab>[
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('详情'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('剧集'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('角色'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('制作人员'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('推荐'),
      ),
    ),
  ];

  late TabController tabController;
  late final AnimationController animationController;
  final ValueNotifier<int> id = ValueNotifier(0);
  final ValueNotifier<int> tabIndex = ValueNotifier(0);
  List<BangumiDetailModel> result = [];
  final ValueNotifier<bool> collectStatusLoading = ValueNotifier(true);
  final ValueNotifier<bool> collectStatus = ValueNotifier(false);
  final ValueNotifier<int> collectType = ValueNotifier(999);
  List collectTypeList = ['wish', 'watch', 'watched'];

  void _init() {
    get();
    getCollectStatus();
  }

  // 查询数据
  BangumiDetailModel? find(ValueNotifier<int> id) {
    try {
      return result.where((i) => i.id == id.value).first;
    } catch (e) {
      return null;
    }
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiDetail(id: id.value);
      if (response.statusCode == 200) {
        final data = BangumiDetailModel.fromJson(response.data);
        final old = find(id);
        if (old == null) {
          result.add(data);
        } else {
          result.remove(old);
          result.add(data);
        }
        change(data, status: LoadStatus.success);
      } else {
        throw Error();
      }
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 收藏状态
  void getCollectStatus() async {
    try {
      final token = AccountUtil.token();
      if (token.isEmpty) {
        return;
      }
      collectStatusLoading.value = (true);
      debugPrint('BangumiDetailController-getCollectStatus');
      final response = await BangumiApi.collectStatus(id: id.value);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final type = response.data['type'] ?? 999;
        collectStatus.value = (data);
        collectType.value = (type);
        collectStatusLoading.value = (false);
      } else {
        throw Error();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 收藏状态
  void changeCollect(index) async {
    try {
      final token = AccountUtil.token();
      if (token.isEmpty) {
        return;
      }
      collectStatusLoading.value = (true);
      debugPrint('BangumiDetailController-changeCollect');
      debugPrint('$id ${collectTypeList[index]}');
      final response = await BangumiApi.changeCollect(
          id: id.value, type: collectTypeList[index]);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        collectStatus.value = (data);
        collectType.value = (index);
        collectStatusLoading.value = (false);
        SmartDialog.showToast('操作成功');
      } else {
        throw Error();
      }
    } catch (e) {
      SmartDialog.showToast('操作失败，请重试');
      debugPrint(e.toString());
    }
  }

  // 取消收藏
  void cancelCollect() async {
    try {
      final token = AccountUtil.token();
      if (token.isEmpty) {
        return;
      }
      collectStatusLoading.value = (true);
      debugPrint('BangumiDetailController-cancelCollect');
      final response = await BangumiApi.cancelCollect(id: id.value);
      if (response.statusCode == 200) {
        // final data = response.data['data'];
        // final type = response.data['type'] ?? 999;
        collectStatus.value = (false);
        collectType.value = (999);
        collectStatusLoading.value = (false);
        SmartDialog.showToast('取消成功');
      } else {
        throw Error();
      }
    } catch (e) {
      SmartDialog.showToast('取消失败');
      debugPrint(e.toString());
    }
  }

  void showCollectSheet() {
    Utils.showBottomSheet(
        title: '收藏到...',
        maxHeight: 250,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SettingsCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SettingsAction(
                      rightIcon: false,
                      title: '我想看的',
                      onTap: () {
                        appPop();
                        changeCollect(0);
                      },
                    ),
                    AppStyle.divider,
                    SettingsAction(
                      rightIcon: false,
                      title: '我在看的',
                      onTap: () {
                        appPop();
                        changeCollect(1);
                      },
                    ),
                    AppStyle.divider,
                    SettingsAction(
                      rightIcon: false,
                      title: '我看过的',
                      onTap: () {
                        appPop();
                        changeCollect(2);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void showMarkSheet() {
    Utils.showBottomSheet(
        title: '标记为...',
        maxHeight: 250,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SettingsCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Offstage(
                      offstage: collectType.value == 0,
                      child: Column(
                        children: [
                          SettingsAction(
                            rightIcon: false,
                            title: '我想看的',
                            onTap: () {
                              appPop();
                              changeCollect(0);
                            },
                          ),
                          AppStyle.divider,
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: collectType.value == 1,
                      child: Column(
                        children: [
                          SettingsAction(
                            rightIcon: false,
                            title: '我在看的',
                            onTap: () {
                              appPop();
                              changeCollect(1);
                            },
                          ),
                          AppStyle.divider,
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: collectType.value == 2,
                      child: Column(
                        children: [
                          SettingsAction(
                            rightIcon: false,
                            title: '我看过的',
                            onTap: () {
                              appPop();
                              changeCollect(2);
                            },
                          ),
                          AppStyle.divider,
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: false,
                      child: Column(
                        children: [
                          SettingsAction(
                            rightIcon: false,
                            title: '取消收藏',
                            color: Colors.red,
                            onTap: () {
                              appPop();
                              cancelCollect();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BangumiDetailIndexController extends LoadableController<dynamic> {
  BangumiDetailIndexController() {
    _init();
  }

  List result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailIndexController-get');
      change(result, status: LoadStatus.loading);
      // final response = await BangumiApi.getBangumiList();
      // final data = bangumi_list_.fromBuffer(response.data);
      // result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('BangumiDetailIndexController-more');
      isLoading.value = (true);
      // final response = await BangumiApi.getBangumiList(skip: result.last.id);
      // final data = bangumi_list_.fromBuffer(response.data);
      // result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiDetailIndexController-reload');
      // final response = await BangumiApi.getBangumiList();
      // final data = bangumi_list_.fromBuffer(response.data);
      // result.clear();
      // result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiDetailEpisodesController
    extends LoadableController<List<bangumi_episodes_data_>> {
  BangumiDetailEpisodesController(this.id);
  final int id;

  List<bangumi_episodes_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailEpisodesController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiEpisodes(id: id);
      final data = bangumi_episodes_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  // void more() async {
  //   try {
  //     debugPrint('BangumiDetailEpisodesController-more');
  //     isLoading.value = (true);
  //     // final response = await BangumiApi.getBangumiList(skip: result.last.id);
  //     // final data = bangumi_list_.fromBuffer(response.data);
  //     // result.addAll(data.data);
  //     change(result, status: LoadStatus.success);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   isLoading.value = (false);
  // }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiDetailEpisodesController-reload');
      final response = await BangumiApi.getBangumiEpisodes(id: id);
      final data = bangumi_episodes_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiDetailRelatedController
    extends LoadableController<List<bangumi_related_data_>> {
  BangumiDetailRelatedController(int id) {
    _init();
  }
  List<bangumi_related_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> id = ValueNotifier(0);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailRelatedController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiRelated(id: id.value);
      final data = bangumi_related_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 加载更多
  // void more() async {
  //   try {
  //     debugPrint('BangumiDetailRelatedController-more');
  //     isLoading.value = (true);
  //     // final response = await BangumiApi.getBangumiList(skip: result.last.id);
  //     // final data = bangumi_list_.fromBuffer(response.data);
  //     // result.addAll(data.data);
  //     change(result, status: LoadStatus.success);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   isLoading.value = (false);
  // }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiDetailRelatedController-reload');
      final response = await BangumiApi.getBangumiRelated(id: id.value);
      final data = bangumi_related_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiDetailCharactersController
    extends LoadableController<List<bangumi_characters_data_>> {
  BangumiDetailCharactersController(this.id) {
    _init();
  }
  final int id;

  List<bangumi_characters_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailCharactersController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getCharacters(id: id);
      final data = bangumi_characters_.fromBuffer(response.data);
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
      debugPrint('BangumiDetailCharactersController-reload');
      final response = await BangumiApi.getCharacters(id: id);
      final data = bangumi_characters_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}

class BangumiDetailPersonsController
    extends LoadableController<List<bangumi_persons_data_>> {
  BangumiDetailPersonsController(this.id) {
    _init();
  }
  final int id;

  List<bangumi_persons_data_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void _init() {
    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiDetailPersonsController-get');
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getPersons(id: id);
      final data = bangumi_persons_.fromBuffer(response.data);
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
      debugPrint('BangumiDetailPersonsController-reload');
      final response = await BangumiApi.getPersons(id: id);
      final data = bangumi_persons_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
