import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:xs/src/pages/thread/controller.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/utils/color.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';
import 'package:xs/protobuf/list.pb.dart';
import 'package:xs/src/app/navigator_key.dart';

class ThreadPage extends StatelessWidget {
  const ThreadPage({super.key, required this.id, this.data});
  final int id;
  final thread_list_data_? data;

  @override
  Widget build(BuildContext context) {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    final ValueNotifier<bool> isLight =
        ValueNotifier((currentBrightness == Brightness.light));
    // final data = data;
    final selectedIndex = ValueNotifier(1);
    final ValueNotifier<String> color = ValueNotifier('#ffffff');
    final ValueNotifier<String> darkColor = ValueNotifier('#000000');
    return ControllerBuilder(
      create: () => ThreadController(id: id, preview: data),
      builder: (context, controller) {
        return Material(
          child: controller.obx((context, state) {
            color.value = (state?.images[selectedIndex.value - 1].color ?? '');
            return AnnotatedRegion(
              value: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      ColorUtil.fromHex(color.value).computeLuminance() >= 0.5
                          ? Brightness.dark
                          : Brightness.light
                  // statusBarIconBrightness: ThemeData.estimateBrightnessForColor(
                  //     ColorUtil.fromHex(color.value))
                  ),
              child: Scaffold(
                extendBody: true,
                key: const PageStorageKey<String>('thread'),
                body: Stack(children: [
                  PageView.builder(
                    itemCount: state!.images.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      selectedIndex.value = (index + 1);
                      if (isLight.value) {
                        color.value = (state.images[index].color);
                      } else {
                        color.value = (darkColor.value);
                      }
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        color: ColorUtil.fromHex(isLight.value
                            ? state.images[index].color
                            : darkColor.value),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          child: GestureDetector(
                            onTap: () {
                              showOriginal(state.images[index].original);
                            },
                            child: Image.network(state.images[index].master),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      right: 0,
                      child: CustomDragToMoveArea(
                        child: Row(children: [
                          Offstage(
                            offstage: !state.ai,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.black.withAlpha(120)),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black.withAlpha(120)),
                            child: ListenableBuilder(
                              listenable: selectedIndex,
                              builder: (context, _) => Text(
                                '$selectedIndex.value /${state.images.length}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black.withAlpha(120)),
                            child: ListenableBuilder(
                              listenable: selectedIndex,
                              builder: (context, _) => Text(
                                '${state.images[selectedIndex.value - 1].width}x${state.images[selectedIndex.value - 1].height}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    showOriginal(state
                                        .images[selectedIndex.value - 1]
                                        .original);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(120)),
                                    child: ListenableBuilder(
                                        listenable: selectedIndex,
                                        builder: (context, _) {
                                          return Text(
                                            '查看原图 (${(state.images[selectedIndex.value - 1].originalSize / 1024 / 1024).toStringAsFixed(2)}MB)',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ))
                ]),
                bottomNavigationBar: ListenableBuilder(
                    listenable: Listenable.merge(
                        [controller.collectStatus, controller.likeStatus]),
                    builder: (context, _) {
                      return NavBar(
                        children: [
                          NavItem(
                              icon: Icons.arrow_back,
                              title: '返回',
                              onTap: () => appPop()),
                          controller.likeStatus.value
                              ? NavItem(
                                  icon: Icons.thumb_up_alt,
                                  title: '取消点赞',
                                  onTap: () {
                                    controller.cancelLike();
                                  })
                              : NavItem(
                                  icon: Icons.thumb_up_off_alt,
                                  title: '点赞',
                                  onTap: () {
                                    controller.like();
                                  }),
                          controller.collectStatus.value
                              ? NavItem(
                                  icon: Icons.favorite,
                                  title: '取消收藏',
                                  onTap: () {
                                    controller.cancelCollect();
                                  })
                              : NavItem(
                                  icon: Icons.favorite_border,
                                  title: '收藏',
                                  onTap: () {
                                    controller.collect();
                                  }),
                          NavItem(
                              icon: Icons.article,
                              title: '详情',
                              onTap: () => controller.showDetailSheet(
                                  context, controller)),
                        ],
                      );
                    }),
              ),
            );
          }),
        );
      },
    );
  }

  void showOriginal(image) {
    showDialog(
      context: appContext,
      builder: (context) => Stack(
        children: [
          SizedBox(
            child: GestureDetector(
              onTap: () {
                appPop();
              },
              child: PhotoView(
                  imageProvider: NetworkImage(image),
                  loadingBuilder: (context, progress) {
                    return Center(
                      child: SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: progress == null
                              ? null
                              : progress.cumulativeBytesLoaded /
                                  (progress.expectedTotalBytes as num),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
