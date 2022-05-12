import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../manager/expertmanager.dart';
import '../service/locator.dart';
import '../service/models/expert_model.dart';
import '../view/widget/expertdetails/expert_details_page.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class ScriptRegisterEditPage extends StatefulWidget {
  static const routeName = '/selectedScript';
  @override
  _ScriptRegisterEditPagState createState() => _ScriptRegisterEditPagState();
}

class _ScriptRegisterEditPagState extends State<ScriptRegisterEditPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _expertMgr = locator<ExpertManager>();
  List<String> _skills = <String>[
    '',
    'Materials',
    'Industrials',
    'Financials',
    'Energy',
    'Real estate',
    'Others'
  ];
  Expert selectedExpert;
  bool isSuccess = false;
  String _skill;
  String _desc;
  String _paypal;
  String _refs;
  final _descControl = TextEditingController();
  final _paypalControl = TextEditingController();
  final _refsControl = TextEditingController();

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      if (_skill != null)
        selectedExpert.skills = _skill.split(',');
      else
        selectedExpert.skills = List<String>();
      if (_refs != null)
        selectedExpert.refers = _refs.split(',');
      else
        selectedExpert.refers = List<String>();

      _forDemo();
      _expertMgr
          .updateExpert(selectedExpert, selectedExpert.expertID)
          .then((value) {
        setState(() {
          _showWelcomeDialog();
          isSuccess = true;
        });
      });
    }
  }

  void _DeleteExpert() async {
    _expertMgr.removeExpert(selectedExpert.expertID).then((value) {
      setState(() {
        isSuccess = true;
      });
    });
  }

  void _forDemo() {
    selectedExpert.portfolios = List<String>();
    selectedExpert.portfolios.add('images/portfolio_1.jpeg');
    selectedExpert.portfolios.add('images/portfolio_2.jpeg');
    selectedExpert.portfolios.add('images/portfolio_3.jpeg');
    selectedExpert.portfolios.add('images/portfolio_4.jpeg');
    selectedExpert.portfolios.add('images/portfolio_5.jpeg');
    selectedExpert.portfolios.add('images/portfolio_6.jpeg');
  }

  Widget _expertWidget() {
    return new ExpertDetailsPage(selectedExpert,
        avatarTag: selectedExpert.expertID);
  }

  Widget _expertRegisterWidget() {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Script Register'),
        leading: BackButton(color: Colors.white),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.only(top: 35.0),
                    child: Center(
                      child: Icon(
                        Icons.headset_mic,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                  new Container(
                    width: 80,
                    child: TextFormField(
                      controller: _descControl,
                      maxLines: null,
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.description),
                        hintText: 'Make a brief introduction about yourserlf',
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.isEmpty)
                          return 'make a brief introduction';
                        else
                          return null;
                      },
                      onSaved: (value) => _desc = value.trim(),
                    ),
                  ),
                  new TextFormField(
                    controller: _paypalControl,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.payment),
                      hintText: 'Enter your paypal address for reward',
                      labelText: 'Paypal',
                    ),
                    keyboardType: TextInputType.url,
                    onSaved: (value) => _paypal = value.trim(),
                  ),
                  new FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.color_lens),
                          labelText: 'Skill',
                        ),
                        isEmpty: _skill == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            value: _skill,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                _skill = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _skills.map((String value) {
                              return new DropdownMenuItem(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    validator: (value) {
                      if (value == null && _skill == null) {
                        return "Select your area";
                      }
                    },
                  ),
                  new Container(
                    width: 80,
                    child: TextFormField(
                      controller: _refsControl,
                      maxLines: null,
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.info),
                        hintText:
                            'Add reference eg. blog, artice in website etc',
                        labelText: 'reference(split with comma)',
                      ),
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) => _refs = value.trim(),
                    ),
                  ),
                  new FormField(
                    builder: (FormFieldState state) {
                      return CheckboxListTile(
                        dense: state.hasError,
                        title: Text(
                            'I have read and agree to the terms and conditions'),
                        value: state.value ?? false,
                        onChanged: state.didChange,
                        subtitle: state.hasError
                            ? Text(
                                state.errorText,
                                style: TextStyle(
                                    color: Theme.of(context).errorColor),
                              )
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                    validator: (value) {
                      if (value == null || value == false) {
                        return 'you must agree the term';
                      } else
                        return null;
                    },
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      child: Icon(
                        Typicons.warning,
                        color: Colors.green,
                        size: 40,
                      ),
                      onTap: () => {
                        showAboutDialog(
                            context: context,
                            applicationLegalese:
                                'Any remarks and various self-media content published are the responsibility of the parties  and do not represent the platform’s views',
                            applicationName: 'PrivChat')
                      },
                    ),
                  ),
                  new Container(
                    child: _getActionButtons(),
                  ),
                ],
              ))),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  _validateAndSubmit();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Delete"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  _DeleteExpert();
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Success!"),
          content: new Text("Your Expert info modified"),
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

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selectedExpert = ModalRoute.of(context).settings.arguments;
    if (isSuccess)
      return _expertWidget();
    else {
      String _reftext = '';
      _descControl.text = selectedExpert.description;
      _paypalControl.text = selectedExpert.paypalUrl;
      selectedExpert.refers.forEach((element) {
        _reftext += element + ',';
      });
      _refsControl.text = _reftext;
      _skill = selectedExpert.skills[0];
      return _expertRegisterWidget();
    }
  }
}
