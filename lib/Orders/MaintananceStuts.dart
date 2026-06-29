import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Req_report/TicketDetailsReports.dart';
import '../login/user_provider.dart';
import 'TicketDetailsReview.dart';

class StatusMaintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? personalStatus = Provider.of<UserProvider>(context).firstName;
    String? personalFileNumber = Provider.of<UserProvider>(context).email;
    String? personalEmpId = Provider.of<UserProvider>(context).empid;

    const brandColor = Color(0xFF104164);

    const String managerEmpCode = '18096';

    String _formatTimestamp(dynamic value) {
      if (value is Timestamp) {
        return DateFormat('yyyy-MM-dd HH:mm').format(value.toDate());
      }
      return '';
    }

    Widget _chip({required String text, required Color color}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      );
    }

    Widget _infoRow({required String label, required String value}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _sectionCard({required String title, required Widget child}) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandColor.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: brandColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
    }

    Future<void> confirmDailyReportSupervisor(DocumentSnapshot reportDoc) async {
      if (personalFileNumber == null || personalFileNumber.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing file number. Please login again.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snapshot = await tx.get(reportDoc.reference);
          final data = snapshot.data() as Map<String, dynamic>?;

          final assigned = (data?['assigned_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
          final approved = (data?['approved_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

          if (!assigned.contains(personalFileNumber)) {
            throw Exception('This report is not assigned to you.');
          }

          final approvedSet = approved.toSet();
          approvedSet.add(personalFileNumber!);

          final allApproved = assigned.isNotEmpty && assigned.every(approvedSet.contains);
          final stage = allApproved ? 'pending_manager' : 'pending_supervisors';

          tx.update(reportDoc.reference, {
            'approved_supervisors': approvedSet.toList(),
            'all_supervisors_approved': allApproved,
            'approval_stage': stage,
            'supervisor_confirmed_at.${personalFileNumber!}': FieldValue.serverTimestamp(),
          });
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirmed successfully.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm: ${e.toString()}')),
        );
      }
    }

    Future<void> rejectDailyReportManager(DocumentSnapshot reportDoc) async {
      if (personalFileNumber == null || personalFileNumber.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing manager id. Please login again.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snapshot = await tx.get(reportDoc.reference);
          final data = snapshot.data() as Map<String, dynamic>?;

          final manager = data?['Manager']?.toString() ?? '';
          final allApproved = data?['all_supervisors_approved'] == true;
          final stage = data?['approval_stage']?.toString() ?? '';
          final alreadyApproved = data?['manager_approved'] == true;

          if (manager != personalFileNumber) {
            throw Exception('This report is not assigned to you as manager.');
          }

          if (alreadyApproved) {
            throw Exception('This report is already approved.');
          }

          if (!allApproved || stage != 'pending_manager') {
            throw Exception('This report is not ready for manager action yet.');
          }

          tx.update(reportDoc.reference, {
            'manager_rejected': true,
            'approval_stage': 'rejected',
            'manager_rejected_at': FieldValue.serverTimestamp(),
          });
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report rejected.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: ${e.toString()}')),
        );
      }
    }

    Future<void> openDailyReport(DocumentSnapshot reportDoc) async {
      final data = reportDoc.data() as Map<String, dynamic>?;
      final reportNumber = data?['Report Number']?.toString() ?? reportDoc.id;
      final dept = data?['Selected Dept']?.toString() ?? '';
      final machine = data?['Machine Name']?.toString() ?? '';
      final desc = data?['Description Of Maintanance']?.toString() ?? '';
      final start = data?['Start Time']?.toString() ?? '';
      final end = data?['End Time']?.toString() ?? '';
      final stage = data?['approval_stage']?.toString() ?? '';
      final images = (data?['images'] as List?)?.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList() ?? <String>[];
      final approved = (data?['approved_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
      final bool alreadyConfirmed = personalFileNumber != null && approved.contains(personalFileNumber);
      final Map<String, dynamic>? confirmedAtMap = (data?['supervisor_confirmed_at'] as Map?)
          ?.map((key, value) => MapEntry(key.toString(), value));
      final confirmedAt = personalFileNumber == null ? null : confirmedAtMap?[personalFileNumber!];
      final confirmedAtText = _formatTimestamp(confirmedAt);

      final Color stageColor = stage == 'pending_manager'
          ? Colors.orange
          : stage == 'completed'
              ? Colors.green
              : stage == 'rejected'
                  ? Colors.red
                  : brandColor;

      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'Daily Maintenance Review',
              style: const TextStyle(color: brandColor, fontWeight: FontWeight.w900),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(text: 'Report #$reportNumber', color: brandColor),
                        _chip(text: stage.isEmpty ? 'stage: -' : stage, color: stageColor),
                        _chip(
                          text: alreadyConfirmed ? 'Confirmed' : 'Pending',
                          color: alreadyConfirmed ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _sectionCard(
                      title: 'Report Details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(label: 'Department', value: dept),
                          _infoRow(label: 'Machine', value: machine),
                          _infoRow(label: 'Start Time', value: start),
                          _infoRow(label: 'End Time', value: end),
                        ],
                      ),
                    ),
                    _sectionCard(
                      title: 'Description',
                      child: Text(
                        desc.isEmpty ? '-' : desc,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, height: 1.35),
                      ),
                    ),
                    if (images.isNotEmpty)
                      _sectionCard(
                        title: 'Images',
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: images.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final url = images[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.04),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.broken_image_outlined, color: Colors.black.withValues(alpha: 0.35)),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: brandColor.withValues(alpha: 0.80),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    _sectionCard(
                      title: 'Your Confirmation',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(label: 'File Number', value: personalFileNumber ?? ''),
                          _infoRow(label: 'Status', value: alreadyConfirmed ? 'Confirmed' : 'Not confirmed yet'),
                          _infoRow(label: 'Confirmed At', value: confirmedAtText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: alreadyConfirmed ? null : () => Navigator.of(dialogContext).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        await confirmDailyReportSupervisor(reportDoc);
      }
    }

    Future<void> approveDailyReportManager(DocumentSnapshot reportDoc) async {
      if (personalFileNumber == null || personalFileNumber.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing manager id. Please login again.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snapshot = await tx.get(reportDoc.reference);
          final data = snapshot.data() as Map<String, dynamic>?;

          final manager = data?['Manager']?.toString() ?? '';
          final allApproved = data?['all_supervisors_approved'] == true;
          final stage = data?['approval_stage']?.toString() ?? '';
          final alreadyApproved = data?['manager_approved'] == true;


          if (alreadyApproved) {
            throw Exception('This report is already approved.');
          }

          if (manager != personalFileNumber) {
            throw Exception('This report is not assigned to you as manager.');
          }

          if (!allApproved || stage != 'pending_manager') {
            throw Exception('This report is not ready for manager approval yet.');
          }

          tx.update(reportDoc.reference, {
            'manager_approved': true,
            'approval_stage': 'completed',
            'manager_confirmed_at': FieldValue.serverTimestamp(),
          });
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manager approval completed.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: ${e.toString()}')),
        );
      }
    }

    Future<void> openDailyReportManager(DocumentSnapshot reportDoc) async {
      final data = reportDoc.data() as Map<String, dynamic>?;
      final reportNumber = data?['Report Number']?.toString() ?? reportDoc.id;
      final dept = data?['Selected Dept']?.toString() ?? '';
      final machine = data?['Machine Name']?.toString() ?? '';
      final desc = data?['Description Of Maintanance']?.toString() ?? '';
      final start = data?['Start Time']?.toString() ?? '';
      final end = data?['End Time']?.toString() ?? '';
      final stage = data?['approval_stage']?.toString() ?? '';
      final images = (data?['images'] as List?)?.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList() ?? <String>[];
      final bool managerApproved = data?['manager_approved'] == true;
      final bool managerRejected = data?['manager_rejected'] == true || stage == 'rejected';
      final bool canTakeAction = stage == 'pending_manager' && !managerApproved && !managerRejected;
      final approvedSupervisors = (data?['approved_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
      final assignedSupervisors = (data?['assigned_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      final Color stageColor = stage == 'pending_manager'
          ? Colors.orange
          : stage == 'completed'
              ? Colors.green
              : stage == 'rejected'
                  ? Colors.red
                  : brandColor;

      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              'Manager Review',
              style: const TextStyle(color: brandColor, fontWeight: FontWeight.w900),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(text: 'Report #$reportNumber', color: brandColor),
                        _chip(text: stage.isEmpty ? 'stage: -' : stage, color: stageColor),
                        _chip(
                          text: managerApproved
                              ? 'Approved'
                              : managerRejected
                                  ? 'Rejected'
                                  : 'Pending',
                          color: managerApproved
                              ? Colors.green
                              : managerRejected
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _sectionCard(
                      title: 'Report Details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(label: 'Department', value: dept),
                          _infoRow(label: 'Machine', value: machine),
                          _infoRow(label: 'Start Time', value: start),
                          _infoRow(label: 'End Time', value: end),
                        ],
                      ),
                    ),
                    _sectionCard(
                      title: 'Description',
                      child: Text(
                        desc.isEmpty ? '-' : desc,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, height: 1.35),
                      ),
                    ),
                    if (images.isNotEmpty)
                      _sectionCard(
                        title: 'Images',
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: images.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final url = images[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.04),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.broken_image_outlined, color: Colors.black.withValues(alpha: 0.35)),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: brandColor.withValues(alpha: 0.80),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    _sectionCard(
                      title: 'Supervisors Confirmation',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            label: 'Confirmed',
                            value: '${approvedSupervisors.length} / ${assignedSupervisors.length}',
                          ),
                          if (approvedSupervisors.isNotEmpty)
                            Text(
                              approvedSupervisors.join(', '),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: canTakeAction ? () => Navigator.of(dialogContext).pop(null) : null,
                child: const Text('Reject'),
              ),
              ElevatedButton(
                onPressed: canTakeAction ? () => Navigator.of(dialogContext).pop(true) : null,
                child: const Text('Approve'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        await approveDailyReportManager(reportDoc);
      } else if (result == null) {
        final rejectConfirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Reject Report'),
              content: const Text('Are you sure you want to reject this report?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Reject'),
                ),
              ],
            );
          },
        );

        if (rejectConfirm == true) {
          await rejectDailyReportManager(reportDoc);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Status',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth.clamp(0, 900);
          final double horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);

          Widget sectionTitle(String text) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w900,
                  fontSize: (maxWidth * 0.040).clamp(15.0, 18.0),
                ),
              ),
            );
          }

          Widget headerCard() {
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
                    child: const Icon(Icons.build_outlined, color: brandColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personalStatus ?? '',
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
                          'Maintenance requests assigned to you',
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
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 12),
                    sliver: SliverToBoxAdapter(child: headerCard()),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                    sliver: SliverToBoxAdapter(child: sectionTitle('Tickets')),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                    sliver: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Tickets').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final tickets = snapshot.data!.docs;

                        if (tickets.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: Text('No tickets found.')),
                            ),
                          );
                        }

                        final filtered = tickets.where((t) => t['RecevedBy'] == personalStatus).toList();

                        if (filtered.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: Text('No tickets assigned to you.')),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final ticket = filtered[index];
                              final receivedBy = ticket['RecevedBy'];
                              final status = ticket['status'];
                              final status1 = ticket['status1'];
                              final reqNumber = ticket['Requisition Number'];

                              final isCompleteNotApproved =
                                  status == 'Complete' && status1 == 'NotApprove' && personalStatus == receivedBy;
                              final isCompleteAndApproved =
                                  status == 'Complete' && status1 == 'Approved' && personalStatus == receivedBy;

                              final Color cardColor = isCompleteAndApproved
                                  ? (Colors.green[50] ?? Colors.white)
                                  : isCompleteNotApproved
                                      ? (Colors.orange[50] ?? Colors.white)
                                      : Colors.white;

                              final IconData icon = isCompleteAndApproved
                                  ? Icons.check_circle_outline
                                  : isCompleteNotApproved
                                      ? Icons.pending_outlined
                                      : Icons.block;

                              final Color iconColor = isCompleteAndApproved
                                  ? Colors.green
                                  : isCompleteNotApproved
                                      ? Colors.orange
                                      : Colors.grey;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: brandColor.withValues(alpha: 0.10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                    ),
                                    child: Icon(icon, color: iconColor),
                                  ),
                                  title: Text(
                                    'Requisition #: $reqNumber',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Status: $status, $status1',
                                      style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: brandColor.withValues(alpha: 0.70)),
                                  onTap: isCompleteNotApproved
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TicketDetailsReview(ticket: ticket),
                                            ),
                                          );
                                        }
                                      : isCompleteAndApproved
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TicketDetailsReports(ticket: ticket),
                                                ),
                                              );
                                            }
                                          : null,
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                    sliver: SliverToBoxAdapter(child: sectionTitle('Daily Maintenance Reports')),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                    sliver: StreamBuilder<QuerySnapshot>(
                      stream: personalFileNumber == null || personalFileNumber.trim().isEmpty
                          ? const Stream<QuerySnapshot>.empty()
                          : FirebaseFirestore.instance
                              .collection('Report')
                              .where('assigned_supervisors', arrayContains: personalFileNumber)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final reports = snapshot.data!.docs;
                        final sortedReports = [...reports]
                          ..sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>?;
                            final bData = b.data() as Map<String, dynamic>?;
                            final aTime = aData?['Reported_time']?.toString() ?? '';
                            final bTime = bData?['Reported_time']?.toString() ?? '';
                            return bTime.compareTo(aTime);
                          });

                        if (sortedReports.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: Text('No daily reports assigned to you.')),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final report = sortedReports[index];
                              final data = report.data() as Map<String, dynamic>?;
                              final reportNumber = data?['Report Number']?.toString() ?? report.id;
                              final dept = data?['Selected Dept']?.toString() ?? '';
                              final status = data?['status']?.toString() ?? '';
                              final stage = data?['approval_stage']?.toString() ?? '';

                              final approvedSupervisors =
                                  (data?['approved_supervisors'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
                              final bool isConfirmedByMe =
                                  personalFileNumber != null && approvedSupervisors.contains(personalFileNumber);

                              final Color cardColor = stage == 'completed'
                                  ? (Colors.green[50] ?? Colors.white)
                                  : stage == 'pending_supervisors'
                                      ? (isConfirmedByMe
                                          ? (Colors.blue[50] ?? Colors.white)
                                          : (Colors.orange[50] ?? Colors.white))
                                      : stage == 'pending_manager'
                                          ? (Colors.deepPurple[50] ?? Colors.white)
                                          : stage == 'rejected'
                                              ? (Colors.red[50] ?? Colors.white)
                                              : Colors.white;

                              final IconData icon = stage == 'completed'
                                  ? Icons.check_circle_outline
                                  : stage == 'pending_supervisors'
                                      ? (isConfirmedByMe ? Icons.hourglass_top_rounded : Icons.pending_outlined)
                                      : stage == 'pending_manager'
                                          ? Icons.verified_outlined
                                          : stage == 'rejected'
                                              ? Icons.cancel_outlined
                                              : Icons.assignment_outlined;

                              final Color iconColor = stage == 'completed'
                                  ? Colors.green
                                  : stage == 'pending_supervisors'
                                      ? (isConfirmedByMe ? Colors.blue : Colors.orange)
                                      : stage == 'pending_manager'
                                          ? Colors.deepPurple
                                          : stage == 'rejected'
                                              ? Colors.red
                                              : brandColor;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: brandColor.withValues(alpha: 0.10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                    ),
                                    child: Icon(icon, color: iconColor),
                                  ),
                                  title: Text(
                                    'Report #: $reportNumber',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Dept: $dept, Status: $status, Stage: $stage',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: brandColor.withValues(alpha: 0.70)),
                                  onTap: () {
                                    openDailyReport(report);
                                  },
                                ),
                              );
                            },
                            childCount: sortedReports.length,
                          ),
                        );
                      },
                    ),
                  ),
                  if (personalFileNumber == managerEmpCode)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                      sliver: SliverToBoxAdapter(child: sectionTitle('Manager Approval')),
                    ),
                  if (personalFileNumber == managerEmpCode)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                      sliver: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Report')
                            .where('approval_stage', whereIn: ['pending_manager', 'completed', 'rejected'])
                            .where('Manager', isEqualTo: managerEmpCode)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            );
                          }

                          final pending = snapshot.data!.docs;
                          final sortedPending = [...pending]
                            ..sort((a, b) {
                              final aData = a.data() as Map<String, dynamic>?;
                              final bData = b.data() as Map<String, dynamic>?;
                              final aTime = aData?['Reported_time']?.toString() ?? '';
                              final bTime = bData?['Reported_time']?.toString() ?? '';
                              return bTime.compareTo(aTime);
                            });

                          if (sortedPending.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Center(child: Text('No reports pending manager approval.')),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final report = sortedPending[index];
                                final data = report.data() as Map<String, dynamic>?;
                                final reportNumber = data?['Report Number']?.toString() ?? report.id;
                                final dept = data?['Selected Dept']?.toString() ?? '';
                                final status = data?['status']?.toString() ?? '';
                                final stage = data?['approval_stage']?.toString() ?? '';

                                final Color cardColor = stage == 'completed'
                                    ? (Colors.green[50] ?? Colors.white)
                                    : stage == 'rejected'
                                        ? (Colors.red[50] ?? Colors.white)
                                        : (Colors.orange[50] ?? Colors.white);

                                final IconData icon = stage == 'completed'
                                    ? Icons.check_circle_outline
                                    : stage == 'rejected'
                                        ? Icons.cancel_outlined
                                        : Icons.verified_outlined;

                                final Color iconColor = stage == 'completed'
                                    ? Colors.green
                                    : stage == 'rejected'
                                        ? Colors.red
                                        : Colors.orange;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: brandColor.withValues(alpha: 0.10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                      ),
                                      child: Icon(icon, color: iconColor),
                                    ),
                                    title: Text(
                                      'Report #: $reportNumber',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: brandColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Dept: $dept, Status: $status, Stage: $stage',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: brandColor.withValues(alpha: 0.70)),
                                    onTap: () {
                                      openDailyReportManager(report);
                                    },
                                  ),
                                );
                              },
                              childCount: sortedPending.length,
                            ),
                          );
                        },
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                    sliver: SliverToBoxAdapter(child: sectionTitle('Change Password Requests')),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
                    sliver: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('ChangePassword').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final changePasswords = snapshot.data!.docs;

                        if (changePasswords.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: Text('')),
                            ),
                          );
                        }

                        final filtered = changePasswords.where((doc) {
                          final username = doc['Username'];
                          return username == personalFileNumber;
                        }).toList();

                        if (filtered.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Center(child: Text('')),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final changePassword = filtered[index];
                              final status = changePassword['status'];
                              final username = changePassword['Username'];
                              final oldPassword = changePassword['Oldpassword'];
                              final newPassword = changePassword['Newpassword'];

                              final isPending = status == "pending";
                              final isComplete = status == "complete";
                              final isRejected = status == "rejected";

                              final Color cardColor = isComplete
                                  ? (Colors.green[50] ?? Colors.white)
                                  : isRejected
                                      ? (Colors.red[50] ?? Colors.white)
                                      : isPending
                                          ? (Colors.grey[100] ?? Colors.white)
                                          : Colors.white;

                              final IconData icon = isComplete
                                  ? Icons.check_circle_outline
                                  : isRejected
                                      ? Icons.cancel_outlined
                                      : Icons.pending_outlined;

                              final Color iconColor = isComplete
                                  ? Colors.green
                                  : isRejected
                                      ? Colors.red
                                      : Colors.orange;

                              final String label = isComplete
                                  ? 'Complete'
                                  : isRejected
                                      ? 'Rejected'
                                      : 'Pending';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: brandColor.withValues(alpha: 0.10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                                    ),
                                    child: Icon(icon, color: iconColor),
                                  ),
                                  title: Text(
                                    'Username #${index + 1}: $username',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Status: Old Password: $oldPassword, New Password: $newPassword, $status',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: brandColor.withValues(alpha: 0.14)),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: iconColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        );
                      },
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
