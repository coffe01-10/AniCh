import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xs/src/app/app.dart';
import 'package:xs/src/config.dart';
import 'package:xs/src/services/danmaku_settings_service.dart';
import 'package:xs/src/services/danmaku_shield_service.dart';
import 'package:xs/src/services/play_history_service.dart';
import 'package:xs/src/services/session_service.dart';
import 'package:xs/src/services/theme_service.dart';
import 'package:xs/src/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await GetStorage.init();
  await GetStorage.init(PlayHistoryService.boxName);
  await initWindow();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // 状态栏透明
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // 图片缓存
  PaintingBinding.instance.imageCache.maximumSize = 1000000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;
  // 配置初始化
  await AppConfig.init();
  // 主题初始化
  ThemeService.instance.init();
  // 历史记录初始化
  PlayHistoryService.instance.init();
  // 弹幕设置初始化
  DanmakuSettingsService.instance.init();
  // 初始化弹幕屏蔽词
  DanmakuShieldService.instance.init();
  runApp(const AniChApp());

  // 检测更新 + 恢复用户会话（不阻塞首帧）
  Utils.checkUpdate();
  SessionService.instance.init();
}

Future<void> initWindow() async {
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return;
  }
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
      size: Size(600, 800),
      title: '像宿',
      titleBarStyle: TitleBarStyle.hidden,
      skipTaskbar: false,
      windowButtonVisibility: false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
