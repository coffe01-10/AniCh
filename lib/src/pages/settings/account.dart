import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xs/src/pages/settings/controller.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/color.dart';
import 'package:xs/src/widgets/drag_to_move_bar.dart';
import 'package:xs/src/widgets/multi_sliver_compat/sliver_persistent_header_delegate.dart';
import 'package:xs/src/widgets/navbar.dart';
import 'package:xs/src/widgets/settings/settings_action.dart';
import 'package:xs/src/widgets/settings/settings_card.dart';
import 'package:xs/src/app/navigator_key.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/widgets/controller_builder.dart';

const String assetName = 'assets/images/no_image.svg';
final Widget noImage = SvgPicture.asset(assetName);

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    GetStorage box = GetStorage();
    final user = box.read('user');
    final ValueNotifier<int> scrollHeight = ValueNotifier(0);
    final ValueNotifier<bool> scrollStatus = ValueNotifier(true);
    final ValueNotifier<double> maxShrinkOpacity = ValueNotifier(1.0);
    return ControllerBuilder(
        create: () => AccountSettingsPageController(),
        builder: (context, controller) {
          return Scaffold(
            extendBody: true,
            backgroundColor: Theme.of(context).dialogBackgroundColor,
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
                      SliverToBoxAdapter(
                        child: ListView(
                          shrinkWrap: true,
                          padding: AppStyle.edgeInsetsA12,
                          children: [
                            Padding(
                              padding: AppStyle.edgeInsetsA12.copyWith(top: 50),
                              child: Text(
                                '修改资料',
                                style:
                                    Theme.of(appContext).textTheme.titleSmall,
                              ),
                            ),
                            SettingsCard(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SettingsCard(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SettingsAction(
                                          title: '头像',
                                          trailing: Container(
                                            padding: const EdgeInsets.all(5),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                color: ColorUtil.fromHex(
                                                    user['color']),
                                                child: user['avatar'] != null
                                                    ? Image.network(
                                                        user['avatar'],
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return noImage;
                                                        },
                                                      )
                                                    : Center(
                                                        child: Text(
                                                          user['name']
                                                              .substring(0, 1),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            SmartDialog.showToast('功能未实现');
                                          },
                                        ),
                                        AppStyle.divider,
                                        SettingsAction(
                                          title: '用户名',
                                          value: user['name'],
                                          onTap: () {
                                            SmartDialog.showToast('功能未实现');
                                          },
                                        ),
                                        AppStyle.divider,
                                        SettingsAction(
                                          title: '密码',
                                          value: '******',
                                          onTap: () {
                                            SmartDialog.showToast('功能未实现');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppStyle.vGap12,
                            Padding(
                              padding: AppStyle.edgeInsetsA12,
                              child: Text(
                                '登录状态',
                                style:
                                    Theme.of(appContext).textTheme.titleSmall,
                              ),
                            ),
                            SettingsCard(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SettingsCard(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SettingsAction(
                                          title: '退出登录',
                                          color: Colors.red,
                                          onTap: () {
                                            box.remove('user');
                                            box.remove('token');
                                            appPushReplacementNamed('/');
                                            SmartDialog.showToast('已退出登录');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                              color: Theme.of(context).dialogBackgroundColor,
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
                                              .dialogBackgroundColor,
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                child: Text(
                                                  '账号管理',
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
