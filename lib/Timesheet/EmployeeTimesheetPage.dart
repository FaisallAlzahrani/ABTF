
import 'package:flutter/material.dart';
import 'dart:convert'; // For parsing JSON
import 'package:http/http.dart' as http;

class EmployeeTimesheetPage extends StatefulWidget {
  final String empCode;

  EmployeeTimesheetPage({required this.empCode});

  @override
  _EmployeeTimesheetPageState createState() => _EmployeeTimesheetPageState();
}

class _EmployeeTimesheetPageState extends State<EmployeeTimesheetPage> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  List<Map<String, dynamic>> timesheetData = [];
  int currentPage = 1;
  bool isLoading = false;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  final String adminToken = 'swd'; // Replace with the admin token

  @override

  void initState() {
    super.initState();
    fetchTimesheetData();
  }

  Future<void> fetchTimesheetData() async {
    setState(() {
      isLoading = true;
    });

    String startTime = startTimeController.text.isNotEmpty ? startTimeController.text : '';
    String endTime = endTimeController.text.isNotEmpty ? endTimeController.text : '';

    final String apiUrl =
        'http://172.18.101.32:8085/iclock/api/transactions/?emp_code=${widget.empCode}&start_time=$startTime&end_time=$endTime&page=$currentPage';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Token $adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('http://172.18.101.32:8085/iclock/api/transactions/?emp_code=${widget.empCode}&start_time=$startTime&end_time=$endTime&page=$currentPage');
        final jsonData = json.decode(response.body);
        setState(() {
          timesheetData = List<Map<String, dynamic>>.from(jsonData['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data. Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String calculateTotalHours(String? checkIn, String? checkOut) {
    if (checkIn == null || checkOut == null || checkIn == '-' || checkOut == '-') return '-';

    try {
      final checkInTime = DateTime.parse("1970-01-01T$checkIn:00");
      final checkOutTime = DateTime.parse("1970-01-01T$checkOut:00");
      final duration = checkOutTime.difference(checkInTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return "${hours}.${minutes.toString().padLeft(2, '0')}";
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Timesheet'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: screenHeight*0.03,left: screenHeight*0.02,right: screenHeight*0.02,bottom: screenHeight*0.04),
        child: Column(
          children: [
            // Date Pickers
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        startTimeController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        endTimeController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentPage = 1;
                  fetchTimesheetData();
                });
              },
              child: Text('Fetch Timesheet'),
            ),
            SizedBox(height: 16),

            // Timesheet Table
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Check In')),
                    DataColumn(label: Text('Check Out')),
                    DataColumn(label: Text('Total Hours')),
                  ],
                  rows: timesheetData.map((entry) {
                    final punchDate = entry['punch_time'].split(' ')[0];
                    final punchTime = entry['punch_time'].split(' ')[1];
                    final punchState = entry['punch_state_display'];

                    return DataRow(cells: [
                      DataCell(Text(punchDate)),
                      DataCell(Text(punchState == 'Check In' ? punchTime : '-')),
                      DataCell(Text(punchState == 'Check Out' ? punchTime : '-')),
                      DataCell(Text('-')), // Total Hours calculation goes here
                    ]);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Pagination Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () {
                    setState(() {
                      currentPage--;
                      fetchTimesheetData();
                    });
                  }
                      : null,
                  child: Text('Previous Page'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentPage++;
                      fetchTimesheetData();
                    });
                  },
                  child: Text('Next Page'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
