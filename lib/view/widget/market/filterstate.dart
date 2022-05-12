import 'package:flutter/material.dart';

import 'dropdown.dart';

class Filter extends StatefulWidget {
  final Function update;
  Filter({this.update = null});
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Select Criterias",
          style: new TextStyle(color: const Color(0xFFFFFFFF)),
        ),
        titleSpacing: -1.0,
        leading: new BackButton(color: Colors.white),
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: Card(
              elevation: 10,
              child: Container(
                height: ((MediaQuery.of(context).size.height) / 2),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Dropdown(
                          'Oscillators',
                          [
                            'Average Directional Index (ADX)',
                            'Stochastic Oscillator',
                            'Chande Momentum Oscillator (CMO)',
                            'True Strength Index (TSI)',
                            'Ultimate Oscillator (UO)',
                            'Stochastic RSI',
                            'Vortex Indicator (VI)',
                            'Directional Movement Index (DMI)',
                            'Relative Strength Index (RSI)',
                            'DM Indicator'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Centered oscillators',
                          [
                            'Moving Average',
                            'Convergence Divergence (MACD)',
                            'Commodity Channel Index (CCI)',
                            'Fisher Transform',
                            'Momentum Indicator (MOM)',
                            'Woodies CCI',
                            'TRIX',
                            'Detrended Price Oscillator (DPO)',
                            'Percent Price Oscillator (PPO)',
                            'Bears Power',
                            'Know Sure Thing (KST)'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Volatility',
                          [
                            'Average True Range (ATR)',
                            'Bollinger Bands (BB)',
                            'Rate of Change (ROC)',
                            'Donchian Channels',
                            'Keltner Channels (KC)',
                            'Parabolic Stop and Reverse (PSAR)',
                            'Historical Volatility',
                            'Standard Deviation',
                            'Volatility Stop',
                            'Chaikin Volatility (CHV)'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Trend analysis',
                          [
                            'Ichimoku Cloud',
                            'Pivot Points',
                            'Price/Earnings Ratio (P/E Ratio)',
                            'Support and Resistance',
                            'Commitment of Traders (COT)',
                            'Linear Regression',
                            'Pring Special K',
                            'Zig Zag Indicator',
                            'Candlestick Analysis',
                            'Relative Strength Comparison (RSC)'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Volume',
                          [
                            'Put/Call Ratio (PCR)',
                            'Volume Indicator',
                            'Money Flow Index (MFI)',
                            'Chaikin Money Flow (CMF)',
                            'Volume Profile',
                            'Volume-weighted Average Price (VWAP)',
                            'Accumulation / Distribution Line (ADL)',
                            'Price Volume Trend (PVT)',
                            'Ease of Movement (EOM)',
                            'Negative Volume Index (NVI)'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Moving average',
                          [
                            'Exponential Moving Average (EMA)',
                            'Weighted Moving Average (WMA)',
                            'Simple Moving Average (SMA)',
                            'Hull Moving Average (HMA)',
                            'Kaufman\'s Adaptive Moving Average (KAMA)',
                            'Smoothed Moving Average (SMMA)',
                            'Variable Index Dynamic Average (VIDYA)',
                            'Volume-weighted Moving Average (VWMA)',
                            'Fractal Adaptive Moving Average (FRAMA)',
                            'Double Exponential Moving Average (DEMA)'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Breadth indicators',
                          [
                            'On Balance Volume (OBV)',
                            'McClellan Oscillator',
                            'McClellan Summation Index',
                            'Advance/Decline Ratio',
                            'Cumulative Volume Index (CVI)',
                            'Arms Index (TRIN)',
                            'Advance/Decline Line',
                            'High-Low Index',
                            'Advance/Decline Volume Line'
                          ],
                          update: widget.update,
                        ),
                        Dropdown(
                          'Bill Williams indicator',
                          [
                            'Awesome Oscillator (AO)',
                            'Williams Fractal',
                            'Market Facilitation Index',
                            'Williams Alligator',
                            'Gator Oscillator',
                            'Accelerator Oscillator (AC)'
                          ],
                          update: widget.update,
                        ),
                      ],
                    ),
                    // RaisedButton(
                    //   child: Text('Submit'),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
