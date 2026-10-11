import 'package:dio/dio.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/apis/thread.dart';

/// 评论数据源。
///
/// 帖子评论与番剧评论调用同一组 `/comment` 接口，
/// 仅 `type` 参数不同（`thread` / `bangumi_episode`），
/// 这里以策略方式抹平差异，让 UI 层只写一套。
abstract class CommentApi {
  const CommentApi();

  Future<Response> getComments({required String id, dynamic skip});

  Future<Response> postComment({
    required String id,
    String? parent,
    String? reply,
    required List contents,
  });

  Future<Response> getCommentReplies({required String id, dynamic skip});

  Future<Response> likeComment({required String id});

  Future<Response> cancelLikeComment({required String id});
}

/// 帖子评论数据源（`type: thread`）。
class ThreadCommentApi extends CommentApi {
  const ThreadCommentApi();

  @override
  Future<Response> getComments({required String id, dynamic skip}) =>
      ThreadApi.getComments(id: id, skip: skip);

  @override
  Future<Response> postComment({
    required String id,
    String? parent,
    String? reply,
    required List contents,
  }) =>
      ThreadApi.postComment(
          id: id, parent: parent, reply: reply, contents: contents);

  @override
  Future<Response> getCommentReplies({required String id, dynamic skip}) =>
      ThreadApi.getCommentReplies(id: id, skip: skip);

  @override
  Future<Response> likeComment({required String id}) =>
      ThreadApi.likeComment(id: id);

  @override
  Future<Response> cancelLikeComment({required String id}) =>
      ThreadApi.cancelLikeComment(id: id);
}

/// 番剧（分集）评论数据源（`type: bangumi_episode`）。
class BangumiCommentApi extends CommentApi {
  const BangumiCommentApi();

  @override
  Future<Response> getComments({required String id, dynamic skip}) =>
      BangumiApi.getComments(id: id, skip: skip);

  @override
  Future<Response> postComment({
    required String id,
    String? parent,
    String? reply,
    required List contents,
  }) =>
      BangumiApi.postComment(
          id: id, parent: parent, reply: reply, contents: contents);

  @override
  Future<Response> getCommentReplies({required String id, dynamic skip}) =>
      BangumiApi.getCommentReplies(id: id, skip: skip);

  @override
  Future<Response> likeComment({required String id}) =>
      BangumiApi.likeComment(id: id);

  @override
  Future<Response> cancelLikeComment({required String id}) =>
      BangumiApi.cancelLikeComment(id: id);
}
