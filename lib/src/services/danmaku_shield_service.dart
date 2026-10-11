import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xs/src/utils/log.dart';
import 'package:xs/src/utils/utils.dart';

/// 弹幕屏蔽词服务。
///
/// 维护用户自定义屏蔽关键词（支持 `/正则/` 写法），
/// 并为弹幕加载方提供过滤能力。
class DanmakuShieldService {
  DanmakuShieldService._();

  static final DanmakuShieldService instance = DanmakuShieldService._();

  static const String storageKey = 'DanmakuShieldList';

  final GetStorage _box = GetStorage();

  /// 已保存的屏蔽关键词集合。
  final ValueNotifier<Set<String>> shieldList = ValueNotifier<Set<String>>({});

  final TextEditingController textEditingController = TextEditingController();

  /// 内置默认屏蔽规则（正则）。
  static List<String> defaultList = [];

  void init() {
    final list = _box.read(storageKey);
    if (list != null) {
      shieldList.value = list.cast<String>().toSet();
    }
  }

  /// 从输入框添加一个关键词。
  void add() {
    if (textEditingController.text.isEmpty) {
      SmartDialog.showToast('请输入关键词');
      return;
    }
    addShieldList(textEditingController.text.trim());
    textEditingController.text = '';
  }

  void remove(String item) => removeShieldList(item);

  void addShieldList(String keyword) {
    final next = {...shieldList.value, keyword};
    shieldList.value = next;
    _box.write(storageKey, next.toList());
  }

  void removeShieldList(String keyword) {
    final next = {...shieldList.value}..remove(keyword);
    shieldList.value = next;
    _box.write(storageKey, next.toList());
  }

  /// 关键词屏蔽检查：命中屏蔽返回 `false`，正常返回 `true`。
  bool shieldCheck(String str) {
    for (final keyword in shieldList.value) {
      Pattern? pattern;
      if (Utils.isRegexFormat(keyword)) {
        final removedSlash = Utils.removeRegexFormat(keyword);
        try {
          pattern = RegExp(removedSlash);
        } catch (e) {
          // 关键词在加入时应已校验，这里兜底记录
          Log.d('关键词：$keyword 正则格式错误');
        }
      } else {
        pattern = keyword;
      }
      if (pattern != null && str.contains(pattern)) {
        Log.d('关键词：$keyword\n已屏蔽消息内容：$str');
        return false;
      }
    }
    return true;
  }

  /// 使用内置默认规则过滤一组含 `content` 字段的数据项。
  ///
  /// 该函数会作为 `compute` 的回调在后台 isolate 中执行，
  /// 因此必须是静态/顶层函数。
  static List<dynamic> defaultShieldCheck(List<dynamic> data) {
    final list = <dynamic>[];
    for (final item in data) {
      final content = item.content;
      var keep = true;
      for (final keyword in defaultList) {
        final removedSlash = Utils.removeRegexFormat(keyword);
        final pattern = RegExp(removedSlash);
        if (pattern.hasMatch(content)) {
          keep = false;
          break;
        }
      }
      if (keep) {
        list.add(item);
      }
    }
    return list;
  }
}
