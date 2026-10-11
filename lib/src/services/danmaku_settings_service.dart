import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

/// 弹幕设置服务。
///
/// 持久化并广播弹幕显示相关的用户偏好。
/// 替代原 `DanmakuSettingsStorage` 的 `Rx` 字段。
class DanmakuSettingsService {
  DanmakuSettingsService._();

  static final DanmakuSettingsService instance = DanmakuSettingsService._();

  final GetStorage _box = GetStorage();
  final TextEditingController textEditingController = TextEditingController();

  /// 弹幕总开关。
  final ValueNotifier<bool> danmakuEnable = ValueNotifier<bool>(true);

  /// 弹幕显示区域（0.1 ~ 1.0）。
  final ValueNotifier<double> danmakuArea = ValueNotifier<double>(1.0);

  /// 弹幕不透明度（0.1 ~ 1.0）。
  final ValueNotifier<double> danmakuOpacity = ValueNotifier<double>(1.0);

  /// 弹幕字体大小。
  final ValueNotifier<double> danmakuSize = ValueNotifier<double>(14.0);

  /// 弹幕滚动速度（持续秒数，越小越快）。
  final ValueNotifier<double> danmakuSpeed = ValueNotifier<double>(8.0);

  /// 哔哩哔哩弹幕源开关。
  final ValueNotifier<bool> bilibiliDanmakuEnable = ValueNotifier<bool>(true);

  /// 哔哩哔哩（港澳台）弹幕源开关。
  final ValueNotifier<bool> bilibiliHmtDanmakuEnable =
      ValueNotifier<bool>(true);

  /// 腾讯视频弹幕源开关。
  final ValueNotifier<bool> qqDanmakuEnable = ValueNotifier<bool>(true);

  void init() {
    danmakuEnable.value = _box.read('danmakuEnable') ?? true;
    danmakuArea.value = (_box.read('danmakuArea') ?? 1.0).toDouble();
    danmakuOpacity.value = (_box.read('danmakuOpacity') ?? 1.0).toDouble();
    danmakuSize.value = (_box.read('danmakuSize') ?? 14.0).toDouble();
    danmakuSpeed.value = (_box.read('danmakuSpeed') ?? 8.0).toDouble();
    bilibiliDanmakuEnable.value = _box.read('bilibiliDanmakuEnable') ?? true;
    bilibiliHmtDanmakuEnable.value =
        _box.read('bilibiliHmtDanmakuEnable') ?? true;
    qqDanmakuEnable.value = _box.read('qqDanmakuEnable') ?? true;
  }

  void setDanmakuEnable(bool value) =>
      _write(danmakuEnable, 'danmakuEnable', value);

  void setDanmakuArea(double value) =>
      _write(danmakuArea, 'danmakuArea', value);

  void setDanmakuOpacity(double value) =>
      _write(danmakuOpacity, 'danmakuOpacity', value);

  void setDanmakuSize(double value) =>
      _write(danmakuSize, 'danmakuSize', value);

  void setDanmakuSpeed(double value) =>
      _write(danmakuSpeed, 'danmakuSpeed', value);

  void setBilibiliDanmakuEnable(bool value) =>
      _write(bilibiliDanmakuEnable, 'bilibiliDanmakuEnable', value);

  void setBilibiliHmtDanmakuEnable(bool value) =>
      _write(bilibiliHmtDanmakuEnable, 'bilibiliHmtDanmakuEnable', value);

  void setQQDanmakuEnable(bool value) =>
      _write(qqDanmakuEnable, 'qqDanmakuEnable', value);

  void _write<T>(ValueNotifier<T> notifier, String key, T value) {
    notifier.value = value;
    _box.write(key, value);
  }
}
