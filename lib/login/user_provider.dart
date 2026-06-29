import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = "";
  String _email = "";
  String _emp_id= "";
  String _department_id = "";
  String? _fcmToken;

  String get firstName => _firstName;
  String get email => _email;
  String get empid => _emp_id;
  String get department_id => _department_id;
  
  // Load user data from SharedPreferences when app starts
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('userName') ?? "";
    _email = prefs.getString('username') ?? "";
    _emp_id = prefs.getString('userId') ?? "";
    _department_id = prefs.getString('userDepartment') ?? "";
    _fcmToken = prefs.getString('fcmToken');
    notifyListeners();
  }

  // Update methods that also save to SharedPreferences
  Future<void> updateFirstName(String name) async {
    _firstName = name;
    print("Updated first name: $_firstName");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    _email = email;
    print("Updated email: $_email");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', email);
    notifyListeners();
  }
  
  Future<void> updateEmpId(String id) async {
    _emp_id = id;
    print("Updated emp_id: $_emp_id");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    notifyListeners();
  }
  
  Future<void> updatedeoartment_id(String department_id) async {
    _department_id = department_id;
    print("Updated department_id: $_department_id");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDepartment', department_id);
    notifyListeners();
  }
  
  Future<void> updateFcmToken(String fcmToken) async {
    _fcmToken = fcmToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', fcmToken);
    notifyListeners();
  }
  Future<void> logout() async {
    _firstName = '';
    _emp_id = '';
    _department_id= '';
    _email = '';
    _fcmToken = null;
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('username');
    await prefs.remove('userId');
    await prefs.remove('userDepartment');
    await prefs.remove('fcmToken');
    await prefs.setBool('isLoggedIn', false);
    
    notifyListeners();
  }
}

