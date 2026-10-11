import 'package:flutter/material.dart';
import 'package:xs/protobuf/bangumi.pb.dart';
import 'package:xs/src/apis/bangumi.dart';
import 'package:xs/src/services/loading_state.dart';
import 'package:xs/src/widgets/controller_builder.dart';

class BangumiMarkListController
    extends LoadableController<List<bangumi_list_item_>>
    implements VsyncAttachable {
  BangumiMarkListController(String name) {
    mark.value = name;
    _init();
  }
  TickerProvider? _vsync;

  @override
  void attach(TickerProvider vsync) {
    _vsync = vsync;
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void detach() {
    animationController.dispose();
  }

  final ValueNotifier<String> mark = ValueNotifier('');
  List<bangumi_list_item_> result = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Map<String, String> typeList = {
    '': '类型',
    'tv': '正篇',
    'movie': '剧场版',
    'ova': '特别篇'
  };

  Map<String, String> langList = {
    '': '语言',
    'ja': '日语',
    'zh': '国语',
    'en': '英语',
    'ko': '韩语',
    'other': '其他'
  };

  Map<String, String> yearList = {
    '': '年份',
  };

  final ValueNotifier<String> typeSelect = ValueNotifier('');
  final ValueNotifier<String> langSelect = ValueNotifier('');
  final ValueNotifier<String> yearSelect = ValueNotifier('');
  final ValueNotifier<String> typeSelected = ValueNotifier('');
  final ValueNotifier<String> langSelected = ValueNotifier('');
  final ValueNotifier<String> yearSelected = ValueNotifier('');

  late final AnimationController animationController;

  void _init() {
    // 创建年份
    int currentYear = DateTime.now().year;
    List<String>.generate(35, (i) {
      String year = (currentYear - i).toString();
      yearList[year] = '$year年';
      return year;
    });

    get();
  }

  // 获取数据
  void get() async {
    try {
      debugPrint('BangumiMarkListController-get');
      change(result, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiList(mark: mark);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
  }

  // 筛选
  void filter() async {
    try {
      typeSelected.value = (typeSelect.value);
      langSelected.value = (langSelect.value);
      yearSelected.value = (yearSelect.value);
      debugPrint('BangumiMarkListController-filter');
      result.clear();
      change(null, status: LoadStatus.loading);
      final response = await BangumiApi.getBangumiList(
          mark: mark,
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
      change(null, status: LoadStatus.error, error: 'error');
    }
    isLoading.value = (false);
  }

  // 加载更多
  void more() async {
    try {
      debugPrint('BangumiMarkListController-more');
      isLoading.value = (true);
      final response = await BangumiApi.getBangumiList(
          mark: mark,
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value,
          skip: result.last.id);
      final data = bangumi_list_.fromBuffer(response.data);
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    isLoading.value = (false);
  }

  // 刷新
  Future<bool> reload() async {
    try {
      debugPrint('BangumiMarkListController-reload');
      final response = await BangumiApi.getBangumiList(
          mark: mark,
          type: typeSelected.value,
          lang: langSelected.value,
          year: yearSelected.value);
      final data = bangumi_list_.fromBuffer(response.data);
      result.clear();
      result.addAll(data.data);
      change(result, status: LoadStatus.success);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }
}
