import 'dart:convert';
import 'dart:io';
import 'package:douban/model/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/search_item.dart';

class HttpUtils {
  String apikey = '054022eaeae0b00e0fc068c0c0a2102a';
  HttpClient _httpClient = HttpClient();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<Map<String, dynamic>> getMovieData(
      int start, int count, String keyWord) async {
    String url =
        'http://frodo.douban.com/api/v2/subject_collection/$keyWord/items?start=$start&count=$count&apiKey=' +
            this.apikey;
    HttpClientRequest request = await _httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();

    var responseData = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseData);
    List<Movie> list = [];
    var dataList = json['subject_collection_items'];
    int total = json['subject_collection']['total'];
    dataList.forEach((item) {
      list.add(Movie.fromJson(item));
    });
    Map<String, dynamic> dataDic = {'data': list, 'total': total};
    return dataDic;
  }

  Future<Map<String, dynamic>> getSearchData(
      int start, int count, String keyWord) async {
    String url =
        'https://frodo.douban.com/api/v2/search/weixin?q=$keyWord&start=$start&count=$count&apiKey=' +
            this.apikey;

    url = Uri.encodeComponent(url);
    url = Uri.decodeComponent(url);

    HttpClientRequest request = await _httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();

    var responseData = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseData);

    List<SearchItem> list = [];
    List dataList = json['items'];
    int total = json['total'];
    
    if (dataList[0]['target_type'] == 'doulist_cards') {
      dataList.removeAt(0);
      total--;
    }
    dataList.forEach((item) {
      list.add(SearchItem.fromJson(item));
    });
    
    Map<String, dynamic> dataDic = {'data': list, 'total': total};
    return dataDic;
  }
}
