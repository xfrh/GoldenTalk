import 'package:flutter/material.dart';
import '../../../../service/models/expert_model.dart';
import 'articles_showcase.dart';
import 'portfolio_showcase.dart';
import 'skills_showcase.dart';

class ExpertShowcase extends StatefulWidget {
  ExpertShowcase(this.expert);

  final Expert expert;

  @override
  _ExpertShowcaseState createState() => new _ExpertShowcaseState();
}

class _ExpertShowcaseState extends State<ExpertShowcase>
    with TickerProviderStateMixin {
  List<Tab> _tabs;
  List<Widget> _pages;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _tabs = [
      new Tab(text: 'Transcript'),
      new Tab(text: 'Skills'),
      new Tab(text: 'References'),
    ];
    _pages = [
      new PortfolioShowcase(widget.expert),
      new SkillsShowcase(widget.expert.skills),
      new ArticlesShowcase(widget.expert.refers),
    ];
    _controller = new TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          new TabBar(
            controller: _controller,
            tabs: _tabs,
            indicatorColor: Colors.white,
          ),
          new SizedBox.fromSize(
            size: const Size.fromHeight(300.0),
            child: new TabBarView(
              controller: _controller,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
