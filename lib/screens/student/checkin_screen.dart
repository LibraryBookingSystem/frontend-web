import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/booking_provider.dart';
import '../../core/utils/qr_code_utils.dart';
import '../../core/mixins/error_handling_mixin.dart';
import '../../constants/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/theme_switcher.dart';

/// Check-in screen with QR code scanner
class CheckInScreen extends StatefulWidget {
  final int bookingId;

  const CheckInScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with ErrorHandlingMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  final TextEditingController _manualQrController = TextEditingController();
  bool _showManualEntry = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualQrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        actions: [
          ThemeSwitcherIcon(),
        ],
      ),
      body: _showManualEntry ? _buildManualEntry() : _buildQRScanner(),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onQRCodeDetected,
              ),
              // Overlay
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Scan QR code to check in',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showManualEntry = true;
                    });
                  },
                  child: const Text('Enter QR code manually'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntry() {
    return ResponsiveFormLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _manualQrController,
            decoration: const InputDecoration(
              labelText: 'QR Code',
              border: OutlineInputBorder(),
              hintText: 'Enter QR code',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          SizedBox(height: Responsive.getSpacing(context, mobile: 20, tablet: 24, desktop: 28)),
          SizedBox(
            height: Responsive.getButtonHeight(context),
            child: ElevatedButton(
              onPressed: () {
                final qrCode = _manualQrController.text.trim();
                if (qrCode.isNotEmpty) {
                  _processQRCode(qrCode);
                }
              },
              child: const Text('Check In'),
            ),
          ),
          SizedBox(height: Responsive.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          TextButton(
            onPressed: () {
              setState(() {
                _showManualEntry = false;
              });
            },
            child: const Text('Back to Scanner'),
          ),
        ],
      ),
    );
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue != null) {
      _isScanning = false;
      _processQRCode(barcode.rawValue!);
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    // Validate QR code format
    if (!QRCodeUtils.isValidQRCodeFormat(qrCode)) {
      if (mounted) {
        showErrorSnackBar(context, 'Invalid QR code format');
        setState(() {
          _isScanning = true;
        });
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Check-In'),
          content: const Text('Do you want to check in to this booking?'),
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

    if (confirmed != true) {
      setState(() {
        _isScanning = true;
      });
      return;
    }

    // Process check-in
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final booking = await bookingProvider.checkIn(qrCode);

    if (!mounted) return;

    if (booking != null) {
      showSuccessSnackBar(context, 'Check-in successful!');
      Navigator.pushReplacementNamed(
        context,
        RouteNames.bookingDetails,
        arguments: booking.id,
      );
    } else {
      showErrorSnackBar(context, bookingProvider.error ?? 'Failed to check in');
      setState(() {
        _isScanning = true;
      });
    }
  }
}
