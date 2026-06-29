import 'package:application_v1/Announcement/Announcementpost.dart';
import 'package:application_v1/MissionVisionPage/MissionVision.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Announcement/Announcement.dart';
import '../Attendance/HR_trucking.dart';
import '../Attendance/attandancescreen.dart';
import '../Calender/Calanderone.dart';
import '../Evolation/Evolation.dart';
import '../Orders/VoiceUpPage.dart';
import '../Orders/status.dart';
import '../Timesheet/EmployeeTimesheetPage.dart';
import '../eFiles/EFILES.dart';
import '../login/user_provider.dart';

class Hrdscreen extends StatefulWidget {
  const Hrdscreen({super.key});

  @override
  State<Hrdscreen> createState() => _HrdscreenState();
}

class _HrdscreenState extends State<Hrdscreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Widget _buildDashboardTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    String? badgeText,
    bool enabled = true,
  }) {
    const brandColor = Color(0xFF104164);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double padding = (w * 0.10).clamp(14.0, 18.0);
        final double iconBoxPadding = (w * 0.075).clamp(10.0, 14.0);
        final double iconSize = (w * 0.16).clamp(22.0, 30.0);
        final double titleSize = (w * 0.085).clamp(13.0, 16.0);
        final double subtitleSize = (w * 0.070).clamp(11.5, 13.5);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: enabled ? Colors.white : const Color(0xFFE9EDF2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: brandColor.withValues(alpha: 0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconBoxPadding),
                          decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: brandColor, size: iconSize),
                        ),
                        SizedBox(height: (w * 0.09).clamp(10.0, 14.0)),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: enabled ? brandColor : Colors.black54,
                            fontWeight: FontWeight.w800,
                            fontSize: titleSize,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          SizedBox(height: (w * 0.04).clamp(4.0, 6.0)),
                          Flexible(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: subtitleSize,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(flex: 1),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: brandColor,
                              size: (w * 0.10).clamp(14.0, 18.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (badgeText != null && badgeText.isNotEmpty)
                    Positioned(
                      top: (w * 0.07).clamp(10.0, 12.0),
                      right: (w * 0.07).clamp(10.0, 12.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: (w * 0.06).clamp(8.0, 10.0),
                          vertical: (w * 0.035).clamp(5.0, 6.0),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: (w * 0.060).clamp(10.0, 11.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String Fileno = Provider.of<UserProvider>(context).email;
    String userName = Provider.of<UserProvider>(context).firstName;
    final String userDepartment = userProvider.department_id;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    late FirebaseMessaging _firebaseMessaging;
    final date1 = DateTime.now();
    final date2 = DateTime(date1.year, date1.month + 1, 0);

    const brandColor = Color(0xFF104164);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.blue[900]),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm Logout'),
                content: Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Logout'),
                    onPressed: () async {
                      Provider.of<UserProvider>(context, listen: false).logout();
                      Navigator.pushReplacementNamed(context, '/login');
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const brandColor = Color(0xFF104164);
          final padding = MediaQuery.of(context).padding;
          final double maxWidth = constraints.maxWidth;
          final int crossAxisCount = maxWidth >= 900
              ? 4
              : maxWidth >= 600
              ? 3
              : 2;
          final double horizontalPadding = (constraints.maxWidth * 0.04).clamp(16.0, 24.0);
          final double headerTitleSize = (maxWidth * 0.045).clamp(18.0, 24.0);
          final double headerSubSize = (maxWidth * 0.030).clamp(12.0, 14.0);
          final double tileAspectRatio = maxWidth >= 900
              ? 1.10
              : maxWidth >= 600
              ? 1.05
              : 1.00;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(horizontalPadding),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.lightBlue[50],
                      border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.people_outline, color: brandColor, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isNotEmpty ? 'Welcome, $userName' : 'Welcome',
                                maxLines: 3,
                                softWrap: true,
                                style: TextStyle(
                                  color: brandColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: headerTitleSize,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (userDepartment.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: brandColor.withValues(alpha: 0.14)),
                                      ),
                                      child: Text(
                                        userDepartment,
                                        style: TextStyle(
                                          color: brandColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: (headerSubSize * 0.95).clamp(11.0, 13.0),
                                        ),
                                      ),
                                    ),
                                  if (Fileno.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: brandColor.withValues(alpha: 0.14)),
                                      ),
                                      child: Text(
                                        Fileno,
                                        style: TextStyle(
                                          color: brandColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: (headerSubSize * 0.95).clamp(11.0, 13.0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Quick access to your services',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  fontWeight: FontWeight.w600,
                                  fontSize: headerSubSize,
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
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Services',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w900,
                      fontSize: (maxWidth * 0.032).clamp(15.0, 18.0),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  16,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildDashboardTile(
                      context: context,
                      title: 'My Leave Balance',
                      icon: Icons.calendar_today_outlined,
                      subtitle: 'Coming Soon',
                      badgeText: 'Coming Soon',
                      enabled: false,
                      onTap: () {
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Payment Schedule',
                      icon: Icons.payments_outlined,
                      subtitle: '${daysBetween(date1, date2)} days until next payment',
                      onTap: () {
                        print('Container 2 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return Calendar();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'eFILE',
                      icon: Icons.file_copy_outlined,
                      onTap: () {
                        print('Container 3 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return const eFile();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Attendance',
                      icon: Icons.fingerprint_outlined,
                      onTap: () {
                        print('Container 4 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return AttendanceScreen();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'EVO',
                      icon: Icons.elevator_outlined,
                      onTap: () {
                        print('Container 8 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return EvaluationPage();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'TimeSheet',
                      icon: Icons.access_time,
                      onTap: () {
                        print('Container 6 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return EmployeeTimesheetPage(empCode: Fileno);
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Status',
                      icon: Icons.monitor_outlined,
                      onTap: () {
                        print('Container 13 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return StatusPage();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'HR Tracking',
                      icon: Icons.track_changes_outlined,
                      onTap: () {
                        print('HR Tracking clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return HrDashboardPage();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Post Announcement',
                      icon: Icons.post_add_outlined,
                      onTap: () {
                        print('Container 6 clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return AnnouncementPost();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Announcements',
                      icon: Icons.announcement_outlined,
                      onTap: () {
                        print('Announcement clicked');
                        print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return Announcement();
                        }));
                      },
                    ),
                    _buildDashboardTile(
                      context: context,
                      title: 'Voice Up',
                      icon: Icons.hearing_outlined,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Voice Up"),
                              content: const Text(
                                  "No one will know who you are. Feel free to tell anything to the top management. This conversation is completely secure."),
                              actions: [
                                TextButton(
                                  child: const Text("No, thank you"),
                                  onPressed: () {
                                    print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text("Agree"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VoiceUpPage()),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: horizontalPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            print('Container 15 clicked');
                            print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return MissionVisionPage();
                            }));
                          },
                          icon: const Icon(Icons.info_outline, color: brandColor),
                          label: const Text(
                            'More',
                            style: TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
