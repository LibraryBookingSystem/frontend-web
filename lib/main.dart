import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/resource_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/policy_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/audit_log_provider.dart';
import 'providers/realtime_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'constants/route_names.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LibraryBookingApp());
}

class LibraryBookingApp extends StatelessWidget {
  const LibraryBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PolicyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AuditLogProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Library Booking System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.themeMode, // Use ThemeProvider instead of system
            initialRoute: RouteNames.login,
            routes: AppRouter.generateRoutes(),
            onGenerateRoute: (settings) {
              // Use custom transitions for routes
              return AppRouter.generateRouteWithTransition(settings);
            },
            builder: (context, child) {
              Widget widget = AnimatedTheme(
                data: Theme.of(context),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                ),
              );

              // Wrap in SafeArea for mobile to avoid system UI intrusions
              if (!kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.android ||
                      defaultTargetPlatform == TargetPlatform.iOS)) {
                widget = SafeArea(child: widget);
              }

              return widget;
            },
          );
        },
      ),
    );
  }
}
