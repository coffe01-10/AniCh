import 'package:flutter/material.dart';
import 'package:xs/src/app/navigator_key.dart';
import 'package:xs/src/pages/bangumi_vod/controller.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/widgets/comments/comment_api.dart';
import 'package:xs/src/widgets/comments/comment_controller.dart';
import 'package:xs/src/widgets/comments/comment_item.dart';
import 'package:xs/src/widgets/keepalive.dart';
import 'package:xs/src/widgets/reply.dart';
import 'package:xs/src/widgets/subordinate_scroll_controller.dart';

/// 播放页评论标签页。
///
/// 数据源为 [CommentController] + [BangumiCommentApi]，
/// 被评论对象 id 随选集变化（`番剧id|集数`），切集时重建。
class BangumiVodCommentsView extends StatefulWidget {
  final BangumiVodPageController bangumiVodPageController;
  const BangumiVodCommentsView(
      {super.key, required this.bangumiVodPageController});

  @override
  State<BangumiVodCommentsView> createState() =>
      _BangumiVodCommentsViewState();
}

class _BangumiVodCommentsViewState extends State<BangumiVodCommentsView> {
  BangumiVodPageController get vodController =>
      widget.bangumiVodPageController;

  CommentController? _commentController;
  String _commentId = '';

  CommentController _ensureCommentController() {
    final id = '${vodController.id}|${vodController.episode}';
    if (_commentId != id || _commentController == null) {
      _commentController?.dispose();
      _commentId = id;
      _commentController = CommentController(
        id: id,
        api: const BangumiCommentApi(),
      )..load();
    }
    return _commentController!;
  }

  @override
  void dispose() {
    _commentController?.dispose();
    super.dispose();
  }

  void _showReplySheet({String? parent, String? reply}) {
    final controller = _commentController;
    if (controller == null) return;
    showModalBottomSheet(
      context: appContext,
      isScrollControlled: true,
      builder: (context) => ReplyNewDialog(
        id: _commentId,
        parent: parent,
        reply: reply,
        sendFn: (json) {
          appNavigator?.pop();
          controller.sendComment(json);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentController = PrimaryScrollController.of(context);
    final scrollController = SubordinateScrollController(parentController);
    return KeepAliveWrapper(
      child: ListenableBuilder(
        listenable: vodController.pageListenable,
        builder: (context, _) {
          final controller = _ensureCommentController();
          final id = _commentId;
          return ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.comments.isEmpty && controller.commentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.comments.isEmpty && controller.commentsError) {
                return const Center(child: Text('加载失败'));
              }
              return SafeArea(
                top: true,
                bottom: true,
                maintainBottomViewPadding: true,
                minimum: const EdgeInsets.only(
                    top: 0, bottom: 0, left: 0, right: 0),
                child: Stack(
                  children: [
                    NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        final metrics = notification.metrics;
                        if (metrics.atEdge) {
                          bool isTop = metrics.pixels == 0;
                          if (isTop) {
                          } else {
                            if (!controller.commentsLoading) {
                              controller.getMoreComments(id);
                            }
                          }
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        displacement: 20,
                        edgeOffset: 80,
                        onRefresh: () async {
                          await controller.getComments(id);
                        },
                        child: CustomScrollView(
                          controller: vodController.tabIndex.value == 1
                              ? scrollController
                              : ScrollController(),
                          slivers: [
                            SliverOverlapInjector(
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(
                                        context)),
                            SliverToBoxAdapter(
                              child: Container(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Text(
                                        '第${vodController.episode}集 评论区 (${controller.comments.length})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: ListView.builder(
                                primary: true,
                                shrinkWrap: true,
                                itemBuilder: (itemBuilder, index) {
                                  Map comment =
                                      controller.comments[index];
                                  return CommentItem(
                                    comment,
                                    controller: controller,
                                    replyFn: () {
                                      showModalBottomSheet(
                                        context: appContext,
                                        isScrollControlled: true,
                                        builder: (context) =>
                                            ReplyNewDialog(
                                          id: id,
                                          sendFn: (json) async {
                                            appNavigator?.pop();
                                            final data =
                                                await controller
                                                    .replyComment(
                                                        json: json,
                                                        parent: comment[
                                                            'id'],
                                                        reply: null);
                                            if (data.isNotEmpty) {
                                              comment['replies'].add(data);
                                              controller.refresh();
                                            }
                                          },
                                        ),
                                      );
                                    },
                                    likeFn: (id) {
                                      return controller.likeComment(id);
                                    },
                                    cancelLikeFn: (id) {
                                      return controller
                                          .cancelLikeComment(id);
                                    },
                                  );
                                },
                                itemCount: controller.comments.length,
                              ),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(bottom: 50),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color:
                            Theme.of(context).scaffoldBackgroundColor,
                        height: 50,
                        child: Column(
                          children: [
                            AppStyle.divider,
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Material(
                                    child: InkWell(
                                      onTap: () {
                                        _showReplySheet();
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 10),
                                        width: double.infinity,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withAlpha(20),
                                        child: const Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            '发送评论',
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
