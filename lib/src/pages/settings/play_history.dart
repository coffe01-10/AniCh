import 'package:flutter/material.dart';
import 'package:xs/src/pages/settings/controller.dart';
import 'package:xs/src/services/play_history_service.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/time.dart';
import 'package:xs/src/utils/utils.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/multi_sliver_compat/sliver_persistent_header_delegate.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class PlayHistoryPage extends StatelessWidget {
  const PlayHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    PlayHistoryService.instance.init();
    try {
      PlayHistoryService.instance.history.value.sort((a, b) =>
          int.parse(b['date'].toString())
              .compareTo(int.parse(a['date'].toString())));
    } catch (e) {
      debugPrint(e.toString());
    }
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    final ValueNotifier<double> maxShrinkOpacity = ValueNotifier(1.0);
    return ControllerBuilder(
        create: () => PlayHistorySettingsPageController(),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            body: SafeArea(
              top: true,
              bottom: false,
              maintainBottomViewPadding: false,
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
                  child: CustomScrollView(
                    shrinkWrap: true,
                    controller: ScrollController(),
                    slivers: [
                      SliverPadding(
                          padding: AppStyle.edgeInsetsA12.copyWith(top: 50)),
                      SliverToBoxAdapter(
                        child: ListenableBuilder(
                          listenable: PlayHistoryService.instance.history,
                          builder: (context, _) => ListView.builder(
                            shrinkWrap: true,
                            itemCount: PlayHistoryService
                                .instance.history.value.length,
                            itemBuilder: (_, i) {
                              final item =
                                  PlayHistoryService.instance.history.value[i];
                              try {
                                item['episodes'].sort((a, b) =>
                                    int.parse(b['date'].toString()).compareTo(
                                        int.parse(a['date'].toString())));
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                              return Dismissible(
                                key: ValueKey(item['id']),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  padding: AppStyle.edgeInsetsA12,
                                  alignment: Alignment.centerRight,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await Utils.showAlertDialog(
                                      '确定要删除此记录吗?',
                                      title: '删除记录');
                                },
                                onDismissed: (_) {
                                  PlayHistoryService.instance
                                      .remove(item['id']);
                                },
                                child: InkWell(
                                  onTap: () {
                                    appPushNamed('/vod/${item['id']}',
                                        arguments: {
                                          'id': item['id'],
                                          'episode':
                                              item['episodes'].first['episode']
                                        });
                                  },
                                  onLongPress: () async {
                                    var result = await Utils.showAlertDialog(
                                        '确定要删除此记录吗?',
                                        title: '删除记录');
                                    if (!result) {
                                      return;
                                    }
                                    PlayHistoryService.instance
                                        .remove(item['id']);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: Container(
                                            color: Colors.grey,
                                            width: 120 / 1.5,
                                            height: 160 / 1.5,
                                            child: Image.network(
                                              item['image'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'],
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              item['episodes'].first['title'],
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '观看进度: ${Duration(seconds: item['episodes'].first['position']).toString().split('.').first}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              Time.dateTimeFormat(item['date']),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
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
                                                  '观看记录',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: PlayHistoryService
                                                    .instance.clean,
                                                icon: const Icon(
                                                    Icons.delete_outline),
                                                label: const Text('清空'),
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
