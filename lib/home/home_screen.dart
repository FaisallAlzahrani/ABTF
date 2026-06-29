import 'package:application_v1/Announcement/Announcement.dart';
import 'package:application_v1/Attendance/attandancescreen.dart';
import 'package:application_v1/Evolation/Evolation.dart';
import 'package:application_v1/Orders/status.dart';
import 'package:application_v1/Timesheet/EmployeeTimesheetPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Calender/Calanderone.dart';
import '../MissionVisionPage/MissionVisionTest.dart';
import '../Orders/VoiceUpPage.dart';
import '../eFiles/EFILES.dart';
import '../login/user_provider.dart';
import '../inspection_management/screens/inspection_management_screen.dart';
import '../planning_management/screens/planning_dashboard_screen.dart';
import '../planning_management/screens/planning_main_screen.dart';
import '../admin/admin_menu_item.dart';


class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  double screenHeight = 0 ;
  double screenWidth = 0 ;

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
        final double footerSize = (w * 0.070).clamp(11.5, 13.5);

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
                          SizedBox(height: (w * 0.04).clamp(4.0, 8.0)),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w600,
                              fontSize: subtitleSize,
                            ),
                          ),
                        ],
                        const Spacer(),
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

  Widget _buildLegacyTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    String? badgeText,
    bool enabled = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final double iconSize = (w * 0.32).clamp(34.0, 58.0);
        final double titleSize = (w * 0.12).clamp(13.0, 18.0);
        final double subtitleSize = (w * 0.09).clamp(11.0, 14.0);
        final double radius = (w * 0.22).clamp(26.0, 44.0);
        final Color fg = Colors.blue[900]!;
        final Color bg = enabled ? (Colors.lightBlue[50] ?? const Color(0xFFE3F2FD)) : Colors.grey[300]!;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              height: h,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all((w * 0.10).clamp(12.0, 18.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.lightBlue[900], size: iconSize),
                        SizedBox(height: (h * 0.06).clamp(8.0, 14.0)),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          SizedBox(height: (h * 0.03).clamp(4.0, 10.0)),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w600,
                              fontSize: subtitleSize,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badgeText != null && badgeText.isNotEmpty)
                    Positioned(
                      top: (h * 0.08).clamp(10.0, 14.0),
                      right: (w * 0.08).clamp(10.0, 14.0),
                      child: Transform.rotate(
                        angle: -0.35,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: (w * 0.18).clamp(22.0, 40.0),
                            vertical: (h * 0.02).clamp(4.0, 7.0),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: (w * 0.08).clamp(10.0, 12.5),
                            ),
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
    final date1 = DateTime.now();
    final date2 = DateTime(date1.year , date1.month+1 , 0);


    const brandColor = Color(0xFF104164);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: brandColor),
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
                      await prefs.clear(); // or prefs.remove('isLoggedIn');

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
          final double maxWidth = constraints.maxWidth;
          final int crossAxisCount = maxWidth >= 900
              ? 4
              : maxWidth >= 600
                  ? 3
                  : 2;
          final double padding = (maxWidth * 0.05).clamp(16.0, 24.0);
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
                padding: EdgeInsets.all(padding),
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
                          child: const Icon(Icons.person_outline, color: brandColor, size: 30),
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
                              if (userDepartment.isNotEmpty || Fileno.isNotEmpty) ...[
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
                              ],
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
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  bottom: 8,
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
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  bottom: padding,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: tileAspectRatio,
                  ),
                  delegate: SliverChildListDelegate(
                    [
                      _buildDashboardTile(
                        context: context,
                        title: 'My Leave Balance',
                        subtitle: 'Annual: 10.87',
                        icon: Icons.source_outlined,
                        badgeText: 'Coming Soon',
                        enabled: false,
                        onTap: () {
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: '${daysBetween(date1, date2)} Days',
                        subtitle: 'Until next payment',
                        icon: Icons.calendar_month_outlined,
                        onTap: () {
                          print('Container 2 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return Calendar();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'eFILE',
                        icon: Icons.file_copy_outlined,
                        onTap: () {
                          print('Container 3 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const eFile();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'Attendance',
                        icon: Icons.fingerprint_outlined,
                        onTap: () {
                          print('Container 4 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return AttendanceScreen();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'EVO',
                        icon: Icons.elevator_outlined,
                        onTap: () {
                          print('Container 8 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return EvaluationPage();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'TimeSheet',
                        icon: Icons.access_time,
                        onTap: () {
                          print('Container 6 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return EmployeeTimesheetPage(empCode: Fileno,);
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'Status',
                        icon: Icons.monitor_weight_outlined,
                        onTap: () {
                          print('Container 13 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهرani © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return StatusPage();
                          }),);
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
                      _buildDashboardTile(
                        context: context,
                        title: 'Announcement',
                        icon: Icons.announcement_outlined,
                        onTap: () {
                          print('Announcement 6 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return Announcement();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'Inspection',
                        icon: Icons.assignment_outlined,
                        onTap: () {
                          print(' Inspection clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهرani © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const InspectionManagementScreen();
                          }),);
                        },
                      ),
                      _buildDashboardTile(
                        context: context,
                        title: 'Planning',
                        icon: Icons.engineering,
                        onTap: () {
                          print('Planning 6 clicked');
                          print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهرani © 2025');
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return PlanningDashboardScreen();
                          }),);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: padding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AdminMenuItem(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            print('Container 15 clicked');
                            print ('CopyRight© جميع الحقوق محفوظة لفيصل الزهرani © 2025');
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return MissionVisionPage();
                            }),);
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
  int daysBetween(DateTime from , DateTime to){
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month , to.day);
    return (to.difference(from).inHours/ 24).round();
  }
}