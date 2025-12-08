import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/student/home_screen.dart';
import '../screens/student/browse_resources_screen.dart';
import '../screens/student/floor_plan_screen.dart';
import '../screens/student/create_booking_screen.dart';
import '../screens/student/my_bookings_screen.dart';
import '../screens/student/booking_details_screen.dart';
import '../screens/student/checkin_screen.dart';
import '../screens/staff/staff_dashboard.dart';
import '../screens/staff/occupancy_overview.dart';
import '../screens/staff/manual_checkin_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/resource_management_screen.dart';
import '../screens/admin/policy_config_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/audit_logs_screen.dart';
import '../constants/route_names.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

/// Application router with route configuration and guards
class AppRouter {
  /// Generate routes for the application
  static Map<String, WidgetBuilder> generateRoutes() {
    return {
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.register: (context) => const RegisterScreen(),
      RouteNames.studentHome: (context) => const HomeScreen(),
      RouteNames.browseResources: (context) => const BrowseResourcesScreen(),
      RouteNames.floorPlan: (context) => const FloorPlanScreen(),
      RouteNames.createBooking: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return CreateBookingScreen(
          resourceId: args is int ? args : null,
        );
      },
      RouteNames.myBookings: (context) => const MyBookingsScreen(),
      RouteNames.bookingDetails: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return BookingDetailsScreen(
          bookingId: args is int ? args : 0,
        );
      },
      RouteNames.checkIn: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return CheckInScreen(
          bookingId: args is int ? args : 0,
        );
      },
      RouteNames.staffDashboard: (context) => const StaffDashboard(),
      RouteNames.occupancyOverview: (context) => const OccupancyOverviewScreen(),
      RouteNames.manualCheckIn: (context) => const ManualCheckInScreen(),
      RouteNames.adminDashboard: (context) => const AdminDashboard(),
      RouteNames.resourceManagement: (context) => const ResourceManagementScreen(),
      RouteNames.policyConfig: (context) => const PolicyConfigScreen(),
      RouteNames.userManagement: (context) => const UserManagementScreen(),
      RouteNames.analytics: (context) => const AnalyticsScreen(),
      RouteNames.auditLogs: (context) => const AuditLogsScreen(),
    };
  }
  
  /// Route guard wrapper for authenticated routes
  static Widget buildAuthenticatedRoute({
    required BuildContext context,
    required Widget child,
    List<Role>? allowedRoles,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, RouteNames.login);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (allowedRoles != null) {
          final user = authProvider.currentUser;
          if (user == null || !allowedRoles.contains(user.role)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, RouteNames.login);
            });
            return const Scaffold(
              body: Center(child: Text('Access Denied')),
            );
          }
        }
        
        return child;
      },
    );
  }
  
  /// Navigate to appropriate dashboard based on user role
  static void navigateToDashboard(BuildContext context, Role role) {
    switch (role) {
      case Role.student:
        Navigator.pushReplacementNamed(context, RouteNames.studentHome);
        break;
      case Role.faculty:
        Navigator.pushReplacementNamed(context, RouteNames.staffDashboard);
        break;
      case Role.admin:
        Navigator.pushReplacementNamed(context, RouteNames.adminDashboard);
        break;
    }
  }
}

