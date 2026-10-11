import 'package:flutter/material.dart';
import 'package:xs/src/utils/app_style.dart';

/// 设置项：加减按钮调节数值，点击条目弹出滑杆。
class SettingsNumber extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String unit;
  final int value;
  final int step;
  final int min;
  final int max;
  final String? displayValue;
  final Function(int)? onChanged;
  const SettingsNumber(
      {required this.title,
      required this.value,
      required this.max,
      this.subtitle,
      this.onChanged,
      this.step = 1,
      this.min = 0,
      this.unit = '',
      this.displayValue,
      super.key});

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
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
      contentPadding: AppStyle.edgeInsetsL16.copyWith(right: 12),
      trailing: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.1),
          borderRadius: AppStyle.radius24,
        ),
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: AppStyle.edgeInsetsA4,
              constraints: const BoxConstraints(
                minHeight: 32,
              ),
              onPressed: () {
                int newValue = value - step;
                if (newValue < min) {
                  newValue = min;
                }
                onChanged?.call(newValue);
              },
              icon: Icon(
                Icons.remove,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color!
                    .withOpacity(.6),
              ),
            ),
            Text(
              displayValue ?? '$value$unit',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.grey),
            ),
            IconButton(
              padding: AppStyle.edgeInsetsA4,
              constraints: const BoxConstraints(
                minHeight: 32,
              ),
              onPressed: () {
                int newValue = value + step;
                if (newValue > max) {
                  newValue = max;
                }
                onChanged?.call(newValue);
              },
              icon: Icon(
                Icons.add,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color!
                    .withOpacity(.6),
              ),
            ),
          ],
        ),
      ),
      onTap: () => openSlider(context),
    );
  }

  void openSlider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: _SettingsNumberSlider(
          title: title,
          initialValue: value,
          min: min,
          max: max,
          unit: unit,
          onConfirm: onChanged,
        ),
      ),
    );
  }
}

/// 底部滑杆面板。
class _SettingsNumberSlider extends StatefulWidget {
  final String title;
  final int initialValue;
  final int min;
  final int max;
  final String unit;
  final Function(int)? onConfirm;

  const _SettingsNumberSlider({
    required this.title,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.unit,
    this.onConfirm,
  });

  @override
  State<_SettingsNumberSlider> createState() => _SettingsNumberSliderState();
}

class _SettingsNumberSliderState extends State<_SettingsNumberSlider> {
  late int _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppStyle.edgeInsetsH16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$_value${widget.unit}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Slider(
          value: _value.toDouble(),
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          onChanged: (e) {
            setState(() => _value = e.toInt());
          },
        ),
        Padding(
          padding: AppStyle.edgeInsetsH16,
          child: TextButton(
            onPressed: () {
              widget.onConfirm?.call(_value);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}
