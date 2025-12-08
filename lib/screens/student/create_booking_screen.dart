import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/policy_provider.dart';
import '../../providers/resource_provider.dart';
import '../../widgets/bookings/booking_form.dart';
import '../../widgets/bookings/qr_code_display.dart';
import '../../models/booking.dart';
import '../../models/resource.dart';
import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/mixins/error_handling_mixin.dart';
import '../../core/storage/secure_storage.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';

/// Create booking screen
class CreateBookingScreen extends StatefulWidget {
  final int? resourceId;

  const CreateBookingScreen({
    super.key,
    this.resourceId,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen>
    with ErrorHandlingMixin {
  final SecureStorage _storage = SecureStorage.instance;
  bool _showSuccess = false;
  Booking? _createdBooking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    policyProvider.loadActivePolicies();

    if (widget.resourceId != null) {
      final resourceProvider =
          Provider.of<ResourceProvider>(context, listen: false);
      resourceProvider.loadResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess && _createdBooking != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Created'),
        ),
        body: ResponsiveLayout(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: Responsive.getIconSize(context, size: IconSize.large),
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context, size: SpacingSize.large)),
                  Text(
                    'Booking Created Successfully!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: Responsive.getFontSize(context, size: FontSize.large),
                        ),
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context, size: SpacingSize.xl)),
                  QRCodeDisplay(booking: _createdBooking!),
                  SizedBox(
                      height: Responsive.getSpacing(context, size: SpacingSize.xl)),
                  SizedBox(
                    height: Responsive.getButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, RouteNames.myBookings);
                      },
                      child: const Text('View My Bookings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
      ),
      body: ResponsiveFormLayout(
        child: SingleChildScrollView(
          child: Consumer3<BookingProvider, PolicyProvider, ResourceProvider>(
            builder: (context, bookingProvider, policyProvider,
                resourceProvider, _) {
              Resource? selectedResource;
              if (widget.resourceId != null) {
                selectedResource = resourceProvider.resources.firstWhere(
                    (r) => r.id == widget.resourceId,
                    orElse: () => resourceProvider.resources.first);
              }

              return BookingForm(
                selectedResource: selectedResource,
                onSubmit: (startTime, endTime, resourceId) async {
                  await _createBooking(context, resourceId, startTime, endTime);
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _createBooking(
    BuildContext context,
    int resourceId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final userIdStr = await _storage.getUserId();

    if (!mounted) return;

    if (userIdStr == null) {
      showErrorSnackBar(context, 'User not authenticated');
      return;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Invalid user ID');
      return;
    }

    final request = {
      'resourceId': resourceId,
      'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
      'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
    };

    final booking = await bookingProvider.createBooking(request);

    if (booking != null && context.mounted) {
      setState(() {
        _createdBooking = booking;
        _showSuccess = true;
      });
    }
  }
}
