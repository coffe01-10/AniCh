import 'package:flutter/material.dart';
import 'package:xs/src/pages/search/models/search_type.dart';
import 'package:xs/src/app/routes.dart';
import 'package:xs/src/services/loading_state.dart';

class SearchPanelController extends LoadableController<dynamic> {
  SearchPanelController(
      {required this.searchType, String? keyword, String? hintText}) {
    if (keyword != null) {
      onClickKeyword(keyword);
    }
    if (hintText != null) {
      this.hintText = hintText;
      searchKeyWord.value = hintText;
    }
    historyList.value = historyCacheList;
  }

  final FocusNode searchFocusNode = FocusNode();
  final ValueNotifier<TextEditingController> controller =
      ValueNotifier(TextEditingController());
  final ValueNotifier<String> searchKeyWord = ValueNotifier('');
  String hintText = '搜索';
  List historyCacheList = [];
  final historyList = ValueNotifier([]);
  SearchType searchType = SearchType.picture;

  // 搜索
  void submit() {
    // ignore: unrelated_type_equality_checks
    if (searchKeyWord.value == '') {
      return;
    }
    List arr = historyCacheList.where((e) => e != searchKeyWord.value).toList();
    arr.insert(0, searchKeyWord.value);
    historyCacheList = arr;

    historyList.value = historyCacheList;
    // 手动刷新
    notifyListeners();
    // histiryWord.put('cacheList', historyCacheList);
    searchFocusNode.unfocus();
    appPushReplacementNamed(
      '/search',
      arguments:
          SearchArguments(type: searchType, keyword: searchKeyWord.value),
      // parameters: {'type': 'bangumi', 'keyword': searchKeyWord.value}
    );
  }

  // 点击热搜关键词
  void onClickKeyword(String keyword) {
    searchKeyWord.value = keyword;
    controller.value.text = keyword;
    // 移动光标
    controller.value.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.value.text.length),
    );
    submit();
  }

  void onChange(value) {
    searchKeyWord.value = value;
    if (value == '') {
      // searchSuggestList.value = [];
      return;
    }
    // _debouncer.call(() => querySearchSuggest(value));
  }

  void onClear() {
    if (searchKeyWord.value.isNotEmpty && controller.value.text != '') {
      controller.value.clear();
      searchKeyWord.value = '';
      // searchSuggestList.value = [];
    } else {
      appPop();
    }
  }
}
