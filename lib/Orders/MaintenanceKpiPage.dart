import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MaintenanceKpiPage extends StatefulWidget {
  const MaintenanceKpiPage({super.key});

  @override
  State<MaintenanceKpiPage> createState() => _MaintenanceKpiPageState();
}

class _MaintenanceKpiPageState extends State<MaintenanceKpiPage> {
  static const Color brandColor = Color(0xFF1565C0);

  final DateFormat _dtFormat = DateFormat('yyyy-MM-dd HH:mm');

  DateTimeRange? _range;
  String _department = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  DateTime? _tryParse(String? value) {
    if (value == null) return null;
    final v = value.trim();
    if (v.isEmpty) return null;
    try {
      return _dtFormat.parse(v);
    } catch (_) {
      return null;
    }
  }

  bool _inRange(DateTime? dt) {
    final r = _range;
    if (r == null || dt == null) return false;
    return !dt.isBefore(r.start) && !dt.isAfter(r.end);
  }

  Future<void> _pickRange() async {
    final initial = _range;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: initial,
    );
    if (picked == null) return;
    setState(() {
      _range = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
    });
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.72),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: brandColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }

  Widget _statCard({required String title, required String value, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: color),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final rangeText = range == null
        ? 'Select date range'
        : '${DateFormat('yyyy-MM-dd').format(range.start)} → ${DateFormat('yyyy-MM-dd').format(range.end)}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Maintenance KPIs',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final contentWidth = maxWidth.clamp(0, 1000);
          final horizontalPadding = (maxWidth * 0.05).clamp(16.0, 24.0);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth.toDouble()),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Report').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final filtered = <QueryDocumentSnapshot>[];
                  for (final d in docs) {
                    final data = d.data() as Map<String, dynamic>?;
                    final dept = data?['Selected Dept']?.toString() ?? '';
                    final reportedAt = _tryParse(data?['Reported_time']?.toString());

                    if (_department != 'All' && dept != _department) continue;
                    if (!_inRange(reportedAt)) continue;

                    filtered.add(d);
                  }

                  int pendingSupervisors = 0;
                  int pendingManager = 0;
                  int completed = 0;
                  int rejected = 0;

                  int durationCount = 0;
                  Duration durationSum = Duration.zero;

                  final Map<String, int> machineCounts = <String, int>{};
                  final Map<DateTime, int> createdByDay = <DateTime, int>{};
                  final Map<DateTime, int> completedByDay = <DateTime, int>{};

                  for (final d in filtered) {
                    final data = d.data() as Map<String, dynamic>?;
                    final stage = data?['approval_stage']?.toString() ?? '';

                    final reportedAt = _tryParse(data?['Reported_time']?.toString());
                    if (reportedAt != null) {
                      final day = DateTime(reportedAt.year, reportedAt.month, reportedAt.day);
                      createdByDay[day] = (createdByDay[day] ?? 0) + 1;
                      if (stage == 'completed') {
                        completedByDay[day] = (completedByDay[day] ?? 0) + 1;
                      }
                    }

                    if (stage == 'pending_supervisors') {
                      pendingSupervisors++;
                    } else if (stage == 'pending_manager') {
                      pendingManager++;
                    } else if (stage == 'completed') {
                      completed++;
                    } else if (stage == 'rejected') {
                      rejected++;
                    }

                    final machine = data?['Machine Name']?.toString() ?? '';
                    if (machine.trim().isNotEmpty) {
                      machineCounts[machine] = (machineCounts[machine] ?? 0) + 1;
                    }

                    final start = _tryParse(data?['Start Time']?.toString());
                    final end = _tryParse(data?['End Time']?.toString());
                    if (start != null && end != null && !end.isBefore(start)) {
                      durationSum += end.difference(start);
                      durationCount++;
                    }
                  }

                  final total = filtered.length;
                  final avgDuration = durationCount == 0 ? null : Duration(milliseconds: (durationSum.inMilliseconds / durationCount).round());

                  String fmtDuration(Duration? d) {
                    if (d == null) return '-';
                    final hours = d.inHours;
                    final minutes = d.inMinutes.remainder(60);
                    if (hours <= 0) return '${minutes}m';
                    return '${hours}h ${minutes}m';
                  }

                  final topMachines = machineCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  List<DateTime> daysInRange() {
                    final r = _range;
                    if (r == null) return <DateTime>[];
                    final start = DateTime(r.start.year, r.start.month, r.start.day);
                    final end = DateTime(r.end.year, r.end.month, r.end.day);
                    final out = <DateTime>[];
                    var cur = start;
                    while (!cur.isAfter(end)) {
                      out.add(cur);
                      cur = cur.add(const Duration(days: 1));
                    }
                    return out;
                  }

                  final days = daysInRange();
                  final int maxY = days.isEmpty
                      ? 0
                      : days
                          .map((d) => (createdByDay[d] ?? 0))
                          .fold<int>(0, (p, e) => e > p ? e : p);

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: brandColor.withValues(alpha: 0.12)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Filters'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickRange,
                                      icon: const Icon(Icons.date_range_outlined, size: 18),
                                      label: Text(rangeText, overflow: TextOverflow.ellipsis),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 200,
                                    child: DropdownButtonFormField<String>(
                                      value: _department,
                                      decoration: InputDecoration(
                                        labelText: 'Department',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'All', child: Text('All')),
                                        DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                                        DropdownMenuItem(value: 'Mechanical', child: Text('Mechanical')),
                                        DropdownMenuItem(value: 'AC', child: Text('AC')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          _department = v;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('KPIs'),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: maxWidth < 680 ? 2 : 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _statCard(title: 'Total Reports', value: total.toString(), color: brandColor, icon: Icons.assignment_outlined),
                            _statCard(title: 'Pending Supervisor', value: pendingSupervisors.toString(), color: Colors.orange, icon: Icons.pending_outlined),
                            _statCard(title: 'Pending Manager', value: pendingManager.toString(), color: Colors.deepPurple, icon: Icons.verified_outlined),
                            _statCard(title: 'Completed', value: completed.toString(), color: Colors.green, icon: Icons.check_circle_outline),
                            _statCard(title: 'Rejected', value: rejected.toString(), color: Colors.red, icon: Icons.cancel_outlined),
                            _statCard(title: 'Avg Service Time', value: fmtDuration(avgDuration), color: Colors.teal, icon: Icons.timer_outlined),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _sectionTitle('Charts'),
                        const SizedBox(height: 8),
                        _chartCard(
                          title: 'Reports per Day',
                          child: days.isEmpty
                              ? Center(
                                  child: Text(
                                    'No data for selected range.',
                                    style: TextStyle(color: Colors.black.withValues(alpha: 0.65), fontWeight: FontWeight.w700),
                                  ),
                                )
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (maxY + 2).toDouble(),
                                    gridData: FlGridData(show: true, drawVerticalLine: false),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          interval: 2,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(color: Colors.black.withValues(alpha: 0.60), fontWeight: FontWeight.w700, fontSize: 11),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            final idx = value.toInt();
                                            if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                                            final d = days[idx];
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                DateFormat('MM/dd').format(d),
                                                style: TextStyle(color: Colors.black.withValues(alpha: 0.60), fontWeight: FontWeight.w700, fontSize: 10),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(days.length, (i) {
                                      final d = days[i];
                                      final created = (createdByDay[d] ?? 0).toDouble();
                                      final completedCount = (completedByDay[d] ?? 0).toDouble();

                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: created,
                                            width: 10,
                                            color: brandColor.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          BarChartRodData(
                                            toY: completedCount,
                                            width: 10,
                                            color: Colors.green.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        _chartCard(
                          title: 'Approval Stage Distribution',
                          child: total == 0
                              ? Center(
                                  child: Text(
                                    'No data for selected filters.',
                                    style: TextStyle(color: Colors.black.withValues(alpha: 0.65), fontWeight: FontWeight.w700),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 34,
                                          sections: [
                                            PieChartSectionData(
                                              value: pendingSupervisors.toDouble(),
                                              color: Colors.orange,
                                              title: pendingSupervisors == 0 ? '' : pendingSupervisors.toString(),
                                              radius: 48,
                                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              value: pendingManager.toDouble(),
                                              color: Colors.deepPurple,
                                              title: pendingManager == 0 ? '' : pendingManager.toString(),
                                              radius: 48,
                                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              value: completed.toDouble(),
                                              color: Colors.green,
                                              title: completed == 0 ? '' : completed.toString(),
                                              radius: 48,
                                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              value: rejected.toDouble(),
                                              color: Colors.red,
                                              title: rejected == 0 ? '' : rejected.toString(),
                                              radius: 48,
                                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 170,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _legendRow(color: Colors.orange, text: 'Pending Supervisor'),
                                          const SizedBox(height: 8),
                                          _legendRow(color: Colors.deepPurple, text: 'Pending Manager'),
                                          const SizedBox(height: 8),
                                          _legendRow(color: Colors.green, text: 'Completed'),
                                          const SizedBox(height: 8),
                                          _legendRow(color: Colors.red, text: 'Rejected'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 18),
                        _sectionTitle('Top Machines'),
                        const SizedBox(height: 8),
                        if (topMachines.isEmpty)
                          Text(
                            'No data for selected filters.',
                            style: TextStyle(color: Colors.black.withValues(alpha: 0.65), fontWeight: FontWeight.w700),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                            child: Column(
                              children: topMachines.take(8).map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          e.key,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: brandColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: brandColor.withValues(alpha: 0.15)),
                                        ),
                                        child: Text(
                                          e.value.toString(),
                                          style: const TextStyle(color: brandColor, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legendRow({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.70), fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
