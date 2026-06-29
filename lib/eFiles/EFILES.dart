import 'package:application_v1/eFiles/BusinessTrip.dart';
import 'package:application_v1/eFiles/Ticket.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../login/user_provider.dart';


class eFile extends StatefulWidget {
  const eFile({Key? key}) : super(key: key);

  @override
  State<eFile> createState() => _eFileState();
}

class _eFileState extends State<eFile> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _ibanController = TextEditingController();
  final _fileController = TextEditingController();
  final _uplodeSecondFile = TextEditingController();
  final _any = TextEditingController();
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final admin = '18069';
  final status = 'pending';
  String? username;

  String? _SelectedFilePath;

  @override
  void dispose() {
    _fileController.dispose();
    _companyNameController.dispose();
    _uplodeSecondFile.dispose();
    _any.dispose();
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    String? subtitle,
    String? badge,
  }) {
    const brandColor = Color(0xFF104164);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                  ),
                  child: Icon(icon, color: brandColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: enabled ? brandColor : Colors.black54,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null && badge.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Icon(
                  Icons.arrow_forward_rounded,
                  color: brandColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void>
  _openFilePicker() async {
    FilePickerResult? result =
    await
    FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _SelectedFilePath =
            result.files.single.path;
        _fileController.text =
            result.files.single.name;
      });
    }
  }

  // Function to show the popup dialog for Salary Statement
  void showSalaryStatementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Salary Statement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Company Name:'),
              TextFormField(
                controller: _companyNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                },
              ),
              Text('any'),
              TextFormField(
                controller: _any,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Perform the submit action here
                  print('Submitted');
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    final username = Provider.of<UserProvider>(context, listen: false).email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const brandColor = Color(0xFF104164);

        InputDecoration decoration(String label, IconData icon) {
          return InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: brandColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brandColor.withValues(alpha: 0.20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brandColor.withValues(alpha: 0.16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: brandColor, width: 2),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brandColor.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                  ),
                  child: const Icon(Icons.lock_reset_outlined, color: brandColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Change Password',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: decoration('Old Password', Icons.lock_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: decoration('New Password', Icons.lock_open_outlined),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: decoration('Confirm New Password', Icons.verified_outlined),
                      validator: (value) {
                        if (value == null || value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: brandColor,
                  side: BorderSide(color: brandColor.withValues(alpha: 0.20), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('ChangePassword')
                          .add({
                        'Username': username,
                        'Oldpassword': _oldPasswordController.text.trim(),
                        'Newpassword': _newPasswordController.text.trim(),
                        'adminneed' : admin,
                        'status': status,
                      });
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();


                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password change request submitted successfully!"),
                          duration: Duration(seconds: 3),
                        ),
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error submitting request: $e"),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        );
      },
    );
  }



  // Function to show the popup dialog for Change Bank
  void showChangeBankDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Bank'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Uploaded File:'),
              TextFormField(
                controller: _fileController,
                decoration: InputDecoration(labelText: 'Upload'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please upload';
                  }
                  return null;
                },
                readOnly: true,
                onTap: _openFilePicker,
              ),
              Text('Uploaded second File:'),
              TextFormField(
                controller: _uplodeSecondFile,
                decoration: InputDecoration(labelText: 'Upload'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please upload';
                  }
                },
                readOnly: true,
                onTap: _openFilePicker,
              ),

            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                // Perform the submit action here
                print('Submitted');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context, listen: false).firstName;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    const brandColor = Color(0xFF104164);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        title: const Text(
          'eFILE',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: brandColor),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);
          final double contentWidth = maxWidth.clamp(0, 720);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
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
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                              ),
                              child: const Icon(Icons.folder_open_outlined, color: brandColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello ${username.isNotEmpty ? username : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Submit requests and manage your employee files',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Services',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.70),
                          fontWeight: FontWeight.w900,
                          fontSize: (maxWidth * 0.040).clamp(15.0, 18.0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context: context,
                        title: 'Salary Statement',
                        subtitle: 'Generate & download (coming soon)',
                        icon: Icons.receipt_long_outlined,
                        enabled: false,
                        badge: 'Soon',
                        onTap: () {
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context: context,
                        title: 'Change Bank',
                        subtitle: 'Upload IBAN/bank details (coming soon)',
                        icon: Icons.account_balance_outlined,
                        enabled: false,
                        badge: 'Soon',
                        onTap: () {
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context: context,
                        title: 'Ticket',
                        subtitle: 'Request a ticket (coming soon)',
                        icon: Icons.confirmation_number_outlined,
                        enabled: false,
                        badge: 'Soon',
                        onTap: () {
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context: context,
                        title: 'Forms',
                        subtitle: 'Company forms (coming soon)',
                        icon: Icons.description_outlined,
                        enabled: false,
                        badge: 'Soon',
                        onTap: () {
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        context: context,
                        title: 'Change Password',
                        subtitle: 'Submit password change request',
                        icon: Icons.lock_reset_outlined,
                        onTap: () {
                          showChangePasswordDialog();
                        },
                      ),
                      const SizedBox(height: 24),
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
