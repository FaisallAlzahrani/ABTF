import 'package:application_v1/MissionVisionPage/MissionVisionTest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Announcement/Announcement.dart';
import '../Attendance/attandancescreen.dart';
import '../Calender/Calanderone.dart';
import '../Evolation/Evolation.dart';
import '../Orders/MaintananceStuts.dart';
import '../Orders/Status_Operation.dart';
import '../Orders/Stauts_admin.dart';
import '../Orders/VoiceUpPage.dart';
import '../Req_report/send_ticket/OpenTicket.dart';
import '../Timesheet/EmployeeTimesheetPage.dart';
import '../eFiles/EFILES.dart';
import '../login/user_provider.dart';




class Operations_screen extends StatefulWidget {
  const Operations_screen({super.key});

  @override
  State<Operations_screen> createState() => _Main_screenState();
}

class _Main_screenState extends State<Operations_screen> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  @override
  Widget build(BuildContext context) {
    String Fileno = Provider.of<UserProvider>(context).email;
    String userName = Provider.of<UserProvider>(context).firstName;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final date1 = DateTime.now();
    final date2 = DateTime(date1.year , date1.month+1 , 0);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.blue[900]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm Logout'),
                content: Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Logout'),
                    onPressed: () async {
                      Provider.of<UserProvider>(context, listen: false).logout();
                      Navigator.pushReplacementNamed(context, '/login');

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // or prefs.remove('isLoggedIn');

                    },
                  ),
                ],
              ),
            );
          },

        ),
        title: Text( userName.isNotEmpty ? "Welcome, $userName !" : "Welcome!",style: TextStyle(
            color: Colors.blue[900],fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,
            fontSize: 20),

        ),
      ),



      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            Padding(

              padding:  EdgeInsets.only(right: screenHeight*0.00,left: screenHeight*0.01,top: screenHeight*0.01,bottom: screenHeight*0.005),
              child: Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  GestureDetector(
                    onTap: () {
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      // Perform action when the container is clicked
                    },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Stack(
                        children: [
                          // Centered text
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Centers content vertically
                              children: [
                                Text(
                                  "My Leave Balance",overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.022,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  "10.87",overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.030,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  "Employee Leave",overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // "Coming Soon" label in the top-right corner
                          Positioned(
                            bottom: 120, // Distance from the top of the container
                            right: 10,
                            // Distance from the right of the container
                            child: Transform.rotate(
                              angle: -70 * 3.14159 / 280, // Convert degrees to radians
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenHeight * 0.07,
                                    vertical: screenHeight * 0.002),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  "Coming Soon",overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenHeight * 0.02,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Padding(padding: EdgeInsets.only( bottom: screenHeight*0.0005,left: screenHeight*0.03), child: Text('Managment ',style: TextStyle(color: Colors.blue[900],fontWeight: FontWeight.bold, fontSize: 11),),),

                  // Icon(Icons.arrow_forward)

                  Padding(
                    padding: EdgeInsets.all(screenWidth*0.02),
                    child: GestureDetector(
                      onTap: () {

                        // Perform action when container is clicked
                        print('Container 2 clicked');
                        print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){

                          return Calendar();
                        }),);
                      },
                      child: Container(
                        height: screenHeight * 0.25,
                        width: screenWidth * 0.40,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50],
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight*0.005 , bottom: screenHeight*0.0005),
                              child: Text(daysBetween(date1, date2).toString(),style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight*0.070,
                                  color: Colors.blue[900]
                              )),
                            ),

                            Text("Until next payment",overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.blue[900],

                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight*0.005 , bottom: screenHeight*0.0005),
                              child: Text("Direct Despost Schdule",overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.blue[900],

                                      fontWeight: FontWeight.bold,
                                      fontSize: screenHeight*0.019)),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: screenHeight*0.02),
                                  child: Text('Schdule',style: TextStyle(
                                      color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                                      fontWeight: FontWeight.bold,
                                      fontSize: screenHeight*0.018)),
                                ),

                                Icon(Icons.arrow_forward_rounded,
                                  color: Colors.lightBlue[900],
                                  size: screenHeight*0.029,),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                Padding(
                  padding: EdgeInsets.only(right: screenHeight*0.015,left: screenHeight*0.00001),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 3 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return const eFile();
                      }),); },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.005),
                            child: Icon(Icons.file_copy_outlined,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.120,
                            ),
                          ),
                          Text("eFILE",style: TextStyle(
                              color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight*0.026),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // Perform action when container is clicked
                    print('Container 4 clicked');
                    print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return AttendanceScreen();
                    }),);

                  },
                  child: Container(
                    height: screenHeight * 0.25,
                    width: screenWidth * 0.40,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: Column(
                      children: [

                        Padding(
                          padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                          child: Icon(Icons.fingerprint_outlined,
                            color: Colors.lightBlue[900],
                            size: screenHeight*0.115,
                          ),
                        ),
                        Text("Attendence ",style: TextStyle(
                            color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight*0.026),
                        ),
                      ],
                    ),
                  ),
                ),


              ],


            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenHeight*0.015,left: screenHeight*0.00001,top: screenHeight*0.014),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 8 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return EvaluationPage();
                      }),); },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.elevator_outlined,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,
                            ),
                          ),
                          Text("EVO",style: TextStyle(
                              color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight*0.026),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.015),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 6 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return EmployeeTimesheetPage(empCode: Fileno,);
                      }),); },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.access_time,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,),
                          ),

                          Text("TimeSheet"
                            ,style: TextStyle(
                              color: Colors.lightBlue[900],overflow: TextOverflow.ellipsis,
                              fontSize: screenHeight*0.026,
                              fontWeight: FontWeight.bold,

                            ),
                          )
                        ],
                      ),
                    ),

                  ),
                ),
              ],

            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenHeight*0.015,left: screenHeight*0.00001,top: screenHeight*0.014),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 13 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return StatusPageoperations();
                      }),); },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.monitor_outlined,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,
                            ),
                          ),
                          Text("Status ",style: TextStyle(
                              color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight*0.026),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.015),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Voice Up"),
                            content: const Text(
                                "No one will know who you are. Feel free to tell anything to the top management. This conversation is completely secure."),
                            actions: [
                              TextButton(
                                child: const Text("No, thank you"),// Perform action when container is clicked
                                onPressed: () {
                                  Navigator.of(context).pop(); // Dismiss dialog
                                },
                              ),
                              ElevatedButton(
                                child: const Text("Agree"),
                                onPressed: () {
                                  print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VoiceUpPage()),
                                  );
                                },
                              ),
                            ],
                          );
                        },);},
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.hearing_outlined,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,),
                          ),

                          Text("Voice Up"
                            ,style: TextStyle(
                              color: Colors.lightBlue[900],overflow: TextOverflow.ellipsis,
                              fontSize: screenHeight*0.026,
                              fontWeight: FontWeight.bold,

                            ),
                          )
                        ],
                      ),
                    ),

                  ),
                ),
              ],

            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenHeight*0.015,left: screenHeight*0.00001,top: screenHeight*0.014),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 6 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return Announcement();
                      }),);
                      },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.broadcast_on_personal_rounded,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,
                            ),
                          ),
                          Text("Announcement",style: TextStyle(
                              color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight*0.026),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.015),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 6 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return OpenTicketPage();
                      }),); },
                    child: Container(
                      height: screenHeight * 0.25,
                      width: screenWidth * 0.40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.07 , bottom: screenHeight*0.007),
                            child: Icon(Icons.access_time,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,),
                          ),

                          Text("Open Ticket"
                            ,style: TextStyle(
                              color: Colors.lightBlue[900],overflow: TextOverflow.ellipsis,
                              fontSize: screenHeight*0.026,
                              fontWeight: FontWeight.bold,

                            ),
                          )
                        ],
                      ),
                    ),

                  ),
                ),
              ],

            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      // Perform action when container is clicked
                      print('Container 15 clicked');
                      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){

                        return MissionVisionPage();
                      }
                      ),
                      );
                    },
                    child: Container(
                      height: 105,
                      width: 105,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      ),
                      child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text("More",style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                            ),
                            Icon(Icons.info_outline),
                          ]
                      ),
                    ),
                  ),
                ),
              ],

            ),

          ],
        ),
      ),
    );
  }
  int daysBetween(DateTime from , DateTime to){
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month , to.day);
    return (to.difference(from).inHours/ 24).round();
  }
}