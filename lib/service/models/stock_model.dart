class OHLC {
  DateTime time;
  double open;
  double high;
  double low;
  double close;
  double volume;
  OHLC({this.time,this.open, this.high, this.low, this.close, this.volume});
  fromMap(Map json) {
    this.time=json['time'];
    this.open = json['open'];
    this.high = json['high'];
    this.low = json['low'];
    this.close = json['close'];
    this.volume = json['volume'];
  }

  toJson() {
    return {
      "time" :time,
      "open": open,
      "high": high,
      "low": low,
      "close": close,
      "volume": volume,
    };
  }
}
enum TIMESPAN{
  MONTHLY,
  WEEKLY,
  DAILY
}

class BidAsk{
   String symbol;
   String name;
   double bid;
   double ask;
   double change;
   double changepct;
   BidAsk({this.symbol,this.name,this.bid, this.ask,this.change,this.changepct});

}