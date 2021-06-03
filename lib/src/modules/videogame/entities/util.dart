// TODO: Create one util file

String removeAllHtmlTags(String htmlText) {
  var exp = RegExp(
    r"<[^>]*>",
    multiLine: true,
    caseSensitive: true,
  );

  return htmlText.replaceAll('<br>', '\n').replaceAll(exp, '');
}
