import 'dart:convert';
import 'models/stock_model.dart';
import 'package:http/http.dart' as http;

class MarketService {
  final client = http.Client();
  List<BidAsk> activelst = List<BidAsk>();

  Future<bool> fetchprices() async {
    final response = await client.get(
        'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XAU/USD');
    final response_silver = await client.get(
        'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XAG/USD');
    final response_platium = await client.get(
        'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XPT/USD');
    final response_palladium = await client.get(
        'https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/XPD/USD');
    final body = List<String>();
    body.add(response.body);
    body.add(response_silver.body);
    body.add(response_platium.body);
    body.add(response_palladium.body);
    return parsePrice(body);
  }

  bool parsePrice(List<String> responseBody) {
    try {
      String symbol;
      String name;
      for (int i = 0; i < responseBody.length; i++) {
        var data = jsonDecode(responseBody[i]);
        var _data = data[0]['spreadProfilePrices'];
        switch (i) {
          case 0:
            symbol = 'XAUUSD';
            name = 'Gold Real Time';
            break;
          case 1:
            symbol = 'XAGUSD';
            name = 'Silver Real Time';
            break;
          case 2:
            symbol = 'XPTUSD';
            name = 'Platium Real Time';
            break;
          case 3:
            symbol = 'XPDUSD';
            name = 'Palladium Real Time';
            break;
        }

        var dummy = new BidAsk();
        var p = activelst.firstWhere((e) => e.symbol == symbol,
            orElse: () => dummy);
        if (p != dummy) {
          var lx = activelst[activelst.indexOf(p)];
          lx.ask = _data[0]['ask'];
          lx.change = _data[0]['bid'] - lx.bid;
          lx.changepct = lx.change / lx.bid;
          lx.bid = _data[0]['bid'];
        } else {
          dummy.symbol = symbol;
          dummy.name = name;
          dummy.bid = _data[0]['bid'];
          dummy.ask = _data[0]['ask'];
          dummy.change = 0;
          dummy.changepct = 0;
          activelst.add(dummy);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
