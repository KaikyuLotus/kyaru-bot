class ImgAssets {
  ImgAssets(this.icon, this.banner);

  factory ImgAssets.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ImgAssets(
      json['icon'] as String,
      json['banner'] as String,
    );
  }

  String icon;
  String banner;
}
