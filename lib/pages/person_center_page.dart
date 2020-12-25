import 'package:douban/db/like_provider.dart';
import 'package:douban/pages/like_page.dart';
import 'package:flutter/material.dart';

class PersonalCenter extends StatefulWidget {
  LikeProvider likeProvider = new LikeProvider();
  State createState() {
    return _PersonalCenterState();
  }
}

class _PersonalCenterState extends State<PersonalCenter> {
  List typeName = ['影视', '音乐', '书籍', '应用', '游戏'];
  List type = ['movie', 'music', 'book', 'app', 'game'];
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        centerTitle: true,
        leading: Text(''),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeadPart(), _buildLikePart(), _buildLikeList()],
        ),
      ),
    );
  }

  Widget _buildHeadPart() {
    return Container(
      color: Colors.green,
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            child: ClipOval(
              child: Image.network(
                "https://q1.qlogo.cn/g?b=qq&s=100&nk=2285352317",
                width: 75,
                height: 75,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            height: 56,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('hhydrogen',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20)),
                Container(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '关注 0',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text('粉丝 200', style: TextStyle(color: Colors.white))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLikePart() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Column(
        children: [
          Text(
            '我的喜欢',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red[300]),
          )
        ],
      ),
    );
  }

  Widget _buildLikeList() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildItem(index);
      },
    );
  }

  Widget _buildItem(int index) {
    return InkWell(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
          ),
          child: ListTile(
            leading: Image.asset('images/${type[index]}.png',width: 36,height: 36,),
            title: Text(typeName[index]),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        onTap: () {
          pushToLikePage(type[index]);
        });
  }

  void pushToLikePage(String keyword) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LikePage(keyword)));
  }
}
