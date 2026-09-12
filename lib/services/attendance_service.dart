import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

import '../models/student.dart';

class AttendanceService {
  static final Box _students = Hive.box('students');
  static final Box _attendance = Hive.box('attendance');

  static String dateKey([DateTime? date]) =>
      DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  static List<Student> getStudents() {
    return _students.values
        .map((e) => Student.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static Student? findStudent(String id) {
    final value = _students.get(id);
    if (value == null) return null;
    return Student.fromMap(Map<String, dynamic>.from(value));
  }

  static Future<void> saveStudent(Student student) async {
    await _students.put(student.id, student.toMap());
  }

  static Future<void> deleteStudent(String id) async {
    await _students.delete(id);
  }

  static bool isPresent(String studentId, [DateTime? date]) {
    final day = dateKey(date);
    return _attendance.get('$day|$studentId') != null;
  }

  static Future<bool> markPresent(String studentId, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    final day = dateKey(now);
    final key = '$day|$studentId';

    if (_attendance.get(key) != null) return false;

    await _attendance.put(key, {
      'studentId': studentId,
      'date': day,
      'timestamp': now.toIso8601String(),
    });
    return true;
  }

  static List<Map<String, dynamic>> attendanceForDay([DateTime? date]) {
    final day = dateKey(date);
    final rows = <Map<String, dynamic>>[];

    for (final value in _attendance.values) {
      final map = Map<String, dynamic>.from(value);
      if (map['date'] == day) rows.add(map);
    }

    rows.sort(
      (a, b) => '${a['timestamp']}'.compareTo('${b['timestamp']}'),
    );
    return rows;
  }

  static int presentCount([DateTime? date]) => attendanceForDay(date).length;

  static int absentCount([DateTime? date]) {
    final active = getStudents().where((s) => s.active).length;
    return (active - presentCount(date)).clamp(0, active);
  }
}
