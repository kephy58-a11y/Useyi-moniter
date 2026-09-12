import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/student.dart';
import '../services/attendance_service.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> addStudent() async {
    final id = TextEditingController();
    final name = TextEditingController();
    final program = TextEditingController();
    final cohort = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: id,
                decoration: const InputDecoration(labelText: 'Student ID'),
              ),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              TextField(
                controller: program,
                decoration: const InputDecoration(labelText: 'Program'),
              ),
              TextField(
                controller: cohort,
                decoration: const InputDecoration(labelText: 'Cohort'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final studentId = id.text.trim();
              final studentName = name.text.trim();

              if (studentId.isEmpty || studentName.isEmpty) return;

              if (AttendanceService.findStudent(studentId) != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('That Student ID already exists.'),
                    ),
                  );
                }
                return;
              }

              await AttendanceService.saveStudent(
                Student(
                  id: studentId,
                  name: studentName,
                  program: program.text.trim(),
                  cohort: cohort.text.trim(),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    id.dispose();
    name.dispose();
    program.dispose();
    cohort.dispose();
  }

  void showQr(Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: student.id,
              size: 240,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              'Student ID: ${student.id}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = AttendanceService.getStudents();
    final q = search.text.trim().toLowerCase();
    final students = all
        .where(
          (s) =>
              q.isEmpty ||
              s.id.toLowerCase().contains(q) ||
              s.name.toLowerCase().contains(q),
        )
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by ID or name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text('No students registered yet.'),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) {
                      final s = students[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              s.id.isEmpty ? '?' : s.id[0],
                            ),
                          ),
                          title: Text(
                            s.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${s.id} • ${s.program} • ${s.cohort}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Show QR',
                            icon: const Icon(Icons.qr_code_2),
                            onPressed: () => showQr(s),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addStudent,
        icon: const Icon(Icons.person_add),
        label: const Text('ADD STUDENT'),
      ),
    );
  }
}
