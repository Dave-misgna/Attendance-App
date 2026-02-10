import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newhope_attendance/core/database/app_database.dart';
import 'package:newhope_attendance/feature/attendance/attendance_repository.dart';
import 'package:newhope_attendance/feature/employee/employee_repository.dart';
import 'package:newhope_attendance/feature/presentation/widgets/bottom_navigation.dart';
import 'package:newhope_attendance/feature/presentation/widgets/attendance_card.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final AppDatabase _db;
  late final EmployeeRepository _employeeRepository;
  late final AttendanceRepository _attendanceRepository;
  late Future<List<Employee>> _employeesFuture;

  final Set<int> _selectedEmployeeIds = {};
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _employeeRepository = EmployeeRepository(_db);
    _attendanceRepository = AttendanceRepository(_db);
    _employeesFuture = _employeeRepository.getAllEmployees();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ETDateTime now = ETDateTime.now();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
          return;
        }
        _lastBackPressed = now;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Hope Attendance'),
          centerTitle: true,
        ),
        body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Text(
                ETDateFormat("dd-MMMM-yyyy").format(now),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Employee>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load employees',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                final employees = snapshot.data ?? [];

                if (employees.isEmpty) {
                  return const Center(
                    child: Text('No employees found.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return AttendanceCard(
                      name: emp.name,
                      selected: _selectedEmployeeIds.contains(emp.id),
                      onSelectedChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedEmployeeIds.add(emp.id);
                          } else {
                            _selectedEmployeeIds.remove(emp.id);
                          }
                        });
                      },
                      onTap: () {
                        setState(() {
                          if (_selectedEmployeeIds.contains(emp.id)) {
                            _selectedEmployeeIds.remove(emp.id);
                          } else {
                            _selectedEmployeeIds.add(emp.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                onPressed: _selectedEmployeeIds.isEmpty
                    ? null
                    : () async {
                        ETDateTime now = ETDateTime.now();
                        for (final id in _selectedEmployeeIds) {
                          await _attendanceRepository.markAttendance(id, now);
                        }

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance submitted successfully'),
                          ),
                        );

                        setState(() {
                          _selectedEmployeeIds.clear();
                        });
                      },
                child: const Text('Submit Attendance'),
              ),
            ),
          ),
        ],
        ),
        bottomNavigationBar: MyBottomNavigation(selectedIndex: 0),
      ),
    );
  }
}