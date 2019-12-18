import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';


/// ChangeNotifier 是 Flutter SDK 中的一个简单的类。
/// 它用于向监听器发送通知。换言之，如果被定义为 ChangeNotifier，
/// 你可以订阅它的状态变化。（这和大家所熟悉的观察者模式相类似）。

/// 在 provider 中，ChangeNotifier 是一种能够封装应用程序状态的方法。
/// 对于特别简单的程序，你可以通过一个 ChangeNotifier 来满足全部需求。
/// 在相对复杂的应用中，由于会有多个模型，所以可能会有多个 ChangeNotifier。
/// (不是必须得把 ChangeNotifier 和 provider 结合起来用，不过它确实是一个特别简单的类)。

class Token extends ChangeNotifier {
//  User get user => _profile.user;

  // 构造函数，获取本地保存的token'
  Token() {
    this._fetchToken();
  }

  Future<List> _fetchToken() async {
    var sql = SqlUtil.setTable("tokens");
    sql.get().then((res) {
      res.forEach((f){
        this._items.add(f);
      });
    });
    notifyListeners();
  }

  // APP是否登录(如果有用户信息，则证明登录过)
//  bool get isLogin => user != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
//  set user(User user) {
//    if (user?.login != _profile.user?.login) {
//      _profile.lastLogin = _profile.user?.login;
//      _profile.user = user;
//      notifyListeners();
//    }
//  }

  /// Internal, private state of the cart. 内部的，购物车的私有状态
  List<Map> _items = [];

  /// 现在全部商品的总价格（假设他们加起来 $42）
  int get totalPrice => _items.length * 42;

  // 获取所有token
  List<Map> get items => _items;

  ///  将 [item] 到token列表中
  void add(Map item) {
    _items.add(item);
    notifyListeners();
  }

  // 获取token列表
//  List get(){
//    return _items;
//  }

}