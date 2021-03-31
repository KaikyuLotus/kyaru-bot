class ImgAssets {
  String? icon;
  String? banner;

  ImgAssets(this.icon, this.banner);

  static ImgAssets fromJson(Map<String, dynamic> json) {
    return ImgAssets(json['icon'], json['banner']);
  }
}
