import 'package:go_router/go_router.dart';
import 'package:newhope_attendance/feature/presentation/pages/admin.dart';
import 'package:newhope_attendance/feature/presentation/pages/attendance_page.dart';
import 'package:newhope_attendance/feature/presentation/pages/employee_list_page.dart';

import '../../feature/presentation/pages/employee_detail_page.dart';

class AppRoutes{

  final GoRouter route = GoRouter(
    initialLocation: '/',
    
    routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(
      path: '/employees',
      builder: (context, state) => const EmployeeListPage(),
      routes: [
        GoRoute(
          path: '/:id',
          name: 'employeeDetail',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return EmployeeDetailPage(employeeId: id);
          },
        ),
      ],
    ),
    GoRoute(path:'/admin', builder: (context, state) => const Admin()),


  ]);
}