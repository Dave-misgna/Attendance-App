import 'package:drift/drift.dart';
import 'package:newhope_attendance/core/database/app_database.dart';

class EmployeeRepository {
  final AppDatabase db;

  EmployeeRepository(this.db);

  Future<List<Employee>> getAllEmployees() =>
      db.select(db.employees).get();
  
  Future<Employee?> getEmployeeById(int id) {
  return (db.select(db.employees)
        ..where((e) => e.id.equals(id)))
      .getSingleOrNull();
  } 

  Future<void> addEmployee(String name) =>
      db.into(db.employees).insert(
        EmployeesCompanion(name: Value(name)),
      );
  
  Future<void> updateEmployee(Employee employee) =>
    db.update(db.employees).replace(employee);
  

  Future deleteEmployee(Employee emp) => db.delete(db.employees).delete(emp);
}
