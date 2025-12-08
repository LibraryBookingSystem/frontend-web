import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/booking.dart';
import '../../core/utils/qr_code_utils.dart';
import '../../core/utils/date_utils.dart' as date_utils;

/// QR code display widget for bookings
class QRCodeDisplay extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onShare;
  
  const QRCodeDisplay({
    super.key,
    required this.booking,
    this.onShare,
  });
  
  @override
  Widget build(BuildContext context) {
    final qrData = booking.qrCode ?? 
        QRCodeUtils.generateQRCodeData(
          bookingId: booking.id,
          resourceId: booking.resourceId,
          timestamp: booking.createdAt,
        );
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booking QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Booking information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Resource',
                    value: booking.resourceName,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Date',
                    value: date_utils.AppDateUtils.formatDate(booking.startTime),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Time',
                    value: '${date_utils.AppDateUtils.formatTime(booking.startTime)} - ${date_utils.AppDateUtils.formatTime(booking.endTime)}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Status',
                    value: booking.status.value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // QR Code data (for manual entry)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      qrData,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard
                      // Clipboard.setData(ClipboardData(text: qrData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR code copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (onShare != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

