import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:xs/src/widgets/comments/comment_api.dart';

/// 评论区控制器。
///
/// 统一管理评论列表、回复列表与点赞/发评操作，
/// 帖子页与播放页各持有一个实例。
/// 数据源由 [api] 决定（帖子/番剧共用同一组接口）。
class CommentController extends ChangeNotifier {
  CommentController({required this.id, required this.api});

  /// 被评论对象 id（帖子 id 或分集 id）。
  final String id;

  /// 评论数据源。
  final CommentApi api;

  /// 评论列表（JSON Map 结构）。
  final List<dynamic> comments = [];

  /// 评论列表是否处于加载中。
  bool commentsLoading = true;

  /// 评论列表首屏是否加载失败。
  bool commentsError = false;

  /// 当前展开的回复列表。
  final List<dynamic> commentReplies = [];

  /// 回复列表是否处于加载中。
  bool commentRepliesLoading = true;

  /// 首屏拉取评论。
  Future<void> load() => getComments(id);

  // 获取评论列表
  Future<void> getComments(id) async {
    commentsError = false;
    comments.clear();
    commentsLoading = true;
    notifyListeners();
    try {
      final response = await api.getComments(id: id);
      if (response.statusCode == 200) {
        comments.addAll(response.data['body']['data'].toList());
      } else {
        throw StateError('getComments ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      commentsError = true;
    }
    commentsLoading = false;
    notifyListeners();
  }

  // 评论列表加载更多
  Future<void> getMoreComments(id) async {
    if (commentsLoading || comments.isEmpty) return;
    commentsLoading = true;
    notifyListeners();
    try {
      final response = await api.getComments(id: id, skip: comments.last['id']);
      if (response.statusCode == 200) {
        comments.addAll(response.data['body']['data'].toList());
      } else {
        throw StateError('getMoreComments ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    commentsLoading = false;
    notifyListeners();
  }

  // 发送评论
  Future<void> sendComment(Map json) async {
    try {
      final response = await api.postComment(
          id: json['id'], contents: json['contents']);
      if (response.statusCode == 200) {
        comments.insert(0, response.data['body']);
        notifyListeners();
        SmartDialog.showToast('发送成功');
      } else {
        throw StateError('sendComment ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      SmartDialog.showToast('发送失败');
    }
  }

  // 回复评论
  Future<Map> replyComment({json, parent, reply}) async {
    try {
      final response = await api.postComment(
          id: json['id'],
          parent: parent,
          reply: reply,
          contents: json['contents']);
      if (response.statusCode == 200) {
        SmartDialog.showToast('回复成功');
        return response.data['body'];
      } else {
        throw StateError('replyComment ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      SmartDialog.showToast('回复失败');
    }
    return {};
  }

  // 评论点赞
  Future<bool> likeComment(id) async {
    try {
      final response = await api.likeComment(id: id);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw StateError('likeComment ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // 评论取消点赞
  Future<bool> cancelLikeComment(id) async {
    try {
      final response = await api.cancelLikeComment(id: id);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw StateError('cancelLikeComment ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // 获取评论回复列表
  Future<void> getCommentReplies(id) async {
    commentReplies.clear();
    commentRepliesLoading = true;
    notifyListeners();
    try {
      final response = await api.getCommentReplies(id: id);
      if (response.statusCode == 200) {
        commentReplies.addAll(response.data['body']['data'].toList());
      } else {
        throw StateError('getCommentReplies ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    commentRepliesLoading = false;
    notifyListeners();
  }

  // 评论回复加载更多
  Future<void> getMoreCommentReplies(id) async {
    if (commentRepliesLoading || commentReplies.isEmpty) return;
    commentRepliesLoading = true;
    notifyListeners();
    try {
      final response = await api.getCommentReplies(
          id: id, skip: commentReplies.last['id']);
      if (response.statusCode == 200) {
        commentReplies.addAll(response.data['body']['data'].toList());
      } else {
        throw StateError('getMoreCommentReplies ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    commentRepliesLoading = false;
    notifyListeners();
  }

  /// 向当前回复列表追加一条新回复（发评成功后调用）。
  void appendReply(Map reply) {
    commentReplies.add(reply);
    notifyListeners();
  }

  /// 手动刷新（点赞等本地字段更新后调用）。
  void refresh() => notifyListeners();
}
