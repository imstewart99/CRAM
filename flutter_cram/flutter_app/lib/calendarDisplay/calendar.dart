import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/calendarDisplay/completedWorkloads.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:table_calendar/table_calendar.dart';
import '../subjectCards/addSubject.dart';
import '../main/mainScreen.dart';
import '../model/subject.dart';
import '../model/workload.dart';
import 'expandWorkload.dart';


class Calendar extends StatefulWidget{

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarController _controller;
  Map<DateTime, Map<String, List<Workload>>> _calendar;
  Map<DateTime, List<Workload>> _events;
  List<Workload> _selectedEvents;
  Future<List<Workload>> _workloads;
  ExpandWorkload _expandWorkload;
  CompletedWorkloads _completedWorkloads;
  bool _initial;

  @override
  void initState() {
    super.initState();
    _workloads = updateWorkloadList();
    _controller = CalendarController();
    _selectedEvents = [];
    _initial = true;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: FutureBuilder(
        future: _workloads,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator()
              );
            default:
              List<Workload> workloads = snapshot.data ??  [];

              _calendar = downloadCalendar(workloads);
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

                            _completedWorkloads = CompletedWorkloads(workloads);
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
                          labelBackgroundColor: Color(0xFF801E48)),
                    ],
                  ),
                  body: SingleChildScrollView(
                      child: Column(
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
                            ),
                          ),

                          //if initial state ask user to select a date, else display current date's events
                          _initial == true ?
                            Align(
                              alignment: Alignment.center,
                              child: Container(
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
                            Column(children: <Widget>[
                              ... _selectedEvents.map((event) => ListTile(
                                leading: Icon(Icons.album),
                                title: Text(event.workloadName),
                                onTap: (){
                                  _expandWorkload = ExpandWorkload(event);
                                  showDialog(context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return _expandWorkload;
                                    },
                                  );
                                },
                              )),
                            ],),
                        ],
                      )
                  )
              );
          }
        }
        ),
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