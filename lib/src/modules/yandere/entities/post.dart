class Post {
  Post(this.id, this.rating, this.tags, this.fileUrl, this.sampleUrl, this.jpegUrl);

  factory Post.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Post(
      json['id'] as int,
      json['rating'] as String,
      json['tags'] as String,
      json['file_url'] as String,
      json['sample_url'] as String,
      json['jpeg_url'] as String,
    );
  }

  int id;
  String rating;
  String tags;
  String fileUrl;
  String sampleUrl;
  String jpegUrl;

  static List<Post> listFromJsonArray(List<dynamic> jsonArray) {
    if (jsonArray == null) return null;
    return List<Post>.generate(jsonArray.length, (int i) => Post.fromJson(jsonArray[i] as Map<String, dynamic>));
  }
}
