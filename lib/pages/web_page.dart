import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebMain extends StatelessWidget {
  String url;
  String title;
  WebMain(this.url, this.title);
  @override
  Widget build(BuildContext context) {
    
    // WebviewScaffold是插件提供的组件，用于在页面上显示一个WebView并加载URL
    return new WebviewScaffold(
      url: this.url,
      // 登录的URL
      appBar: new AppBar(
        title: Text(this.title),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      // 允许网页缩放
      withLocalStorage: true,
      // 允许LocalStorage
      withJavascript: true, // 允许执行js代码
    );
  }
}
