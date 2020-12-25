class Movie {
  String id;
  String title;
  double score;
  String year;
  String date;
  String info;
  String img;
  int wishCount;

  Movie(
      {this.id,
      this.title,
      this.score,
      this.year,
      this.date,
      this.info,
      this.img,
      this.wishCount});
  Movie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    year = json['year'];
    date = json['release_date'];
    info = json['info'];
    img = json['cover']['url'];
    try {
      wishCount = json['wish_count'];
      score = json['rating']['value'];
    } catch (e) {}
  }
}
