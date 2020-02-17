
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class GetPasswordPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<GetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Builder(builder: (BuildContext context) {
          return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 22.0),
                children: <Widget>[
                  SizedBox(height: kToolbarHeight,),
                  buildTitle(),
                  buildTitleLine(),
                  SizedBox(height: 70.0),
                  buildEmailTextField(),
//                  SizedBox(height: 30.0),
//                  buildPasswordTextField(context),
                  SizedBox(height: 60.0),
                  buildLoginButton(context),
                ],
              )
          );
        })
    );
  }

  // 获取用户两次输入的密码，两次密码必须相同
  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: new MaterialButton(
          color: Colors.blue,
          textColor: Colors.white,
          minWidth: 300, // 控制按钮宽度
          child: new Text('确定'),
          onPressed: () {
            _formKey.currentState.save();
            if (!_email.isEmpty) {
              Navigator.of(context).pop(_email);
            } else {
              final snackBar = new SnackBar(content: new Text('密码不能为空'));
              Scaffold.of(context).showSnackBar(snackBar);
            }
          },
        ),
      ),
    );
  }


  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      decoration: InputDecoration(
        labelText: '请再次输入密码',
//          suffixIcon: IconButton(
//              icon: Icon(
//                Icons.remove_red_eye,
//                color: _eyeColor,
//              ),
//              onPressed: () {
//                setState(() {
//                  _isObscure = !_isObscure;
//                  _eyeColor = _isObscure
//                      ? Colors.grey
//                      : Theme.of(context).iconTheme.color;
//                });
//              })
      ),
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '请输入密码',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入密码';
        }
      },
      onSaved: (String value) => _email = value,
    );
  }

  Padding buildTitleLine() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.white,
          width: 40.0,
          height: 2.0,
        ),
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '',
        style: TextStyle(fontSize: 42.0),
      ),
    );
  }
}