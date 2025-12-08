/// Route name constants for navigation
class RouteNames {
  RouteNames._();
  
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Student routes
  static const String studentHome = '/student/home';
  static const String browseResources = '/student/resources';
  static const String floorPlan = '/student/floor-plan';
  static const String createBooking = '/student/booking/create';
  static const String myBookings = '/student/bookings';
  static const String bookingDetails = '/student/booking/details';
  static const String checkIn = '/student/checkin';
  
  // Staff routes
  static const String staffDashboard = '/staff/dashboard';
  static const String occupancyOverview = '/staff/occupancy';
  static const String manualCheckIn = '/staff/checkin';
  
  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String resourceManagement = '/admin/resources';
  static const String policyConfig = '/admin/policies';
  static const String userManagement = '/admin/users';
  static const String analytics = '/admin/analytics';
  static const String auditLogs = '/admin/audit-logs';
}

