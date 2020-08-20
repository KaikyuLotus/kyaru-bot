class Post {
  int id;
  String rating;
  String tagString;
  String fileUrl;
  String largeFileUrl;
  String previewFileUrl;
  String fileExt;

  Post(this.id, this.rating, this.tagString, this.fileUrl, this.largeFileUrl, this.previewFileUrl, this.fileExt);

  factory Post.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return Post(
      json['id'],
      json['rating'],
      json['tag_string'],
      json['file_url'],
      json['large_file_url'],
      json['preview_file_url'],
      json['file_ext'],
    );
  }

  static List<Post> listFromJsonArray(dynamic jsonArray) {
    if (jsonArray == null) {
      return null;
    }
    return List.generate(jsonArray.length, (i) => Post.fromJson(jsonArray[i]));
  }
}
