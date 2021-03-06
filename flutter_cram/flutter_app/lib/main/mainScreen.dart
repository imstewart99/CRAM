import 'package:flutter/material.dart';
import 'package:flutter_app/dashboard/dashboardBody.dart';
import '../subjectCards/subjectBody.dart';
import '../calendarDisplay/calendar.dart';
import 'futureArea.dart';

DateTime mostRecentlyVisitedDay = DateTime.now();
int currentPage = 1;

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  String pageTitle;

  final List<MyTabs> _tabs = [
    MyTabs(title: "Subjects", color: Colors.teal[200]),
    MyTabs(title: "Dashboard", color: Colors.orange[200]),
    MyTabs(title: "Calendar", color: Colors.red[200]),
  ];

  MyTabs _myHandler ;
  TabController _controller ;
  Widget index0;
  Widget index1;
  Widget index2;

  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this, initialIndex: currentPage);
    _myHandler = _tabs[currentPage];
    _controller.addListener(_handleSelected);
    index0 = SubjectBody();
    index1 = DashboardBody();
    index2 = Calendar();
  }
  void _handleSelected() {
    setState(() {
      _myHandler= _tabs[_controller.index];
      currentPage = _controller.index;
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: new NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: Text(_myHandler.title),
                  backgroundColor: _myHandler.color,
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: new TabBar(
                    controller: _controller,
                    tabs: <Tab>[
                      new Tab(icon: Icon(Icons.view_list)),
                      new Tab(icon: Icon(Icons.home)),
                      new Tab(icon: Icon(Icons.calendar_today)),
                    ],
                  ),
                ),
              ];
            },
            body: new TabBarView(
              controller: _controller,
              children: <Widget>[
                index0,
                index1,
                index2,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyTabs {
  final String title;
  final Color color;
  MyTabs({this.title,this.color});
}