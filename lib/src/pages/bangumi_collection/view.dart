import 'package:flutter/material.dart';
import 'package:xs/src/pages/bangumi_collection/controller.dart';
import 'package:xs/src/pages/bangumi_collection/views/watch.dart';
import 'package:xs/src/pages/bangumi_collection/views/watched.dart';
import 'package:xs/src/pages/bangumi_collection/views/wish.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/multi_sliver_compat/sliver_persistent_header_delegate.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiCollectionPage extends StatelessWidget {
  const BangumiCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    final ValueNotifier<double> maxShrinkOpacity = ValueNotifier(1.0);
    return ControllerBuilder(
        create: () => BangumiCollectionController(),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            body: SafeArea(
              top: true,
              bottom: false,
              maintainBottomViewPadding: false,
              child: DefaultTabController(
                length: controller.tabs.length,
                child: NestedScrollView(
                  floatHeaderSlivers: true,
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
                        BangumiWishCollectionView(
                          active: controller.tabIndex.value == 0,
                        ),
                        BangumiWatchCollectionView(
                          active: controller.tabIndex.value == 1,
                        ),
                        BangumiWatchedCollectionView(
                          active: controller.tabIndex.value == 2,
                        ),
                      ],
                    ),
                  ),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                          floating: true,
                          delegate: CustomSliverPersistentHeaderDelegate(
                            onMaxOffset: (offset) {
                              maxShrinkOpacity.value = (1 - offset);
                            },
                            child: Material(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: CustomDragToMoveArea(
                                child: ListenableBuilder(
                                    listenable: maxShrinkOpacity,
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
                                              const Expanded(
                                                child: Text(
                                                  '追番列表',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
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
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverPersistentHeader(
                            pinned: true,
                            delegate: CustomSliverPersistentHeaderDelegate(
                              maxExtent: 40,
                              minExtent: 40,
                              child: PreferredSize(
                                preferredSize: const Size.fromHeight(40),
                                child: Material(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: CustomDragToMoveArea(
                                    child: TabBar(
                                      controller: controller.tabController,
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      indicatorSize: TabBarIndicatorSize.label,
                                      dividerColor: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainer,
                                      tabs: controller.tabs,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ];
                  },
                ),
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
