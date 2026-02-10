import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newhope_attendance/core/database/app_database.dart';
import 'package:newhope_attendance/feature/attendance/attendance_repository.dart';
import 'package:newhope_attendance/feature/employee/employee_repository.dart';
import 'package:newhope_attendance/feature/presentation/widgets/employee_profile.dart';
import 'package:newhope_attendance/feature/presentation/widgets/employee_state.dart';

class EmployeeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late final AppDatabase _db;
  late final EmployeeRepository _employeeRepository;
  late final AttendanceRepository _attendanceRepository;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _employeeRepository = EmployeeRepository(_db);
    _attendanceRepository = AttendanceRepository(_db);
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<void> _deleteEmployeeDialog(Employee employee) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Employee'),
          content: Text(
            'Are you sure you want to delete "${employee.name}"?\n'
            'All attendance records will also be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _employeeRepository.deleteEmployee(employee);

      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _updateEmployeeDialog(Employee employee) async {
    final controller = TextEditingController(text: employee.name);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Employee'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _employeeRepository.updateEmployee(
        employee.copyWith(name: controller.text.trim()),
      );

      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/employees');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.go('/employees'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: FutureBuilder(
          future: Future.wait([
            _employeeRepository.getEmployeeById(widget.employeeId),
            _attendanceRepository.getEmployeeAttendanceDays(widget.employeeId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load employee',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            final results = snapshot.data!;
            final employee = results[0] as Employee?;
            final attendanceDays = results[1] as List<DateTime>;

            if (employee == null) {
              return const Center(child: Text('Employee not found.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  EmployeeProfile(
                    name: employee.name,
                    onDelete: () => _deleteEmployeeDialog(employee),
                    onUpdate: () => _updateEmployeeDialog(employee),
                  ),
                  EmployeeState(
                    numberOfDays: attendanceDays.length,
                    dates: attendanceDays,
                    onDelete: () async {
                      // Show confirmation dialog
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Attendance'),
                          content: Text(
                            'Are you sure you want to clear all attendance for "${employee.name}"?\n'
                            'This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      );

                      // If user confirmed, clear attendance
                      if (shouldDelete == true) {
                        await _attendanceRepository.clearEmployeeAttendance(
                          employee.id,
                        );
                        if (!mounted) return;
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
