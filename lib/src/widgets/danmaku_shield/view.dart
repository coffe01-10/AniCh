import 'package:flutter/material.dart';
import 'package:xs/src/services/danmaku_shield_service.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/utils/utils.dart';

/// 弹幕屏蔽词管理面板。
///
/// 替代原 `DanmakuShieldView`，数据由
/// [DanmakuShieldService] 统一维护。
class DanmakuShieldView extends StatelessWidget {
  const DanmakuShieldView({super.key});

  @override
  Widget build(BuildContext context) {
    final shield = DanmakuShieldService.instance;
    return ListView(
      padding: AppStyle.edgeInsetsA12,
      children: [
        TextField(
          controller: shield.textEditingController,
          decoration: InputDecoration(
            contentPadding: AppStyle.edgeInsetsH12,
            border: const OutlineInputBorder(),
            hintText: '请输入关键词或正则表达式',
            suffixIcon: TextButton.icon(
              onPressed: shield.add,
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
          ),
          onSubmitted: (_) => shield.add(),
        ),
        AppStyle.vGap4,
        Text(
          '以"/"开头和结尾将视作正则表达式, 如"/\\d+/"表示屏蔽所有数字',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppStyle.vGap12,
        ValueListenableBuilder<Set<String>>(
          valueListenable: shield.shieldList,
          builder: (context, shieldList, _) => Text(
            '已添加${shieldList.length}个关键词（点击移除）',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        AppStyle.vGap12,
        ValueListenableBuilder<Set<String>>(
          valueListenable: shield.shieldList,
          builder: (context, shieldList, _) => Wrap(
            runSpacing: 12,
            spacing: 12,
            children: shieldList
                .map(
                  (item) => InkWell(
                    borderRadius: AppStyle.radius24,
                    onTap: () => shield.remove(item),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: AppStyle.radius24,
                      ),
                      padding: AppStyle.edgeInsetsH12.copyWith(
                        top: 4,
                        bottom: 4,
                      ),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static void showDanmakuShieldBottomSheet() {
    Utils.showBottomSheet(
      title: '关键词屏蔽',
      child: const DanmakuShieldView(),
    );
  }

  static void showDanmakuShieldRightDialog() {
    Utils.showRightDialog(
      title: '关键词屏蔽',
      width: 400,
      useSystem: true,
      child: const DanmakuShieldView(),
    );
  }
}
