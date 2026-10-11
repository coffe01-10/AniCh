import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xs/src/utils/utils.dart';

/// 播放历史服务。
///
/// 历史记录以番剧 id 为键持久化在 `playHistory` 存储桶中：
///
/// ```json
/// {
///   "id": 1, "title": "...", "date": 1710000000000, "image": "...",
///   "episodes": [
///     {"episode": 1, "title": "第1集 ...", "position": 123,
///      "date": 1710000000000, "image": "..."}
///   ]
/// }
/// ```
///
/// 替代原 `PlayHistoryStorage`。
class PlayHistoryService {
  PlayHistoryService._();

  static final PlayHistoryService instance = PlayHistoryService._();

  static const String boxName = 'playHistory';

  final GetStorage _box = GetStorage(boxName);

  /// 全部历史条目（Map 结构，按写入顺序）。
  final ValueNotifier<List<dynamic>> history = ValueNotifier<List<dynamic>>([]);

  void init() {
    history.value = _box.getValues().toList();
  }

  /// 写入/更新一条历史记录。
  void save(int id, Map<dynamic, dynamic> info) {
    _box.write('$id', info);
    history.value = _box.getValues().toList();
  }

  /// 清空历史记录（先弹确认框）。
  Future<void> clean() async {
    final result = await Utils.showAlertDialog('确定要清空观看记录吗?', title: '清空观看记录');
    if (!result) {
      return;
    }
    _box.erase();
    history.value = _box.getValues().toList();
  }

  /// 删除单个番剧的历史记录。
  void remove(dynamic id) {
    _box.remove(id.toString());
    history.value = _box.getValues().toList();
  }

  /// 取得某集的上次播放进度（秒）。
  int getLastPosition(dynamic id, dynamic episode) {
    final record = _box.read(id.toString());
    if (record != null) {
      final thisEpisode = (record['episodes'] as List).firstWhere(
        (e) => e['episode'].toString() == episode.toString(),
        orElse: () => {},
      );
      return int.parse((thisEpisode['position'] ?? 0).toString());
    }
    return 0;
  }
}
