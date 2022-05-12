import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import '../manager/expertmanager.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';
import '../service/models/expert_model.dart';

class ScriptRegisterPage extends StatefulWidget {
  ScriptRegisterPage({this.expert = null}); //
  final Expert expert;
  @override
  _State createState() => _State();
}

class _State extends State<ScriptRegisterPage> {
  final _auth = locator<AuthService>();
  final _expertMgr = locator<ExpertManager>();
  var _skills = List<String>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          title: Text("Select Your Expertise"),
          titleSpacing: -1.0,
          leading: BackButton(
            color: Colors.white,
          )),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            {widget.expert == null ? _addExpert() : _updateExpert()},
        child: Icon(
          Icons.save,
          //color=Colors.white,
        ),
        backgroundColor: Colors.deepPurple,
        tooltip: "Save",
      ),
    );
  }

  Widget _body() {
    return ListView(children: <Widget>[
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Oscillators",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Average Directional Index (ADX)",
          "Stochastic Oscillator",
          "Chande Momentum Oscillator (CMO)",
          "True Strength Index (TSI)",
          "Ultimate Oscillator (UO)",
          "Stochastic RSI",
          "Vortex Indicator (VI)",
          "Directional Movement Index (DMI)",
          "Relative Strength Index (RSI)",
          "DM Indicator"
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Centered oscillators",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Moving Average (MACD)",
          "Commodity Channel Index (CCI)",
          "Fisher Transform",
          "Momentum Indicator (MOM)",
          "Woodies CCI",
          "TRIX",
          "Detrended Price Oscillator (DPO)",
          "Percent Price Oscillator (PPO)",
          "Bears Power",
          "Know Sure Thing (KST)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Volatility",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Average True Range (ATR)",
          "Bollinger Bands (BB)",
          "Rate of Change (ROC)",
          "Donchian Channels",
          "Keltner Channels (KC)",
          "Parabolic Stop and Reverse (PSAR)",
          "Historical Volatility",
          "Standard Deviation",
          "Volatility Stop",
          "Chaikin Volatility (CHV)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Trend analysis",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Ichimoku Cloud",
          "Pivot Points",
          "Price/Earnings Ratio (P/E Ratio)",
          "Support and Resistance",
          "Commitment of Traders (COT)",
          "Linear Regression",
          "Pring Special K",
          "Zig Zag Indicator",
          "Candlestick Analysis",
          "Relative Strength Comparison (RSC)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Volume",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Put/Call Ratio (PCR)",
          "Volume Indicator",
          "Money Flow Index (MFI)",
          "Chaikin Money Flow (CMF)",
          "Volume Profile",
          "Volume-weighted Average Price (VWAP)",
          "Accumulation / Distribution Line (ADL)",
          "Price Volume Trend (PVT)",
          "Ease of Movement (EOM)",
          "Negative Volume Index (NVI)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Moving average",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Exponential Moving Average (EMA)",
          "Weighted Moving Average (WMA)",
          "Simple Moving Average (SMA)",
          "Hull Moving Average (HMA)",
          "Kaufman\'s Adaptive Moving Average (KAMA)",
          "Smoothed Moving Average (SMMA)",
          "Variable Index Dynamic Average (VIDYA)",
          "Volume-weighted Moving Average (VWMA)",
          "Fractal Adaptive Moving Average (FRAMA)",
          "Double Exponential Moving Average (DEMA)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Breadth indicators",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "On Balance Volume (OBV)",
          "McClellan Oscillator",
          "McClellan Summation Index",
          "Advance/Decline Ratio",
          "Cumulative Volume Index (CVI)",
          "Arms Index (TRIN)",
          "Advance/Decline Line",
          "High-Low Index",
          "Advance/Decline Volume Line",
        ],
        onChange: (bool isChecked, String label, int index) =>
            print("isChecked: $isChecked   label: $label  index: $index"),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
      Container(
        padding: const EdgeInsets.only(left: 14.0, top: 14.0),
        child: Text(
          "Bill Williams indicator",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
      CheckboxGroup(
        labels: <String>[
          "Awesome Oscillator (AO)",
          "Williams Fractal",
          "Market Facilitation Index",
          "Williams Alligator",
          "Gator Oscillator",
          "Accelerator Oscillator (AC)",
        ],
        onChange: (bool isChecked, String label, int index) =>
            update(isChecked, label),
        onSelected: (List<String> checked) =>
            print("checked: ${checked.toString()}"),
      ),
    ]);
  }

  void update(bool isChecked, String label) {
    if (isChecked) {
      if (!_skills.contains(label)) _skills.add(label);
    } else {
      if (_skills.contains(label)) _skills.remove(label);
    }
  }

  void _addExpert() {
    final _currentUser = _auth.activeUser;
    final _expert = Expert(
        date: DateTime.now().millisecondsSinceEpoch,
        uid: _currentUser.uid,
        name: _currentUser.displayName,
        email: _currentUser.email,
        avator: _currentUser.photoUrl,
        description: 'successfully registed scripter',
        paypalUrl: _currentUser.email);
    _expert.skills = _skills;
    _expert.members = List<String>();
    _expert.portfolios = List<String>();
    _expert.refers = List<String>();
    _expert.portfolios.add('images/portfolio_1.jpeg');
    _expert.portfolios.add('images/portfolio_2.jpeg');
    _expert.portfolios.add('images/portfolio_3.jpeg');
    _expert.portfolios.add('images/portfolio_4.jpeg');
    _expert.portfolios.add('images/portfolio_5.jpeg');
    _expert.portfolios.add('images/portfolio_6.jpeg');
    _expertMgr.addExpert(_expert).then((value) {
      _expert.expertID = value;
      _expertMgr.updateExpert(_expert, value);
      _showWelcomeDialog();
    });
  }

  void _updateExpert() {
    widget.expert.skills = _skills;
    _expertMgr.updateExpert(widget.expert, widget.expert.expertID);
    Navigator.pop(context);
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Congratulation!"),
          content: new Text("Thank you and welcome to be expert member"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
