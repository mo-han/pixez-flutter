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
import 'package:pixez/models/account.dart';
import 'package:pixez/page/account/select/account_select_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_store.g.dart';

class AccountStore = _AccountStoreBase with _$AccountStore;

abstract class _AccountStoreBase with Store {
  AccountProvider accountProvider = new AccountProvider();
  @observable
  AccountPersist now;

  @action
  deleteAll() async {
    await accountProvider.open();
    await accountProvider.deleteAll();
    now = null;
  }

  @action
  updateSingle(AccountPersist accountPersist) async {
    await accountProvider.open();
    await accountProvider.update(accountPersist);
  }

  @action
  fetch() async {
    await accountProvider.open();
    List<AccountPersist> list = await accountProvider.getAllAccount();
    var pre = await SharedPreferences.getInstance();
    var i = pre.getInt(AccountSelectBloc.ACCOUNT_SELECT_NUM);
    if (list != null && list.isNotEmpty) {
      now = list[i ?? 0];
    }
  }
}
