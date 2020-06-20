/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'rank_store.g.dart';

class RankStore = _RankStoreBase with _$RankStore;

abstract class _RankStoreBase with Store {
  static const MODE_LIST = 'mode_list';
  List<String> intialModeList = [
    "day",
    "day_male",
    "day_female",
    "week_original",
    "week_rookie",
    "week",
    "month",
    "day_r18",
    "week_r18"
  ];
  @observable
  ObservableList<String> modeList = ObservableList();
  @observable
  bool modifyUI = false;

  @action
  Future<void> reset() async {
    var pre = await SharedPreferences.getInstance();
    await pre.remove(MODE_LIST);
    modeList.clear();
  }

  SharedPreferences pre;
  @action
  Future<void> init() async {
    pre = await SharedPreferences.getInstance();
    var list = pre.getStringList(MODE_LIST);
    if (list == null || list.isEmpty) {
      return;
    }
    modeList.clear();
    modeList.addAll(list);
  }

  @action
  Future<void> saveChange(Map<int, bool> selectMap) async {
    var pre = await SharedPreferences.getInstance();

    List<String> saveList = [];
    selectMap.forEach((s, b) {
      if (b) saveList.add(intialModeList[s]);
    });
    await pre.setStringList(MODE_LIST, saveList);
    modeList.clear();
    modeList.addAll(saveList);
  }
}
