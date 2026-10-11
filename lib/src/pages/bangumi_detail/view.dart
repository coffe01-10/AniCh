import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xs/src/pages/bangumi_detail/controller.dart';
import 'package:xs/src/pages/bangumi_detail/models/bangumi_detail_model.dart';
import 'package:xs/src/pages/bangumi_detail/views/characters.dart';
import 'package:xs/src/pages/bangumi_detail/views/index.dart';
import 'package:xs/src/pages/bangumi_detail/views/episodes.dart';
import 'package:xs/src/pages/bangumi_detail/views/persons.dart';
import 'package:xs/src/pages/bangumi_detail/views/related.dart';
import 'package:xs/src/utils/time.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiDetailPage extends StatelessWidget {
  const BangumiDetailPage({super.key, required this.id, this.data});
  final int id;
  final BangumiDetailModel? data;

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/images/no_image.svg';
    final Widget noImage = SvgPicture.asset(assetName);
    final ValueNotifier<double> appBarHeight = ValueNotifier(1.0);
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    return ControllerBuilder(
        create: () => BangumiDetailController(id: id, data: data),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            body: controller.obx((context, state) {
              final data = state;
              return ListenableBuilder(
                  listenable: Listenable.merge([
                    appBarHeight,
                    controller.collectStatusLoading,
                    controller.collectStatus,
                    controller.tabIndex,
                    scrollHeight,
                    scrollStatus
                  ]),
                  builder: (context, _) {
                    return DefaultTabController(
                      length: controller.tabs.length,
                      child: NestedScrollView(
                        floatHeaderSlivers: false,
                        body: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final pixels = notification.metrics.pixels.toInt();
                            if ((pixels - scrollHeight.value).abs() >= 50) {
                              final lastScrollStatus = scrollStatus.value;
                              if (pixels > scrollHeight.value) {
                                if (notification.depth > 0 &&
                                    lastScrollStatus != false) {
                                  scrollStatus.value = (false);
                                  controller.animationController.forward();
                                  debugPrint('向下');
                                }
                              } else if (pixels < scrollHeight.value) {
                                if (lastScrollStatus != true) {
                                  scrollStatus.value = (true);
                                  controller.animationController.reverse();
                                  debugPrint('向上');
                                }
                              }
                              scrollHeight.value = (pixels);
                            }
                            return false;
                          },
                          child: TabBarView(
                            controller: controller.tabController,
                            children: [
                              BangumiDetailIndexView(
                                active: controller.tabIndex.value == 0,
                                data: data,
                              ),
                              BangumiDetailEpisodesView(
                                id: controller.id.value,
                                active: controller.tabIndex.value == 1,
                                data: data,
                              ),
                              BangumiDetailCharactersView(
                                  id: controller.id.value,
                                  active: controller.tabIndex.value == 2),
                              BangumiDetailPersonsView(
                                  id: controller.id.value,
                                  active: controller.tabIndex.value == 3),
                              BangumiDetailRelatedView(
                                  id: controller.id.value,
                                  active: controller.tabIndex.value == 4),
                            ],
                          ),
                        ),
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverOverlapAbsorber(
                              sliver: SliverAppBar(
                                title: ListenableBuilder(
                                    listenable: appBarHeight,
                                    builder: (context, _) {
                                      return CustomDragToMoveArea(
                                          child: Opacity(
                                        opacity:
                                            min(appBarHeight.value.abs(), 1.0),
                                        child: Text('${data?.title}'),
                                      ));
                                    }),
                                actions: [closeWindowButton(positioned: false)],
                                pinned: true,
                                automaticallyImplyLeading: false,
                                floating: true,
                                snap: false,
                                expandedHeight: 270,
                                collapsedHeight: 50,
                                toolbarHeight: 50,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                surfaceTintColor: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                flexibleSpace: LayoutBuilder(
                                  builder: (context, constraints) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      appBarHeight.value = (1.5 -
                                          (constraints.biggest.height -
                                                  MediaQuery.of(context)
                                                      .padding
                                                      .top) /
                                              180);
                                    });
                                    return ListenableBuilder(
                                        listenable: appBarHeight,
                                        builder: (context, _) {
                                          return Opacity(
                                            opacity: max(
                                                (appBarHeight.value - 1).abs(),
                                                0.0),
                                            child: CustomDragToMoveArea(
                                              child: FlexibleSpaceBar(
                                                background: Stack(
                                                  children: [
                                                    ShaderMask(
                                                      shaderCallback: (rect) {
                                                        return LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              Colors.black
                                                                  .withAlpha(
                                                                      100),
                                                              Colors.transparent
                                                            ]).createShader(
                                                            Rect.fromLTRB(
                                                                0,
                                                                0,
                                                                rect.width,
                                                                rect.height));
                                                      },
                                                      blendMode:
                                                          BlendMode.dstIn,
                                                      child: Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          data!.image != null
                                                              ? Image.network(
                                                                  '${data.image}',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : noImage,
                                                          BackdropFilter(
                                                            filter: ImageFilter
                                                                .blur(
                                                                    sigmaX: 10,
                                                                    sigmaY: 10),
                                                            child: Container(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .padding
                                                                  .top +
                                                              10,
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 150,
                                                            child: AspectRatio(
                                                              aspectRatio:
                                                                  3 / 4,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: data.image !=
                                                                        null
                                                                    ? Image
                                                                        .network(
                                                                        '${data.image}',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : noImage,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  child: Text(
                                                                    '${data.title}',
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '时间: ${Time.dateTimeFormat(data.airdate ?? 0)}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  '状态: ${data.status == null ? '敬请期待' : data.status == 'released' ? '全1集' : data.status == 'finale' ? '全${data.episodesTotal}集' : '更新至第${data.episode}集'}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                  '评分: ${data.rating!.where((i) {
                                                                    return i!
                                                                            .score!
                                                                            .toInt() >
                                                                        0;
                                                                  }).isNotEmpty ? data.rating?.where((i) {
                                                                        return i!.score!.toInt() >
                                                                            0;
                                                                      }).map((i) {
                                                                        return '${i?.site}(${i!.score})';
                                                                      }).toSet().join('  ') : '暂无'}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // centerTitle: true,
                                                collapseMode: CollapseMode.pin,
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                ),
                                bottom: PreferredSize(
                                  preferredSize: const Size.fromHeight(50),
                                  child: Material(
                                    color: Colors.transparent,
                                    // color: Theme.of(context).scaffoldBackgroundColor,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: TabBar(
                                              labelPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              controller:
                                                  controller.tabController,
                                              tabAlignment: TabAlignment.start,
                                              isScrollable: true,
                                              indicatorSize:
                                                  TabBarIndicatorSize.label,
                                              dividerColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              tabs: controller.tabs,
                                            ),
                                          ),
                                        ),
                                        ListenableBuilder(
                                            listenable: Listenable.merge([
                                              controller.collectStatusLoading,
                                              controller.collectStatus
                                            ]),
                                            builder: (context, _) {
                                              if (controller
                                                  .collectStatusLoading.value) {
                                                return !controller
                                                        .collectStatus.value
                                                    ? SizedBox(
                                                        height: 30,
                                                        child: FilledButton(
                                                          style: ButtonStyle(
                                                              shape: WidgetStateProperty.all(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)))),
                                                          onPressed: () {
                                                            controller
                                                                .showCollectSheet();
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.favorite,
                                                                size: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text('收藏')
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 30,
                                                        child: FilledButton(
                                                          style: ButtonStyle(
                                                              backgroundColor: WidgetStateProperty
                                                                  .all(Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withAlpha(
                                                                          200)),
                                                              shape: WidgetStateProperty.all(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)))),
                                                          onPressed: () {
                                                            controller
                                                                .showMarkSheet();
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.more_vert,
                                                                size: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Text('标记为...')
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                              } else {
                                                return Container();
                                              }
                                            }),
                                        const SizedBox(width: 10)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                          ];
                        },
                      ),
                    );
                  });
            }),
            bottomNavigationBar: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SlideTransition(
                  position: Tween(begin: Offset.zero, end: const Offset(0, 1.0))
                      .animate(controller.animationController),
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
        });
  }
}
