import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/policy_provider.dart';
import '../../providers/resource_provider.dart';
import '../../providers/realtime_provider.dart';
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
import '../../widgets/common/theme_switcher.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    policyProvider.loadActivePolicies();

    // Always load resources so they're available for selection
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);
    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    // Set real-time availability map before loading so it syncs
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
    await resourceProvider.loadResources();

    // Fetch currently booked resources and mark them as unavailable
    try {
      final bookedResourceIds = await bookingProvider.getBookedResourceIds();
      debugPrint(
          'CreateBooking: Fetched ${bookedResourceIds.length} booked resource IDs');

      for (final resourceId in bookedResourceIds) {
        resourceProvider.updateResourceAvailability(
            resourceId, ResourceStatus.unavailable);
        resourceProvider.syncResourceWithRealtime(resourceId, 'unavailable');
      }
    } catch (e) {
      debugPrint('CreateBooking: Failed to fetch booked resources: $e');
    }

    // Connect to real-time updates
    _connectRealtime();

    // If a specific resource ID was provided, check if it's available
    if (widget.resourceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkResourceAvailability();
      });
    }
  }

  void _checkResourceAvailability() {
    // Don't check if booking was already created successfully
    if (_showSuccess) return;

    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);

    try {
      final resource = resourceProvider.allResources.firstWhere(
        (r) => r.id == widget.resourceId,
      );

      if (!resource.isAvailable) {
        // Resource is unavailable, navigate back and show error
        // But only if we haven't successfully created a booking
        if (!_showSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_showSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${resource.name} is ${resource.status.value.toLowerCase()} and cannot be booked',
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      // Resource not found, that's okay
    }
  }

  void _connectRealtime() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      final resourceProvider =
          Provider.of<ResourceProvider>(context, listen: false);

      // Connect to WebSocket
      realtimeProvider.connect().catchError((error) {
        // Silently handle WebSocket connection errors
      });

      // Listen to real-time updates
      realtimeProvider.addListener(_handleRealtimeUpdate);

      // Subscribe to resources when loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Set availability map reference first
        resourceProvider
            .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);

        if (resourceProvider.allResources.isNotEmpty) {
          final resourceIds =
              resourceProvider.allResources.map((r) => r.id).toList();
          realtimeProvider.subscribeToResources(resourceIds);

          // Sync initial state
          if (realtimeProvider.availabilityMap.isNotEmpty) {
            realtimeProvider.availabilityMap
                .forEach((resourceId, statusString) {
              resourceProvider.syncResourceWithRealtime(
                  resourceId, statusString);
            });
            resourceProvider.syncAllResourcesWithRealtime();
          }
        } else {
          // Resources not loaded yet, wait and retry
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && resourceProvider.allResources.isNotEmpty) {
              resourceProvider
                  .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);
              final resourceIds =
                  resourceProvider.allResources.map((r) => r.id).toList();
              realtimeProvider.subscribeToResources(resourceIds);

              if (realtimeProvider.availabilityMap.isNotEmpty) {
                realtimeProvider.availabilityMap
                    .forEach((resourceId, statusString) {
                  resourceProvider.syncResourceWithRealtime(
                      resourceId, statusString);
                });
                resourceProvider.syncAllResourcesWithRealtime();
              }
            }
          });
        }
      });
    } catch (e) {
      // Silently handle errors
    }
  }

  void _handleRealtimeUpdate() {
    if (!mounted) return;

    // Don't process updates if we've already shown success
    if (_showSuccess) return;

    final realtimeProvider =
        Provider.of<RealtimeProvider>(context, listen: false);
    final resourceProvider =
        Provider.of<ResourceProvider>(context, listen: false);

    // Update the availability map reference
    resourceProvider
        .setRealtimeAvailabilityMap(realtimeProvider.availabilityMap);

    realtimeProvider.availabilityMap.forEach((resourceId, statusString) {
      resourceProvider.syncResourceWithRealtime(resourceId, statusString);
    });

    // Don't check resource availability after booking is created
    // The realtime update might mark it as unavailable (because it's now booked),
    // but we don't want to show an error after successful booking
  }

  @override
  void dispose() {
    try {
      final realtimeProvider =
          Provider.of<RealtimeProvider>(context, listen: false);
      realtimeProvider.removeListener(_handleRealtimeUpdate);
    } catch (e) {
      // Provider may not be available during dispose
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess && _createdBooking != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Booking Created'),
          actions: [
            ThemeSwitcherIcon(),
          ],
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
                        gradient: const LinearGradient(
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        actions: [
          ThemeSwitcherIcon(),
        ],
      ),
      body: ResponsiveFormLayout(
        child: SingleChildScrollView(
          child: Consumer3<BookingProvider, PolicyProvider, ResourceProvider>(
            builder: (context, bookingProvider, policyProvider,
                resourceProvider, _) {
              Resource? selectedResource;
              if (widget.resourceId != null && !_showSuccess) {
                try {
                  // Check allResources, not filtered resources
                  selectedResource = resourceProvider.allResources
                      .firstWhere((r) => r.id == widget.resourceId);
                  // Check if selected resource is available
                  // Don't show error if booking was already created successfully
                  if (!selectedResource.isAvailable && !_showSuccess) {
                    final resourceName = selectedResource.name;
                    final resourceStatus = selectedResource.status.value;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_showSuccess) {
                        showErrorSnackBar(
                          context,
                          '$resourceName is ${resourceStatus.toLowerCase()} and cannot be booked. Please select an available resource.',
                        );
                      }
                    });
                  }
                } catch (e) {
                  // Resource not found, selectedResource will remain null
                  selectedResource = null;
                }
              } else if (widget.resourceId != null && _showSuccess) {
                // If booking was successful, still show the resource but don't check availability
                try {
                  selectedResource = resourceProvider.allResources
                      .firstWhere((r) => r.id == widget.resourceId);
                } catch (e) {
                  selectedResource = null;
                }
              }

              return BookingForm(
                selectedResource: selectedResource,
                // Filter to only show available resources
                resources: resourceProvider.allResources
                    .where((r) => r.isAvailable)
                    .toList(),
                isLoading: _isLoading,
                onSubmit: (startTime, endTime, resourceId) async {
                  // Validate resource availability before submitting
                  // Use allResources to get the actual resource status
                  final resource = resourceProvider.allResources.firstWhere(
                    (r) => r.id == resourceId,
                    orElse: () =>
                        selectedResource ?? resourceProvider.allResources.first,
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

    setState(() {
      _isLoading = true;
    });

    final request = {
      'resourceId': resourceId,
      'startTime': date_utils.AppDateUtils.formatDateTime(startTime),
      'endTime': date_utils.AppDateUtils.formatDateTime(endTime),
    };

    try {
      final booking = await bookingProvider.createBooking(request);

      if (!context.mounted) return;

      if (booking != null) {
        setState(() {
          _createdBooking = booking;
          _showSuccess = true;
          _isLoading = false;
        });
      } else {
        // Show error message if booking creation failed
        final errorMessage =
            bookingProvider.error ?? 'Failed to create booking';

        // Check if error contains policy violations
        String displayMessage = errorMessage;
        if (errorMessage.contains('violates policy') ||
            errorMessage.contains('Booking violates policy')) {
          // Extract violations from error message
          // Format: "Booking violates policy: violation1, violation2"
          final violationsMatch =
              RegExp(r'Booking violates policy:\s*(.+)', caseSensitive: false)
                  .firstMatch(errorMessage);
          if (violationsMatch != null) {
            final violations = violationsMatch
                    .group(1)
                    ?.split(',')
                    .map((v) => v.trim())
                    .toList() ??
                [];
            displayMessage =
                'Policy Violation:\n${violations.map((v) => '• $v').join('\n')}';
          }
        }

        // Show error dialog for policy violations to display them properly
        if (displayMessage.contains('Policy Violation')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Policy Violation'),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                    displayMessage.replaceFirst('Policy Violation:\n', '')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showErrorSnackBar(context, displayMessage);
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'An unexpected error occurred');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
