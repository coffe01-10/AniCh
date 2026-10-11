import 'package:flutter/material.dart';
import 'package:xs/src/services/danmaku_settings_service.dart';
import 'package:xs/src/utils/app_style.dart';
import 'package:xs/src/widgets/danmaku_shield/view.dart';
import 'package:xs/src/widgets/ns_danmaku/danmaku_controller.dart';
import 'package:xs/src/widgets/ns_danmaku/models/danmaku_option.dart';
import 'package:xs/src/widgets/player/controller.dart';
import 'package:xs/src/widgets/settings/settings_action.dart';
import 'package:xs/src/widgets/settings/settings_card.dart';
import 'package:xs/src/widgets/settings/settings_number.dart';
import 'package:xs/src/widgets/settings/settings_switch.dart';

/// 弹幕设置页（路由 `/danmaku_settings`）。
class DanmakuSettingsPage extends StatelessWidget {
  const DanmakuSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('弹幕设置'),
      ),
      body: ListView(
        padding: AppStyle.edgeInsetsA12,
        children: const [
          DanmakuSettingsView(),
        ],
      ),
    );
  }
}

/// 弹幕设置面板（可内嵌在播放器或设置页中）。
class DanmakuSettingsView extends StatelessWidget {
  final Function()? onTapDanmakuShield;
  final PlayerController? playerController;
  final DanmakuController? danmakuController;
  const DanmakuSettingsView({
    this.onTapDanmakuShield,
    this.danmakuController,
    this.playerController,
    super.key,
  });

  DanmakuSettingsService get _settings => DanmakuSettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppStyle.edgeInsetsA12.copyWith(top: 0),
          child: Text(
            '弹幕屏蔽',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SettingsCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsAction(
                title: '关键词屏蔽',
                onTap: onTapDanmakuShield ??
                    () {
                      DanmakuShieldView.showDanmakuShieldRightDialog();
                    },
              ),
            ],
          ),
        ),
        Padding(
          padding: AppStyle.edgeInsetsA12.copyWith(top: 12),
          child: Text(
            '弹幕设置',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SettingsCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _settings.danmakuEnable,
                builder: (context, value, _) => SettingsSwitch(
                  title: '默认开关',
                  value: value,
                  onChanged: (e) {
                    playerController?.showDanmakuState.value = e;
                    _settings.setDanmakuEnable(e);
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<double>(
                valueListenable: _settings.danmakuArea,
                builder: (context, value, _) => SettingsNumber(
                  title: '显示区域',
                  value: (value * 100).toInt(),
                  min: 10,
                  max: 100,
                  step: 10,
                  unit: '%',
                  onChanged: (e) {
                    _settings.setDanmakuArea(e / 100.0);
                    updateDanmakuOption(
                      danmakuController?.option.copyWith(area: e / 100.0),
                    );
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<double>(
                valueListenable: _settings.danmakuOpacity,
                builder: (context, value, _) => SettingsNumber(
                  title: '不透明度',
                  value: (value * 100).toInt(),
                  min: 10,
                  max: 100,
                  step: 10,
                  unit: '%',
                  onChanged: (e) {
                    _settings.setDanmakuOpacity(e / 100.0);
                    updateDanmakuOption(
                      danmakuController?.option.copyWith(opacity: e / 100.0),
                    );
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<double>(
                valueListenable: _settings.danmakuSize,
                builder: (context, value, _) => SettingsNumber(
                  title: '字体大小',
                  value: value.toInt(),
                  min: 8,
                  max: 48,
                  onChanged: (e) {
                    _settings.setDanmakuSize(e.toDouble());
                    updateDanmakuOption(
                      danmakuController?.option
                          .copyWith(fontSize: e.toDouble()),
                    );
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<double>(
                valueListenable: _settings.danmakuSpeed,
                builder: (context, value, _) => SettingsNumber(
                  title: '滚动速度',
                  subtitle: '弹幕持续时间(秒)，越小速度越快',
                  value: value.toInt(),
                  min: 4,
                  max: 20,
                  onChanged: (e) {
                    _settings.setDanmakuSpeed(e.toDouble());
                    updateDanmakuOption(
                      danmakuController?.option
                          .copyWith(duration: e.toDouble()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: AppStyle.edgeInsetsA12.copyWith(top: 12),
          child: Text(
            '外部弹幕',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SettingsCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _settings.bilibiliDanmakuEnable,
                builder: (context, value, _) => SettingsSwitch(
                  title: '哔哩哔哩弹幕',
                  value: value,
                  onChanged: (e) {
                    playerController?.bilibiliDanmakuState.value = e;
                    _settings.setBilibiliDanmakuEnable(e);
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<bool>(
                valueListenable: _settings.bilibiliHmtDanmakuEnable,
                builder: (context, value, _) => SettingsSwitch(
                  title: '哔哩哔哩(港澳台)弹幕',
                  value: value,
                  onChanged: (e) {
                    playerController?.bilibiliHmtDanmakuState.value = e;
                    _settings.setBilibiliHmtDanmakuEnable(e);
                  },
                ),
              ),
              AppStyle.divider,
              ValueListenableBuilder<bool>(
                valueListenable: _settings.qqDanmakuEnable,
                builder: (context, value, _) => SettingsSwitch(
                  title: '腾讯视频弹幕',
                  value: value,
                  onChanged: (e) {
                    playerController?.qqDanmakuState.value = e;
                    _settings.setQQDanmakuEnable(e);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateDanmakuOption(DanmakuOption? option) {
    if (danmakuController == null || option == null) return;
    danmakuController!.updateOption(option);
  }
}
