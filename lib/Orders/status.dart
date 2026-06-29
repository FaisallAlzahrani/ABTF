import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../Req_report/TicketDetailsReports.dart';
import '../login/user_provider.dart';
import 'TicketDetailsReview.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? personalStatus = Provider.of<UserProvider>(context).firstName;
    String? personalFileNumber = Provider.of<UserProvider>(context).email;

    const brandColor = Color(0xFF104164);

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
          final double contentWidth = maxWidth.clamp(0, 820);
          final double horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 12),
                    sliver: SliverToBoxAdapter(
                      child: Container(
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
                              child: const Icon(Icons.track_changes_outlined, color: brandColor),
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
                                    'Track your requests status',
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
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Change Password Requests',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w900,
                          fontSize: (maxWidth * 0.040).clamp(15.0, 18.0),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 24),
                    sliver: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('ChangePassword').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final changePasswords = snapshot.data!.docs;

                        if (changePasswords.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: Text('No change password requests found.')),
                            ),
                          );
                        }

                        final filtered = changePasswords
                            .where((doc) => doc['Username'] == personalFileNumber)
                            .toList();

                        if (filtered.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: Text('No requests found for your account.')),
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
                                    'Req#${index + 1}  FileNo. $username',
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
                                      'Old Password: $oldPassword\nNew Password: $newPassword',
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
