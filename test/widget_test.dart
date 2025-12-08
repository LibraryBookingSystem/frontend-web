// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:library_booking_app/main.dart';
import 'package:library_booking_app/providers/auth_provider.dart';
import 'package:library_booking_app/providers/user_provider.dart';
import 'package:library_booking_app/providers/resource_provider.dart';
import 'package:library_booking_app/providers/booking_provider.dart';
import 'package:library_booking_app/providers/policy_provider.dart';
import 'package:library_booking_app/providers/notification_provider.dart';
import 'package:library_booking_app/providers/analytics_provider.dart';
import 'package:library_booking_app/providers/realtime_provider.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ResourceProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => PolicyProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
          ChangeNotifierProvider(create: (_) => RealtimeProvider()),
        ],
        child: const LibraryBookingApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(LibraryBookingApp), findsOneWidget);
  });
}
