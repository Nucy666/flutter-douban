class SearchItem {
  String title;
  String id;
  String img;
  double score;
  String subtitle;
  String type;
  String typeName;
  SearchItem({this.id, this.title, this.img, this.score, this.type});
  SearchItem.fromJson(Map<String, dynamic> json) {
    title = json['target']['title'];
    id = json['target']['id'];
    score = double.parse(json['target']['rating']['value'].toString());
    subtitle = json['target']['card_subtitle'];
    img = json['target']['cover_url'];
    type = json['target_type'];
    typeName = json['type_name'];
  }
}
