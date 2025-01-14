import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';

class TokenHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TokenHistory> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
        appBar: buildAppBar(context),
        body: new Column(
          children: <Widget>[
            _buildBar(),
            new Container(
                padding: new EdgeInsets.all(16.0),
                child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(right: 20.0),
                          child: new Text('收款转账'),
                        ),

                        new Text('历史兑换'),
                      ],
                    ),
                    _getHistoryToken(),
                  ],
                )
            ),
          ],
        ),
      bottomNavigationBar: new BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: new SizedBox(
                height: 50.0,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))
                  ),
                  elevation: 0,
                  icon: Icon(Icons.search),
                  label: Text("兑换"),
                  onPressed: (){
                    Navigator.pushNamed(context, "tab_exchange");
                  },
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: new SizedBox(
                height: 50.0,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))
                  ),
                  elevation: 0,
                  icon: Icon(Icons.search),
                  color: Colors.blue,
                  label: Text("收款"),
                  onPressed: () => print("图标按钮"),
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: new SizedBox(
                height: 50.0,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))
                  ),
                  elevation: 0,
                  icon: Icon(Icons.search),
                  label: Text("转账"),
                  color: Colors.green,
                  onPressed: () => print("图标按钮"),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
      );
  }

  // 构建app bar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: Colors.white,
        title: new Text('Token'),
//        bottom: new TabBar(
//          tabs: [
//            new Tab(text: '日期'),
//            new Tab(text: '今天'),
//            new Tab(text: '三天')
//          ],
//        )
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 构建tabbar
  _buildBar() {
    return Container(
        decoration: new BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        padding: new EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBarItem('日期'),
            new Text('今日'),
            new Text('三天'),
            new Text('本周'),
            new Text('本月'),
          ],
        )
    );
  }

  _buildBarItem(str) {
    return Container(
      child: GestureDetector(
        onTap: (){
          debugPrint("onTap");
        },
        child: Text(str),
      ),
    );
  }

  _getHistoryToken() {
    return new Container(
      child: new Column(
        children: <Widget>[
          _buildToken(),
          _buildToken()
        ],
      ),
    );
  }

  _buildToken() {
    return new Container(
        padding: const EdgeInsets.only(top: 12.0,bottom: 12.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text('收款-fromtoken'),
                new Text(
                    '+0.123 token',
                    style: new TextStyle(
                        color: Colors.lightBlue
                    )
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                    '2019-11-11 10:11:12',
                    style: new TextStyle(
                        color: Colors.black38
                    )
                ),
                new Text(
                    '转账中',
                    style: new TextStyle(
                        color: Colors.deepOrange
                    )
                )
              ],
            ),
          ],
        )
    );
  }

  @override
  _onClick() {
    debugPrint("onTap");
  }

//  void _onTabChanged() {
//
//  }

}
