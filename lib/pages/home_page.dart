import 'package:douban/pages/search_page.dart';

import '../widgets/star.dart';
import 'package:douban/model/movie.dart';
import 'package:douban/pages/web_page.dart';
import 'package:flutter/material.dart';
import '../widgets/search_input.dart';
import 'package:douban/httpUtils.dart';
import 'more_page.dart';

class HomePage extends StatefulWidget {
  State createState() {
    return _HomePageState();
  }
}

enum MovieState { loading, loaded, fail }

class _HomePageState extends State<HomePage> {
  List<Movie> _recentMovies;
  List<Movie> _topMovies;
  List<Movie> _hotMovies;
  List<Movie> _upcomingMovies;
  HttpUtils util = new HttpUtils();

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("主页"),
          centerTitle: true,
          leading: Text(""),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _recentMovies != null &&
                    _upcomingMovies != null &&
                    _topMovies != null
                ? [
                    buildSearchPart(),
                    buildMovie('正在上映'),
                    buildMovie('即将上映'),
                    buildMovie('豆瓣热门'),
                    buildMovie("Top250")
                  ]
                : [
                    Center(
                        child: Column(children: <Widget>[
                      SizedBox(height: 200),
                      CircularProgressIndicator(strokeWidth: 4.0),
                      Text('正在加载')
                    ]))
                  ],
          ),
        ));
  }

  void initState() {
    _requestData();
  }

  void _requestData() {
    util
        .getMovieData(0, 15, 'movie_showing')
        .then((data) => setState(() => _recentMovies = data['data']));
    util
        .getMovieData(0, 15, 'movie_soon')
        .then((data) => setState(() => _upcomingMovies = data['data']));
    util
        .getMovieData(0, 15, 'movie_hot')
        .then((data) => setState(() => _hotMovies = data['data']));
    util
        .getMovieData(0, 15, 'movie_top250')
        .then((data) => setState(() => _topMovies = data['data']));
  }

  Widget buildSearchPart() {
    return Container(
      child: SearchInputWidget(onTap: _onFocusSearchInput,autofocus: false,),
      color: Colors.green,
      height: 60,
      width: MediaQuery.of(context).size.width,
    );
  }

  Widget buildMovie(String keyword) {
    List<Widget> movies = [];

    if (keyword == '正在上映') {
      for (var item in _recentMovies) {
        movies.add(buildMovieItem(item, keyword));
      }
    }
    if (keyword == '即将上映') {
      for (var item in _upcomingMovies) {
        movies.add(buildMovieItem(item, keyword));
      }
    }
    if (keyword == 'Top250') {
      for (var item in _topMovies) {
        movies.add(buildMovieItem(item, keyword));
      }
    }
    if (keyword == '豆瓣热门') {
      for (var item in _hotMovies) {
        movies.add(buildMovieItem(item, keyword));
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 220,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  keyword,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MorePage(keyword)));
                  },
                  child: Text(
                    "查看更多>",
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                )
              ],
            ),
            width: MediaQuery.of(context).size.width,
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: movies,
            ),
          )
        ],
      ),
    );
  }

  Widget buildMovieItem(Movie movie, String keyword) {
    Widget starOrSee;
    if (keyword == '正在上映' || keyword == '豆瓣热门' || keyword == 'Top250') {
      starOrSee = new Container(
        padding: EdgeInsets.only(left: 5, top: 5),
        height: 20,
        width: 80,
        child: movie.score == null
            ? Text(
                '暂无评分',
                style: TextStyle(fontSize: 10),
              )
            : StarWidget(movie.score, 5),
      );
    } else if (keyword == '即将上映') {
      starOrSee = new Container(
          padding: EdgeInsets.only(left: 5, top: 5),
          height: 20,
          width: 80,
          child: Text(
            '${movie.wishCount}' + '人想看',
            style: TextStyle(fontSize: 10),
          ));
    }
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebMain(
                      'https://movie.douban.com/subject/' + movie.id,
                      movie.title)));
        },
        child: Column(
          children: [
            Container(
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                padding: EdgeInsets.only(left: 16),
                width: 100,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'images/movie_default.png',
                    image: movie.img,
                    fit: BoxFit.cover,
                  ),
                )),
            Container(
                width: 80,
                padding: EdgeInsets.only(top: 5, left: 5),
                child: Text(
                  movie.title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
            starOrSee
          ],
        ));
  }

  void _onFocusSearchInput() {
    Navigator.push(context,
         MaterialPageRoute(builder: (context) => SearchPage()));
  }
}
