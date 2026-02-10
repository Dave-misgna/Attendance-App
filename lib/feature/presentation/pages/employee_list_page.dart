import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newhope_attendance/core/database/app_database.dart';
import 'package:newhope_attendance/feature/employee/employee_repository.dart';
import 'package:newhope_attendance/feature/presentation/widgets/bottom_navigation.dart';
import 'package:newhope_attendance/feature/presentation/widgets/employee_card.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  late final AppDatabase _db;
  late final EmployeeRepository _employeeRepository;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _employeeRepository = EmployeeRepository(_db);
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<void> _addEmployeeDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Employee'),
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _employeeRepository.addEmployee(controller.text.trim());
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
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employees'),
        ),
        body: FutureBuilder<List<Employee>>(
        future: _employeeRepository.getAllEmployees(),
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
              child: Text('No employees yet. Tap + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final emp = employees[index];
              return EmployeeCard(
                name: emp.name,
                onTap: () {
                  context.goNamed(
                    'employeeDetail',
                    pathParameters: {
                      'id': emp.id.toString(),
                    },
                  );
                },
              );
            },
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addEmployeeDialog,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: MyBottomNavigation(selectedIndex: 1),
      ),
    );
  }
}