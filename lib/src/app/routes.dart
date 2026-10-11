import 'package:flutter/material.dart';
import 'package:xs/protobuf/list.pb.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/src/app/navigator_key.dart';
import 'package:xs/src/pages/account/change_password.dart';
import 'package:xs/src/pages/account/login.dart';
import 'package:xs/src/pages/account/register.dart';
import 'package:xs/src/pages/bangumi/view.dart';
import 'package:xs/src/pages/bangumi_collection/view.dart';
import 'package:xs/src/pages/bangumi_detail/models/bangumi_detail_model.dart';
import 'package:xs/src/pages/bangumi_detail/view.dart';
import 'package:xs/src/pages/bangumi_genre_list/view.dart';
import 'package:xs/src/pages/bangumi_mark_list/view.dart';
import 'package:xs/src/pages/bangumi_vod/view.dart';
import 'package:xs/src/pages/character/view.dart';
import 'package:xs/src/pages/download/view.dart';
import 'package:xs/src/pages/home/view.dart';
import 'package:xs/src/pages/person/view.dart';
import 'package:xs/src/pages/profile/view.dart';
import 'package:xs/src/pages/search/models/search_type.dart';
import 'package:xs/src/pages/search/view.dart';
import 'package:xs/src/pages/search_panel/view.dart';
import 'package:xs/src/pages/settings/account.dart';
import 'package:xs/src/pages/settings/danmaku.dart';
import 'package:xs/src/pages/settings/info.dart';
import 'package:xs/src/pages/settings/play_history.dart';
import 'package:xs/src/pages/settings/theme.dart';
import 'package:xs/src/pages/tags/view.dart';
import 'package:xs/src/pages/thread/view.dart';
import 'package:xs/src/pages/thread_collection/view.dart';
import 'package:xs/src/services/session_service.dart';

/// 应用路由表。
///
/// 路径与原 GetX `GetPage` 定义保持一致，保证
/// `ModalRoute.settings.name` 及深链行为不变。
abstract final class AppRoutes {
  static const String home = '/';
  static const String tags = '/tags';
  static const String login = '/login';
  static const String register = '/register';
  static const String changePassword = '/change_password';
  static const String profile = '/profile';
  static const String thread = '/thread';
  static const String bangumi = '/bangumi';
  static const String bangumiGenreList = '/bangumi_genre_list';
  static const String bangumiMarkList = '/bangumi_mark_list';
  static const String vod = '/vod';
  static const String character = '/character';
  static const String person = '/person';
  static const String searchPanel = '/search_panel';
  static const String search = '/search';
  static const String accountSettings = '/account_settings';
  static const String themeSettings = '/theme_settings';
  static const String danmakuSettings = '/danmaku_settings';
  static const String info = '/info';
  static const String playHistory = '/play_history';
  static const String bangumiCollection = '/bangumi_collection';
  static const String threadCollection = '/thread_collection';
  static const String download = '/download';
}

/// 标签页参数。
class TagsArguments {
  const TagsArguments({required this.tag});
  final String tag;
}

/// 帖子详情参数。
class ThreadArguments {
  const ThreadArguments({required this.id, this.data});
  final int id;

  /// 可选的列表项数据，用于详情页首屏展示。
  final thread_list_data_? data;
}

/// 番剧详情参数。
class BangumiDetailArguments {
  const BangumiDetailArguments({required this.id, this.data});
  final int id;
  final BangumiDetailModel? data;
}

/// 播放页参数。
class VodArguments {
  const VodArguments({
    required this.id,
    this.episode,
    this.data,
    this.episodes,
  });
  final int id;
  final int? episode;
  final BangumiDetailModel? data;
  final List<bangumi_episodes_data_>? episodes;
}

/// 番剧分类/标签列表页参数。
class BangumiTagListArguments {
  const BangumiTagListArguments({required this.name});
  final String name;
}

/// 角色/人物页参数。
class IdArguments {
  const IdArguments(this.id);
  final int id;
}

/// 搜索面板参数。
class SearchPanelArguments {
  const SearchPanelArguments({
    required this.type,
    this.keyword,
    this.hintText,
  });
  final SearchType type;
  final String? keyword;
  final String? hintText;
}

/// 搜索结果页参数。
class SearchArguments {
  const SearchArguments({required this.type, required this.keyword});
  final SearchType type;
  final String keyword;
}

/// 无过渡动画的页面路由（保持原 `Transition.noTransition` 行为）。
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required Widget page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}

/// `onGenerateRoute`：把原 GetX 路由表翻译为原生 Navigator 路由。
class AppRouter {
  AppRouter._();

  /// 需要登录才能访问的路由。
  static const Set<String> _protectedRoutes = {AppRoutes.profile};

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.home;
    final uri = Uri.parse(name);
    final path = uri.path;
    final segments = uri.pathSegments;
    final args = settings.arguments;

    // 未登录访问受保护路由时重定向到登录页
    if (_protectedRoutes.contains(path) &&
        !SessionService.instance.isLoggedIn) {
      return _route(const LoginPage(), settings);
    }

    switch (path) {
      case AppRoutes.home:
        return _route(const HomePage(), settings);
      case AppRoutes.tags:
        return _route(
          TagsPage(tag: _readKey(args, 'tag') ?? ''),
          settings,
        );
      case AppRoutes.login:
        return _route(const LoginPage(), settings);
      case AppRoutes.register:
        return _route(const RegisterPage(), settings);
      case AppRoutes.changePassword:
        return _route(const ChangePasswordPage(), settings);
      case AppRoutes.profile:
        return _route(const ProfilePage(), settings);
      case AppRoutes.bangumi:
        if (segments.length == 2) {
          return _route(
            BangumiDetailPage(
              id: _readId(args) ?? int.tryParse(segments[1]) ?? 0,
              data: _detailData(args),
            ),
            settings,
          );
        }
        return _route(const BangumiPage(), settings);
      case AppRoutes.bangumiGenreList:
        return _route(
          BangumiGenreListPage(name: _readKey(args, 'name') ?? ''),
          settings,
        );
      case AppRoutes.bangumiMarkList:
        return _route(
          BangumiMarkListPage(name: _readKey(args, 'name') ?? ''),
          settings,
        );
      case AppRoutes.vod:
        if (segments.length == 2) {
          final vodArgs = args is VodArguments ? args : null;
          return _route(
            BangumiVodPage(
              id: vodArgs?.id ?? int.tryParse(segments[1]) ?? 0,
              episode: vodArgs?.episode,
              data: vodArgs?.data,
              episodes: vodArgs?.episodes,
            ),
            settings,
          );
        }
        break;
      case AppRoutes.character:
        return _route(
          CharacterPage(id: _readId(args) ?? 0),
          settings,
        );
      case AppRoutes.person:
        return _route(
          PersonPage(id: _readId(args) ?? 0),
          settings,
        );
      case AppRoutes.searchPanel:
        final panelArgs = args is SearchPanelArguments ? args : null;
        return _route(
          SearchPanelPage(
            type: panelArgs?.type ??
                (args is SearchType ? args : SearchType.picture),
            keyword: panelArgs?.keyword ?? uri.queryParameters['keyword'],
            hintText: panelArgs?.hintText ?? uri.queryParameters['hintText'],
          ),
          settings,
        );
      case AppRoutes.search:
        final searchArgs = args is SearchArguments ? args : null;
        return _route(
          SearchPage(
            type: searchArgs?.type ?? SearchType.picture,
            keyword: searchArgs?.keyword ?? '',
          ),
          settings,
        );
      case AppRoutes.accountSettings:
        return _route(const AccountSettingsPage(), settings);
      case AppRoutes.themeSettings:
        return _route(const ThemeSettingsPage(), settings);
      case AppRoutes.danmakuSettings:
        return _route(const DanmakuSettingsPage(), settings);
      case AppRoutes.info:
        return _route(const InfoSettingsPage(), settings);
      case AppRoutes.playHistory:
        return _route(const PlayHistoryPage(), settings);
      case AppRoutes.bangumiCollection:
        return _route(const BangumiCollectionPage(), settings);
      case AppRoutes.threadCollection:
        return _route(const ThreadCollectionPage(), settings);
      case AppRoutes.download:
        return _route(const DownloadPage(), settings);
      case AppRoutes.thread:
        if (segments.length == 2) {
          return _route(
            ThreadPage(
              id: _readId(args) ?? int.tryParse(segments[1]) ?? 0,
              data: _threadData(args),
            ),
            settings,
          );
        }
        break;
    }
    // 未知路由回退到首页
    return _route(const HomePage(), settings);
  }

  static Route<T> _route<T>(Widget page, RouteSettings settings) =>
      AppPageRoute<T>(page: page, settings: settings);

  /// 从 arguments 中读取 `id` 字段。
  ///
  /// 兼容 `IdArguments`/`ThreadArguments`/`BangumiDetailArguments`/
  /// `Map` 以及任意带 `id` getter 的数据对象（protobuf 列表项等）。
  static int? _readId(Object? args) {
    if (args == null) return null;
    if (args is IdArguments) return args.id;
    if (args is ThreadArguments) return args.id;
    if (args is BangumiDetailArguments) return args.id;
    if (args is VodArguments) return args.id;
    if (args is Map) return _toInt(args['id']);
    // protobuf 列表项等：直接通过 dynamic 读取 .id
    try {
      final dynamic d = args;
      final dynamic id = d.id;
      return _toInt(id);
    } catch (_) {
      return null;
    }
  }

  static String? _readKey(Object? args, String key) {
    if (args is Map) return args[key]?.toString();
    if (args is TagsArguments) return args.tag;
    if (args is BangumiTagListArguments) return args.name;
    return null;
  }

  static BangumiDetailModel? _detailData(Object? args) =>
      args is BangumiDetailArguments ? args.data : null;

  static thread_list_data_? _threadData(Object? args) =>
      args is ThreadArguments
          ? args.data
          : (args is thread_list_data_ ? args : null);

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }
}

/// 便捷导航：替代 `Get.toNamed`。
Future<T?> appPushNamed<T extends Object?>(String routeName,
        {Object? arguments}) =>
    appNavigator!.pushNamed<T>(routeName, arguments: arguments);

/// 便捷导航：替代 `Get.offAndToNamed`（替换当前页）。
Future<T?> appPushReplacementNamed<T extends Object?, TO extends Object?>(
        String routeName,
        {Object? arguments}) =>
    appNavigator!.pushReplacementNamed<T, TO>(routeName,
        arguments: arguments);

/// 便捷导航：替代 `Get.back`。
void appPop<T extends Object?>([T? result]) => appNavigator?.pop(result);
