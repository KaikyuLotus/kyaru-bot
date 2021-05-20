class MarkdownUtils {
  static String generateUrl(String text, String link) {
    return '[${escape(text)}](${escape(link)})';
  }

  static String generateHiddenUrl(String link) {
    return generateUrl('\u200D', link);
  }

  static String? escape(String? string, {bool v2 = true}) {
    var markdownV1 = RegExp(r'[_*`[]');
    var markdownV2 = RegExp(r'[_*[\]()~`>#+\-=|{}.!]');

    var pattern = v2 ? markdownV2 : markdownV1;

    return string?.replaceAllMapped(pattern, (match) => '\\${match.group(0)}');
  }
}
