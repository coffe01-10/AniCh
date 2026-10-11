import 'package:flutter/material.dart';
import 'package:xs/src/utils/app_style.dart';

/// 设置项：标题 + 可选副标题 + 右侧值/箭头。
class SettingsAction extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function()? onTap;
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final bool rightIcon;
  final Color? color;

  const SettingsAction({
    required this.title,
    this.value,
    this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.rightIcon = true,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: color ?? color),
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
          if (trailing != null) trailing!,
          if (value != null)
            Text(
              value!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.grey),
            ),
          AppStyle.hGap4,
          if (rightIcon)
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
