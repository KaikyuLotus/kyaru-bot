class Post {
  int? id;
  String? rating;
  String? tagString;
  String? fileUrl;
  String? largeFileUrl;
  String? previewFileUrl;
  String? fileExt;

  int width;
  int height;
  int fileSize;

  Post(
    this.id,
    this.rating,
    this.tagString,
    this.fileUrl,
    this.largeFileUrl,
    this.previewFileUrl,
    this.fileExt,
    this.width,
    this.height,
    this.fileSize,
  );

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      json['id'],
      json['rating'],
      json['tag_string'],
      json['file_url'],
      json['large_file_url'],
      json['preview_file_url'],
      json['file_ext'],
      json['image_width'],
      json['image_height'],
      json['file_size'],
    );
  }

  static List<Post> listFromJsonArray(dynamic jsonArray) {
    return List.generate(
      jsonArray.length,
      (i) => Post.fromJson(jsonArray[i]),
    );
  }
}
