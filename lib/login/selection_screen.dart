
import 'package:application_v1/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'local_login.dart';

class SelectionScreen extends StatelessWidget {

  const SelectionScreen({super.key});

  @override


  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 700;
    const brand = Color(0xFF104164);

    Widget buildOptionCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: brand, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: brand,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 760 : 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assest/images/Icon.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome',
                                  style: TextStyle(
                                    color: brand,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Choose how you want to sign in',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: buildOptionCard(
                                icon: Icons.engineering,
                                title: 'Employee',
                                subtitle: 'Company users (requires your employee account)',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildOptionCard(
                                icon: Icons.lock_outline,
                                title: 'Local',
                                subtitle: 'Public / review login (works on any internet)',
                                onTap: () {
                                  print('Container 6 clicked');
                                  print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const LocalLoginPage()),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            buildOptionCard(
                              icon: Icons.engineering,
                              title: 'Employee',
                              subtitle: 'Company users (requires your employee account)',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            buildOptionCard(
                              icon: Icons.lock_outline,
                              title: 'Local',
                              subtitle: 'Public / review login (works on any internet)',
                              onTap: () {
                                print('Container 6 clicked');
                                print('CopyRight© جميع الحقوق محفوظة لفيصل الزهراني © 2025');
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LocalLoginPage()),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
