class MangaChapter implements Comparable<MangaChapter> {
  double number;
  double date;
  String title;
  String id;

  String titleText() {
    var text = number.toString();
    if (title != null && title != text && title != number.toInt().toString()) {
      text += ': ' + title;
    }
    return text;
  }

  Map<String, dynamic> toJsonable() {
    return {
      'number': number,
      'date': date,
      'title': title,
      'id': id
    };
  }

  static MangaChapter fromJson(Map<String, dynamic> json) {
    var chapter = MangaChapter();
    chapter.number = json['number'];
    chapter.date = json['date'];
    chapter.title = json['title'];
    chapter.id = json['id'];
    return chapter;
  }

  @override
  int compareTo(MangaChapter other) {
    return other != null ? other.number.compareTo(number) : -1;
  }
}