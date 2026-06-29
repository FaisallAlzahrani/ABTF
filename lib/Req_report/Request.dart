import 'package:flutter/material.dart';

class EmployeeRequest {
  final String type;
  final String details;
  bool approved;
  String? rejectionReason;
  List<String> uploadedFiles;

  EmployeeRequest({
    required this.type,
    required this.details,
    this.approved = false,
    this.rejectionReason,
    this.uploadedFiles = const [],
  });
}

class HRRequestScreen extends StatefulWidget {
  @override
  _HRRequestScreenState createState() => _HRRequestScreenState();
}

class _HRRequestScreenState extends State<HRRequestScreen> {
  List<EmployeeRequest> _requests = [
    EmployeeRequest(type: 'Vacation', details: 'Going on vacation', uploadedFiles: ['file1.pdf']),
    EmployeeRequest(type: 'Leave', details: 'Personal leave request'),
    EmployeeRequest(type: 'Business Trip', details: 'Attending a conference'),
  ];

  EmployeeRequest? _selectedRequest;

  TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _approveRequest() {
    setState(() {
      _selectedRequest!.approved = true;
    });
  }

  void _rejectRequest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reject Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason for Rejection'),
              SizedBox(height: 8.0),
              TextField(
                controller: _rejectionReasonController,
                decoration: InputDecoration(hintText: 'Enter the reason for rejection'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRequest!.approved = false;
                  _selectedRequest!.rejectionReason = _rejectionReasonController.text;
                  _rejectionReasonController.clear();
                });
                Navigator.pop(context);
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _uploadFile() {
    // Simulating file upload process
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _selectedRequest!.uploadedFiles.add('uploaded_file.pdf');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue[800],
        title: Text('HR Requests',style: TextStyle(color: Colors.white),),
      ),
      body: Column(
          children: [
      Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Employee Requests',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    ),
         Expanded(
           child: ListView.builder(
             itemCount: _requests.length,
              itemBuilder: (BuildContext context, int index) {
               return Card(color: Colors.red,
                 margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                 child: ListTile(
                  title: Text(_requests[index].type),
                  subtitle: Text(_requests[index].details),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                  setState(() {
                   _selectedRequest = _requests[index];
    });
    },
    ),
    );
    },
    ),
    ),
            if (_selectedRequest != null)
               Expanded(
                     child:SingleChildScrollView(
                       child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        'Request Details',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(_selectedRequest!.details),
                        SizedBox(height: 16.0),
                        if (_selectedRequest!.approved)
                           Text(
                        'Request Status: Approved',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                          if (!_selectedRequest!.approved)
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                          'Request Status: Pending Approval',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                          onPressed: _approveRequest,
                           child: Text('Approve Request'),
                          ),
                             SizedBox(height: 8.0),
                               ElevatedButton(
                                 onPressed: _rejectRequest,
                                  child: Text('Reject Request'),
                          ),
                                SizedBox(height: 16.0),
                            if (_selectedRequest!.rejectionReason != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   Text(
                                                      'Rejection Reason:',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                                  SizedBox(height: 8.0),
                                  Text(_selectedRequest!.rejectionReason!),
    ],
    ),
    ],
    ),
                              SizedBox(height: 16.0),
                              Text(
                          'Uploaded Files:',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        if (_selectedRequest!.uploadedFiles.isNotEmpty)
                          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _selectedRequest!.uploadedFiles.map((file) {
                          return Text(file);
                        }).toList(),
                          ),
                        ElevatedButton(
                          onPressed: _uploadFile,
                          child: Text('Upload File'),
                        ),
    ],
    ),
    ),
    ),
               ), ],
      ),
    );
  }
}
