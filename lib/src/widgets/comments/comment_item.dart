import 'package:flutter/material.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/color.dart';
import 'package:xs/src/utils/time.dart';
import 'package:xs/src/widgets/comments/comment_controller.dart';
import 'package:xs/src/widgets/comments/replies_preview.dart';
import 'package:xs/src/widgets/sticker.dart';

/// 单条评论（含点赞/回复入口与回复预览）。
class CommentItem extends StatefulWidget {
  final Map comment;
  final bool repliesPreview;
  final CommentController controller;
  final Function()? replyFn;
  final Function(String id)? likeFn;
  final Function(String id)? cancelLikeFn;
  const CommentItem(this.comment,
      {super.key,
      this.repliesPreview = true,
      this.replyFn,
      this.likeFn,
      this.cancelLikeFn,
      required this.controller});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  late int _likeCount;
  late bool _like;

  Map get comment => widget.comment;

  @override
  void initState() {
    super.initState();
    _like = comment['like'] ?? false;
    _likeCount = comment['likes_count'] ?? 0;
  }

  Future<void> _toggleLike() async {
    final likeFn = widget.likeFn;
    if (!_like) {
      if (likeFn == null) return;
      final ok = await likeFn(comment['id']);
      if (ok) {
        comment['like'] = true;
        _like = true;
        comment['likes_count'] = (comment['likes_count'] ?? 0) + 1;
        _likeCount = comment['likes_count'];
      } else {
        comment['like'] = false;
        _like = false;
      }
    } else {
      final cancelLikeFn = widget.cancelLikeFn;
      if (cancelLikeFn == null) return;
      final ok = await cancelLikeFn(comment['id']);
      if (ok) {
        comment['like'] = false;
        _like = false;
        comment['likes_count'] = (comment['likes_count'] ?? 0) - 1;
        _likeCount = comment['likes_count'];
      } else {
        comment['like'] = true;
        _like = true;
      }
    }
    widget.controller.refresh();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final contents = comment['contents'];
    contents.last['content'] =
        contents.last['content'].replaceAll(RegExp('\n\$'), '');
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.only(top: 5, bottom: 0, left: 10, right: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: ColorUtil.fromHex(comment['user']['color']),
                      child: comment['user']?['avatar'] != null
                          ? Image.network(comment['user']['avatar'])
                          : Center(
                              child: Text(
                                comment['user']['name'].substring(0, 1),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['user']['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        Opacity(
                          opacity: 0.6,
                          child: Text(
                            Time.dateFormat(
                                DateTime.parse(comment['created'])
                                    .millisecondsSinceEpoch),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 16),
                            children: contents
                                .map((e) {
                                  if (e['type'] == 'sticker') {
                                    final sticker_ = sticker['list'].firstWhere(
                                        (i) => i['text'] == e['content']);
                                    final String src =
                                        '${sticker['path']}${sticker_['src']}';
                                    return WidgetSpan(
                                      child: Image.asset(
                                        src,
                                        height: 40,
                                      ),
                                    );
                                  } else {
                                    return TextSpan(
                                      text: e['content'],
                                    );
                                  }
                                })
                                .toList()
                                .cast<InlineSpan>(),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _toggleLike,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          size: 14,
                                          color: _like
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                        ),
                                        Text(
                                          _likeCount > 0
                                              ? '$_likeCount'
                                              : '点赞',
                                          style: TextStyle(
                                            color: _like
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.replyFn?.call();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.reply,
                                          size: 14,
                                        ),
                                        Text('回复')
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        if (widget.repliesPreview) ...[
                          const SizedBox(height: 5),
                          RepliesPreview(comment,
                              controller: widget.controller,
                              replyFn: widget.replyFn,
                              likeFn: widget.likeFn,
                              cancelLikeFn: widget.cancelLikeFn),
                        ],
                        const SizedBox(height: 5),
                      ],
                    ),
                  )
                ],
              ),
              AppStyle.divider
            ],
          ),
        ),
      ),
    );
  }
}
