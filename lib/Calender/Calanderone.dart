import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final List<DateTime> toHighlight;
 
  CalendarFormat format = CalendarFormat.month;

  TextEditingController _eventController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<DateTime> ex = [
      DateTime(now.year, now.month + 1, 0),
      DateTime(now.year, now.month + 2, 0),
      DateTime(now.year, now.month + 3, 0),
      DateTime(now.year, now.month + 4, 0),
      DateTime(now.year, now.month + 5, 0),
      DateTime(now.year, now.month + 6, 0),
      DateTime(now.year, now.month + 7, 0),
      DateTime(now.year, now.month + 8, 0),
      DateTime(now.year, now.month + 9, 0),
      DateTime(now.year, now.month + 10, 0),
      DateTime(now.year, now.month + 11, 0),
      DateTime(now.year, now.month + 12, 0)
    ];
    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }
    final date1 = DateTime.now();
    final date2 = DateTime(date1.year, date1.month+1 , 0);


    print(DateTime(now.year, now.month + 1, 0));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text("ESTech Calendar",
        style: TextStyle(
          color: Colors.white
        ),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //defining min an max years
          TableCalendar(
            calendarBuilders: CalendarBuilders(
                prioritizedBuilder: (context, day ,focusedDay)
                {
                  for(DateTime d in ex)
                  {
                    if(day.day == d.day && day.month == d.month && day.year == d.year)
                    {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.all(Radius.circular(8),),
                        ),
                        child: Center(
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white),),
                        ),
                      );
                    }
                  }
                  return null ;
                }

            ),
            focusedDay: ex[0],
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),

            //changing calendar format
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,


            //To style the Calendar
            calendarStyle: CalendarStyle(
              isTodayHighlighted: false,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

    );

  }
}
