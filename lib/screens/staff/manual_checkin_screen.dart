import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../widgets/common/theme_switcher.dart';

/// Manual check-in screen for staff
class ManualCheckInScreen extends StatefulWidget {
  const ManualCheckInScreen({super.key});

  @override
  State<ManualCheckInScreen> createState() => _ManualCheckInScreenState();
}

class _ManualCheckInScreenState extends State<ManualCheckInScreen>
    with ErrorHandlingMixin {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  User? _selectedUser;
  List<Booking> _userBookings = [];
  Booking? _selectedBooking;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // NOTE: Removed loadAllUsers() call as it is ADMIN-only
    // Staff can search for users by username instead
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _filteredUsers = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use the new searchUsers method for partial matching
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final users = await userProvider.searchUsers(query);
      setState(() {
        _filteredUsers = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _filteredUsers = [];
        _isSearching = false;
      });
    }
  }

  void _selectUser(User user) async {
    setState(() {
      _selectedUser = user;
      _userBookings = [];
      _selectedBooking = null;
    });

    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadUserBookings(user.id);

    setState(() {
      _userBookings = bookingProvider.userBookings
          .where((b) => b.isUpcoming && b.status == BookingStatus.confirmed)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Check-In'),
        actions: [
          ThemeSwitcherIcon(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search User',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Enter username (min 2 characters)',
                    ),
                    onSubmitted: (_) => _searchUsers(_searchController.text),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching
                        ? null
                        : () => _searchUsers(_searchController.text),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // User list
            if (_filteredUsers.isNotEmpty)
              Card(
                child: Column(
                  children: _filteredUsers.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.username[0].toUpperCase()),
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      onTap: () {
                        _selectUser(user);
                        setState(() {
                          _filteredUsers = [];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            // Selected user
            if (_selectedUser != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(_selectedUser!.username[0].toUpperCase()),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedUser!.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(_selectedUser!.email),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedUser = null;
                            _userBookings = [];
                            _selectedBooking = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // User bookings
            if (_selectedUser != null && _userBookings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Select Booking to Check-In',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ..._userBookings.map((booking) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(booking.resourceName),
                    subtitle: Text(
                      '${booking.startTime.toString().substring(0, 16)} - ${booking.endTime.toString().substring(11, 16)}',
                    ),
                    trailing: _selectedBooking?.id == booking.id
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedBooking = booking;
                      });
                    },
                  ),
                );
              }),
            ],
            // Check-in button
            if (_selectedBooking != null) ...[
              const SizedBox(height: 24),
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: bookingProvider.isLoading
                        ? null
                        : () => _handleCheckIn(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    if (_selectedBooking == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Manual Check-In'),
          content: Text(
            'Check in ${_selectedUser?.username} to ${_selectedBooking?.resourceName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final booking =
        await bookingProvider.checkIn(_selectedBooking!.qrCode ?? '');

    if (!mounted) return;

    if (booking != null) {
      showSuccessSnackBar(context, 'Check-in successful!');
      setState(() {
        _selectedUser = null;
        _userBookings = [];
        _selectedBooking = null;
      });
    } else {
      showErrorSnackBar(context, bookingProvider.error ?? 'Failed to check in');
    }
  }
}
