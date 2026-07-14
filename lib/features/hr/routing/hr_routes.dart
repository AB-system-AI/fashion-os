import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/pages/hr_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/pages/hr_feature_page.dart';
import 'package:fashion_pos_enterprise/features/hr/routing/hr_route_paths.dart';

List<RouteBase> buildHrRoutes() {
  return [
    GoRoute(
      path: HrRoutePaths.dashboard,
      name: HrRouteNames.dashboard,
      builder: (_, __) => const HrDashboardPage(),
      routes: [
        GoRoute(
          path: 'employees',
          name: HrRouteNames.employees,
          builder: (_, __) => const HrFeaturePage(
            title: 'Employees',
            description: 'Manage employee records and profiles.',
            permission: EmployeePermissions.manage,
            showEmployees: true,
          ),
        ),
        GoRoute(
          path: 'departments',
          name: HrRouteNames.departments,
          builder: (_, __) => const HrFeaturePage(
            title: 'Departments',
            description: 'Organizational departments.',
            permission: HrPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'positions',
          name: HrRouteNames.positions,
          builder: (_, __) => const HrFeaturePage(
            title: 'Positions',
            description: 'Job positions and default salaries.',
            permission: HrPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'attendance',
          name: HrRouteNames.attendance,
          builder: (_, __) => const HrFeaturePage(
            title: 'Attendance',
            description: 'Clock in and track attendance.',
            permission: AttendancePermissions.manage,
            showAttendance: true,
          ),
        ),
        GoRoute(
          path: 'attendance/history',
          name: HrRouteNames.attendanceHistory,
          builder: (_, __) => const HrFeaturePage(
            title: 'Attendance History',
            description: 'Historical attendance records.',
            permission: AttendancePermissions.manage,
            showAttendance: true,
          ),
        ),
        GoRoute(
          path: 'shifts',
          name: HrRouteNames.shifts,
          builder: (_, __) => const HrFeaturePage(
            title: 'Shifts',
            description: 'Schedule and validate employee shifts.',
            permission: AttendancePermissions.manage,
          ),
        ),
        GoRoute(
          path: 'leave',
          name: HrRouteNames.leaveRequests,
          builder: (_, __) => const HrFeaturePage(
            title: 'Leave Requests',
            description: 'Request and approve employee leave.',
            permission: LeavePermissions.manage,
            showLeave: true,
          ),
        ),
        GoRoute(
          path: 'payroll',
          name: HrRouteNames.payroll,
          builder: (_, __) => const HrFeaturePage(
            title: 'Payroll',
            description: 'Calculate and approve payroll runs.',
            permission: PayrollPermissions.view,
            showPayroll: true,
          ),
        ),
        GoRoute(
          path: 'payroll/details',
          name: HrRouteNames.payrollDetails,
          builder: (_, __) => const HrFeaturePage(
            title: 'Payroll Details',
            description: 'Line items per employee.',
            permission: PayrollPermissions.view,
            showPayroll: true,
          ),
        ),
        GoRoute(
          path: 'salary-structures',
          name: HrRouteNames.salaryStructures,
          builder: (_, __) => const HrFeaturePage(
            title: 'Salary Structures',
            description: 'Base salary and pay frequency.',
            permission: PayrollPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'bonuses',
          name: HrRouteNames.bonuses,
          builder: (_, __) => const HrFeaturePage(
            title: 'Bonuses',
            description: 'Employee bonus records.',
            permission: PayrollPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'deductions',
          name: HrRouteNames.deductions,
          builder: (_, __) => const HrFeaturePage(
            title: 'Deductions',
            description: 'Payroll deductions.',
            permission: PayrollPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'commissions',
          name: HrRouteNames.commissions,
          builder: (_, __) => const HrFeaturePage(
            title: 'Commissions',
            description: 'Sales commissions from POS.',
            permission: CommissionPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'performance',
          name: HrRouteNames.performanceReviews,
          builder: (_, __) => const HrFeaturePage(
            title: 'Performance Reviews',
            description: 'Employee performance metrics.',
            permission: PerformancePermissions.manage,
          ),
        ),
        GoRoute(
          path: 'documents',
          name: HrRouteNames.documents,
          builder: (_, __) => const HrFeaturePage(
            title: 'Employee Documents',
            description: 'Contracts, IDs, and certificates.',
            permission: EmployeePermissions.manage,
          ),
        ),
        GoRoute(
          path: 'reports',
          name: HrRouteNames.reports,
          builder: (_, __) => const HrFeaturePage(
            title: 'HR Reports',
            description: 'Export attendance, payroll, and performance reports.',
            permission: HrPermissions.view,
          ),
        ),
      ],
    ),
  ];
}
