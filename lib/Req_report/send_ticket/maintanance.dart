import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/Main_Screen.dart';
import '../../home/Maintanace.dart';
import '../../login/user_provider.dart';
import 'package:intl/intl.dart';

class MaintananceForm extends StatefulWidget {
  const MaintananceForm({super.key});

  @override
  State<MaintananceForm> createState() => _MaintananceFormState();
}

class _MaintananceFormState extends State<MaintananceForm> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  final _formKey = GlobalKey<FormState>();
  String? selectedRequisitionNumber;
  String? RecevedBy1;
  String? Complate = 'Complete';
  String? _TypeOfService;
  String currentDateTime1 = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());
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
  List <Map<String, dynamic>> tickets=[];
  Map<String, dynamic>? ticketDetails;

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    fetchPendingTickets();
  }


  Future<List<Map<String, dynamic>>> fetchPendingTickets() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Tickets')
          .where('status', isEqualTo: 'pending')
          .get();

      // Debugging: Check the structure of fetched data
      print('Fetched tickets: ${snapshot.docs.map((e) => e.data()).toList()}');

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'data': doc.data() as Map<String, dynamic>, // Ensure this cast matches the structure
        };
      }).toList();
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }
  // Save form data as draft
  Future<void> saveDraft() async {
    try {
      setState(() {
        isSubmitting = true;
      });
      
      if (selectedRequisitionNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a requisition number first")),
        );
        setState(() {
          isSubmitting = false;
        });
        return;
      }
      
      // Save the current form data as draft
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
        'PreapardBY': prepardBy.text,
        'CostOfCunsumedMaterials': CoOfCunsMaterial.text,
        'CheckedBy': checkedBy.text,
        'CostOfConsumedManHours': CoOfCunsMaHours.text,
        'TotalofServices': ToCoOfServices.text,
        'status': 'draft', // Mark as draft
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Draft saved successfully!")),
      );
      
    } catch (e) {
      print("Error saving draft: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save draft: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

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
          setState(() {
            isSubmitting = true;
          });
          
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
            'PreapardBY': prepardBy.text,
            'CostOfCunsumedMaterials': CoOfCunsMaterial.text,
            'CheckedBy': checkedBy.text,
            'CostOfConsumedManHours': CoOfCunsMaHours.text,
            'TotalofServices': ToCoOfServices.text,
            'status' : Complate,
          });
          
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
            _formKey.currentState?.reset();
          });

        } catch (e) {
          print("Error submitting ticket: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit maintenance form: ${e.toString()}")),
          );
        } finally {
          setState(() {
            isSubmitting = false;
          });
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
        final data = doc.data() as Map<String, dynamic>?; // Safely cast

        if (data != null) {
          print('Fetched ticket details: $data');
          setState(() {
            ticketDetails = data;
          });
        } else {
          print('Ticket details are null for ID: $ticketId');
        }
      } else {
        print('Ticket not found for ID: $ticketId');
      }
    } catch (e) {
      print('Error fetching ticket details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {

    _TypeOfService ??= _TypeOfServiceOption.first;
    RecevedBy1 = Provider.of<UserProvider>(context, listen: false).firstName ?? "Unknown";

    RecevedBy1 = Provider.of<UserProvider>(context, listen: false).firstName;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue[800],
          title: Text('Maintenance Request Form', style: TextStyle(color: Colors.white,),),),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : isSubmitting
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Processing your request...', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        child: Text('Select Requisition Number:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(border: OutlineInputBorder()),
                        value: selectedRequisitionNumber,
                        items: tickets.map((ticket) {
                          final requisitionNumber = ticket['Requisition Number']?.toString() ?? 'Unknown';
                          final id = ticket['id']?.toString() ?? '';

                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(requisitionNumber),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            selectedRequisitionNumber = value;
                          });
                          if (value != null) {
                            await fetchTicketDetails(value);
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      // Display ticket details
                      if (ticketDetails != null)...[
                        // Tower & Section as row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Factory: ${ticketDetails!['Factory'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Section: ${ticketDetails!['Section'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Machine Equipment: ', style: TextStyle(fontWeight: FontWeight.bold),),
                                    TextSpan(
                                      text: '${ticketDetails!['machineEquipment'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.normal),),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              flex: 2,
                              child: Text(
                                'Serial No: ${ticketDetails!['Serial Number'] ?? 'N/A'}', 
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Trouble Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 4),
                        Text(
                          '${ticketDetails!['TroubleDescription'] ?? 'N/A'}', style: TextStyle(fontSize: 16),),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Reported By: ${ticketDetails!['Reported_By'] ?? 'N/A'}', 
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Date & Time: ${ticketDetails!['Date_Time'] ?? 'N/A'}', 
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 32, thickness: 4),

                      SizedBox(height: 2,),
                      Row(crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Received By: $RecevedBy1', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              'Date/Time: $currentDateTime1',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Type Of service :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: _TypeOfServiceOption.map((option) {
                                return ChoiceChip(
                                  label: Text(option),
                                  selected: _TypeOfService == option,
                                  onSelected: (selected) {
                                    setState(() {
                                      _TypeOfService = selected ? option : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Text('Analysis of Work to be Done :',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,),),
                      // Additional fields for maintenance employee input
                      TextFormField(
                        controller: AnaOfWorkToBeDone,
                        decoration: InputDecoration(border: OutlineInputBorder(),),
                        validator: (value) => value?.isEmpty ?? true ? 'This field is required' : null,
                        maxLines: 4,
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Add buttons for Save Draft and Submit
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: saveDraft,
                            icon: Icon(Icons.save_outlined),
                            label: Text('Save as Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: submitForm,
                            icon: Icon(Icons.send),
                            label: Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                 ] )
              ),
            )
    );
  }

  }

