
import 'package:application_v1/home/home_screen.dart';
import 'package:application_v1/login/login_screen.dart';
import 'package:flutter/material.dart';
import '../Announcement/Announcement.dart';
import 'local_login.dart';

class SelectionScreen extends StatelessWidget {

  const SelectionScreen({super.key});

  @override


  Widget build(BuildContext context) {

    double screenHeight = 0 ;
    double screenWidth = 0 ;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(

      backgroundColor: Colors.grey[250],

      body: Container(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Container(
                  height: screenHeight* 0.09,
                  width: screenWidth* 0.85,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(
                        top: screenHeight * 0.03
                      ),),
                      Text('Please Select your Orgnization',
                      style: TextStyle(
                          color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight*0.024),)
                    ],
                  ),
                )

              ],
            ),
            Padding(padding: EdgeInsets.only(
              top: screenHeight * 0.1
            )),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenHeight*0.015,left: screenHeight*0.00001,top: screenHeight*0.014),
                  child: GestureDetector(
                    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return LoginScreen();
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
                            child: Icon(Icons.engineering,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,
                            ),
                          ),
                          Text("Al-babtain Employee ",style: TextStyle(
                              color: Colors.blue[900],overflow: TextOverflow.ellipsis,

                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight*0.024),
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
                        return LocalLoginPage();
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
                            child: Icon(Icons.local_activity,
                              color: Colors.lightBlue[900],
                              size: screenHeight*0.115,),
                          ),

                          Text("Local"
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
          ],
        ),
      ),
    );
  }
}
