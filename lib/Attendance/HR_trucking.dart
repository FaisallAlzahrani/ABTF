import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HrDashboardPage extends StatefulWidget {
  @override
  _HrDashboardPageState createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage> {
  DateTime selectedDate = DateTime.now();
  List<DocumentSnapshot> attendanceRecords = [];
  List<DocumentSnapshot> filteredRecords = [];

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchAttendanceRecords();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchAttendanceRecords();
    }
  }

  Future<List<DocumentSnapshot>> getAttendancesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('attendances')
        .where('timestamp_obj', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp_obj', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs;
  }

  void _filterRecords(String query) {
    setState(() {
      searchQuery = query.toLowerCase().trim();
      if (searchQuery.isEmpty) {
        filteredRecords = attendanceRecords;
      } else {
        filteredRecords = attendanceRecords.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['firstname'] ?? '').toString().toLowerCase();
          final empCode = (data['emp_code'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery) || empCode.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _fetchAttendanceRecords() async {
    final records = await getAttendancesByDate(selectedDate);
    setState(() {
      attendanceRecords = records;
      _filterRecords(searchQuery); // apply current search query
    });
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final base64Image = record['image_base64'];
    Widget imageWidget;

    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(base64Image);
        imageWidget = CircleAvatar(
          radius: 30,
          backgroundImage: MemoryImage(decodedBytes),
        );
      } catch (_) {
        imageWidget = CircleAvatar(
          radius: 30,
          child: Icon(Icons.broken_image),
        );
      }
    } else {
      imageWidget = CircleAvatar(
        radius: 30,
        child: Icon(Icons.person),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: imageWidget,
        title: Text(
          "${record['firstname'] ?? 'N/A'}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Emp Code: ${record['emp_code'] ?? 'Unknown'}"),
            Text("Time: ${record['timestamp'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text("HR Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: $formattedDate",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or emp code...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: _filterRecords,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(child: Text("No attendance records found."))
                : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index].data() as Map<String, dynamic>;
                return _buildAttendanceCard(record);
              },
            ),
          ),
        ],
      ),
    );
  }
}
