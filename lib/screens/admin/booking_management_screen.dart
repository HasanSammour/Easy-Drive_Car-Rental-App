import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easydrive/models/booking_model.dart';
import 'package:intl/intl.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          final bookings = snapshot.data!.docs.map((doc) {
            return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.carModel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    booking.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(booking.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Payment status
            Row(
              children: [
                Icon(
                  booking.isPaid ? Icons.check_circle : Icons.pending,
                  color: booking.isPaid ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  booking.isPaid ? 'Paid' : 'Pending Payment',
                  style: TextStyle(
                    color: booking.isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (booking.isPaid && booking.paymentMethod != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${booking.paymentMethod!})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            Text('User ID: ${booking.userId}'),
            Text('Dates: ${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}'),
            Text('Duration: ${booking.durationInDays} days'),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (booking.isPaid && booking.paymentDate != null) 
                  Text(
                    'Paid on: ${dateFormat.format(booking.paymentDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showBookingDetails(context, booking),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!booking.isPaid)
                  ElevatedButton(
                    onPressed: () => _markAsPaid(context, booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Mark as Paid', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Car Model', booking.carModel),
              _buildDetailRow('User ID', booking.userId),
              _buildDetailRow('Start Date', dateFormat.format(booking.startDate)),
              _buildDetailRow('End Date', dateFormat.format(booking.endDate)),
              _buildDetailRow('Duration', '${booking.durationInDays} days'),
              _buildDetailRow('Total Price', '\$${booking.totalPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Status', booking.status),
              _buildDetailRow('Payment Status', booking.isPaid ? 'Paid' : 'Pending'),
              if (booking.isPaid) ...[
                _buildDetailRow('Payment Method', booking.paymentMethod ?? 'Not specified'),
                _buildDetailRow('Payment Date', booking.paymentDate != null 
                    ? dateFormat.format(booking.paymentDate!) 
                    : 'Not available'),
              ],
              _buildDetailRow('Created', dateFormat.format(booking.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _markAsPaid(BuildContext context, BookingModel booking) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking.id)
          .update({
        'isPaid': true,
        'paymentDate': DateTime.now().millisecondsSinceEpoch,
        'paymentMethod': 'Manual (Admin)',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking marked as paid successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating payment status: $e')),
      );
    }
  }
}