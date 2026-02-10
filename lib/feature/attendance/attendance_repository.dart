import 'package:drift/drift.dart';
import 'package:newhope_attendance/core/database/app_database.dart';

class AttendanceRepository {
  final AppDatabase db;

  AttendanceRepository(this.db);

  
  Future<void> markAttendance(int employeeId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if an attendance record already exists for this employee + day.
    final existing = await (db.select(db.attendances)
          ..where(
            (a) =>
                a.employeeId.equals(employeeId) &
                a.date.equals(normalizedDate),
          ))
        .getSingleOrNull();

    if (existing != null) {
      // Already marked for this Ethiopian day – do nothing.
      return;
    }

    await db.into(db.attendances).insert(
      AttendancesCompanion(
        employeeId: Value(employeeId),
        date: Value(normalizedDate),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<int> countEmployeeDays(int employeeId) =>
      (db.select(db.attendances)
        ..where((a) => a.employeeId.equals(employeeId)))
      .get()
      .then((rows) => rows.length);

  Future<List<DateTime>> getEmployeeAttendanceDays(int employeeId) =>
      (db.select(db.attendances)
        ..where((a) => a.employeeId.equals(employeeId))
        ..orderBy([(a) => OrderingTerm.desc(a.date)]))
      .get()
      .then((attendances) => attendances.map((a) => a.date).toList());

  Future<void> clearEmployeeAttendance(int employeeId) async {
    await (db.delete(db.attendances)
          ..where((a) => a.employeeId.equals(employeeId)))
        .go();
  }
  Future<void> clearAllAttendance() async {
    await db.delete(db.attendances).go();
  }

  Future<void> deleteAttendanceForDay(int employeeId, DateTime date) async {
    await (db.delete(db.attendances)
          ..where((a) => a.employeeId.equals(employeeId))
          ..where((a) => a.date.equals(date)))
        .go();
  }
  
}
