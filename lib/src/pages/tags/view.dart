import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xs/src/pages/tags/controller.dart';
import 'package:xs/src/pages/tags/views/all.dart';
import 'package:xs/src/pages/tags/views/artwork.dart';
import 'package:xs/src/pages/tags/views/cosplay.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key, required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/images/no_image.svg';
    final Widget noImage = SvgPicture.asset(assetName);
    final ValueNotifier<double> appBarHeight = ValueNotifier(1.0);
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    return ControllerBuilder(
        create: () => TagsController(tag),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            body: controller.obx((context, state) {
              return SafeArea(
                top: false,
                bottom: false,
                maintainBottomViewPadding: false,
                child: ListenableBuilder(
                    listenable: Listenable.merge([
                      appBarHeight,
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
                              final pixels =
                                  notification.metrics.pixels.toInt();
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
                                  TagsAllView(
                                      tag: tag,
                                      active: controller.tabIndex.value == 0),
                                  TagsArtworkView(
                                      tag: tag,
                                      active: controller.tabIndex.value == 1),
                                  TagsCosplayView(
                                      tag: tag,
                                      active: controller.tabIndex.value == 2)
                                ]),
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
                                          opacity: min(
                                              appBarHeight.value.abs(), 1.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text('${state.name}')),
                                            ],
                                          ),
                                        ));
                                      }),
                                  actions: [
                                    closeWindowButton(positioned: false)
                                  ],
                                  pinned: true,
                                  automaticallyImplyLeading: false,
                                  floating: true,
                                  snap: false,
                                  expandedHeight: 245,
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
                                        appBarHeight.value = (1 -
                                            max(
                                                    0,
                                                    constraints.biggest.height -
                                                        145 -
                                                        MediaQuery.of(context)
                                                            .padding
                                                            .top) /
                                                100);
                                      });
                                      return ListenableBuilder(
                                          listenable: appBarHeight,
                                          builder: (context, _) {
                                            return Opacity(
                                              opacity: min(
                                                  1.0,
                                                  max(
                                                      (appBarHeight.value - 1)
                                                          .abs(),
                                                      0.0)),
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
                                                                Colors
                                                                    .transparent
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
                                                            state.image
                                                                    .isNotEmpty
                                                                ? Image.network(
                                                                    '${state.image}',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : noImage,
                                                            BackdropFilter(
                                                              filter: ImageFilter
                                                                  .blur(
                                                                      sigmaX:
                                                                          10,
                                                                      sigmaY:
                                                                          10),
                                                              child:
                                                                  Container(),
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
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 120,
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        1 / 1,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      child: state
                                                                              .image
                                                                              .isNotEmpty
                                                                          ? Image
                                                                              .network(
                                                                              '${state.image}',
                                                                              fit: BoxFit.cover,
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
                                                                      Text(
                                                                        '${state.name}',
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            const TextStyle(
                                                                          height:
                                                                              0,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      state.translate
                                                                              .isNotEmpty
                                                                          ? Text(
                                                                              state.translate,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.start,
                                                                              style: const TextStyle(height: 0, fontSize: 12, fontWeight: FontWeight.bold),
                                                                            )
                                                                          : Container(),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            60,
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          child:
                                                                              Text(
                                                                            '简介: ${state.desc.isNotEmpty ? state.desc : "大约有${state.count}个与 ⌈${state.name}⌋ 相关的作品。"}',
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            style:
                                                                                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Offstage(
                                                              offstage:
                                                                  appBarHeight
                                                                          .value >
                                                                      0.7,
                                                              child: SizedBox(
                                                                height: 60,
                                                                child: ListView
                                                                    .builder(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemBuilder:
                                                                      (itemBuilder,
                                                                          index) {
                                                                    return Container(
                                                                      constraints:
                                                                          const BoxConstraints(
                                                                              minWidth: 100),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10,
                                                                          right:
                                                                              5),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(7),
                                                                        child:
                                                                            Material(
                                                                          color: Colors
                                                                              .black
                                                                              .withAlpha(20),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              appPushReplacementNamed('/tags', arguments: {
                                                                                'tag': state.related[index].name
                                                                              });
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(5),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  state.related[index].translate.isNotEmpty
                                                                                      ? Text(
                                                                                          state.related[index].translate,
                                                                                          maxLines: 1,
                                                                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                                                        )
                                                                                      : Container(),
                                                                                  Text(state.related[index].name, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  itemCount: state
                                                                      .related
                                                                      .length,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // centerTitle: true,
                                                  collapseMode:
                                                      CollapseMode.pin,
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
                                      child: TabBar(
                                        controller: controller.tabController,
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
                                ),
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(context),
                              ),
                            ];
                          },
                        ),
                      );
                    }),
              );
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
