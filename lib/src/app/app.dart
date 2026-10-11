import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xs/src/app/navigator_key.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/services/theme_service.dart';
import 'package:xs/src/utils/listen_fourth_button.dart';
import 'package:xs/src/widgets/app_loadding_widget.dart';

/// 应用根组件。
///
/// 组合：
/// - [DynamicColorBuilder] 动态取色
/// - [ThemeService] 主题设置订阅（亮暗模式/主题色/动态取色）
/// - [MaterialApp] + [FlutterSmartDialog]
/// - 桌面端 ESC 退出全屏、鼠标侧键返回
class AniChApp extends StatelessWidget {
  const AniChApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([
        theme.themeMode,
        theme.isDynamic,
        theme.styleColor,
      ]),
      builder: (context, _) {
        final isDynamicColor = theme.isDynamic.value;
        final styleColor = Color(theme.styleColor.value);
        return DynamicColorBuilder(
          builder: (lightDynamicColorScheme, darkDynamicColorScheme) {
            ColorScheme? lightColorScheme;
            ColorScheme? darkColorScheme;
            if (lightDynamicColorScheme != null &&
                darkDynamicColorScheme != null &&
                isDynamicColor) {
              lightColorScheme = lightDynamicColorScheme;
              darkColorScheme = darkDynamicColorScheme;
            } else {
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: styleColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: styleColor,
                brightness: Brightness.dark,
              );
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              themeMode: ThemeMode.values[theme.themeMode.value],
              theme: ThemeData(
                fontFamily: 'Ubuntu',
                brightness: Brightness.light,
                colorScheme: lightColorScheme,
                scaffoldBackgroundColor: Colors.white,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Ubuntu',
                brightness: Brightness.dark,
                colorScheme: darkColorScheme,
                scaffoldBackgroundColor: Colors.black,
                useMaterial3: true,
              ),
              initialRoute: AppRoutes.home,
              onGenerateRoute: AppRouter.onGenerateRoute,
              scrollBehavior: const AppScrollBehavior(),
              navigatorObservers: [FlutterSmartDialog.observer],
              builder: FlutterSmartDialog.init(
                loadingBuilder: (msg) => const AppLoaddingWidget(),
                // 字体大小不跟随系统变化
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: Stack(
                    children: [
                      // 侧键返回
                      RawGestureDetector(
                        excludeFromSemantics: true,
                        gestures: <Type, GestureRecognizerFactory>{
                          FourthButtonTapGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                  FourthButtonTapGestureRecognizer>(
                            () => FourthButtonTapGestureRecognizer(),
                            (FourthButtonTapGestureRecognizer instance) {
                              instance.onTapDown =
                                  (TapDownDetails details) async {
                                // 如果处于全屏状态，退出全屏
                                if (!Platform.isAndroid && !Platform.isIOS) {
                                  if (await windowManager.isFullScreen()) {
                                    await windowManager.setFullScreen(false);
                                    return;
                                  }
                                }
                                appNavigatorKey.currentState?.maybePop();
                              };
                            },
                          ),
                        },
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (KeyEvent event) async {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.escape) {
                              // ESC 退出全屏
                              if (!Platform.isAndroid && !Platform.isIOS) {
                                if (await windowManager.isFullScreen()) {
                                  await windowManager.setFullScreen(false);
                                  return;
                                }
                              }
                            }
                          },
                          child: child!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 允许鼠标拖拽滚动。
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
