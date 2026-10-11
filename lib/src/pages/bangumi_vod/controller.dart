import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/protobuf/danmaku.pb.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/app/navigator_key.dart';
import 'package:xs/src/pages/bangumi_detail/models/bangumi_detail_model.dart';
import 'package:xs/src/pages/bangumi_vod/models/qq_video_model.dart';
import 'package:xs/src/services/danmaku_settings_service.dart';
import 'package:xs/src/services/danmaku_shield_service.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/services/play_history_service.dart';
import 'package:xs/src/utils/time.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/color.dart';
import 'package:xs/src/utils/log.dart';
import 'package:xs/src/utils/utils.dart';
import 'package:xs/src/widgets/danmaku_settings/view.dart';
import 'package:xs/src/widgets/danmaku_shield/view.dart';
import 'package:xs/src/widgets/ns_danmaku/danmaku_controller.dart';
import 'package:xs/src/widgets/ns_danmaku/models/danmaku_item.dart';
import 'package:xs/src/widgets/ns_danmaku/utils.dart';
import 'package:xs/src/widgets/player/controller.dart';
import 'package:xs/src/widgets/settings/settings_card.dart';
import 'package:xs/src/widgets/settings/settings_switch.dart';

const String assetName = 'assets/images/no_image.svg';
final Widget noImage = SvgPicture.asset(assetName);

/// 番剧播放页控制器。
///
/// 原实现为 `GetxController + StateMixin`，重写后：
/// - 加载状态改为 [LoadStatus] + [notifyListeners]；
/// - 响应式字段改为 `ValueNotifier`；
/// - `TabController`/`AnimationController` 由页面 [State] 通过
///   [attach]/[detach] 注入与销毁；
/// - 播放器流订阅统一由 [_bindPlayerStreams] 建立一次并在
///   [dispose] 中取消（原实现在 build 中重复订阅）。
class BangumiVodPageController extends PlayerController {
  BangumiVodPageController({
    required int pId,
    required int pEpisode,
  })  : idNotifier = ValueNotifier<int>(pId),
        episodeNotifier = ValueNotifier<int>(pEpisode) {
    get();
    _bindPlayerStreams();
  }

  /// 番剧 id（随换集/换番更新）。
  final ValueNotifier<int> idNotifier;
  int get id => idNotifier.value;

  /// 当前选集。
  final ValueNotifier<int> episodeNotifier;
  int get episode => episodeNotifier.value;

  /// 切换选集并重新加载播放数据。
  void setEpisode(int value) {
    if (value == episode) return;
    episodeNotifier.value = value;
    debugPrint('切换到第$episode集');
    player.stop();
    danmakuController?.clear();
    get();
  }

  /// 音量
  final ValueNotifier<double> playerVolume = ValueNotifier<double>(100.0);

  /// 线路数据
  final ValueNotifier<List<vod_item_>> playUrls =
      ValueNotifier<List<vod_item_>>([]);

  /// 当前线路
  int currentLineIndex = -1;
  final ValueNotifier<String> currentLineInfo = ValueNotifier<String>('');

  /// 详情数据加载状态
  LoadStatus status = LoadStatus.initial;

  /// 加载失败
  bool loadError = false;
  Error? error;

  /// 退出标记（用于终止后台弹幕拉取循环）
  bool leave = false;

  /// 导航栏
  final List<Tab> tabs = <Tab>[
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('简介'),
      ),
    ),
    const Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text('评论'),
      ),
    ),
  ];

  TabController? tabController;
  AnimationController? animationController;
  final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  BangumiDetailModel? data;
  bangumi_episodes_data_? episodeDetail;
  List<bangumi_episodes_data_> episodes = [];
  List<data_> danmakuList = [];
  List<bilibili_danmaku_item_> bilibiliDanmakuList = [];
  List<bilibili_danmaku_item_> bilibiliHmtDanmakuList = [];
  List<BarrageList> qqDanmakuList = [];

  ScrollController playListScrollController = ScrollController();
  ScrollController playListScrollController2 = ScrollController();

  Map<dynamic, dynamic> bangumiInfo = {'episodes': []};

  final ValueNotifier<int> lastPosition = ValueNotifier<int>(0);

  final ValueNotifier<bool> playing = ValueNotifier<bool>(true);

  final List<StreamSubscription> _playerSubscriptions = [];

  Listenable? _pageListenable;

  /// 页面级聚合通知器。
  ///
  /// 合并 [ChangeNotifier] 本身（data/episodes/status 等普通字段）
  /// 与播放器控制层、选集、线路等 `ValueNotifier`，
  /// 供页面与控制层 [ListenableBuilder] 统一订阅。
  Listenable get pageListenable => _pageListenable ??= Listenable.merge([
        this,
        controlsListenable,
        episodeNotifier,
        idNotifier,
        playUrls,
        currentLineInfo,
        playing,
        tabIndex,
        playerSpeed,
        danmakuTypeIndex,
        danmakuColor,
        textFormatStatus,
      ]);

  /// 由页面 [State] 注入 vsync 驱动的控制器。
  void attach(TickerProvider vsync) {
    tabController ??= TabController(
      vsync: vsync,
      length: tabs.length,
      initialIndex: 0,
    )..addListener(() {
        tabIndex.value = tabController!.index;
      });
    animationController ??= AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
  }

  /// 页面销毁时释放 [attach] 创建的资源。
  void detach() {
    tabController?.dispose();
    tabController = null;
    animationController?.dispose();
    animationController = null;
  }

  /// 上次弹幕分发位置（0.1s 精度）
  int _danmakuPosition = 0;

  /// 上次历史写入时的播放秒数
  int _historySeconds = 0;

  /// 建立播放器事件流订阅（仅调用一次）。
  void _bindPlayerStreams() {
    _playerSubscriptions.addAll([
      player.stream.error.listen((event) {
        SmartDialog.showToast('播放失败: $event');
      }),
      player.stream.completed.listen((event) {
        if (event) {
          showControls();
        }
      }),
      player.stream.playing.listen((event) {
        playing.value = player.state.playing;
        final settings = DanmakuSettingsService.instance;
        showDanmakuState.value = settings.danmakuEnable.value;
        bilibiliDanmakuState.value = settings.bilibiliDanmakuEnable.value;
        bilibiliHmtDanmakuState.value =
            settings.bilibiliHmtDanmakuEnable.value;
        qqDanmakuState.value = settings.qqDanmakuEnable.value;
        if (showDanmakuState.value && danmakuController is DanmakuController) {
          if (event) {
            int currentPosition =
                player.state.position.inMilliseconds ~/ 1000;
            if (_danmakuPosition != currentPosition) {
              _danmakuPosition = currentPosition;
            }
            danmakuController!.resume();
          } else {
            danmakuController!.pause();
          }
        }
      }),
      player.stream.position.listen((event) async {
        int currentinSeconds = event.inSeconds;
        if (currentinSeconds > 0 && lastPosition.value > 0) {
          final thisLastPosition = Duration(seconds: lastPosition.value);
          lastPosition.value = 0;
          await player.seek(thisLastPosition);
          debugPrint('跳转到$thisLastPosition');
        }
        if ((_historySeconds - currentinSeconds).abs() >= 5) {
          _historySeconds = currentinSeconds;
          _savePlayHistory(currentinSeconds);
        }
        _dispatchDanmaku(event.inMilliseconds);
      }),
    ]);
  }

  /// 每 5 秒写入一次观看历史（数据结构与原 `playHistory` 桶一致）。
  void _savePlayHistory(int currentinSeconds) {
    final detail = data;
    final ep = episodeDetail;
    if (detail == null || ep == null) return;
    final date = DateTime.now().millisecondsSinceEpoch;
    bangumiInfo['id'] = id;
    bangumiInfo['title'] = detail.title;
    bangumiInfo['date'] = date;
    bangumiInfo['image'] = detail.image;
    final episodeInfo = {
      'episode': episode,
      'title': '第$episode集 ${ep.title}',
      'position': currentinSeconds,
      'date': date,
      'image': ep.image,
    };
    final item = bangumiInfo['episodes'].firstWhere(
      (e) => e['episode'] == episode,
      orElse: () => {},
    );
    if (item.isEmpty) {
      bangumiInfo['episodes'].add(episodeInfo);
    } else {
      item['position'] = episodeInfo['position'];
      item['date'] = episodeInfo['date'];
    }
    PlayHistoryService.instance.save(id, bangumiInfo);
  }

  /// 按播放进度分发弹幕（内部弹幕 + 哔哩哔哩 + 港澳台 + 腾讯视频）。
  void _dispatchDanmaku(int positionMs) {
    if (!showDanmakuState.value || danmakuController is! DanmakuController) {
      return;
    }
    int current = positionMs ~/ 100;
    if (current == _danmakuPosition) return;
    _danmakuPosition = current;
    final shield = DanmakuShieldService.instance;
    final danmaku = danmakuController!;
    void add(List<DanmakuItem> items) {
      try {
        danmaku.addItems(items);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    // 默认弹幕
    if (danmakuList.isNotEmpty) {
      add(danmakuList
          .where((e) =>
              double.parse(e.time.toStringAsFixed(1)) == current / 10 &&
              shield.shieldCheck(e.text))
          .map((e) => DanmakuItem(
                e.text,
                color: ColorUtil.fromHex(e.color),
                time: e.time,
                type: DanmakuUtils.getPosition(e.type),
              ))
          .toList());
    }
    // 哔哩哔哩弹幕
    if (bilibiliDanmakuList.isNotEmpty && bilibiliDanmakuState.value) {
      add(bilibiliDanmakuList
          .where((e) =>
              double.parse((e.progress / 1000).toStringAsFixed(1)) ==
                  current / 10 &&
              shield.shieldCheck(e.content))
          .map((e) => DanmakuItem(
                e.content,
                color: ColorUtil.decimalToColor(e.color),
                time: e.progress / 1000,
                type: DanmakuUtils.getBilibiliPosition(e.mode),
              ))
          .toList());
    }
    // 哔哩哔哩(港澳台)弹幕
    if (bilibiliHmtDanmakuList.isNotEmpty &&
        bilibiliHmtDanmakuState.value) {
      add(bilibiliHmtDanmakuList
          .where((e) =>
              double.parse((e.progress / 1000).toStringAsFixed(1)) ==
                  current / 10 &&
              shield.shieldCheck(e.content))
          .map((e) => DanmakuItem(
                e.content,
                color: ColorUtil.decimalToColor(e.color),
                time: e.progress / 1000,
                type: DanmakuUtils.getBilibiliPosition(e.mode),
              ))
          .toList());
    }
    // 腾讯视频弹幕
    if (qqDanmakuList.isNotEmpty && qqDanmakuState.value) {
      add(qqDanmakuList
          .where((e) =>
              double.parse(
                  (int.parse(e.timeOffset ?? '0') / 1000)
                      .toStringAsFixed(1)) ==
                  current / 10 &&
              shield.shieldCheck(e.content))
          .map((e) => DanmakuItem(
                e.content ?? '一条弹幕',
                color: Colors.white,
                time: int.parse(e.timeOffset ?? '0') / 1000,
                type: DanmakuUtils.getQQPosition(e.rickType ?? 1),
              ))
          .toList());
    }
  }

  /// 番剧数据（由详情页透传时直接注入）。
  void setBangumiData(BangumiDetailModel value) {
    try {
      data = value;
      status = LoadStatus.success;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 获取番剧数据
  Future<void> getBangumiData() async {
    try {
      status = LoadStatus.loading;
      notifyListeners();
      final response = await BangumiApi.getBangumiDetail(id: id);
      if (response.statusCode == 200) {
        data = BangumiDetailModel.fromJson(response.data);
        status = LoadStatus.success;
      } else {
        throw Error();
      }
    } catch (e) {
      debugPrint(e.toString());
      status = LoadStatus.error;
      loadError = true;
    }
    notifyListeners();
  }

  /// 番剧剧集（由详情页透传时直接注入）。
  void setBangumiEpisodes(List<bangumi_episodes_data_> value) {
    try {
      episodes = value;
      episodeDetail = episodes.firstWhere((e) => e.sort == episode);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 获取番剧剧集
  Future<void> getBangumiEpisodes() async {
    try {
      final response = await BangumiApi.getBangumiEpisodes(id: id);
      if (response.statusCode == 200) {
        final result = bangumi_episodes_.fromBuffer(response.data);
        episodes.addAll(result.data);
        episodeDetail = episodes.firstWhere((e) => e.sort == episode);
        notifyListeners();
      } else {
        throw Error();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 获取弹幕
  Future<void> getDanmaku() async {
    int thisEpisode = episode;
    int index = 0;
    int length = 3000;
    bool completed = false;
    while (!completed && !leave && thisEpisode == episode) {
      try {
        debugPrint('BangumiVodController-getDanmaku-$index');
        final response = await BangumiApi.getDanmaku(
            id: id, episode: episode, skip: index * length);
        if (response.statusCode == 200) {
          final result = danmaku_.fromBuffer(response.data);
          if (result.data.isNotEmpty) {
            danmakuList.addAll(result.data);
            if (result.data.length == length) {
              index += 1;
            } else {
              completed = true;
            }
          } else {
            completed = true;
          }
        } else {
          throw Error();
        }
      } catch (e) {
        completed = true;
        debugPrint(e.toString());
      }
    }
    debugPrint('BangumiVodController-getDanmaku-complete');
  }

  /// 外部弹幕分页拉取的通用流程。
  ///
  /// [siteName] 为剧集站点标记；[fetchPage] 返回一页原始数据，
  /// 返回 `null` 表示出错终止，空列表表示拉取完成。
  Future<void> _fetchExternalDanmaku(
    String siteName,
    String tag,
    Future<List<dynamic>?> Function(String siteId, int index) fetchPage,
    void Function(List<dynamic> list) onData,
  ) async {
    int thisEpisode = episode;
    int index = 1;
    bool completed = false;
    while (!completed && !leave && thisEpisode == episode) {
      await Future.delayed(const Duration(seconds: 1));
      if (episodes.isEmpty) continue;
      final currentEpisode = getEpisodeData();
      if (currentEpisode.sites.isEmpty) continue;
      final site = currentEpisode.sites.firstWhere(
        (e) => e.site == siteName,
        orElse: () => bangumi_episodes_sites_(),
      );
      if (site.id.isEmpty) {
        return;
      }
      try {
        debugPrint('BangumiVodController-$tag-$index');
        final list = await fetchPage(site.id, index);
        if (list == null) {
          return;
        }
        if (list.isEmpty) {
          completed = true;
        } else {
          for (final item in Utils.splitList(list, 500)) {
            onData((await compute(
                    DanmakuShieldService.defaultShieldCheck, item))
                .cast<dynamic>());
          }
          index += 1;
        }
      } catch (e) {
        completed = true;
        debugPrint(e.toString());
      }
    }
    debugPrint('BangumiVodController-$tag-complete');
  }

  /// 获取哔哩哔哩弹幕
  Future<void> getBilibiliDanmaku() => _fetchExternalDanmaku(
        'bili_cid',
        'getBilibiliDanmaku',
        (siteId, index) async {
          final response = await BangumiApi.getBilibiliDanmaku(
              type: 1, oid: int.parse(siteId), segmentIndex: index);
          if (response.statusCode == 200) {
            return bilibili_danmaku_.fromBuffer(response.data).list;
          }
          return null;
        },
        (list) => bilibiliDanmakuList
            .addAll(list.cast<bilibili_danmaku_item_>()),
      );

  /// 获取哔哩哔哩(港澳台)弹幕
  Future<void> getBilibiliHmtDanmaku() => _fetchExternalDanmaku(
        'bili_hmt_cid',
        'getBilibiliHmtDanmaku',
        (siteId, index) async {
          final response = await BangumiApi.getBilibiliDanmaku(
              type: 1, oid: int.parse(siteId), segmentIndex: index);
          if (response.statusCode == 200) {
            return bilibili_danmaku_.fromBuffer(response.data).list;
          }
          return null;
        },
        (list) => bilibiliHmtDanmakuList
            .addAll(list.cast<bilibili_danmaku_item_>()),
      );

  /// 获取腾讯视频弹幕
  Future<void> getQQDanmaku() => _fetchExternalDanmaku(
        'qq',
        'getQQDanmaku',
        (siteId, index) async {
          final response =
              await BangumiApi.getQQDanmaku(id: siteId, page: index);
          if (response.statusCode == 200) {
            return QqVideoModel.fromJson(response.data).barrageList ?? [];
          }
          return null;
        },
        (list) => qqDanmakuList.addAll(list.cast<BarrageList>()),
      );

  /// URL解密
  String urlDecode(str) {
    try {
      return utf8.decode(base64
          .decode(base64.normalize(str.substring(0, 3) + str.substring(4))));
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  /// 获取视频链接
  Future<void> getPlayUrl() async {
    playUrls.value = [];
    currentLineInfo.value = '获取中...';
    currentLineIndex = -1;
    final response =
        await BangumiApi.getBangumiEpisodeVod(id: id, episode: episode);
    if (response.statusCode == 200) {
      vod_ result = vod_.fromBuffer(response.data.cast<int>());
      playUrls.value = result.data;
      currentLineIndex = 0;
      currentLineInfo.value = '线路${currentLineIndex + 1}';
      setPlayer();
    } else {
      currentLineInfo.value = '获取失败';
      SmartDialog.showToast('无法读取播放地址');
      return;
    }
    if (playUrls.value.isEmpty) {
      currentLineInfo.value = '暂无资源';
      SmartDialog.showToast('暂无资源');
    }
  }

  /// 设置视频链接
  Future<void> setPlayer() async {
    if (playUrls.value.isNotEmpty) {
      lastPosition.value =
          PlayHistoryService.instance.getLastPosition(id, episode);
      currentLineInfo.value = '线路${currentLineIndex + 1}';
      Map<String, String> headers = {};
      await player.open(
        Media(
          urlDecode(playUrls.value[currentLineIndex].url),
          httpHeaders: headers,
        ),
      );
      Log.d(
          '播放链接\r\n：${urlDecode(playUrls.value[currentLineIndex].url)}');
    }
  }

  /// 获取集数据
  bangumi_episodes_data_ getEpisodeData() {
    return episodes.firstWhere((e) => e.sort == episode,
        orElse: () => bangumi_episodes_data_());
  }

  /// 切换线路
  void changePlayLine(int index) {
    currentLineIndex = index;
    setPlayer();
  }

  /// 刷新
  void reload() {
    getPlayUrl();
  }

  /// 获取当前集的全部数据（播放地址 + 各弹幕源）。
  void get() {
    getPlayUrl();
    danmakuList.clear();
    bilibiliDanmakuList.clear();
    bilibiliHmtDanmakuList.clear();
    qqDanmakuList.clear();
    getDanmaku();
    getBilibiliDanmaku();
    getBilibiliHmtDanmaku();
    getQQDanmaku();
  }

  /// 滚动到当前集的位置
  void scrollToIndex() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      try {
        final index = episodes.indexWhere((e) => e.sort == episode);
        if (playListScrollController.hasClients &&
            playListScrollController.position.hasPixels) {
          playListScrollController.animateTo(index * 150,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeIn);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  /// 底部打开弹幕设置
  void showDanmakuSettingsSheet() {
    Utils.showBottomSheet(
      title: '弹幕设置',
      child: ListView(
        padding: AppStyle.edgeInsetsA12,
        children: [
          DanmakuSettingsView(
            playerController: this,
            danmakuController: danmakuController,
            onTapDanmakuShield: () {
              appNavigator?.pop();
              DanmakuShieldView.showDanmakuShieldBottomSheet();
            },
          ),
        ],
      ),
    );
  }

  /// 底部打开播放设置
  void showPlayerSettingsSheet() {
    final textTheme = Theme.of(appContext).textTheme;
    Utils.showBottomSheet(
      scrollControlDisabledMaxHeightRatio: 0.7,
      title: '播放设置',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          padding: AppStyle.edgeInsetsV12,
          children: [
            Padding(
              padding: AppStyle.edgeInsetsA12.copyWith(top: 0),
              child: Text(
                '画面尺寸',
                style: textTheme.titleSmall,
              ),
            ),
            SettingsCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _scaleModeItem('适应', 0),
                  AppStyle.divider,
                  _scaleModeItem('拉伸', 1),
                  AppStyle.divider,
                  _scaleModeItem('铺满', 2),
                  AppStyle.divider,
                  _scaleModeItem('16:9', 3),
                  AppStyle.divider,
                  _scaleModeItem('4:3', 4),
                ],
              ),
            ),
            Padding(
              padding: AppStyle.edgeInsetsA12.copyWith(top: 12),
              child: Text(
                '播放速度',
                style: textTheme.titleSmall,
              ),
            ),
            SettingsCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: speedsList.map((rate) {
                  return Column(
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: playerSpeed,
                        builder: (context, value, _) => SettingsSwitch(
                          title: '${rate}X',
                          value: value == rate,
                          onChanged: (e) {
                            setPlaybackSpeed(rate);
                          },
                        ),
                      ),
                      AppStyle.divider,
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scaleModeItem(String title, int mode) {
    return ValueListenableBuilder<int>(
      valueListenable: scaleMode,
      builder: (context, value, _) => SettingsSwitch(
        title: title,
        value: value == mode,
        onChanged: (e) {
          updateScaleMode(mode);
        },
      ),
    );
  }

  /// 右侧选集弹窗（全屏/横屏时使用）
  void showEpisodesSheet() {
    Utils.showRightDialog(
      title: '选集',
      width: 400,
      useSystem: true,
      child: Builder(builder: (builder) {
        WidgetsBinding.instance.addPostFrameCallback((callback) {
          if (playListScrollController2.hasClients &&
              playListScrollController2.position.hasPixels) {
            final index = episodes.indexWhere((e) => e.sort == episode);
            playListScrollController2.animateTo(index * 100,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeIn);
          }
        });
        return ListView(
          controller: playListScrollController2,
          children: episodes.map((item) {
            return Material(
              child: InkWell(
                onTap: () {
                  if (episode == item.sort) {
                    return;
                  }
                  setEpisode(item.sort);
                  Utils.hideRightDialog();
                },
                child: ValueListenableBuilder<int>(
                  valueListenable: episodeNotifier,
                  builder: (context, current, _) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: current == item.sort
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.transparent),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.grey.withOpacity(0.1)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: item.image.isNotEmpty
                                        ? Image.network(
                                            item.image,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return noImage;
                                            },
                                          )
                                        : noImage,
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 0,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 1,
                                              left: 5,
                                              right: 5,
                                              bottom: 3),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color:
                                                  Colors.black.withAlpha(120)),
                                          child: Text(
                                            item.status ? '有资源' : '无资源',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Visibility(
                                          visible: item.duration > 0,
                                          maintainSize: false,
                                          maintainSemantics: false,
                                          maintainAnimation: false,
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 1,
                                                left: 5,
                                                right: 5,
                                                bottom: 3),
                                            margin: const EdgeInsets.only(
                                                right: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.black
                                                    .withAlpha(120)),
                                            child: Text(
                                              Duration(seconds: item.duration)
                                                  .toString()
                                                  .split('.')
                                                  .first,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '第${item.sort}集 ${item.title}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15),
                              ),
                              Opacity(
                                opacity: 0.7,
                                child: Text(
                                  Time.dateTimeFormat(item.airdate.toInt()),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: 0.7,
                                child: Text(
                                  item.overview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            ],
                          ))
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  /// 底部线路弹窗（竖屏时使用）
  void showPlayUrlsSheet() {
    Utils.showBottomSheet(
      title: '切换线路',
      child: ValueListenableBuilder<List<vod_item_>>(
        valueListenable: playUrls,
        builder: (context, urls, _) => ListView.builder(
          itemCount: urls.length,
          itemBuilder: (_, i) {
            return RadioListTile(
              value: i,
              groupValue: currentLineIndex,
              title: Text('线路${i + 1}'),
              subtitle: Text(urlDecode(urls[i].url)),
              secondary: Text(
                urls[i].caption,
              ),
              onChanged: (e) {
                appNavigator?.pop();
                changePlayLine(i);
              },
            );
          },
        ),
      ),
    );
  }

  /// 音量悬浮滑块
  void showVolumeSlider(BuildContext targetContext) {
    SmartDialog.showAttach(
      targetContext: targetContext,
      alignment: Alignment.topCenter,
      displayTime: const Duration(seconds: 3),
      maskColor: const Color(0x00000000),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppStyle.radius12,
            color: Theme.of(context).cardColor,
          ),
          padding: AppStyle.edgeInsetsA4,
          child: SizedBox(
            width: 200,
            child: ValueListenableBuilder<double>(
              valueListenable: playerVolume,
              builder: (context, value, _) => Slider(
                min: 0,
                max: 100,
                value: value,
                onChanged: (newValue) {
                  player.setVolume(newValue);
                  playerVolume.value = newValue;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final subscription in _playerSubscriptions) {
      subscription.cancel();
    }
    _playerSubscriptions.clear();
    detach();
    playListScrollController.dispose();
    playListScrollController2.dispose();
    danmakuController = null;
    leave = true;
    super.dispose();
  }
}
