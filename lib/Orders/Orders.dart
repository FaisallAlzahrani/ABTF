import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/single_child_scroll_view.dart';
class Orders extends StatefulWidget {
  Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Tracking your orders',
          style: TextStyle(color: Colors.white),
      ),
      ),
      body: Center(

        child: ListView(
          children: [

          SizedBox(height: 10,),
          Card(
            child: ListTile(
              onTap: (){
                print('cilcked 1');
              },
              leading: Text('1'),
              title: Text("employe name"),
              subtitle: Text('type of req'),
              trailing: Text('in proccess'),
            ),

          ),
          SizedBox(height: 10,),
          Card(
            child: ListTile(
              onTap: (){
                print('cilcked 2');
              },
              leading: Text('2'),
              title: Text("Faisal"),
              subtitle: Text('short Vacations'),
              trailing: Text('in proccess'),
            ),

          ),
          SizedBox(height: 10,),
          Card(
            child: ListTile(
              onTap: (){
                print('cilcked 3');
              },
              leading: Text('3'),
              title: Text(" Faisal"),
              subtitle: Text('Bussins trip'),
              trailing: Text('in proccess'),
            ),

          ),
          SizedBox(height: 10,),
          Card(
            child: ListTile(
              onTap: (){
                print('cilcked 4');
              },
              leading: Text('4'),
              title: Text("Faisal"),
              subtitle: Text('Salary Stetment'),
              trailing: Text('Aproval',
              style: TextStyle(
                color: Colors.green,
              ),),
            ),

          ),
          SizedBox(height: 10,),
          Card(
            child: ListTile(
              enabled: false,
              onTap: (){
                print('cilcked 5');
              },
              leading: Text('5'),
              title: Text("Faisal"),
              subtitle: Text('Long Vacation'),
              trailing: Text('Reject',
              style: TextStyle(
                color: Colors.red,
              ),),
            ),

          ),


        ],)
      ),
    );
  }
}
