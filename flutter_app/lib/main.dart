import 'package:flutter/material.dart';
import 'dart:io';
import 'package:youwallet/pages/routers.dart';
import 'package:youwallet/global.dart';


import 'package:event_bus/event_bus.dart';

// 应用入口，所有的一起都是从这里开始发生的
//void main() {
//  Global.init().then((e) => runApp(MyApp()));
//  runApp(MyApp());
//  if (Platform.isAndroid) {
//    print('this is Android');
//    // 可以在这里针对安卓和ios做一些区别设置
//    //SystemUiOverlayStyle systemUiOverlayStyle =
//    //SystemUiOverlayStyle(statusBarColor: Colors.transparent);
//    //SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//  } else {
//    print('this is IOS');
//  }
//}

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, //关闭调试
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white
      ),
      initialRoute: '/',
      routes: routers,
      //home: new SplashWidget(tabIndex: 0)
    );
  }
}


