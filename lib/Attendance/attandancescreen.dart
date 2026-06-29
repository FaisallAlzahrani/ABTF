import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';


import '../login/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  Position? _currentPosition;
  late GoogleMapController _mapController;
  bool isLoading = false;
  String? emp_code;
  String? emp_id;
  String? name;
  String? _currentAddress;
  XFile? _capturedImage;
  String? _lastPunchTime;
  String? _lastPunchLocation;
  String? _Picture;


  Future<void> _capturePhoto() async {
    final ImagePicker picker = ImagePicker();
    _capturedImage = await picker.pickImage(source: ImageSource.camera);
  }


  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              "Location permissions are denied. Please enable them.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      // Fetch address using reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        _currentAddress =
        "${place.street}, ${place.locality}, ${place
            .subAdministrativeArea}, ${place.administrativeArea}, ${place
            .country}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
      print('$e');
      print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
    }
  }

  /// Send the attendance record to the API
  Future<void> _captureAndSendAttendance(int punchState) async {
    final ImagePicker picker = ImagePicker();
    try {
      // Open the camera to capture the photo
      XFile? capturedImage = await picker.pickImage(source: ImageSource.camera);

      if (capturedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No photo captured. Please try again.")),
        );
        return;
      }

      setState(() {
        _capturedImage = capturedImage; // Save the captured image
      });

      // Read image bytes and encode to Base64
      final imageBytes = await capturedImage.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Call the attendance function with the photo
      await _sendAttendance(punchState, base64Image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing photo: $e")),
      );
    }print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
  }
  Future<void> _pickImage() async {
    // Request permissions
    if (await Permission.camera.request().isGranted &&
        await Permission.photos.request().isGranted) {
      // Use image_picker after permissions are granted
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        print('Image Path: ${pickedFile.path}');
      }
    } else {
      print('Permissions not granted.');
    }
  }
  Future<void> _loadLastPunchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastPunchTime = prefs.getString('lastPunchTime');
      _lastPunchLocation = prefs.getString('lastPunchLocation');
      String? imagePath = prefs.getString('Picture');
      if (imagePath != null) {
        _capturedImage = XFile(imagePath); // Load the image from the saved path
      }
    });
  }

  /// Save the last punch data to SharedPreferences
  Future<void> _saveLastPunchData( String time, String location, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPunchTime', time);
    await prefs.setString('lastPunchLocation', location);
    await prefs.setString('Picture', imagePath); // Save the file path
    setState(() {
      _lastPunchTime = time;
      _lastPunchLocation = location;
      _Picture = imagePath;
    });
  }



  //Future<void> _sendToFirebase(String firstname, String empCode, DateTime timestamp, String base64Image) async {
   // String timestampStr = timestamp.toString();

    //await FirebaseFirestore.instance.collection('attendances').add({
     // 'firstname': name,
     // 'emp_code': empCode,
     // 'timestamp': timestampStr,
     // 'timestamp_obj': Timestamp.fromDate(timestamp),
     // 'image_base64': base64Image, // Save Base64 string instead of URL
   // });
//  }



  Future<void> _sendAttendance(int punchState, String base64Image) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location not available. Please enable GPS.")),
      );
      return;
    }

    if (_currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Address not available. Please try again.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    String uploadTime = DateTime.now().toString();
    // Prepare API data
    Map<String, dynamic> requestData = {
      'punch_state': "$punchState", // 0 for Check In, 1 for Check Out
      'punch_time': "${DateTime.now().millisecondsSinceEpoch ~/ 1000}",
      'gps_location': "$_currentAddress", // Dynamic address fetched from GPS
      'emp_code': "$emp_code",
      'verify_type': '0',
      'work_code': '',
      'terminal_sn': 'App',
      'longitude': _currentPosition!.longitude.toString(),
      'latitude': _currentPosition!.latitude.toString(),
      'source': '3',
      'purpose': '1',
      'is_attendance': '1',
      'upload_time': DateTime.now().toString(),
      'sync_status': '0',
      'is_mask': '255',
      'temperature': '255.0',
      'emp_id': "$emp_id",
    };

    try {
      final response = await http.post(
        Uri.parse("http://172.18.100.173:8086/iclock_transaction"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        if (_capturedImage != null) {
          await _saveLastPunchData(uploadTime, _currentAddress!, _capturedImage!.path);
          //await _sendToFirebase(name ??'', emp_code ?? '', DateTime.now(), base64Image);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance recorded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to record attendance: ${response.body}")),
        );
      }







    } catch (e) {
      setState(() {print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
        isLoading = false;
      });print('$e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    print('$requestData');

  }
  /// Show a dialog to let the user choose Check In or Check Out
  void _showPunchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Attendance Type"),
          content: const Text("Please choose Check In or Check Out."),
          actions: <Widget>[
            TextButton(
              onPressed: () {print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                Navigator.pop(context); // Close the dialog
                _captureAndSendAttendance(0); // Send Check In (0)
              },
              child: const Text("Check In"),
            ),
            TextButton(
              onPressed: () {print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                Navigator.pop(context); // Close the dialog
                _captureAndSendAttendance(1); // Send Check Out (1)
              },
              child: const Text("Check Out"),
            ),
          ],
        );
      },
    );
  }


  @override

    void initState() {
      super.initState();
      _getCurrentLocation(); // Fetch location on startup
      _loadLastPunchData(); // Load saved punch data
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

  @override
  void dispose() {
    // Reset orientation to allow all orientations when leaving this screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    // Fetch employee details from the provider
    emp_code ??= Provider.of<UserProvider>(context, listen: false).email;
    emp_id ??= Provider.of<UserProvider>(context, listen: false).empid;
    name ??= Provider.of<UserProvider>(context, listen: false).firstName;

    const brandColor = Color(0xFF104164);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        title: const Text(
          "Attendance",
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: brandColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                final double horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);
                final double contentWidth = maxWidth.clamp(0, 720);
                final double cardRadius = 18;

                final String locationText = (_lastPunchLocation != null && _lastPunchLocation!.length > 20)
                    ? '${_lastPunchLocation!.substring(0, 56)}...'
                    : (_lastPunchLocation ?? "No record");

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 16,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[50],
                                borderRadius: BorderRadius.circular(cardRadius),
                                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Recent Punches',
                                            style: TextStyle(
                                              color: brandColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: (maxWidth * 0.040).clamp(15.0, 18.0),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Last Punch',
                                            style: TextStyle(
                                              color: Colors.black.withValues(alpha: 0.70),
                                              fontWeight: FontWeight.w800,
                                              fontSize: (maxWidth * 0.032).clamp(12.0, 14.0),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Time: ${_lastPunchTime ?? "No record"}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black.withValues(alpha: 0.65),
                                              fontWeight: FontWeight.w600,
                                              fontSize: (maxWidth * 0.030).clamp(12.0, 14.0),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Location: $locationText',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black.withValues(alpha: 0.65),
                                              fontWeight: FontWeight.w600,
                                              fontSize: (maxWidth * 0.030).clamp(12.0, 14.0),
                                            ),
                                          ),
                                          if (_currentAddress != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'Current: ${_currentAddress!}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: brandColor.withValues(alpha: 0.85),
                                                fontWeight: FontWeight.w700,
                                                fontSize: (maxWidth * 0.028).clamp(11.0, 13.0),
                                              ),
                                            ),
                                          ],
                                          if (_capturedImage != null) ...[
                                            const SizedBox(height: 12),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                height: 84,
                                                width: 84,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: brandColor.withValues(alpha: 0.20),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Image.file(
                                                  File(_capturedImage!.path),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Center(child: Text('Failed to load image'));
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 48,
                                          child: ElevatedButton.icon(
                                            onPressed: _showPunchDialog,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: brandColor,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                                side: BorderSide(
                                                  color: brandColor.withValues(alpha: 0.20),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            icon: const Icon(Icons.punch_clock, size: 20),
                                            label: const Text(
                                              'Punch',
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 40,
                                          child: OutlinedButton.icon(
                                            onPressed: _getCurrentLocation,
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: brandColor,
                                              side: BorderSide(color: brandColor.withValues(alpha: 0.20), width: 2),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                            icon: const Icon(Icons.my_location, size: 18),
                                            label: const Text(
                                              'Update',
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Location',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.70),
                                fontWeight: FontWeight.w900,
                                fontSize: (maxWidth * 0.040).clamp(15.0, 18.0),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              height: (screenHeight * 0.34).clamp(220.0, 360.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(cardRadius),
                                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(cardRadius),
                                child: _currentPosition == null
                                    ? Center(
                                        child: Text(
                                          'Fetching location…',
                                          style: TextStyle(
                                            color: Colors.black.withValues(alpha: 0.55),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            _currentPosition!.latitude,
                                            _currentPosition!.longitude,
                                          ),
                                          zoom: 15,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId('user_location'),
                                            position: LatLng(
                                              _currentPosition!.latitude,
                                              _currentPosition!.longitude,
                                            ),
                                          ),
                                        },
                                        onMapCreated: (GoogleMapController controller) {
                                          _mapController = controller;
                                        },
                                        zoomControlsEnabled: true,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );

  }

}




