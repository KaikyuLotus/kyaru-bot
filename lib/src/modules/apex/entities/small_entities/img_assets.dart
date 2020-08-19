class ImgAssets {
  String icon;
  String banner;

  ImgAssets(this.icon, this.banner);

  factory ImgAssets.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return ImgAssets(
      json['icon'],
      json['banner'],
    );
  }
}
