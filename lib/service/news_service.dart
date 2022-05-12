import '../manager/postmanager.dart';
import 'locator.dart';
import 'models/stories_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class GoldTrendNews {
  final _prefx = 'https://www.fxempire.com/';
  final _storyMgr = locator<PostManager>();
  final client = http.Client();
  Future<List<StoriesModel>> GetDailyNews() async {
    final response = await client.get('${_prefx}forecasts/gold');
    dom.Document document = parser.parse(response.body);
    var _elements = document.getElementsByClassName('Link-sc-1vbtzq4-0 bybXMs');
    for (int i = 0; i < _elements.length; i++) {
      if (_elements[i].outerHtml.contains('article')) {
        int startIndex = _elements[i].outerHtml.indexOf('href');
        int endIndex = _elements[i].outerHtml.indexOf('><h3');
        String article_url =
            _prefx + _elements[i].outerHtml.substring(startIndex, endIndex);
        break;
      }
    }
  }
}
