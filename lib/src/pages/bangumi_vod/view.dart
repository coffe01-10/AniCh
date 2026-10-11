import 'dart:io';
import 'dart:math';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/pages/bangumi_detail/models/bangumi_detail_model.dart';
import 'package:xs/src/pages/bangumi_vod/controller.dart';
import 'package:xs/src/pages/bangumi_vod/views/comments.dart';
import 'package:xs/src/pages/bangumi_vod/views/index.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/widgets/player/controls.dart';

const String assetName = 'assets/images/no_image.svg';
final Widget noImage = SvgPicture.asset(assetName);

/// 番剧播放页（路由 `/vod/:id`）。
///
/// 参数由路由表注入（见 [VodArguments]），控制器由页面 [State]
/// 创建、attach 并销毁。
class BangumiVodPage extends StatefulWidget {
  const BangumiVodPage({
    super.key,
    required this.id,
    this.episode,
    this.data,
    this.episodes,
  });

  /// 番剧 id。
  final int id;

  /// 初始选集（缺省为第 1 集）。
  final int? episode;

  /// 详情页透传的番剧数据（为空时走接口拉取）。
  final BangumiDetailModel? data;

  /// 详情页透传的剧集列表（为空时走接口拉取）。
  final List<bangumi_episodes_data_>? episodes;

  @override
  State<StatefulWidget> createState() {
    return BangumiVodPageState();
  }
}

class BangumiVodPageState extends State<BangumiVodPage>
    with TickerProviderStateMixin {
  late final BangumiVodPageController controller;

  final ScrollController nestedScrollViewScrollController = ScrollController();

  /// 顶部折叠进度（0~1），驱动标题透明度。
  final ValueNotifier<double> appBarHeight = ValueNotifier<double>(1.0);

  /// 上次滚动位置/方向（用于导航栏滑入滑出判定）。
  int scrollHeight = 0;
  bool scrollStatus = true;

  @override
  void initState() {
    super.initState();
    controller = BangumiVodPageController(
      pId: widget.id,
      pEpisode: widget.episode ?? 1,
    );
    controller.attach(this);
    final data = widget.data;
    if (data != null) {
      controller.setBangumiData(data);
    } else {
      controller.getBangumiData();
    }
    final episodes = widget.episodes;
    if (episodes != null) {
      controller.setBangumiEpisodes(episodes);
    } else {
      controller.getBangumiEpisodes();
    }
  }

  @override
  void dispose() {
    controller.detach();
    controller.dispose();
    nestedScrollViewScrollController.dispose();
    appBarHeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = ValueListenableBuilder<bool>(
      valueListenable: controller.fullScreenState,
      builder: (context, fullScreen, _) {
        if (fullScreen) {
          return PopScope(
            canPop: false,
            onPopInvoked: (e) {
              controller.exitFull();
            },
            child: Scaffold(
              body: buildMediaPlayer(controller),
            ),
          );
        }
        return buildPageUI(controller);
      },
    );
    if (!Platform.isAndroid) {
      return page;
    }
    return PiPSwitcher(
      floating: controller.pip,
      childWhenDisabled: page,
      childWhenEnabled: buildMediaPlayer(controller),
    );
  }

  Widget buildPageUI(BangumiVodPageController controller) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          extendBody: true,
          appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 0),
            child: AppBar(backgroundColor: Colors.black),
          ),
          body: ListenableBuilder(
            listenable: controller.pageListenable,
            builder: (context, _) {
              if (controller.status == LoadStatus.loading ||
                  controller.status == LoadStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.status == LoadStatus.error) {
                return const Center(child: Text('加载失败'));
              }
              return DefaultTabController(
                length: controller.tabs.length,
                child: NestedScrollView(
                  controller: nestedScrollViewScrollController,
                  body: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      final pixels = notification.metrics.pixels.toInt();
                      if ((pixels - scrollHeight).abs() >= 50) {
                        final lastScrollStatus = scrollStatus;
                        if (pixels > scrollHeight) {
                          if (notification.depth == 1 &&
                              lastScrollStatus != false) {
                            scrollStatus = false;
                            controller.animationController?.forward();
                            debugPrint('向下');
                          }
                        } else if (pixels < scrollHeight) {
                          if (lastScrollStatus != true) {
                            scrollStatus = true;
                            controller.animationController?.reverse();
                            debugPrint('向上');
                          }
                        }
                        scrollHeight = pixels;
                      }
                      return false;
                    },
                    child: TabBarView(
                      controller: controller.tabController,
                      children: [
                        BangumiVodIndexView(
                          controller: controller,
                        ),
                        BangumiVodCommentsView(
                          bangumiVodPageController: controller,
                        ),
                      ],
                    ),
                  ),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    double expandedHeight = min(
                        (MediaQuery.of(context).size.width * 9 / 16) + 50, 450);
                    return [
                      SliverOverlapAbsorber(
                        sliver: SliverAppBar(
                          title: ValueListenableBuilder<double>(
                            valueListenable: appBarHeight,
                            builder: (context, heightValue, _) {
                              return CustomDragToMoveArea(
                                child: Opacity(
                                  opacity: max(min(heightValue.abs(), 1.0), 0),
                                  child: Offstage(
                                    offstage: heightValue > 0.3 ? false : true,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () {
                                          controller.player.play();
                                        },
                                        child: Wrap(
                                          spacing: 5,
                                          alignment: WrapAlignment.center,
                                          runAlignment: WrapAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.play_arrow,
                                              size: 20,
                                            ),
                                            Text(
                                                '${controller.data?.title ?? ''}')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          pinned: true,
                          automaticallyImplyLeading: false,
                          floating: true,
                          snap: false,
                          expandedHeight:
                              nestedScrollViewScrollController.hasClients &&
                                      nestedScrollViewScrollController
                                              .position.pixels >
                                          0
                                  ? 50
                                  : expandedHeight,
                          collapsedHeight: controller.playing.value
                              ? expandedHeight - 50
                              : 50,
                          toolbarHeight: 50,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          surfaceTintColor:
                              Theme.of(context).colorScheme.inverseSurface,
                          flexibleSpace: LayoutBuilder(
                            builder: (context, constraints) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                double height = 1 -
                                    ((constraints.biggest.height.floor() -
                                            MediaQuery.of(context).padding.top -
                                            100) /
                                        expandedHeight.floor());
                                appBarHeight.value = height <= 0.5 ? 0 : height;
                              });
                              return ValueListenableBuilder<double>(
                                valueListenable: appBarHeight,
                                builder: (context, heightValue, _) {
                                  bool visible =
                                      heightValue.floor() == 1 ? false : true;
                                  return Visibility(
                                    visible: visible,
                                    child: Opacity(
                                      opacity: min(
                                          max((heightValue - 1).abs(), 0.0),
                                          1.0),
                                      child: FlexibleSpaceBar(
                                        background: Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                      .padding
                                                      .top,
                                                  bottom: 50),
                                              child: Stack(
                                                children: [
                                                  buildPhoneUI(
                                                      context, controller),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        collapseMode: CollapseMode.pin,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(50),
                            child: Material(
                              color: Colors.transparent,
                              child: CustomDragToMoveArea(
                                child: TabBar(
                                  controller: controller.tabController,
                                  tabAlignment: TabAlignment.start,
                                  isScrollable: true,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  dividerColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  tabs: controller.tabs,
                                ),
                              ),
                            ),
                          ),
                        ),
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
          bottomNavigationBar: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SlideTransition(
                position: Tween(begin: Offset.zero, end: const Offset(0, 1.0))
                    .animate(controller.animationController ??
                        const AlwaysStoppedAnimation(0.0)),
                child: NavBar(
                  children: [
                    NavItem(
                        icon: Icons.arrow_back,
                        title: '返回',
                        onTap: () => appPop()),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildPhoneUI(
      BuildContext context, BangumiVodPageController controller) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: buildMediaPlayer(controller),
          ),
        ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }

  Widget buildMediaPlayer(BangumiVodPageController controller) {
    return Stack(
      children: [
        Video(
          key: controller.globalPlayerKey,
          controller: controller.videoController,
          pauseUponEnteringBackgroundMode: true,
          resumeUponEnteringForegroundMode: true,
          controls: (state) {
            return playerControls(state, controller);
          },
          aspectRatio: controller.aspectRatio,
          fit: controller.boxFit,
        ),
      ],
    );
  }
}
