import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../login/user_provider.dart';
import 'Operation_Approved.dart';

class StatusPageoperations extends StatelessWidget {
  double screenHeight = 0;
  double screenWidth = 0;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    String? PersonalStatus = Provider.of<UserProvider>(context).firstName;
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
                              child: const Icon(Icons.support_agent_outlined, color: brandColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    PersonalStatus ?? '',
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
                                    'Operations tickets that need your action',
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
                        'Tickets',
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
                      stream: FirebaseFirestore.instance.collection('Tickets').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }

                        final tickets = snapshot.data!.docs;

                        if (tickets.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: Text('No tickets found.')),
                            ),
                          );
                        }

                        final filtered = tickets.where((t) => t['Reported_By'] == PersonalStatus).toList();

                        if (filtered.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: Text('No tickets assigned to you.')),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final ticket = filtered[index];
                              final Reported_By = ticket['Reported_By'];
                              final Operation = ticket['Operation'];
                              final reqNumber = ticket['Requisition Number'];

                              final ispendingNotApproved = Operation == 'NotApproved' && PersonalStatus == Reported_By;

                              final Color cardColor = ispendingNotApproved
                                  ? (Colors.orange[50] ?? Colors.white)
                                  : Colors.white;

                              final IconData icon = ispendingNotApproved
                                  ? Icons.pending_outlined
                                  : Icons.block;

                              final Color iconColor = ispendingNotApproved
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
                                      'Status: $Operation, ReportedBy: $Reported_By',
                                      maxLines: 2,
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
                                      ispendingNotApproved ? 'Pending' : 'Blocked',
                                      style: TextStyle(
                                        color: iconColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  onTap: ispendingNotApproved
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OperationApprovedPage(ticket: ticket),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

