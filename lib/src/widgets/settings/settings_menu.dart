import 'package:flutter/material.dart';
import 'package:xs/src/utils/app_style.dart';

/// 设置项：点击弹出底部单选菜单。
class SettingsMenu<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Map<T, String> valueMap;
  final T value;

  final Function(T)? onChanged;
  const SettingsMenu({
    required this.title,
    required this.value,
    required this.valueMap,
    this.subtitle,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyle.radius8,
      ),
      contentPadding: AppStyle.edgeInsetsL16.copyWith(right: 8),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valueMap[value] ?? '???',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.grey),
          ),
          AppStyle.hGap4,
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
      onTap: () => openMenu(context),
    );
  }

  void openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: valueMap.keys
                .map(
                  (e) => RadioListTile(
                    value: e,
                    groupValue: value,
                    title: Text(
                      valueMap[e] ?? '???',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onChanged: (selected) {
                      Navigator.of(sheetContext).pop();
                      onChanged?.call(selected as T);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
