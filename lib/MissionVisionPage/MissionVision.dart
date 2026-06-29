import 'package:flutter/material.dart';

class MissionVisionPage extends StatefulWidget {
  const MissionVisionPage({super.key});

  @override
  State<MissionVisionPage> createState() => _MissionVisionPageState();
}

class _MissionVisionPageState extends State<MissionVisionPage> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  bool isVisible = false;
  bool isVisible1= false;

  @override
  Widget build(BuildContext context) {

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Mission andwd Vision ',
          style: TextStyle(
            color: Colors.white,
          ),),
      ),
      body:  Container(
        height: double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage('assest/images/r7.png'),
    fit: BoxFit.cover,
      filterQuality: FilterQuality.high
    ),
    ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Padding(
               padding:  EdgeInsets.only(bottom: screenHeight*0.01),
               child: Visibility(
                 visible: isVisible,
                         child: Container(
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(15),
                             color: Colors.white70
                           ),
                           child: Text(' To provide innovative, high-quality lighting products \n with  flexible, smarter and greener solutions that \n provide superior performance and greater value to \n meet our customers expectations. To become the \n preferred and most trusted partner while increasing \n market share and increasing shareholder value.',
                           style: TextStyle(
                             color: Colors.black,
                             fontWeight: FontWeight.bold,
                           ),),
                 width: 388,height: 150,
               ),
       ),
             ),

             MaterialButton(
                 elevation: 1.0,
              color: Colors.white60,
                 padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 148),
                 shape: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,),
                   child: Text('Mission',
                     style: TextStyle(
                       color: Colors.black,
                       fontWeight: FontWeight.bold,
                       fontSize: 18,
                     ),),
               onPressed: () {
                   setState(() {
                     isVisible = !isVisible;
                   });
               },

             ),
             Padding(
               padding:  EdgeInsets.only(left:  screenHeight*0.01 , right:  screenHeight*0.01),
               child: Visibility(
                 visible: isVisible1,
                 child: Container(
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(15),
                       color: Colors.white70
                   ),
                   child: Text(' We are moving towards our place as the \n communications company in the market by offering \n professional and competitive lighting solutions. Good \n deal, energy saving, get knowledge through good \n design designs to better serve our valued customers.\n We hope to develop a comfortable and sustainable\n lighting environment for a greener realization.',
                   style: TextStyle(
                     color: Colors.black,
                     fontWeight: FontWeight.bold
                   ),),
                   width: 388,height: 165,

                 ),
               ),
             ),

             MaterialButton(
               elevation: 1.0,
               color: Colors.white60,
               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 148),
               shape: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(50),
                 borderSide: BorderSide.none,),
               child: Text('Vision',
                 style: TextStyle(
                   color: Colors.black,
                   fontWeight: FontWeight.bold,
                   fontSize: 18,
                    ),),
               onPressed: () {
                 setState(() {
                   isVisible1 = !isVisible1;
                 });
               },

             ),
           ],

         ),
       ),
      );



  }
}

