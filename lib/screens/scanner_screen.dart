import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/student.dart';
import '../services/attendance_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool locked = false;
  String message = 'Point the camera at a student QR code.';
  Student? lastStudent;

  Future<void> handleCode(String? raw) async {
    if (locked || raw == null || raw.trim().isEmpty) return;

    setState(() => locked = true);

    final id = raw.trim();
    final student = AttendanceService.findStudent(id);

    if (student == null) {
      setState(() {
        message = 'Student ID $id was not found.';
        lastStudent = null;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          locked = false;
          message = 'Point the camera at a student QR code.';
        });
      }
      return;
    }

    final added = await AttendanceService.markPresent(student.id);

    if (!mounted) return;
    setState(() {
      lastStudent = student;
      message = added
          ? '✓ Attendance recorded'
          : '⚠ Already marked present today';
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() {
        locked = false;
        message = 'Ready for the next student.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Student')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      handleCode(barcode.rawValue);
                      break;
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (lastStudent != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${lastStudent!.name} • ${lastStudent!.id}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
