import 'package:application_v1/Orders/Voiceupreview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../Req_report/TicketDetailsReports.dart';
import '../login/user_provider.dart';
import 'TicketDetailsPage.dart';
import 'TicketDetailsReview.dart';

class StatusPageAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? admin = Provider.of<UserProvider>(context).email;

    const brandColor = Color(0xFF104164);


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Admin Status',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth.clamp(0, 860);
          final double padding = (maxWidth * 0.04).clamp(12.0, 20.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(padding, 12, padding, 16),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Tickets',
                      icon: Icons.confirmation_number_outlined,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('Tickets').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final tickets = snapshot.data!.docs;

                          if (tickets.isEmpty) {
                            return const Center(child: Text('No tickets found.'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              final manager = ticket['manager'];
                              final status = ticket['status'];
                              final status1 = ticket['status1'];
                              final reqNumber = ticket['Requisition Number'];

                              final isCompleteNotApproved = status == 'Complete' && status1 == 'NotApprove';
                              final isCompleteAndApproved = status == 'Complete' && status1 == 'Approved';
                              final isManager = manager == admin;

                              if (manager != admin) {
                                return Container();
                              }

                              final Color tint = isCompleteAndApproved
                                  ? Colors.green.withOpacity(0.10)
                                  : isCompleteNotApproved
                                  ? Colors.orange.withOpacity(0.10)
                                  : Colors.white;

                              final IconData trailingIcon = isCompleteAndApproved
                                  ? Icons.check_circle
                                  : isCompleteNotApproved
                                  ? Icons.pending
                                  : Icons.block;

                              final Color trailingColor = isCompleteAndApproved
                                  ? Colors.green
                                  : isCompleteNotApproved
                                  ? Colors.orange
                                  : Colors.grey;

                              void openTicket() {
                                if (isCompleteNotApproved) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TicketDetailsPage(ticket: ticket),
                                    ),
                                  );
                                  return;
                                }

                                if (isCompleteAndApproved) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TicketDetailsReports(ticket: ticket),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TicketDetailsReview(ticket: ticket),
                                  ),
                                );
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: brandColor.withOpacity(0.10)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: openTicket,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      tileColor: tint,
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: brandColor.withOpacity(0.10)),
                                        ),
                                        child: const Icon(Icons.receipt_long_outlined, color: brandColor),
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
                                      subtitle: Text(
                                        'Status: $status, $status1',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.black.withOpacity(0.60), fontWeight: FontWeight.w700),
                                      ),
                                      trailing: Icon(trailingIcon, color: trailingColor),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Voice Up',
                      icon: Icons.record_voice_over_outlined,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('voice_up_messages').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final messages = snapshot.data!.docs;

                          if (messages.isEmpty) {
                            return const Center(child: Text('No messages found.'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final stageOne = message['Stageone'];
                              final stageTwo = message['Stagetwo'];
                              final Statusofmassage = message['Statusofmassage'];

                              final isITSME = stageOne == admin && Statusofmassage == "";
                              final isITApproved = Statusofmassage == "Approved";
                              final isITSGM = stageTwo == admin && Statusofmassage == "Approved";

                              if (stageOne != admin) {
                                return Container();
                              }

                              final IconData trailingIcon = isITSME
                                  ? Icons.pending
                                  : isITApproved
                                  ? Icons.check_circle
                                  : isITSGM
                                  ? Icons.block
                                  : Icons.block;

                              final Color trailingColor = isITSME
                                  ? Colors.red
                                  : isITApproved
                                  ? Colors.green
                                  : isITSGM
                                  ? Colors.blue
                                  : Colors.grey;

                              final Color tint = isITSGM
                                  ? Colors.green.withOpacity(0.10)
                                  : isITSME
                                  ? Colors.orange.withOpacity(0.10)
                                  : Colors.white;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: brandColor.withOpacity(0.10)),
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  tileColor: tint,
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: brandColor.withOpacity(0.10)),
                                    ),
                                    child: const Icon(Icons.voice_chat_outlined, color: brandColor),
                                  ),
                                  title: Text(
                                    'Message #${index + 1} $Statusofmassage',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    message['message'] ?? 'No message content',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.black.withOpacity(0.60), fontWeight: FontWeight.w700),
                                  ),
                                  trailing: Icon(trailingIcon, color: trailingColor),
                                  onTap: isITSME
                                      ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VoiceUpRequesting(message: message),
                                      ),
                                    );
                                  }
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Change Password',
                      icon: Icons.lock_reset_outlined,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('ChangePassword').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final changePasswords = snapshot.data!.docs;

                          if (changePasswords.isEmpty) {
                            return const Center(child: Text('No change password requests found.'));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: changePasswords.length,
                            itemBuilder: (context, index) {
                              final changePassword = changePasswords[index];
                              final admins = changePassword['adminneed'];
                              final status = changePassword['status'];
                              final username = changePassword['Username'];
                              final oldPassword = changePassword['Oldpassword'];
                              final newPassword = changePassword['Newpassword'];

                              final isPending = admins == admin && status == "pending";
                              final isComplete = status == "complete";
                              final isRejected = status == "rejected";

                              if (admins != admin) {
                                return Container();
                              }

                              final Color tint = isComplete
                                  ? Colors.green.withOpacity(0.10)
                                  : isRejected
                                  ? Colors.red.withOpacity(0.10)
                                  : Colors.white;

                              void openChangePasswordDetails() {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Change Password Request'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SelectableText('Username: $username'),
                                            const SizedBox(height: 8),
                                            SelectableText('Old Password: $oldPassword'),
                                            const SizedBox(height: 8),
                                            SelectableText('New Password: $newPassword'),
                                            const SizedBox(height: 8),
                                            SelectableText('Status: $status'),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: brandColor.withOpacity(0.10)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: openChangePasswordDetails,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      tileColor: tint,
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: brandColor.withOpacity(0.10)),
                                        ),
                                        child: const Icon(Icons.manage_accounts_outlined, color: brandColor),
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
                                      subtitle: Text(
                                        'Status: $status',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.black.withOpacity(0.60), fontWeight: FontWeight.w700),
                                      ),
                                      trailing: isPending
                                          ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('ChangePassword')
                                                  .doc(changePassword.id)
                                                  .update({'status': 'complete'});
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.red),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('ChangePassword')
                                                  .doc(changePassword.id)
                                                  .update({'status': 'rejected'});
                                            },
                                          ),
                                        ],
                                      )
                                          : isComplete
                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                          : const Icon(Icons.block, color: Colors.red),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF104164);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: brandColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: brandColor.withOpacity(0.12)),
                ),
                child: Icon(icon, color: brandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: brandColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
