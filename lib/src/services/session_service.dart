import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xs/src/apis/account.dart';
import 'package:xs/src/app/navigator_key.dart';

/// 登录会话服务。
///
/// 统一管理 `token`/`user` 的读写，并提供退出登录、
/// 路由鉴权判断等能力，替代原 `AuthMiddleware` + 散落的
/// `GetStorage().read('token')` 调用。
class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  final GetStorage _box = GetStorage();

  /// 当前用户信息（服务端 proto 转 JSON 后的 Map）。
  final ValueNotifier<Map<dynamic, dynamic>?> user =
      ValueNotifier<Map<dynamic, dynamic>?>(null);

  /// 是否已登录。
  bool get isLoggedIn => token != null;

  /// 当前 token（未登录为 `null`）。
  String? get token => _box.read('token');

  /// 启动时恢复会话。
  ///
  /// 已有 token 时调用 [AccountApi.init] 拉取最新用户信息。
  Future<void> init() async {
    user.value = _box.read('user');
    if (token != null) {
      try {
        await (AccountApi.init() as Future);
      } catch (_) {
        // 网络异常不阻塞启动，沿用本地缓存
      }
      // init 接口可能刷新了用户信息，再读一次本地缓存
      user.value = _box.read('user');
    }
  }

  /// 登录/注册成功后保存会话。
  void save({required String token, required Map<dynamic, dynamic> user}) {
    _box.write('token', token);
    _box.write('user', user);
    this.user.value = user;
  }

  /// 退出登录并回到首页。
  Future<void> logout() async {
    _box.remove('user');
    _box.remove('token');
    user.value = null;
    await appNavigator?.pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
    SmartDialog.showToast('已退出登录');
  }
}
