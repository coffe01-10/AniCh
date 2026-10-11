import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// 主题设置服务。
///
/// 持久化并广播主题模式、动态取色与主题色。
/// 替代原 `ThemeSettingsStorage` 的 `Rx` 字段，
/// 界面通过 `ListenableBuilder`/`ValueListenableBuilder` 订阅。
class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  static const String _keyThemeMode = 'themeMode';
  static const String _keyDynamic = 'isDynamic';
  static const String _keyStyleColor = 'styleColor';

  final GetStorage _box = GetStorage();

  /// 主题模式索引（对应 [ThemeMode.values]）。
  final ValueNotifier<int> themeMode = ValueNotifier<int>(0);

  /// 是否启用系统动态取色。
  final ValueNotifier<bool> isDynamic = ValueNotifier<bool>(true);

  /// 自定义主题色（`Color.value`）。
  final ValueNotifier<int> styleColor = ValueNotifier<int>(0xff3498db);

  /// 供调色盘展示的自定义颜色编辑控制器。
  final TextEditingController textEditingController = TextEditingController();

  /// 从本地存储恢复设置。
  void init() {
    themeMode.value = _box.read(_keyThemeMode) ?? 0;
    isDynamic.value = _box.read(_keyDynamic) ?? true;
    styleColor.value = _box.read(_keyStyleColor) ?? 0xff3498db;
  }

  /// 当前主题模式。
  ThemeMode get materialThemeMode => ThemeMode.values[themeMode.value];

  void setThemeMode(int mode) {
    themeMode.value = mode;
    _box.write(_keyThemeMode, mode);
  }

  void setIsDynamic(bool value) {
    isDynamic.value = value;
    _box.write(_keyDynamic, value);
  }

  void setStyleColor(int color) {
    styleColor.value = color;
    _box.write(_keyStyleColor, color);
  }
}
