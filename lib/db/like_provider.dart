


import 'package:douban/model/search_item.dart';

import 'database_provider.dart';
class LikeProvider extends TableProvider<SearchItem> {
  static final String likedTable = 'like_table';
  @override
  String get table => likedTable;

  @override
  Map<String, dynamic> toMap(SearchItem t) {
    var map = <String, dynamic>{
      'id': t.id,
      'img': t.img,
      'title':t.title,
      'type':t.type,
      'score':t.score,
    };

    if (t.id != null) {
      map['id'] = t.id;
    }
    return map;
  }

  @override
  SearchItem fromMap(Map<String, dynamic> map) =>
      SearchItem(id: map['id'],img: map['img'],title: map['title'],type: map['type'],score: map['score']);

  deleteById(String id) => super.delete(where: 'id = ?', whereArgs: [id]);
}
