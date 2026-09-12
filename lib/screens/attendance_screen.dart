import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final rows = AttendanceService.attendanceForDay(selected);
    final students = AttendanceService.getStudents();
    final presentIds = rows.map((r) => '${r['studentId']}').toSet();
    final activeStudents = students.where((s) => s.active).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Text(
              DateFormat('EEEE, d MMMM yyyy').format(selected),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selected,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selected = picked);
              }
            },
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${rows.length} present • '
                  '${activeStudents.length - rows.length} absent',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...activeStudents.map((s) {
                final present = presentIds.contains(s.id);
                return ListTile(
                  leading: Icon(
                    present
                        ? Icons.check_circle
                        : Icons.cancel_outlined,
                    color: present ? Colors.green : Colors.grey,
                  ),
                  title: Text(s.name),
                  subtitle: Text(s.id),
                  trailing: Text(
                    present ? 'PRESENT' : 'ABSENT',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
