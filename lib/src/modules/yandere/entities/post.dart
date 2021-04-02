class Post {
  int id;
  String rating;
  String tags;
  String? fileUrl;
  String? sampleUrl;
  String? jpegUrl;

  Post(
    this.id,
    this.rating,
    this.tags,
    this.fileUrl,
    this.sampleUrl,
    this.jpegUrl,
  );

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      json['id'],
      json['rating'],
      json['tags'],
      json['file_url'],
      json['sample_url'],
      json['jpeg_url'],
    );
  }

  static List<Post> listFromJsonArray(dynamic jsonArray) {
    return List<Post>.generate(
      jsonArray.length,
      (i) => Post.fromJson(jsonArray[i]),
    );
  }
}
