
import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/priceNum.dart';
import 'package:youwallet/widgets/transferList.dart';
import 'package:youwallet/widgets/bottomSheetDialog.dart';
import 'package:youwallet/widgets/tokenSelectSheet.dart';
import 'package:youwallet/widgets/input.dart';
import 'package:youwallet/bus.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/service/trade.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import '../../model/token.dart';
import 'package:youwallet/global.dart';
import 'dart:math';


class TabExchange extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new Page();
}

class Page extends State {

  BuildContext mContext;

  // 右侧显示的token
  List baseToken = [{
    'name': 'BTD',
    'address': '0x2e01154391f7dcbf215c77dbd7ff3026ea7514ce'
  }];

  // 数量编辑框
  final controllerAmount = TextEditingController();

  // 价格编辑框
  final controllerPrice = TextEditingController();

  String inputPrice = "";

  // 底部交易列表
  List trades = [];

  // 匹配的数量数组
  Map filledAmount = {};

  // 兑换深度列表
  List tradesDeep = [];

  // 输入框右侧显示的token提示
  String suffixText = "";
  double tradePrice = 0;

  // 需要授权的token
  String needApproveToken = '';

  // 左侧被选中的token
  var value;

  String _btnText="买入";
  List tokens = [];
  String tokenBalance = "";

  //数据初始化
  @override
  void initState() {
    super.initState();

    // 监听页面切换，刷新交易的状态
    eventBus.on<TabChangeEvent>().listen((event) {
      // print("event listen =》${event.index}");
      if (event.index == 1) {
         this._getTradeInfo();
      } else {
        print('do nothing');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // this.getTraderList();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      backgroundColor: _btnText == '买入' ? Colors.green[50] : Colors.red[50],
      appBar: buildAppBar(context),
      body: RefreshIndicator(
      onRefresh: _refresh,
        child: new ListView(
          children: <Widget>[
            new Container(
                padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
                child: new Column(
                  children: <Widget>[
                    buildPageTop(context),
                    new Container(
                      height: 1.0,
                      color: Colors.black12,
                      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: null,
                    ),
                    transferList(arr: this.trades, filledAmount: this.filledAmount)
                  ],
                )
            ),
          ],
        )
      )
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('兑换'),
        automaticallyImplyLeading: false, //设置没有返回按钮
    );
  }

  // 构建页面上半部分区域
  Widget buildPageTop(BuildContext context) {
    return Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //左边一列
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//                new Container(
//                  padding: const EdgeInsets.all(4.0),
//                  margin: const EdgeInsets.only(bottom: 10.0),
//                  decoration: new BoxDecoration(
//                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
//                    border: new Border.all(width: 1.0, color: Colors.black12),
//                    color: Colors.black12,
//                  ),
//                  height: 36.0,
//                  child: GestureDetector(
//                    onTap: this.selectToken,//写入方法名称就可以了，但是是无参的
//                    child: Text(
//                      this.value==null?'选择币种':this.value['name'],
//                      style: TextStyle(
//                          fontSize: 24.0
//                      ),
//                    ),
//                  ),
//                ),
                new TokenSelectSheet(
                    onCallBackEvent: (res){
                       print('成功，在顶级页面看到${res}');
                       setState(() {
                         this.value = res;
                         this.suffixText = res['name'];
                       });
                       this.getSellList();
                    }
                ),
                new Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          child: getButton('买入', this._btnText),
                          flex: 1
                      ),
                      new Expanded(
                          child: getButton('卖出', this._btnText),
                          flex: 1
                      )
                    ],
                  )
                ),
                new Text('限价模式'),
                new Input(
                  hintText: '输入买入价格',
                  controllerEdit: controllerPrice,
                  onSuccessChooseEvent: (res) {
                    print('onSuccessChooseEvent =》 ${res}');
                    this.inputPrice = res;
                    this.computeTrade();
                  },
                ),
                new Text('≈'),
                new Container(height: 10.0, child: null),
                new Input(
                  hintText: '输入买入数量',
                  controllerEdit: controllerAmount,
                  onSuccessChooseEvent: (res) {
                    this.computeTrade();
                  },
                ),
                new Text('当前账户余额${this.value!=null?this.value["balance"]:"~"}'),
                new Container(

                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      new Text('交易额${tradePrice}BTD'),
                      new SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: RaisedButton(
                            color: _btnText == '买入'? Colors.green : Colors.red,
                            elevation: 0,
                            onPressed: () async {
                               this.makeOrder();
                            },
                            child: Text(
                                this._btnText + this.suffixText,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white
                                )
                            ),
                            textColor: Colors.white,
                          ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          new Container(
            width: 20.0,
            child: null,
          ),
          // 右边一列
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //new Text('Base Token'),
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                    color: Colors.black12,
                  ),
                  height: 40.0,
                  child: Text(
                      'BTD',
                    style: TextStyle(
                      fontSize: 24.0
                    )
                  )
                ),
                buildRightWidget()
              ],
            ),

          ),
        ],
      ),
    );
  }


  // 构建一组颜色会动态变更的按钮
  Widget getButton(String btnText, String currentBtn) {
    if (btnText != currentBtn) {
      return RaisedButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0))
        ), // 设置圆角，默认有圆角
        elevation: 0, // 按钮阴影高度
        color: Colors.white,
        child: Text(btnText + this.suffixText)
      );
    } else {
      return OutlineButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        child: Text(btnText + this.suffixText),
        borderSide:  BorderSide(
            color: currentBtn == '买入'? Colors.green : Colors.red,
            width: 1.0,
            style: BorderStyle.solid
        ),
      );
    }

  }

  // 更改下单模式
  void changeOrderModel(String text) {
    print("当前下单模式=》${text}");
    setState(() {
      this._btnText = text;
    });
  }

  // 构建右侧区域
  Widget buildRightWidget() {
    return Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text('价格'),
              new Text('数量'),
            ],
          ),
          priceNum(arr: this.tradesDeep)
        ],
      ),
    );
  }

  /// 下单
  void makeOrder() async {
    // 关闭键盘
    FocusScope.of(context).requestFocus(FocusNode());
//    if (Global._prefsnetwork != 'ropsten') {
//      this.showSnackBar('请切换到ropsten网络');
//      return ;
//    }

    if (this.value == null) {
      this.showSnackBar('请选择左侧token');
      return ;
    }


    if (this.controllerAmount.text.length == 0) {
      this.showSnackBar('请输入数量');
      return ;
    }

    if (this.controllerPrice.text.length == 0) {
      this.showSnackBar('请输入价格');
      return ;
    }

    // 先检查授权
    this.checkApprove();
  }

  // 交易授权
  // 进行交易授权, 每一种token，只需要授权一次，目前没有接口确定token是否授权
  // 买入时对右边的token授权，
  // 卖出时对左边的token授权
  // 一句话说明：哪个token要被转出去给其他人，就给哪个token授权
  void checkApprove() async{
    if (this._btnText == '买入') {
      needApproveToken = this.baseToken[0]['address'];
    } else {
      needApproveToken = this.value['address'];
    }

    String res = await TokenService.allowance(context, needApproveToken);
    print('checkApprove res=> ${res}');
    if (res == '0') {
      // 授权额度为0，发起提示
      Map currentWallet = Provider.of<walletModel.Wallet>(context).currentWalletObject;
      if (currentWallet['balance'] == '0.00') {
        this.showSnackBar('您的钱包ETH余额为0，无法授权，不可以交易');
      } else {
        this.showAuthTips();
      }
    } else {
      // 已经授权
      this.getPwd(true);
    }
  }

  /// 获取用户密码
  /// 4E5398791AD2F8226CD134F0046138EAB5CAB8E3AA1D8887CB057E14ABC14E059F22DEB5117A5ECFFA5120F24B091415BD8ADF4E685877AFB2FCAB2C204F1DBF0F9D0A0C67D363B551CE5022D370B9EF
  /// approve 是否授权
  ///  发起授权之前，要先确认用户的钱包ETH有余额，否则无法授权
  void getPwd(bool approve) {
    Navigator.pushNamed(context, "getPassword").then((data) async{
      if (!approve) {
        await Trade.approve(needApproveToken, data);
      }
       this.startTrade(data);
    });
  }

  /// 提示授权需要密码
  void showAuthTips() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '授权交易',
              content: '为了便于后续兑换，需要您授权youwallet代理。youwallet只会在你授权的情况下才会执行交易，请放心授权！',
              onCancelChooseEvent: () {
                Navigator.pop(context);
                this.showSnackBar('取消交易');
              },
              onSuccessChooseEvent: () async {
                Navigator.pop(context);
                this.getPwd(false);
              });
        });
  }

  // 获取钱包密码，然后用密码解析私钥
  void startTrade(String pwd) async {
    bool isBuy = true;
    if (this._btnText == '买入') {
      isBuy = true;
    } else {
      isBuy = false;
    }
    this.showSnackBar('下单中···');
    if (this.controllerAmount.text is String) {
      print("this.controllerAmount.text is string");
    }
    Trade trade = new Trade(this.value['address'], this.value['name'], this.baseToken[0]['address'], this.baseToken[0]['name'], this.controllerAmount.text, this.controllerPrice.text, isBuy, pwd);
    String hash = await trade.takeOrder();
    if (hash.contains('RPCError')) {
      String barText = '';
      if (hash.contains('insufficient funds for gas * price + value')){
        barText = 'eth手续费不足，请先获取测试所需以太币';
      } else {
        barText = hash;
      }
      final snackBar = new SnackBar(content: new Text(barText));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
       // 下单成功后，刷新用户本地的历史兑换列表
       this.getTraderList();

       // 刷新交易深度
       this.getSellList();
    }
  }

  void showSnackBar(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }


   // 获取订单列表
   Future<void> getTraderList() async {
     List list = await Trade.getTraderList();
     setState(() {
       this.trades = list;
     });
     this._getTradeInfo();
   }

   // 获取当前的买单队列
   Future<void> getBuyList() async {
      String tokenAddress = this.value['address']; // 左边的token
      String baseTokenAddress = this.baseToken[0]['address']; // 右边的token
      bool isSell =  false;
      // 拿到队列中第一个订单的 bq_hash + od_hash
      String hash = await Trade.getOrderQueueInfo(tokenAddress, baseTokenAddress, isSell);
      // 把hash中的bq hash单独拿出来，同一个队列中的bq hash都是相同的 拿到QueueElem的订单结构体
      print('getBuyList hash => ${hash}');
      String bqHash = hash.replaceFirst('0x', '').substring(0,64);
      String odHash = hash.replaceFirst('0x', '').substring(64);

      String queueElem = await Trade.getOrderInfo(hash, isSell);
      this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
   }

   // 递归获取订单信息
   // queueElem后64位，是下一个订单的odHash,
   // 以前的bqHash + 下一个订单的odHash，拼接成新的hash，继续获取下一个订单
   Future<void> deepCallBackOrderInfo(String queueElem, String bqHash, bool isSell) async {
      this.buildQueueElem(queueElem.replaceFirst('0x', ''), isSell);
      String odHash = queueElem.substring(queueElem.length - 64);
      String nextHash = bqHash + odHash;
      String nextQueueElem = await Trade.getOrderInfo(nextHash, isSell);
      if (nextQueueElem != '0x' && odHash != '0000000000000000000000000000000000000000000000000000000000000000') {
        // 同一种类型的订单，达到三个就不再继续获取
        this.deepCallBackOrderInfo(nextQueueElem, bqHash, isSell);
      } else {
        //print('订单队列结束, 最后一个订单的odHash => ${odHash}');
        if (isSell) {
          // 卖单队列获取完毕，开始获取买单队列
          this.getBuyList();
        } else {
          print('deepCallBackOrderInfo =》 done');
        }
      }
   }

   // 获取卖单队列
   Future<void> getSellList() async {
     this.tradesDeep = []; // 清空当前的深度数组
     String tokenAddress = this.value['address'];
     String baseTokenAddress = this.baseToken[0]['address'];
     bool isSell = true;
     String hash = await Trade.getOrderQueueInfo(tokenAddress, baseTokenAddress, isSell);
     String bqHash = hash.replaceFirst('0x', '').substring(0,64);
     String queueElem = await Trade.getOrderInfo(hash, isSell);
     this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
   }

   // 解析queueElem 深度列表的数据需要合并处理，规则如下
   // https://github.com/youwallet/wallet/issues/44#issuecomment-575859132
   void buildQueueElem(String queueElem, bool isSell) {
     BigInt filled = BigInt.parse(queueElem.substring(queueElem.length - 128, queueElem.length - 64), radix: 16);
     // print(filled);
     // print(queueElem.replaceFirst('0x', '').substring(64, 128));
     BigInt baseTokenAmount  = BigInt.parse(queueElem.replaceFirst('0x', '').substring(64, 128), radix: 16);
     // print(baseTokenAmount);
     // BigInt quoteTokenAmount = BigInt.parse(queueElem.replaceFirst('0x', '').substring(128, 192));
     BigInt quoteTokenAmount = BigInt.parse(queueElem.replaceFirst('0x', '').substring(128, 192), radix: 16);
     print("=======================================");
     print("baseTokenAmount   => ${baseTokenAmount}");
     print("quoteTokenAmount  => ${quoteTokenAmount}");
     print("左边显示价格        => ${baseTokenAmount/quoteTokenAmount}");
     print("filled            => ${filled}");
     print("右边显示数量        => ${baseTokenAmount - filled}");
     print("isSell            => ${isSell}");
     if (baseTokenAmount != BigInt.from(0)) {

       String left = (quoteTokenAmount/baseTokenAmount).toStringAsFixed(5);

       // 这里的baseTokenAmount是包含18小数位数的10进制数据，先砍掉小数位
       // 标准做法是根据token对应的小数位
       double right = (baseTokenAmount - filled) / BigInt.from(pow(10, 18));
       int index = this.tradesDeep.indexWhere((element) => element['left']==left && element['isSell']== isSell);

       if (index == -1) {
         Map obj = {
           'left': left,
           'right': right.toStringAsFixed(2),
           'isSell': isSell
         };
         if (isSell) {
           // 如果队列中买单数量已经达到三个，就不要再向队列中增加
           int lenSellOrder = this.tradesDeep.where((e)=>(e['isSell'])).length;
           if (lenSellOrder < 3) {
             setState(() {
               this.tradesDeep.insert(0,obj);
             });
           } else {
             print('卖单队列已经到达三个，第四个开始不显示 => ${obj}');
           }

         } else {
           // 如果队列中买单数量已经达到三个，就不要再向队列中增加
           int lenBuyOrder = this.tradesDeep.where((e)=>(!e['isSell'])).length;
           if (lenBuyOrder < 3) {
             setState(() {
               this.tradesDeep.add(obj);
             });
           } else {
             print('买单队列已经到达三个，第四个开始不显示 => ${obj}');
           }
         }
       } else {
         // 价格相同的订单合并，数量相加即可
         setState(() {
           this.tradesDeep[index]['right'] = double.parse(this.tradesDeep[index]['right']) + right ;
         });
       }
     }
   }


   /// 遍历每个订单的状态
   /// 将查询到的匹配数量保存在数据库中
   /// 如果订单中的数量已经匹配完毕，则代表这个订单转账成功，刷新的时候不再遍历
   Future<void> _getTradeInfo() async {
     Map filled = {};
     for(var i = 0; i<this.trades.length; i++) {
       if(this.trades[i]['status'] != '成功') {
         //double amount = await Trade.getFilled(this.trades[i]['odHash']) /

         double amount = await Trade.getFilled(this.trades[i]['odHash']);
         //double amount = BigInt.parse(res, radix: 16)/BigInt.from(pow(10 ,18));
         print('查询订单   =》${this.trades[i]['txnHash']}');
         print('匹配情况   =》${amount}');
         // 保存匹配的数量进入数据库
         int sqlRes = await Provider.of<Deal>(context).updateFilled(
             this.trades[i], amount.toString());
         filled[this.trades[i]['txnHash']] = (amount).toString();
       } else {
         print('查询订单   =》${this.trades[i]['txnHash']}，该订单已经匹配完毕');
       }
     }
     setState(() {
       this.filledAmount = filled;
     });
     print(this.filledAmount);
   }

   // 计算交易额度
   void computeTrade() {
     if (this.controllerAmount.text.length == 0) {
       return ;
     }

     if (this.controllerPrice.text.length == 0) {
       return ;
     }

     setState(() {
       this.tradePrice = double.parse(this.controllerAmount.text) * double.parse(this.controllerPrice.text);
     });
   }

  // 下拉刷新底部交易列表
  Future<void> _refresh() async {
//    await this._getTradeInfo();
    await this.getTraderList();
    this.showSnackBar('刷新结束');
  }

  // 构建token选择
//  Widget buildTokenSelect() {
//    return
//  }


  /// 选左边的token
  /// token只显示当前钱包的token，其他钱包添加的token不显示
  void selectToken() async {
    String wallet = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    List tokens = Provider.of<Token>(context).items.where((e)=>(e['wallet'] == wallet)).toList();
    if (tokens.length == 0) {
      this.showSnackBar('请先添加token');
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return BottomSheetDialog(
              content: tokens,
              onSuccessChooseEvent: (res) {
                print(res);
                setState(() {
                  this.value = res;
                  this.suffixText = res['name'];
                });
                this.getSellList();
              });
        }
    );
  }

}
