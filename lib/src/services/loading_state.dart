import 'package:flutter/material.dart';

/// 异步数据加载状态。
enum LoadStatus {
  /// 尚未发起请求
  initial,

  /// 请求中（首次加载）
  loading,

  /// 加载成功
  success,

  /// 数据为空
  empty,

  /// 加载失败
  error,
}

/// 单数据加载控制器。
///
/// 作为原 GetX `StateMixin`/`obx` 写法的替代，
/// 以不可变状态字段 + [ChangeNotifier] 驱动界面刷新。
///
/// - [data] 当前数据，加载中/失败时保留上一份；
/// - [error] 最近一次失败信息；
/// - [isEmpty] 与 GetX 的 `status.isEmpty` 语义一致：
///   加载成功且数据为空时为 `true`，用于触发空态 UI。
class DataController<T> extends ChangeNotifier {
  LoadStatus _status = LoadStatus.initial;
  T? _data;
  String _error = '';
  bool _isEmpty = false;

  LoadStatus get status => _status;
  T? get data => _data;
  String get error => _error;
  bool get isEmpty => _isEmpty;

  bool get isLoading => _status == LoadStatus.loading;
  bool get isSuccess => _status == LoadStatus.success;
  bool get isError => _status == LoadStatus.error;

  /// 进入加载态，可选地清空旧数据。
  @protected
  void beginLoading({bool keepData = true}) {
    _status = LoadStatus.loading;
    _isEmpty = false;
    if (!keepData) _data = null;
    notifyListeners();
  }

  /// 写入成功结果并刷新界面。
  @protected
  void succeed(T? value, {bool isEmpty = false}) {
    _data = value;
    _status = LoadStatus.success;
    _isEmpty = isEmpty;
    _error = '';
    notifyListeners();
  }

  /// 记录失败并刷新界面。
  @protected
  void fail(Object e) {
    _status = LoadStatus.error;
    _error = e.toString();
    notifyListeners();
  }

  /// 手动复位为初始态。
  void reset() {
    _status = LoadStatus.initial;
    _isEmpty = false;
    _error = '';
    _data = null;
    notifyListeners();
  }
}

/// 分页列表数据源返回的一页数据。
class PagedResult<T> {
  const PagedResult({required this.items, required this.hasMore});

  /// 当前页的数据项。
  final List<T> items;

  /// 后端是否还有更多数据。
  final bool hasMore;
}

/// 分页列表控制器。
///
/// 统一封装项目中大量重复的
/// “加载状态 + 下拉刷新 + 触底加载更多”列表逻辑，
/// 替代原 GetX `StateMixin` + `RxBool` 组合。
///
/// [fetcher] 接收上次请求的 skip 游标并返回一页数据；
/// [skipOf] 用于从最后一项推导游标（例如按条目 `id`），
/// 缺省时使用 `items.length` 作为 skip。
class PagedListController<T> extends ChangeNotifier {
  PagedListController({
    required Future<PagedResult<T>> Function(int skip) fetcher,
    int Function(T item)? skipOf,
    bool loadMore = true,
    Future<PagedResult<T>> Function()? refresher,
  })  : _fetcher = fetcher,
        _skipOf = skipOf,
        _loadMoreEnabled = loadMore,
        _refresher = refresher;

  final Future<PagedResult<T>> Function(int skip) _fetcher;
  final int Function(T item)? _skipOf;

  /// 是否允许触底加载更多（部分接口是单页数据）。
  final bool _loadMoreEnabled;

  /// 可选的独立刷新逻辑（例如清空后重新拉取）。
  final Future<PagedResult<T>> Function()? _refresher;

  LoadStatus _status = LoadStatus.initial;
  final List<T> _items = [];
  String _error = '';
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _loading = false;

  LoadStatus get status => _status;
  List<T> get items => List.unmodifiable(_items);
  String get error => _error;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  bool get isLoading => _status == LoadStatus.loading;
  bool get isSuccess => _status == LoadStatus.success;
  bool get isError => _status == LoadStatus.error;
  bool get isEmpty => _status == LoadStatus.empty;

  /// 首屏加载：状态机切换为 loading。
  Future<void> load() => _loadInternal(clear: false);

  /// 下拉刷新：清空数据后重新拉取第一页。
  Future<void> reload() => _loadInternal(clear: true);

  Future<void> _loadInternal({required bool clear}) async {
    if (_loading) return;
    _loading = true;
    if (!clear && _items.isEmpty) {
      _status = LoadStatus.loading;
      notifyListeners();
    }
    try {
      final PagedResult<T> page = _refresher != null
          ? await _refresher!()
          : await _fetcher(0);
      _items
        ..clear()
        ..addAll(page.items);
      _hasMore = page.hasMore;
      _status = _items.isEmpty ? LoadStatus.empty : LoadStatus.success;
      _error = '';
    } catch (e) {
      if (_items.isEmpty) {
        _status = LoadStatus.error;
      }
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 触底加载更多。
  Future<void> loadMore() async {
    if (!_loadMoreEnabled ||
        _loading ||
        _isLoadingMore ||
        !_hasMore ||
        _items.isEmpty) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();
    try {
      final skip = _skipOf?.call(_items.last) ?? _items.length;
      final page = await _fetcher(skip);
      _items.addAll(page.items);
      _hasMore = page.hasMore;
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}

/// 通用“数据 + 状态”页面控制器。
///
/// 替代原 GetX `GetxController with StateMixin<T>` 组合：
/// [change] 与旧 `change(data, status: RxStatus.x())` 签名保持一致，
/// [obx] 与旧 `controller.obx(...)` 用法一致（builder 多一个 context 参数）。
class LoadableController<T> extends ChangeNotifier {
  LoadStatus status = LoadStatus.initial;
  T? data;
  Object? error;

  /// 更新数据与状态并刷新界面（对应旧 `change`）。
  void change(T? value, {required LoadStatus status, Object? error}) {
    data = value;
    this.status = status;
    this.error = error;
    notifyListeners();
  }

  /// 状态驱动的界面构建（对应旧 `controller.obx`）。
  ///
  /// [builder] 仅在 [LoadStatus.success] 时调用；
  /// [onLoading]/[onEmpty] 直接给 widget，[onError] 接收 error 字符串。
  Widget obx(
    Widget Function(BuildContext context, T? state) builder, {
    Widget? onLoading,
    Widget? onEmpty,
    Widget Function(BuildContext context, Object? error)? onError,
  }) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) {
        switch (status) {
          case LoadStatus.loading:
          case LoadStatus.initial:
            return onLoading ??
                const Center(child: CircularProgressIndicator());
          case LoadStatus.empty:
            return onEmpty ?? const Center(child: Text('暂无数据'));
          case LoadStatus.error:
            return onError?.call(context, error) ??
                Center(child: Text('加载失败: $error'));
          case LoadStatus.success:
            return builder(context, data);
        }
      },
    );
  }
}
