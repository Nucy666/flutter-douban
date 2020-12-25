import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  State createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopWidget(),
            _buildAccountEditTextField(),
            _buildPwdEditTextField(),
            _buildLoginButton()
          ],
        ),
      ),
    );
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  var _accountController = TextEditingController();
  var _pwdController = TextEditingController();

  void _checkUserInput() {
    if (_accountText.isNotEmpty && _pwdText.isNotEmpty) {
      if (_isEnableLogin) return;
    } else {
      if (!_isEnableLogin) return;
    }
    setState(() {
      _isEnableLogin = !_isEnableLogin;
    });
  }

  @override
  void initState() {
    _prefs.then((prefs) {
      _accountText = prefs.getString('UserAccount') ?? null;
      _accountController.text = _accountText;
      _pwdText = prefs.getString('UserPassword') ?? null;
      _pwdController.text = _pwdText;

      _checkUserInput();
    });
  }

  _getLoginButtonPressed() {
    if (!_isEnableLogin) return null;
    return () async {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('UserAccount', _accountText);
      prefs.setString('UserPassword', _pwdText);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    };
  }

  //顶部logo
  final _borderRadius = BorderRadius.circular(6);
  Widget _buildTopWidget() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("images/douban_logo.png"),
          Text(
            "欢迎登录豆瓣账户",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

//账号输入框
  String _accountText = "";
  String _pwdText = "";
  Widget _buildAccountEditTextField() {
    return Container(
      margin: EdgeInsets.only(top: 80),
      child: TextField(
        controller: _accountController,
        onChanged: (text) {
          _accountText = text;
          _checkUserInput();
        },
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            hintText: "请输入手机号/用户名/邮箱",
            filled: true,
            fillColor: Color.fromARGB(255, 240, 240, 240),
            contentPadding: EdgeInsets.only(left: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none)),
      ),
    );
  }

//密码输入框
  bool _obscureText = true;
  Widget _buildPwdEditTextField() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: TextField(
        controller: _pwdController,
        onChanged: (text) {
          _pwdText = text;
          _checkUserInput();
        },
        style: TextStyle(fontSize: 18),
        obscureText: _obscureText,
        decoration: InputDecoration(
            hintText: "请输入登录密码",
            filled: true,
            fillColor: Color.fromARGB(255, 240, 240, 240),
            contentPadding: EdgeInsets.only(left: 8),
            border: OutlineInputBorder(
                borderSide: BorderSide.none, borderRadius: _borderRadius),
            suffixIcon: IconButton(
              icon: Image.asset(
                _obscureText ? "images/hide.png" : "images/open.png",
                width: 20,
                height: 20,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )),
      ),
    );
  }

  bool _isEnableLogin = false;
  Widget _buildLoginButton() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: RaisedButton(
        child: Text("登 录", style: TextStyle(fontSize: 18)),
        color: Colors.green,
        disabledColor: Colors.black12,
        textColor: Colors.white,
        disabledTextColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        onPressed: _getLoginButtonPressed(),
      ),
    );
  }
}
