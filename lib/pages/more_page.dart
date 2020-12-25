import 'package:douban/db/like_provider.dart';
import 'package:douban/model/movie.dart';
import 'package:douban/model/search_item.dart';
import 'package:douban/pages/web_page.dart';
import 'package:douban/widgets/star.dart';
import 'package:flutter/material.dart';
import '../httpUtils.dart';

class MorePage extends StatefulWidget {
  LikeProvider likeProvider = LikeProvider();
  String keyword;
  MorePage(this.keyword);

  State createState() {
    return _morePageState(this.keyword);
  }
}

class _morePageState extends State<MorePage> {
  List<SearchItem> _likedItems = [];
  List<String> _itemsId = [];
  List<Movie> _movies = [];
  HttpUtils util = new HttpUtils();
  String keyword;
  int count = 20;
  int currentPage = 0;
  int totalSize = 0;
  String loadMoreText = '没有更多数据';
  TextStyle loadMoreTextStyle =
      new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
  TextStyle titleStyle =
      new TextStyle(color: const Color(0xFF757575), fontSize: 14.0);

  //初始化滚动监听器，加载更多使用
  ScrollController _controller = new ScrollController();
  Map<String, String> keyDic = {
    '正在上映': 'movie_showing',
    '即将上映': 'movie_soon',
    'Top250': 'movie_top250',
    '豆瓣热门': 'movie_hot'
  };
  _morePageState(this.keyword) {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixel = _controller.position.pixels;
      if (maxScroll - pixel <= 100) {
        if (_movies.length < totalSize) {
          setState(() {
            loadMoreText = '正在加载中...';
            loadMoreTextStyle =
                new TextStyle(color: const Color(0xFF4483f6), fontSize: 14.0);
          });
          _loadData();
        } else {
          setState(() {
            loadMoreText = '没有更多数据了';
            loadMoreTextStyle =
                new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.likeProvider
        .query()
        .then((list) => setState(() => _likedItems = list));
  }

  void _loadData() {
    this.currentPage++;
    var start = (currentPage - 1) * count;
    util
        .getMovieData(start, count, keyDic[this.keyword])
        .then((data) => setState(() {
              _movies.addAll(data['data']);
              totalSize = data['total'];
            }));
  }

  Future _pullToRefresh() async {
    currentPage = 0;
    _movies.clear();
    _loadData();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(this.keyword), centerTitle: true),
        body: _movies.length == 0
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : new RefreshIndicator(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == _movies.length) {
                      return _buildProgressMoreIndicator();
                    } else {
                      return renderRow(index, context);
                    }
                  },
                  itemCount: _movies.length + 1,
                  controller: _controller,
                ),
                onRefresh: _pullToRefresh));
  }

  Widget _buildProgressMoreIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(15),
      child: new Center(
        child: new Text(
          loadMoreText,
          style: loadMoreTextStyle,
        ),
      ),
    );
  }

  renderRow(index, context) {
    Movie movie = _movies[index];
    return Container(
      height: 100,
      child: new InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebMain(
                      'https://movie.douban.com/subject/' + movie.id,
                      movie.title)));
        },
        child: new Column(
          children: [
            new Container(
              height: 99,
              child: new Row(
                children: [
                  new Container(
                    width: 50,
                    height: 70,
                    margin: EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/movie_default.png',
                        image: movie.img,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    height: 90,
                    margin: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '  (${movie.year})',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(
                          child: movie.score == null && this.keyword != '即将上映'
                              ? Text(
                                  '暂无评分',
                                  style: TextStyle(fontSize: 10),
                                )
                              : this.keyword == '即将上映'
                                  ? Text(
                                      '${movie.wishCount}人想看',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  : StarWidget(movie.score, 5),
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: Text(movie.info,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          padding: EdgeInsets.only(top: 5),
                          width: 300,
                        )
                      ],
                    ),
                  )),
                  IconButton(
                      icon: Icon(
                        getLikedIds().contains(movie.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        SearchItem item = SearchItem(
                            id: movie.id,
                            img: movie.img,
                            title: movie.title,
                            type: 'movie',
                            score: movie.score);

                        if (getLikedIds().contains(movie.id)) {
                          deletLike(item);
                        } else {
                          insertLike(item);
                        }
                      })
                ],
              ),
            ),
            new Divider(
              height: 1,
            )
          ],
        ),
      ),
    );
  }

  void insertLike(SearchItem item) {
    widget.likeProvider
        .insert(item)
        .then((value) => setState(() {
              _likedItems.add(item);
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
    for (SearchItem item in _likedItems) {
      if (item.id == targetItem.id) {
        _likedItems.removeAt(index);
        return;
      }
      index++;
    }
  }

  List<String> getLikedIds() {
    List<String> list = [];
    for (SearchItem item in _likedItems) {
      list.add(item.id);
    }
    return list;
  }
}
