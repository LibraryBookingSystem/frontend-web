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
import '../../core/animations/animation_utils.dart';
import '../../theme/app_theme.dart';

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

    // Always load resources so they're available for selection
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    resourceProvider.loadResources();
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
                  AnimationUtils.scaleIn(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.successColor,
                            AppTheme.tealColor,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: Responsive.getSpacing(context,
                          size: SpacingSize.large)),
                  AnimationUtils.fadeIn(
                    child: Text(
                      'Booking Created Successfully!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: Responsive.getFontSize(context,
                                size: FontSize.large),
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(
                      height:
                          Responsive.getSpacing(context, size: SpacingSize.xl)),
                  QRCodeDisplay(booking: _createdBooking!),
                  SizedBox(
                      height:
                          Responsive.getSpacing(context, size: SpacingSize.xl)),
                  AnimationUtils.slideInFromBottom(
                    child: SizedBox(
                      height: Responsive.getButtonHeight(context),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, RouteNames.myBookings);
                        },
                        icon: const Icon(Icons.event_note),
                        label: const Text('View My Bookings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
                try {
                  selectedResource = resourceProvider.resources.firstWhere(
                      (r) => r.id == widget.resourceId);
                  
                  // Check if selected resource is available
                  if (!selectedResource.isAvailable) {
                    final resourceName = selectedResource.name;
                    final resourceStatus = selectedResource.status.value;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showErrorSnackBar(
                        context,
                        '$resourceName is ${resourceStatus.toLowerCase()} and cannot be booked. Please select an available resource.',
                      );
                    });
                  }
                } catch (e) {
                  // Resource not found, selectedResource will remain null
                  selectedResource = null;
                }
              }

              return BookingForm(
                selectedResource: selectedResource,
                resources: resourceProvider.resources,
                onSubmit: (startTime, endTime, resourceId) async {
                  // Validate resource availability before submitting
                  final resource = resourceProvider.resources.firstWhere(
                    (r) => r.id == resourceId,
                    orElse: () => selectedResource ?? resourceProvider.resources.first,
                  );
                  
                  if (!resource.isAvailable) {
                    showErrorSnackBar(
                      context,
                      '${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked',
                    );
                    return;
                  }
                  
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

    if (!context.mounted) return;

    if (booking != null) {
      setState(() {
        _createdBooking = booking;
        _showSuccess = true;
      });
    } else {
      // Show error message if booking creation failed
      final errorMessage = bookingProvider.error ?? 'Failed to create booking';
      showErrorSnackBar(context, errorMessage);
    }
  }
}
