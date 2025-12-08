import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../core/mixins/error_handling_mixin.dart';

/// Manual check-in screen for staff
class ManualCheckInScreen extends StatefulWidget {
  const ManualCheckInScreen({super.key});
  
  @override
  State<ManualCheckInScreen> createState() => _ManualCheckInScreenState();
}

class _ManualCheckInScreenState extends State<ManualCheckInScreen> with ErrorHandlingMixin {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  User? _selectedUser;
  List<Booking> _userBookings = [];
  Booking? _selectedBooking;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadUsers() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadAllUsers();
  }
  
  void _searchUsers(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
      });
      return;
    }
    
    setState(() {
      _filteredUsers = userProvider.users
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  
  void _selectUser(User user) async {
    setState(() {
      _selectedUser = user;
      _userBookings = [];
      _selectedBooking = null;
    });
    
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User search
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search User',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by username or email',
              ),
              onChanged: _searchUsers,
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
                        _searchController.clear();
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final booking = await bookingProvider.checkIn(_selectedBooking!.qrCode ?? '');
    
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

