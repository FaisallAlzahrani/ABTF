import 'package:application_v1/home/Main_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../Notifications System/google_auth_services.dart';
import '../../login/user_provider.dart';
import '../../utils/connectivity_monitor.dart';
import '../../utils/connectivity_service.dart';
import '../../utils/ticket_storage_service.dart';
import '../../utils/ticket_sync_service.dart';

class DailyMaintanance extends StatefulWidget {
  const DailyMaintanance({super.key});

  @override
  State<DailyMaintanance> createState() => _DailyMaintananceState();
}
class _DailyMaintananceState extends State<DailyMaintanance> {
  double screenHeight = 0;
  double screenWidth = 0;

  // Supervisor Lists (using emp_code)
  final List<String> electricalSupervisors = [
    '4177' //ABDUL KAREM P (file no# 4177) (ELECTRICAL SUPERVISOR )
  ];

  final List<String> mechanicalSupervisors = [
    '13904' // K. SARAVANAN (file no# 13904) (MECHANICAL SUPERVISOR )
  ];

  final List<String> acSupervisors = [
    '18096',  // Salem Albalhareth (18096)
  ];

  String? reportedBy;
  String? reportedByfile;
  String? selectedshift;
  String? Department;
  String? Workordertype;
  String? StatusOfMain;
  TextEditingController Machinename = TextEditingController();
  TextEditingController Remarks = TextEditingController();
  TextEditingController DescriptionOfMain = TextEditingController();
  TextEditingController StartTime = TextEditingController();
  TextEditingController EndTime = TextEditingController();
  String Reportnumber = '';
  String currentDateTime = DateFormat("yyyy-MM-dd HH:mm").format(
      DateTime.now());
  String? pending = 'pending';
  String? Manager = '18096';


  bool isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = <XFile>[];
  static const int _maxImages = 4;

  Future<void> _pickImagesFromGallery() async {
    if (_selectedImages.length >= _maxImages) return;
    try {
      final remaining = _maxImages - _selectedImages.length;
      final picked = await _imagePicker.pickMultiImage(imageQuality: 75);
      if (picked.isEmpty) return;
      setState(() {
        _selectedImages.addAll(picked.take(remaining));
      });
    } catch (_) {}
  }

  Future<void> _takeImageWithCamera() async {
    if (_selectedImages.length >= _maxImages) return;
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 75);
      if (picked == null) return;
      setState(() {
        _selectedImages.add(picked);
      });
    } catch (_) {}
  }

  void _removeSelectedImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadSelectedImages({required String reportId}) async {
    if (_selectedImages.isEmpty) return <String>[];
    final storage = FirebaseStorage.instance;
    final List<String> urls = <String>[];

    for (int i = 0; i < _selectedImages.length; i++) {
      final xFile = _selectedImages[i];
      final file = File(xFile.path);
      final ref = storage.ref().child('daily_reports/$reportId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      try {
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        urls.add(url);
      } on FirebaseException {
        rethrow;
      } catch (_) {
        rethrow;
      }
    }

    return urls;
  }


  // Get supervisor list based on department
  List<String> getAssignedSupervisors() {
    if (Department == 'Electrical') {
      return electricalSupervisors;
    } else if (Department == 'Mechanical') {
      return mechanicalSupervisors;
    } else if (Department == 'AC') {
      return acSupervisors;
    }
    return []; // Return empty list if no department selected
  }

  @override
  void initState() {
    super.initState();
    reportedBy = Provider
        .of<UserProvider>(context, listen: false)
        .firstName;
    reportedByfile = Provider
        .of<UserProvider>(context, listen: false)
        .email;
    _GetReport_number();

    // Check for pending offline tickets and sync them if online


    // Start connectivity monitoring if there are pending tickets

  }


  Future<void> _GetReport_number() async {
    DocumentReference requisitionRef = FirebaseFirestore.instance.collection(
        'settings').doc('Report_number');
    DocumentSnapshot snapshot = await requisitionRef.get();
    int Report_number = 1;
    if (snapshot.exists) {
      Report_number = snapshot['lastReportNumber'] ?? 1;
    }
    setState(() {
      Reportnumber = Report_number.toString();
    });
    Report_number++;
    await requisitionRef.set({
      'lastReportNumber': Report_number,
    });
  }

    Future<void> notifyMaintenanceDepartment({
      required String Notificationtitle,
      required String Notificationtext,
      required String Reportnumber,
      required List<String> supervisors,
    }) async {
      // Query for users whose emp_codes are in the supervisors list
      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('Notification_system')
          .where('emp_code', whereIn: supervisors.isNotEmpty ? supervisors : [''])
          .get();

      final List<String> fcmTokens = usersSnapshot.docs
          .map((doc) => doc['fcm_token'] as String?)
          .where((token) => token != null && token.isNotEmpty)
          .cast<String>()
          .toList();

      if (fcmTokens.isNotEmpty) {
        try {
          final GoogleAuthService authService = GoogleAuthService();
          final String bearerToken = await authService.getOAuth2BearerToken();

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
                  'data': {
                    'Report_number': Reportnumber,
                  },
                },
              }),
            );

            if (response.statusCode != 200) {
              print('Error sending notification to $token: ${response.body}');
            }
          }
        } catch (e) {
          print('Error generating or using token: $e');
        }
      }
    }



    Future<void> submitTicket({final String? Report_number1}) async {
      if (isSubmitting) return;
      setState(() {
        isSubmitting = true;
      });

      // Get assigned supervisors for approval tracking
      List<String> assignedSupervisors = getAssignedSupervisors();

      final List<String> localImagePaths = _selectedImages.map((e) => e.path).toList();
      List<String> uploadedImageUrls = <String>[];

      // Check for internet connectivity
      bool isConnected = await ConnectivityService.isConnected();

      if (isConnected && _selectedImages.isNotEmpty) {
        try {
          uploadedImageUrls = await _uploadSelectedImages(reportId: Reportnumber);
        } catch (e) {
          print('Error uploading images: $e');
          if (!context.mounted) return;
          final msg = e is FirebaseException
              ? 'Images upload failed: ${e.code}${e.message == null ? '' : ' - ${e.message}'}'
              : 'Images upload failed: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
            ),
          );
          setState(() {
            isSubmitting = false;
          });
          return;
        }

        if (uploadedImageUrls.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Images upload failed. Please check internet / storage permissions and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          setState(() {
            isSubmitting = false;
          });
          return;
        }
      }

      Map<String, dynamic> ReportData = {
        'Report Number': Reportnumber,
        'Machine Name': Machinename.text,
        'Remarks': Remarks.text,
        'Description Of Maintanance': DescriptionOfMain.text,
        'Start Time': StartTime.text,
        'End Time': EndTime.text,
        'Seleceted Shift': selectedshift,
        'Selected Dept': Department,
        'Selected Work type': Workordertype,
        'Selected StatusOfMain': StatusOfMain,
        'Reported_By': reportedBy,
        'Reported_By_file':reportedByfile,
        'status': pending,
        'Reported_time': currentDateTime,
        'created_offline': false,
        'Manager' : Manager,
        'images': uploadedImageUrls,
        'images_local_paths': localImagePaths,
        // Multi-level approval tracking
        'assigned_supervisors': assignedSupervisors,
        'approved_supervisors': [],
        'all_supervisors_approved': false,
        'manager_approved': false,
        'approval_stage': 'pending_supervisors', // pending_supervisors, pending_manager, completed
      };

      try {
        if (isConnected) {
          // Online - Submit directly to Firebase
          final requstionformaintservices = FirebaseFirestore.instance
              .collection(
              'Report').doc(Reportnumber);
          await requstionformaintservices.set(
              ReportData, SetOptions(merge: true));

          // Send notification to ALL assigned supervisors based on department
          if (assignedSupervisors.isNotEmpty) {
            await notifyMaintenanceDepartment(
              Notificationtitle: 'New Report Requires Approval - $Department',
              Notificationtext: 'New $Department ticket (#$Reportnumber) requires approval from ALL ${assignedSupervisors.length} supervisors before going to manager. Please review and approve.',
              Reportnumber: Reportnumber,
              supervisors: assignedSupervisors,
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Report submitted successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Main_Screen()),
          );
        } else {
          // Offline - Save to local storage
          ReportData['created_offline'] = true;
          await TicketStorageService.saveOfflineTicket(ReportData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Ticket saved offline. Will be submitted when internet connection is available."),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 12),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Main_Screen()),
          );
        }

        // Clear form fields regardless of online/offline status
        Remarks.clear();
        Machinename.clear();
        DescriptionOfMain.clear();
        StartTime.clear();
        EndTime.clear();
        setState(() {
          _selectedImages.clear();
        });


        // Get new requisition number for next ticket
        if (isConnected) {
          await _GetReport_number();
        } else {
          // If offline, increment locally
          setState(() {
            int currentReqNum = int.parse(Reportnumber);
            Reportnumber = (currentReqNum + 1).toString();
          });
        }
      } catch (e) {
        print("Error submitting ticket: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit ticket: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }


    @override
    Widget build(BuildContext context) {
      screenHeight = MediaQuery
          .of(context)
          .size
          .height;
      screenWidth = MediaQuery
          .of(context)
          .size
          .width;
      const brandColor = Color(0xFF104164);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: brandColor),
          title: const Text(
            '',
            style: TextStyle(
              color: brandColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final double contentWidth = maxWidth.clamp(0, 820);
            final double padding = (maxWidth * 0.05).clamp(16.0, 24.0);
            final bool wide = maxWidth >= 700;

            InputDecoration fieldDecoration(
                {required String label, IconData? icon}) {
              return InputDecoration(
                labelText: label,
                prefixIcon: icon == null ? null : Icon(icon, color: brandColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: brandColor.withValues(alpha: 0.18)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: brandColor.withValues(alpha: 0.12)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      sectionCard(
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: brandColor.withValues(alpha: 0.12)),
                              ),
                              child: const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: brandColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Report_number',
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Reportnumber.isEmpty ? '—' : Reportnumber,
                                    style: TextStyle(
                                      color: Colors.black.withValues(
                                          alpha: 0.65),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assest/images/r2.png',
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Report Details',
                              style: TextStyle(
                                color: brandColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedshift,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedshift = newValue;
                                });
                              },
                              items: ['Day', 'Night']
                                  .map((shift) => DropdownMenuItem<String>(
                                        value: shift,
                                        child: Text(shift),
                                      ))
                                  .toList(),
                              decoration: fieldDecoration(
                                  label: 'Shift', icon: Icons.wb_sunny_outlined),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: Department,
                              onChanged: (String? newValue) {
                                setState(() {
                                  Department = newValue;
                                });
                              },
                              items: ['Electrical', 'Mechanical', 'AC']
                                  .map((dept) => DropdownMenuItem<String>(
                                        value: dept,
                                        child: Text(dept),
                                      ))
                                  .toList(),
                              decoration: fieldDecoration(
                                  label: 'Department', icon: Icons.business_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: Machinename,
                              maxLines: 2,
                              decoration: fieldDecoration(
                                  label: 'Machine Name',
                                  icon: Icons.precision_manufacturing_outlined),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: Workordertype,
                              onChanged: (String? newValue) {
                                setState(() {
                                  Workordertype = newValue;
                                });
                              },
                              items: ['Breakdown', 'PM', 'Inspection', 'Service']
                                  .map((type) => DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              decoration: fieldDecoration(
                                  label: 'Work Order Type',
                                  icon: Icons.build_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: DescriptionOfMain,
                              maxLines: 5,
                              decoration: fieldDecoration(
                                  label: 'Job Description',
                                  icon: Icons.description_outlined),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: StartTime,
                              readOnly: true,
                              decoration: fieldDecoration(
                                  label: 'Start Time',
                                  icon: Icons.access_time),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    DateTime fullDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    setState(() {
                                      StartTime.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
                                    });
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: EndTime,
                              readOnly: true,
                              decoration: fieldDecoration(
                                  label: 'End Time',
                                  icon: Icons.access_time_filled),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    DateTime fullDateTime = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                    setState(() {
                                      EndTime.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
                                    });
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: StatusOfMain,
                              onChanged: (String? newValue) {
                                setState(() {
                                  StatusOfMain = newValue;
                                });
                              },
                              items: ['Completed', 'Pending']
                                  .map((status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                              decoration: fieldDecoration(
                                  label: 'Status', icon: Icons.check_circle_outline),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: Remarks,
                              maxLines: 3,
                              decoration: fieldDecoration(
                                  label: 'Remarks',
                                  icon: Icons.note_outlined),
                            ),

                            const SizedBox(height: 12),
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Images',
                                    style: TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _selectedImages.length >= _maxImages ? null : _takeImageWithCamera,
                                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                          label: const Text('Camera'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _selectedImages.length >= _maxImages ? null : _pickImagesFromGallery,
                                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                                          label: const Text('Gallery'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${_selectedImages.length} / $_maxImages selected',
                                      style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (_selectedImages.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _selectedImages.length,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final img = _selectedImages[index];
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.file(
                                                File(img.path),
                                                fit: BoxFit.cover,
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: InkWell(
                                                  onTap: () => _removeSelectedImage(index),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.55),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),


                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                color: brandColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Reported By: $reportedBy',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date/Time: $currentDateTime',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                            await submitTicket();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            isSubmitting ? 'Submitting...' : 'Submit',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
