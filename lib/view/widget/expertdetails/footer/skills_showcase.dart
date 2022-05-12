import 'package:flutter/material.dart';

class SkillsShowcase extends StatelessWidget {
  final List<String>skills;
  SkillsShowcase(this.skills);
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
return new ListView.builder
  (
    itemCount: skills.length,
    itemBuilder: (BuildContext ctxt, int index) {
     return new Text(
        skills[index],
        style: textTheme.title.copyWith(color: Colors.white),
      );
    }
  );
  }
}
