import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用全局配置。
///
/// 保存构建期/启动期确定的全局常量。
/// 原实现使用 GetX `RxString`，重写后改为启动期一次性赋值，
/// 运行期不再变化，因此无需可监听对象。
class AppConfig {
  AppConfig._();

  /// 后端 API 基础地址。
  static const String baseUrl = 'https://api.emmmm.eu.org';

  /// 哔哩哔哩弹幕代理地址。
  static const String bilibiliApiProxyUrl = 'https://bili-dm.emmmm.eu.org';

  /// 腾讯视频弹幕地址。
  static const String qqVideoApiUrl = 'https://dm.video.qq.com';

  /// 包信息（启动时由 [init] 填充）。
  static late PackageInfo packageInfo;

  /// 应用版本号（启动时由 [init] 填充）。
  static String version = '';

  /// 网络请求使用的 UA（启动时按平台组装）。
  static String ua = '';

  /// 从包信息初始化版本号与 UA。
  static Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    ua = '${packageInfo.packageName} ${_platformName()} $version';
  }

  static String _platformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isFuchsia) return 'Fuchsia';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'MacOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
}
