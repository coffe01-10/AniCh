import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xs/src/pages/bangumi_genre_list/controller.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/keepalive.dart';
import 'package:xs/src/widgets/multi_sliver_compat/sliver_persistent_header_delegate.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/widgets/subordinate_scroll_controller.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiGenreListPage extends StatelessWidget {
  const BangumiGenreListPage({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    final ValueNotifier<double> maxShrinkOpacity = ValueNotifier(1.0);
    const String assetName = 'assets/images/no_image.svg';
    final Widget noImage = SvgPicture.asset(assetName);
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    // 设置状态栏图标的亮度
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: currentBrightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    ));
    final ValueNotifier<bool> filterPanelStatus = ValueNotifier(false);
    return ControllerBuilder(
        create: () => BangumiGenreListController(name),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            body: SafeArea(
              top: true,
              bottom: false,
              maintainBottomViewPadding: false,
              child: NestedScrollView(
                floatHeaderSlivers: true,
                body: SafeArea(
                  top: false,
                  bottom: false,
                  maintainBottomViewPadding: true,
                  child: Builder(builder: (context) {
                    final parentController =
                        PrimaryScrollController.of(context);
                    final scrollController =
                        SubordinateScrollController(parentController);
                    return KeepAliveWrapper(
                        child: NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        final pixels = notification.metrics.pixels.toInt();
                        if ((pixels - scrollHeight.value).abs() >= 50) {
                          final lastScrollStatus = scrollStatus.value;
                          if (pixels > scrollHeight.value) {
                            if (notification.depth == 0 &&
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
                        final metrics = notification.metrics;
                        if (metrics.atEdge) {
                          bool isTop = metrics.pixels == 0;
                          if (isTop) {
                          } else {
                            if (!controller.isLoading.value) {
                              controller.more();
                            }
                          }
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        displacement: 0,
                        edgeOffset: 60,
                        onRefresh: () async {
                          await controller.reload();
                        },
                        child: controller.obx(
                          (context, state) {
                            return Stack(
                              children: [
                                CustomScrollView(
                                  key: const PageStorageKey(
                                      'bangumi-genre-list'),
                                  controller: scrollController,
                                  shrinkWrap: true,
                                  slivers: [
                                    SliverOverlapInjector(
                                        handle: NestedScrollView
                                            .sliverOverlapAbsorberHandleFor(
                                                context)),
                                    SliverPadding(
                                      padding: const EdgeInsets.only(
                                          top: 10 + 35,
                                          left: 10,
                                          right: 10,
                                          bottom: 10),
                                      sliver: SliverGrid.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                  maxCrossAxisExtent: 150,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  childAspectRatio: 0.6),
                                          itemCount: state!.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                appPushNamed(
                                                    '/bangumi/${state[index].id}',
                                                    arguments: state[index]);
                                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                //   behavior: SnackBarBehavior.floating,
                                                //   margin: const EdgeInsets.only(
                                                //       bottom: 10, left: 100, right: 100),
                                                //   content: Text(state[index].title),
                                                // ));
                                              },
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.1)),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            child: Stack(
                                                              alignment:
                                                                  AlignmentDirectional
                                                                      .bottomCenter,
                                                              // fit: StackFit.expand,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(7),
                                                                  ),
                                                                  child: state[
                                                                              index]
                                                                          .image
                                                                          .isEmpty
                                                                      ? noImage
                                                                      : Image
                                                                          .network(
                                                                          state[index]
                                                                              .image,
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            return noImage;
                                                                          },
                                                                        ),
                                                                ),
                                                                Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          minWidth:
                                                                              double.infinity),
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      top: 50,
                                                                      bottom: 5,
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                          begin:
                                                                              Alignment.bottomCenter,
                                                                          end: Alignment.topCenter,
                                                                          stops: const [
                                                                        0,
                                                                        1
                                                                      ],
                                                                          colors: [
                                                                        Colors
                                                                            .black
                                                                            .withAlpha(150),
                                                                        Colors
                                                                            .transparent
                                                                      ])),
                                                                  child: Text(
                                                                    state[index]
                                                                            .status
                                                                            .isEmpty
                                                                        ? '敬请期待'
                                                                        : state[index].status ==
                                                                                'released'
                                                                            ? '全1集'
                                                                            : state[index].status == 'finale'
                                                                                ? '全${state[index].episodesTotal}集'
                                                                                : '更新至第${state[index].episode}集',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                                Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      appPushNamed(
                                                                          '/bangumi/${state[index].id}',
                                                                          arguments:
                                                                              state[index]);
                                                                      // ScaffoldMessenger.of(context)
                                                                      //     .showSnackBar(SnackBar(
                                                                      //   behavior:
                                                                      //       SnackBarBehavior.floating,
                                                                      //   margin: const EdgeInsets.only(
                                                                      //       bottom: 10,
                                                                      //       left: 100,
                                                                      //       right: 100),
                                                                      //   content:
                                                                      //       Text(state[index].title),
                                                                      // ));
                                                                      // appPushNamed('/thread/${state[index].id}',
                                                                      //     arguments: state[index]);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        state[index].title,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Opacity(
                                                        opacity: 0.7,
                                                        child: Text(
                                                          state[index].tagline,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                    SliverToBoxAdapter(
                                        child: ListenableBuilder(
                                            listenable: controller.isLoading,
                                            builder: (context, _) {
                                              return SizedBox(
                                                  height: 5,
                                                  child: Visibility(
                                                    visible: controller
                                                        .isLoading.value,
                                                    maintainSize: false,
                                                    maintainSemantics: false,
                                                    maintainAnimation: false,
                                                    child: LinearProgressIndicator(
                                                        backgroundColor:
                                                            Colors.grey,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary)),
                                                  ));
                                            }))
                                  ],
                                ),
                                Positioned(
                                  top: MediaQuery.of(context).padding.top + 50,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Theme.of(context)
                                                        .dividerColor
                                                        .withAlpha(20)))),
                                        height: 35,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Material(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: InkWell(
                                            onTap: () {
                                              filterPanelStatus.value =
                                                  (!filterPanelStatus.value);
                                            },
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${controller.typeList[controller.typeSelected.value]} · ${controller.langList[controller.langSelected.value]} · ${controller.yearList[controller.yearSelected.value]}',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListenableBuilder(
                                          listenable: filterPanelStatus,
                                          builder: (context, _) {
                                            return Offstage(
                                              offstage:
                                                  !filterPanelStatus.value,
                                              child: Stack(
                                                children: [
                                                  GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () {
                                                      filterPanelStatus.value =
                                                          (!filterPanelStatus
                                                              .value);
                                                    },
                                                    onVerticalDragStart:
                                                        (drag) {
                                                      filterPanelStatus.value =
                                                          (!filterPanelStatus
                                                              .value);
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      color: Colors.black12,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 165,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // 类型
                                                        Container(
                                                          color: Colors
                                                              .transparent,
                                                          height: 40,
                                                          child: ListView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            children: controller
                                                                .typeList
                                                                .entries
                                                                .map((e) {
                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                  child:
                                                                      Material(
                                                                    color: controller.typeSelect.value ==
                                                                            e
                                                                                .key
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                            .withAlpha(
                                                                                30)
                                                                        : Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        controller
                                                                            .typeSelect
                                                                            .value = e.key;
                                                                        debugPrint(
                                                                            e.value);
                                                                      },
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5),
                                                                          child: Text(
                                                                            e.value,
                                                                            style:
                                                                                TextStyle(fontWeight: e.key.isEmpty ? FontWeight.bold : FontWeight.normal),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        // 语言
                                                        Container(
                                                          color: Colors
                                                              .transparent,
                                                          height: 40,
                                                          child: ListView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            children: controller
                                                                .langList
                                                                .entries
                                                                .map((e) {
                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                  child:
                                                                      Material(
                                                                    color: controller.langSelect.value ==
                                                                            e
                                                                                .key
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                            .withAlpha(
                                                                                30)
                                                                        : Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        controller
                                                                            .langSelect
                                                                            .value = e.key;
                                                                        debugPrint(
                                                                            e.value);
                                                                      },
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5),
                                                                          child: Text(
                                                                            e.value,
                                                                            style:
                                                                                TextStyle(fontWeight: e.key.isEmpty ? FontWeight.bold : FontWeight.normal),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        // 年份
                                                        Container(
                                                          color: Colors
                                                              .transparent,
                                                          height: 40,
                                                          child: ListView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            children: controller
                                                                .yearList
                                                                .entries
                                                                .map((e) {
                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                  child:
                                                                      Material(
                                                                    color: controller.yearSelect.value ==
                                                                            e
                                                                                .key
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                            .withAlpha(
                                                                                30)
                                                                        : Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        controller
                                                                            .yearSelect
                                                                            .value = e.key;
                                                                        debugPrint(
                                                                            e.value);
                                                                      },
                                                                      child: Container(
                                                                          padding: const EdgeInsets.all(5),
                                                                          child: Text(
                                                                            e.value,
                                                                            style:
                                                                                TextStyle(fontWeight: e.key.isEmpty ? FontWeight.bold : FontWeight.normal),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        // const SizedBox(height: 5),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                          child: Material(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary
                                                                .withAlpha(30),
                                                            child: InkWell(
                                                              onTap: () {
                                                                filterPanelStatus
                                                                        .value =
                                                                    (false);
                                                                controller
                                                                    .filter();
                                                                scrollController
                                                                    .jumpTo(0);
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(7),
                                                                child: Center(
                                                                  child: Text(
                                                                    '筛选',
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          })
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          onError: (context, error) {
                            return const Text('加载失败');
                          },
                        ),
                      ),
                    ));
                  }),
                ),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverPersistentHeader(
                          pinned: true,
                          delegate: CustomSliverPersistentHeaderDelegate(
                            onMaxOffset: (offset) {
                              maxShrinkOpacity.value = (1 - offset);
                            },
                            child: Material(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: CustomDragToMoveArea(
                                child: ListenableBuilder(
                                    listenable: Listenable.merge(
                                        [controller.genre, maxShrinkOpacity]),
                                    builder: (context, _) {
                                      return Opacity(
                                        opacity: maxShrinkOpacity.value,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          constraints: const BoxConstraints(
                                              minHeight: 50),
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                '分类 - ${controller.genre.value}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              )),
                                              closeWindowButton(
                                                  positioned: false,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )),
                    ),
                  ];
                },
              ),
            ),
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
