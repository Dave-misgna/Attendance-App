import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../attendance/attendance_repository.dart';
import '../../employee/employee_repository.dart';
import '../widgets/bottom_navigation.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  late final AppDatabase _db;
  late final AttendanceRepository _attendanceRepository;
  late final EmployeeRepository _employeeRepo;
  @override
  void initState() {
    super.initState();
    _db = AppDatabase(); // ✅ Initialize your database
    _employeeRepo = EmployeeRepository(_db);
    _attendanceRepository = AttendanceRepository(_db);
  }

  @override
  void dispose() {
    _db.close(); // ✅ Always close DB when page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child:Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Attendance>>(
  future: _db.select(_db.attendances).get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No attendance records'));
    }

    final data = snapshot.data!;

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final a = data[index];
        
        return ListTile(
                title: FutureBuilder<Employee?>(
                  future: _employeeRepo.getEmployeeById(a.employeeId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Text('Employee name: ...');
                    }
                    final emp = snap.data;
                    return Text('Employee name: ${emp?.name ?? 'Unknown'}');
                  },
                ),
                subtitle: Text(
                  a.date.toLocal().toString().split(' ')[0],
                ),

                // ✅ DELETE ICON
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Attendance'),
                        content: const Text(
                          'Are you sure you want to delete this attendance record?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _attendanceRepository.deleteAttendanceForDay(
                        a.employeeId,
                        a.date,
                      );

                      if (!mounted) return;
                      setState(() {}); // 🔄 refresh list
                    }
                  },
                ),
              );
            },
          );
        },
        ),

          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: ()async{
              final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Attendance'),
                        content: const Text(
                          'Are you sure you want to delete attendance record?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
            if (confirm == true) {
              await _attendanceRepository.clearAllAttendance();
              if (!mounted) return;
              setState(() {}); // Refresh UI after clearing data
            }
            
          }, 
          child: Text('Clear Attendance Data'))
        ],
      ),
      

      bottomNavigationBar: MyBottomNavigation(selectedIndex: 2),
    )
    );
    
  }
}
