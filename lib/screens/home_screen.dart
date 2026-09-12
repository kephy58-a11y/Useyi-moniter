import 'package:flutter/material.dart';

import '../services/attendance_service.dart';
import 'attendance_screen.dart';
import 'scanner_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(onRefresh: () => setState(() {})),
      const StudentsScreen(),
      const AttendanceScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 21,
              child: Icon(Icons.qr_code_2),
            ),
            SizedBox(width: 10),
            Text(
              'USEYI Monitor',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: pages[index],
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScannerScreen(),
                  ),
                );
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('SCAN STUDENT'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const DashboardTab({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final students = AttendanceService.getStudents();
    final present = AttendanceService.presentCount();
    final total = students.where((s) => s.active).length;
    final absent = AttendanceService.absentCount();
    final rate = total == 0 ? 0 : (present / total * 100).round();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'UPSHIFT Youth Empowerment Initiative',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Today’s Attendance',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: StatCard('Registered', '$total', Icons.people)),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard('Present', '$present', Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: StatCard('Absent', '$absent', Icons.person_off)),
              const SizedBox(width: 10),
              Expanded(child: StatCard('Rate', '$rate%', Icons.insights)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.qr_code_scanner),
              ),
              title: const Text('Ready to take attendance'),
              subtitle: const Text(
                'Scan a student QR code to mark them present.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScannerScreen(),
                  ),
                );
                onRefresh();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard(this.label, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
