import 'package:douban/db/like_provider.dart';
import 'package:douban/httpUtils.dart';
import 'package:douban/model/search_item.dart';
import 'package:douban/pages/web_page.dart';
import 'package:douban/widgets/search_input.dart';
import 'package:douban/widgets/star.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchPage extends StatefulWidget {
    LikeProvider likeProvider = LikeProvider();
  State createState() {
    return _searchPageState();
  }
}

enum SearchState { typing, loading, done, empty, fail }

class _searchPageState extends State<SearchPage> {
  List<SearchItem> _likedItems = [];
  var _searchState = SearchState.typing;
  List<SearchItem> _searchResult = [];
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
  String _searchKeyWord;
  _searchPageState() {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixel = _controller.position.pixels;
      if (maxScroll - pixel <= 50) {
        if (_searchResult.length < totalSize) {
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
  Future _pullToRefresh() async {
    currentPage = 0;
    _searchResult.clear();
    _onSubmittedSearchWord(this._searchKeyWord);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: SearchInputWidget(
                onSubmitted: _onSubmittedSearchWord,
                onTextChamged: _onSearchTextChanged,
                autofocus: true,
              ),
              color: Colors.green,
              height: 60,
              width: MediaQuery.of(context).size.width,
            ),
            Container(height: 15),
            _buildPageBody()
          ],
        ),
      ),
    );
  }
  void initState(){
     widget.likeProvider
        .query()
        .then((list) => setState(() => _likedItems = list));
  }
  Widget _buildPageBody() {
    switch (_searchState) {
      case SearchState.typing:
        return Container(
          child: null,
        );
      case SearchState.loading:
        return _buildLoadingWidget();
      case SearchState.done:
        return _buildSearchResult();
      case SearchState.fail:
      case SearchState.empty:
        return _buildSearchError();
    }
  }

  void _loadData() {
    this.currentPage++;
    var start = (currentPage - 1) * count;
    util.getSearchData(start, count, this._searchKeyWord).then(
        (data) => setState(() {
              _searchResult.addAll(data['data']);
            }), onError: (e) {
      setState(() {
        Fluttertoast.showToast(
            msg: "遇到问题啦~",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM, // 消息框弹出的位置
            timeInSecForIos: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    });
  }

  void _onSubmittedSearchWord(String value) {
    value = value.trim();
    if (value.isEmpty) return;
    this.currentPage = 0;
    _searchResult.clear();
    this.currentPage++;
    _searchKeyWord = value;
    setState(() => _searchState = SearchState.loading);
    var start = (currentPage - 1) * count;
    util.getSearchData(start, count, _searchKeyWord).then((data) {
      setState(() {
        _searchState = SearchState.done;
        _searchResult.addAll(data['data']);
        totalSize = data['total'];
      });
    }, onError: (e) {
      setState(() {
        print(e);
        _searchState = SearchState.fail;
      });
    });
  }

  Widget _buildLoadingWidget() {
    return Center(
      heightFactor: 6,
      child: Column(
        children: <Widget>[
          CircularProgressIndicator(strokeWidth: 4.0),
          Text('正在搜索')
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    return Expanded(
        child: Column(children: <Widget>[
      Row(
        children: <Widget>[
          Text('搜索结果(${totalSize})',
              style: TextStyle(color: Colors.black, fontSize: 12))
        ],
      ),
      Expanded(
        child: new RefreshIndicator(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index == _searchResult.length) {
                  return _buildProgressMoreIndicator();
                } else {
                  return renderRow(index, context);
                }
              },
              itemCount: _searchResult.length + 1,
              controller: _controller,
            ),
            onRefresh: _pullToRefresh),
      )
    ]));
  }

  Widget _buildSearchError() {
    return Center(
      heightFactor: 3,
      child: Column(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              iconSize: 96,
              onPressed: () => _onSubmittedSearchWord(_searchKeyWord)),
          Text('发生了错误，点击重试')
        ],
      ),
    );
  }

  void _onSearchTextChanged(String value) {
    setState(() {
      _searchKeyWord = value.trim();
      _searchState = SearchState.typing;
    });
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
    SearchItem item = _searchResult[index];
    return Container(
      height: 100,
      child: new InkWell(
        onTap: () {
          String url;
          if (item.type == 'tv' || item.type == 'movie')
            url = 'https://movie.douban.com/subject/' + item.id;
          else if (item.type == 'book' || item.type == 'music')
            url = 'https://${item.type}.douban.com/subject/' + item.id;
          else {
            url = 'https://www.douban.com/${item.type}/' + item.id;
            print(url);
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebMain(url, item.title)));
        },
        child: new Column(
          children: [
            new Container(
              height: 99,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Container(
                    width: 60,
                    height: (item.type == 'game' ||
                            item.type == 'app' ||
                            item.type == 'music')
                        ? 60
                        : 80,
                    margin: EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/movie_default.png',
                        image: item.img,
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
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                          child: item.score == 0.0
                              ? Text(
                                  '暂无评分',
                                  style: TextStyle(fontSize: 10),
                                )
                              : StarWidget(item.score, 5),
                          padding: EdgeInsets.only(top: 5),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(item.typeName + ' ',
                                  style: TextStyle(
                                      backgroundColor:
                                          Color.fromARGB(225, 225, 225, 225),
                                      fontSize: 11)),
                              Container(
                                  child: Text(item.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  width: MediaQuery.of(context).size.width-180)
                            ],
                          ),
                          padding: EdgeInsets.only(top: 5),
                          width: 400,
                        )
                      ],
                    ),
                  )),
                  IconButton(
                      icon: Icon(
                        getLikedIds().contains(item.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        
                        if (getLikedIds().contains(item.id)) {
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
