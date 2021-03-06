import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/calendarDisplay/completedWorkloads.dart';
import 'package:flutter_app/calendarDisplay/skipDates.dart';
import 'package:flutter_app/main/futureArea.dart';
import 'package:flutter_app/model/subject.dart';
import 'package:flutter_app/subjectCards/workloadRow.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main/mainScreen.dart';
import '../model/workload.dart';


class Calendar extends StatefulWidget{

  @override
  _CalendarState createState() => _CalendarState();
}

Subject getSubject(String subjectName, List<Subject> subjectList){
  for (var i=0; i<subjectList.length; i++) {
    if(subjectList[i].name == subjectName){
      return subjectList[i];
    }
  }
  return null;
}


class _CalendarState extends State<Calendar>{
  CalendarController _controller;
  Map<DateTime, Map<String, List<Workload>>> _calendar;
  Map<DateTime, List<Workload>> _events;
  List<Workload> _selectedEvents;
  CompletedWorkloads _completedWorkloads;
  bool _initial;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _selectedEvents = [];
    _initial = true;
  }

  @override
  Widget build(BuildContext context){
    _calendar = downloadCalendar(localWorkloads);
    _events = createEvents();

    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22),
        backgroundColor: Color(0xFF801E48),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          // FAB 1
          SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: Color(0xFF801E48),
              onTap: () {

                _completedWorkloads = CompletedWorkloads(localWorkloads);
                showDialog(context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _completedWorkloads;
                  },
                );

              },
              label: 'Completed Workloads',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Color(0xFF801E48)
          ),
          // FAB 2
          SpeedDialChild(
              child: Icon(Icons.skip_next),
              backgroundColor: Color(0xFF801E48),
              onTap: () {
                var skipDates = SkipDates();
                showDialog(context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return skipDates;
                  },
                );

              },
              label: 'Skip Days',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Color(0xFF801E48)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar (
            initialSelectedDay: mostRecentlyVisitedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            initialCalendarFormat: CalendarFormat.week,
            events: _events,
            calendarController: _controller,
            calendarStyle: CalendarStyle(
              todayColor: Colors.orange,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
            onDaySelected: (date, events){
              _initial = false;
              mostRecentlyVisitedDay = date;
              if(events.isNotEmpty) {
                setState(() {
                  _selectedEvents = events;
                });
              }
              else{
                setState(() {
                  _selectedEvents = [];
                });
              }
            },
            builders: CalendarBuilders(
              markersBuilder: (context, date, events, holidays) {
                final children = <Widget>[];

                if (events.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    ),
                  );
                }

                if (holidays.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: -2,
                      top: -2,
                      child: _buildHolidaysMarker(),
                    ),
                  );
                }

                return children;
              },

//              singleMarkerBuilder: (context, date, event){
//                int diffTotal = 0;
//                for(String subj in _calendar[date].keys){
//                  for(Workload wl in _calendar[date][subj]){
//                    diffTotal += wl.workloadDifficulty;
//                  }
//                }
//
//                return Text(diffTotal.toString());
//              }
            ),
          ),

          //if initial state, ask user to select a date, else display current date's events
          _initial == true ?
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.blue,
              child:
              Text(
                "PLEASE SELECT A DATE!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ),
          ) :

          Expanded(
            child: new Container(
              color: new Color(0xFF0c6f96),
              child: new CustomScrollView(
                scrollDirection: Axis.vertical,
                shrinkWrap: false,
                slivers: <Widget>[
                  new SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0),
                    sliver: new SliverList(
                      delegate: new SliverChildBuilderDelegate(
                            (context, index) =>
                        new WorkloadRow(_selectedEvents[index], getSubject(_selectedEvents[index].subject, localSubjects)),
                        childCount: _selectedEvents.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    int diffTotal = 0;
    for(Workload wl in events){
      diffTotal += wl.workloadDifficulty;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _controller.isSelected(date)
            ? Colors.brown[500]
            : _controller.isToday(date) ? Colors.brown[300] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          diffTotal.toString(),
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Map<DateTime, List<Workload>> createEvents(){
    Map<DateTime, List<Workload>> events = Map();
    for(DateTime date in _calendar.keys){
      for(String subj in _calendar[date].keys){
        for(Workload wl in _calendar[date][subj]){
          events.putIfAbsent(date, () => List());
          events[date].add(wl);
        }
      }
    }
    return events;
  }

}

Map<DateTime, Map<String, List<Workload>>> downloadCalendar(List<Workload> workloads){
  Map<DateTime, Map<String, List<Workload>>> calendar = Map();
  for(Workload wl in workloads){
    if (wl.workloadDate != "NONE"){
      DateTime date = DateTime.parse(wl.workloadDate);
      calendar.putIfAbsent(date, () => Map<String, List<Workload>>());
      calendar[date].putIfAbsent(wl.subject, () => List<Workload>());
      calendar[date][wl.subject].add(wl);
    }
  }
  return calendar;
}