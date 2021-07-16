import 'package:html/parser.dart';

String removeAllHtmlTags(String htmlText) => parse(htmlText).body!.text;
