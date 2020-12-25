import 'package:douban/db/like_provider.dart';
import 'package:douban/model/search_item.dart';
import 'package:douban/pages/web_page.dart';
import 'package:douban/widgets/star.dart';
import 'package:flutter/material.dart';

class LikePage extends StatefulWidget {
  LikeProvider likeProvider = LikeProvider();
  String keyword;
  LikePage(this.keyword);

  State createState() {
    return _likePageState(this.keyword);
  }
}

class _likePageState extends State<LikePage> {
  String keyword;
  Map<String, String> keyDic = {
    'movie': '影视',
    'music': '音乐',
    'book': '书籍',
    'app': '应用',
    'game': '游戏'
  };
  List<SearchItem> _likeList = [];
  _likePageState(this.keyword);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            title: Text('喜欢的${keyDic[this.keyword]}'), centerTitle: true),
        body: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                alignment: Alignment.topLeft,
                child: Text(
                  '喜欢的${keyDic[this.keyword]}数量为${_likeList.length}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              _buildLikeList()
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    widget.likeProvider.query().then((list) => setState(() {
          for (SearchItem item in list) {
            if (item.type == this.keyword) {
              _likeList.add(item);
            }
          }
        }));
  }

  Widget _buildLikeList() {
    return Expanded(
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: _likeList.length,
        itemBuilder: (context, index) {
          return _buildItem(index);
        },
      ),
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
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FadeInImage.assetNetwork(
                placeholder: 'images/movie_default.png',
                image: _likeList[index].img,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(_likeList[index].title),
            subtitle: Container(
              child: _likeList[index].score == 0.0 ||
                      _likeList[index].score == null
                  ? Text(
                      '暂无评分',
                      style: TextStyle(fontSize: 10),
                    )
                  : StarWidget(_likeList[index].score, 5),
              padding: EdgeInsets.only(top: 5),
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () {
                  deletLike(_likeList[index]);
                }),
          ),
        ),
        onTap: () {
          String url;
          if (_likeList[index].type == 'tv' || _likeList[index].type == 'movie')
            url = 'https://movie.douban.com/subject/' + _likeList[index].id;
          else if (_likeList[index].type == 'book' ||
              _likeList[index].type == 'music')
            url = 'https://${_likeList[index].type}.douban.com/subject/' +
                _likeList[index].id;
          else {
            url = 'https://www.douban.com/${_likeList[index].type}/' +
                _likeList[index].id;
            print(url);
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebMain(url, _likeList[index].title)));
        });
  }

  void insertLike(SearchItem item) {
    widget.likeProvider
        .insert(item)
        .then((value) => setState(() {
              _likeList.add(item);
            }))
        .catchError((e) {
      print(e);
    });
  }

  void deletLike(SearchItem item) {
    widget.likeProvider
        .deleteById(item.id)
        .then((value) => setState(() {
              removeItem(item);
            }))
        .catchError((e) {
      print(e);
    });
  }

  void removeItem(SearchItem targetItem) {
    int index = 0;
    for (SearchItem item in _likeList) {
      if (item.id == targetItem.id) {
        _likeList.removeAt(index);
        return;
      }
      index++;
    }
  }

  List<String> getLikedIds() {
    List<String> list = [];
    for (SearchItem item in _likeList) {
      list.add(item.id);
    }
    return list;
  }
}
