import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

class DashboardBody extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardBody> {

  String currentDate = new DateFormat.d().format(new DateTime.now()).toString();
  String currentMonth = new DateFormat.MMMM().format(new DateTime.now()).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Action Button at bottom
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
          },
          label: 'Add Subject',
          labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 16.0),
          labelBackgroundColor: Color(0xFF801E48)),

          ],
        ),

        body: Container(
          padding: EdgeInsets.all(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Column(
              children:[
              Text(currentDate,
              style: TextStyle(fontSize: 90)),
              Text(currentMonth,
                style: TextStyle(fontSize: 30)),
            ],
          ),
         ],
            )
        ),
    );
  }

}
