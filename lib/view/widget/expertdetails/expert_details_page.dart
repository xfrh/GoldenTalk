import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../service/models/expert_model.dart';
import 'expert_detail_body.dart';
import 'footer/friend_detail_footer.dart';

import 'header/expert_detail_header.dart';

class ExpertDetailsPage extends StatefulWidget {
  ExpertDetailsPage(
    this.expert, {
    @required this.avatarTag,
  });

  final Expert expert;
  final Object avatarTag;

  @override
  _ExpertDetailsPageState createState() => new _ExpertDetailsPageState();
}

class _ExpertDetailsPageState extends State<ExpertDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var linearGradient = const BoxDecoration(
      gradient: const LinearGradient(
        begin: FractionalOffset.centerRight,
        end: FractionalOffset.bottomLeft,
        colors: <Color>[
          const Color(0xFF413070),
          const Color(0xFF2B264A),
        ],
      ),
    );

    return new Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          decoration: linearGradient,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new ExpertDetailHeader(
                widget.expert,
                avatarTag: widget.avatarTag,
              ),
              new Padding(
                padding: const EdgeInsets.all(24.0),
                child: new ExpertDetailBody(widget.expert),
              ),
              new ExpertShowcase(widget.expert),
            ],
          ),
        ),
      ),
    );
  }
}
