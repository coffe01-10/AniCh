import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xs/src/utils/app_style.dart';

/// SmartDialog 的全局 loading 指示器。
class AppLoaddingWidget extends StatelessWidget {
  const AppLoaddingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: AppStyle.edgeInsetsA12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.grey.withOpacity(.2),
                  )
                ],
        ),
        child: const CupertinoActivityIndicator(
          radius: 10,
        ),
      ),
    );
  }
}
