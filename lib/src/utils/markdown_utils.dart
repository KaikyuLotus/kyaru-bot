class MarkdownUtils {
  static String generateUrl(String text, String link) {
    return '[$text](${escape(link)})'; // TODO eventually escape text?
  }

  static String generateHiddenUrl(String link) {
    return generateUrl('\u200D', link);
  }

  static String escape(String string) {
    for (var c in ['_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!']) {
      string = string.replaceAll(c, '\\$c');
    }
    return string;
  }
}
