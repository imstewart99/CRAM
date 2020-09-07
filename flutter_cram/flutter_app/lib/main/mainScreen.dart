import 'package:flutter/material.dart';
import '../subjectCards/addSubject.dart';
import 'spread.dart';
import '../subjectCards/homePageBody.dart';
import '../model/subject.dart';
import '../model/workload.dart';
import '../calendarDisplay/calendar.dart';

Map<DateTime, Map<String, List<Workload>>> calendar1;

class MainScreen extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: new Text("CRAM APP"),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: new TabBar(
                    tabs: <Tab>[
                      new Tab(text: "SUBJECTS"),
                      new Tab(text: "CALENDAR"),
                    ],
                  ),
                ),
              ];
            },
            body: new TabBarView(
              children: <Widget>[
                new HomePageBody(),
                new Calendar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}