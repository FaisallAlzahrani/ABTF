import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/material/data_table.dart';

import '../../Notifications System/google_auth_services.dart';
import '../../home/Main_Screen.dart';
import '../../login/user_provider.dart';
import '../../utils/connectivity_service.dart';


class MaintenanceRequestForm extends StatefulWidget {
  const MaintenanceRequestForm({super.key});
  @override
  _MaintenanceRequestFormState createState() => _MaintenanceRequestFormState();
}

class _MaintenanceRequestFormState extends State<MaintenanceRequestForm> {

  double screenHeight = 0 ;
  double screenWidth = 0 ;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, String>> tableData1 = [];
  List<Map<String, String>> tableData2 = [];
  List<List<TextEditingController>> controllers1 = [];
  List<List<TextEditingController>> controllers2 = [];
  final List<String> _TypeOfServiceOption = ['Mechanical', 'Electrical'];
  final TextEditingController AnaOfWorkToBeDone = TextEditingController();
  final TextEditingController RepWorkDo = TextEditingController();
  final TextEditingController RemRecom = TextEditingController();
  final TextEditingController NoOfbreakdawnHours = TextEditingController();
  final TextEditingController QCCHecked = TextEditingController();
  final TextEditingController NoOfReparingHours = TextEditingController();
  final TextEditingController prepardBy = TextEditingController();
  final TextEditingController CoOfCunsMaterial = TextEditingController();
  final TextEditingController checkedBy = TextEditingController();
  final TextEditingController CoOfCunsMaHours = TextEditingController();
  final TextEditingController ToCoOfServices = TextEditingController();

  List<Map<String, dynamic>> tickets = [];
  bool isloading=false;


  // Variables for dropdown and ticket details
  String? selectedRequisitionNumber;
  String? _TypeOfService;
  String? Complate = 'Complete';
  String? RecevedBy1;
  Map<String, dynamic>? ticketDetails;
  String currentDateTime1 = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());

  void _addRowToTable1() {
    setState(() {
      tableData1.add({});
      controllers1.add(List.generate(6, (_) => TextEditingController()));
    });
  }
  void initState() {
    super.initState();
    fetchPendingTickets();
    // Initialize controllers when the table is first created
    controllers1.add(List.generate(6, (_) => TextEditingController()));
    controllers2.add(List.generate(6, (_) => TextEditingController()));

  }
  void dispose() {
    // Clean up the controllers when no longer needed
    controllers1.forEach((controllers) {
      controllers.forEach((controller) => controller.dispose());
    });
    controllers2.forEach((controllers) {
      controllers.forEach((controller) => controller.dispose());
    });
    super.dispose();
  }
  void _addRowToTable2() {
    setState(() {
      tableData2.add({});
      controllers2.add(List.generate(6, (_) => TextEditingController()));
    });
  }
  Future<void> notifyManagerofmaint({
    required String Notificationtitle,
    required String Notificationtext,
  }) async {
    const String maintmanagername = "NiteshKumbhar";

    final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Notification_system')
        .where('name', isEqualTo: maintmanagername)
        .get();
    try {
      // Fetch all FCM tokens from Firestore
      final QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection('Notification_system').get();

      print('Users fetched: ${usersSnapshot.docs.length}');

      // Extract FCM tokens from Firestore
      final List<String> fcmTokens = usersSnapshot.docs
          .map((doc) => doc['fcm_token'] as String?)
          .where((token) => token != null && token.isNotEmpty)
          .cast<String>()
          .toList();


      if (fcmTokens.isEmpty) {
        print('No FCM tokens found.');
        return;
      }
      final GoogleAuthService authService = GoogleAuthService();

      // Your existing OAuth Bearer Token
      final String bearerToken =
      await authService.getOAuth2BearerToken();

      for (String token in fcmTokens) {
        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/towerapp-fec08/messages:send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          },
          body: jsonEncode({
            'message': {
              'token': token,
              'notification': {
                'title': Notificationtitle,
                'body': Notificationtext,
              },


            },
          },
          ),
        );


        if (response.statusCode != 200) {
          print('Error sending notification to $token: ${response.body}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fetch pending tickets


  Future<void> submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show a confirmation dialog before submitting
      bool? confirmSubmit = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to submit the form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmSubmit ?? false) {
        try {
          bool isConnected = await ConnectivityService.isConnected();
          if (!isConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You are offline. Please connect to the internet and try again."),
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }

          // Collect data for the first table
          // Update the existing ticket document in Firestore
          await FirebaseFirestore.instance.collection('Tickets').doc(selectedRequisitionNumber).update({
            'AnalysisOfWorkToBeDone': AnaOfWorkToBeDone.text,
            'RepairWorkDone': RepWorkDo.text,
            'RemarksAndRecom': RemRecom.text,
            'TypeOfServices': _TypeOfService,
            'NoOfBreackDawnHours': NoOfbreakdawnHours.text,
            'QcChecked': QCCHecked.text,
            'NoOfReparingHours': NoOfReparingHours.text,
            'RecevedBy': RecevedBy1,
            'Date_Time2': currentDateTime1,
            'PreapardBY': RecevedBy1,
            'CostOfCunsumedMaterials': CoOfCunsMaterial.text,
            'CheckedBy': checkedBy.text,
            'CostOfConsumedManHours': CoOfCunsMaHours.text,
            'TotalofServices': ToCoOfServices.text,
            'status' : Complate,
            'TableData1': tableData1, // Add first table data
            'TableData2': tableData2, // Add second table data
          });
          await notifyManagerofmaint(
            Notificationtitle: 'Ticket(#$selectedRequisitionNumber) Ready',
            Notificationtext: 'ticket waiting for approve.',



          );
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Maintenance form submitted successfully!")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Main_Screen()),
          );
          // Clear the form after submission

          setState(() {
            selectedRequisitionNumber = null;// Or reset to a default value
            ticketDetails= null;
            _formKey.currentState?.reset();
          });

        } catch (e) {
          print("Error submitting ticket: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit maintenance form: ${e.toString()}")),
          );
        }
      }
    } else {
      // Show a validation error message if the form is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields!")),
      );
    }
  }

  // Fetch ticket details by ID
  Future<void> fetchTicketDetails(String ticketId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Tickets')
          .doc(ticketId)
          .get();
      if (doc.exists) {
        setState(() {
          ticketDetails = doc.data() as Map<String, dynamic>;
        });
      } else {
        print('Ticket not found');
      }
    } catch (e) {
      print('Error fetching ticket details: $e');
    }
  }
  Future<void> fetchPendingTickets() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('status', isEqualTo: 'pending')
          .get();
      setState(() {
        tickets = snapshot.docs
            .map((doc) => {'id': doc.id, 'data': doc.data()})
            .toList();

      });
    } catch (e) {
      print('Error fetching tickets: $e');
      setState(() {
        isloading = false;
      });
    }
  }

  @override

  Widget build(BuildContext context) {

    RecevedBy1 = Provider.of<UserProvider>(context, listen: false).firstName;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    const brandColor = Color(0xFF104164);

    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Maintenance Request Form',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final double contentWidth = maxWidth.clamp(0, 980);
                final double padding = (maxWidth * 0.05).clamp(16.0, 24.0);

                if (tickets.isEmpty) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[50],
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                  ),
                                  child: const Icon(Icons.inbox_outlined, color: brandColor),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No pending tickets',
                                  style: TextStyle(
                                    color: brandColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                InputDecoration fieldDecoration({required String label, IconData? icon}) {
                  return InputDecoration(
                    labelText: label,
                    prefixIcon: icon == null ? null : Icon(icon, color: brandColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: brandColor.withValues(alpha: 0.18)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: brandColor.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: brandColor, width: 2),
                    ),
                  );
                }

                Widget sectionCard({required Widget child}) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: child,
                  );
                }

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(padding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                        ),
                                        child: const Icon(Icons.confirmation_number_outlined, color: brandColor),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Select Requisition Number',
                                          style: TextStyle(
                                            color: brandColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                  // Dropdown for selecting requisition number
                  DropdownButtonFormField<String>(
                    decoration: fieldDecoration(label: 'Ticket', icon: Icons.search_rounded),
                    value: selectedRequisitionNumber,
                    items: isloading
                        ? null // No items while loading
                        : tickets.map((ticket) {
                      return DropdownMenuItem<String>(
                        value: ticket['id'],
                        child: Text(ticket['data']['Requisition Number'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (!isloading) {
                        setState(() {
                          selectedRequisitionNumber = value;
                        });
                        if (value != null) {
                          await fetchTicketDetails(value);
                        }
                      }
                    },
                    hint: isloading
                        ? const Center(child: CircularProgressIndicator())
                        : const Text('Select a ticket'),
                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                  // Display ticket details
                  if (ticketDetails != null) ...[
                    sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                ),
                                child: const Icon(Icons.info_outline, color: brandColor),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Ticket Details',
                                  style: TextStyle(
                                    color: brandColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Factory: ${ticketDetails!['Factory'] ?? 'N/A'}',
                                  style: const TextStyle(color: brandColor, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Section: ${ticketDetails!['Section'] ?? 'N/A'}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(color: brandColor, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 14, color: brandColor),
                                    children: [
                                      const TextSpan(
                                        text: 'Machine Equipment: ',
                                        style: TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      TextSpan(
                                        text: '${ticketDetails!['machineEquipment'] ?? 'N/A'}',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Serial No: ${ticketDetails!['Serial Number'] ?? 'N/A'}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(color: brandColor, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Trouble Description',
                            style: TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${ticketDetails!['TroubleDescription'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.70),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  'Reported By: ${ticketDetails!['Reported_By'] ?? 'N/A'}',
                                  style: const TextStyle(color: brandColor, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Date & Time: ${ticketDetails!['Date_Time'] ?? 'N/A'}',
                                  style: const TextStyle(color: brandColor, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ]
                  ,sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                              ),
                              child: const Icon(Icons.assignment_outlined, color: brandColor),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Work Details',
                                style: TextStyle(
                                  color: brandColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Received By: $RecevedBy1',
                                style: const TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Date/Time: $currentDateTime1',
                                style: const TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Type Of service :',
                          style: const TextStyle(
                            color: brandColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _TypeOfServiceOption.map((option) {
                            final bool selected = _TypeOfService == option;
                            return ChoiceChip(
                              label: Text(option),
                              selected: selected,
                              selectedColor: brandColor.withValues(alpha: 0.14),
                              labelStyle: TextStyle(
                                color: selected ? brandColor : brandColor,
                                fontWeight: FontWeight.w800,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _TypeOfService = selected ? option : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Analysis of Work to be Done',
                          style: TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: AnaOfWorkToBeDone,
                          decoration: fieldDecoration(label: 'Analysis', icon: Icons.analytics_outlined),
                          validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Repair & Works Done',
                          style: TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: RepWorkDo,
                          decoration: fieldDecoration(label: 'Repair / Work Done', icon: Icons.build_outlined),
                          validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Remarks & Recommendations',
                          style: TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: RemRecom,
                          decoration: fieldDecoration(label: 'Remarks', icon: Icons.notes_outlined),
                          validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                              ),
                              child: const Icon(Icons.calculate_outlined, color: brandColor),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Financial Analysis',
                                style: TextStyle(
                                  color: brandColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Consumed Spare Parts & Materials Used",
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 22,
                            headingRowColor: WidgetStatePropertyAll(brandColor.withValues(alpha: 0.08)),
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 60,
                            columns: const [
                              DataColumn(label: Text('No.')),
                              DataColumn(label: Text('Material Description')),
                              DataColumn(label: Text('Qty')),
                              DataColumn(label: Text('Unit')),
                              DataColumn(label: Text('U.Price')),
                              DataColumn(label: Text('Total Cost')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List<DataRow>.generate(
                              tableData1.length,
                              (index) => DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 70,
                                      child: TextFormField(
                                        controller: controllers1[index][0],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['No_table1'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 220,
                                      child: TextFormField(
                                        controller: controllers1[index][1],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['Materialdescription_table'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 90,
                                      child: TextFormField(
                                        controller: controllers1[index][2],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['Qty_table'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 90,
                                      child: TextFormField(
                                        controller: controllers1[index][3],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['unit_table'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        controller: controllers1[index][4],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['U.Price_table'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: controllers1[index][5],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData1[index]['TotalCost_table1'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: brandColor),
                                      onPressed: () {
                                        setState(() {
                                          tableData1.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _addRowToTable1,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: brandColor,
                              side: BorderSide(color: brandColor.withValues(alpha: 0.20), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Row', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Consumed Man Hours",
                          style: TextStyle(
                            color: brandColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 22,
                            headingRowColor: WidgetStatePropertyAll(brandColor.withValues(alpha: 0.08)),
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 60,
                            columns: const [
                              DataColumn(label: Text('No.')),
                              DataColumn(label: Text('Crew Name')),
                              DataColumn(label: Text('I.D.No.')),
                              DataColumn(label: Text('No.OfHrs')),
                              DataColumn(label: Text('Rate/Hrs')),
                              DataColumn(label: Text('TotalCost')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: List<DataRow>.generate(
                              tableData2.length,
                              (index) => DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 70,
                                      child: TextFormField(
                                        controller: controllers2[index][0],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['No_table2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 180,
                                      child: TextFormField(
                                        controller: controllers2[index][1],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['Crew_Name_table2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: controllers2[index][2],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['I.D.No_table2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 110,
                                      child: TextFormField(
                                        controller: controllers2[index][3],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['No.OfHrs_table2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 110,
                                      child: TextFormField(
                                        controller: controllers2[index][4],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['Rate/Hrs_table2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: controllers2[index][5],
                                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                                        onChanged: (value) {
                                          tableData2[index]['TotalCost2'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: brandColor),
                                      onPressed: () {
                                        setState(() {
                                          tableData2.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _addRowToTable2,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: brandColor,
                              side: BorderSide(color: brandColor.withValues(alpha: 0.20), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Row', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                      // Row 1: Type of Service and Requisition No
                      Row(
                    children: [
                      Expanded(

                        child: Text("No. Of break dawn Hours" ,style: TextStyle(fontSize: 17),textAlign: TextAlign.start,),),
                      SizedBox(width: 1),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: NoOfbreakdawnHours,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: Text(
                            'Q.C Checked (If Required):',
                            style: TextStyle(fontSize: 17
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: QCCHecked,
                          decoration: InputDecoration(

                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                    ),
                         SizedBox(height: 10,),
                        Row(
                    children: [
                      Expanded(
                        child: Text("No. Of Repiring Hours" ,style: TextStyle(fontSize: 17),textAlign: TextAlign.start,),),
                      SizedBox(width: 1),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: NoOfReparingHours,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Expanded(
                        flex: 1,
                        child: Text(
                            'Prepard By: ',
                            style: TextStyle(fontSize: 17
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '$RecevedBy1',style: TextStyle(

                        ),

                        ),
                      ),
                    ],
                   ),
                    SizedBox(height: 10,),
                    Row(
                    children: [
                      Expanded(
                        child: Text("Cost of Cunsumed Materials" ,style: TextStyle(fontSize: 17),textAlign: TextAlign.start,),),
                      SizedBox(width: 1),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: CoOfCunsMaterial,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: Text('Checked By:', style: TextStyle(fontSize: 17)),),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: checkedBy,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                   ),
                   SizedBox(height: 10,),
                   Row(
                    children: [
                      Expanded(
                        child: const Text("Cost of Cunsumed ManHours" ,style: TextStyle(fontSize: 17),textAlign: TextAlign.start,),),
                      SizedBox(width: 1),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: CoOfCunsMaHours,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(flex: 1, child: Text(' :', style: TextStyle(fontSize: 17)),),
                      Expanded(
                        flex: 1,
                        child: TextFormField(readOnly: true,controller: checkedBy,
                        ),
                      ),
                    ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                    children: [
                      Expanded(child: const Text("Total Cost Of Services" ,style: TextStyle(fontSize: 17),textAlign: TextAlign.start,),),
                      SizedBox(width: 1),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: ToCoOfServices,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                    ),
                    SizedBox(height: 16),

                   // Submit button
                   MaterialButton(
                    elevation: 6.0,
                    color: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 150),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    onPressed: submitForm,
                    child: const Text(
                      'Submit Ticket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                          ],
                        ),
                      ),
                    ),
                  ),
                );
                },
              ),
    );
  }
}
