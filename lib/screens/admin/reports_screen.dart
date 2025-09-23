import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  double _totalRevenue = 0;
  int _totalBookings = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  /// Helper function to fetch revenue report from Firestore
  Future<Map<String, dynamic>> getRevenueReport(
      DateTime startDate, DateTime endDate) async {
    QuerySnapshot completedBookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'Completed')
        .where('isPaid', isEqualTo: true) // ✅ Only include paid bookings
        .where('endDate',
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('endDate',
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .get();

    double revenue = 0;
    for (var doc in completedBookings.docs) {
      final booking = doc.data() as Map<String, dynamic>;
      revenue += (booking['totalPrice'] ?? 0).toDouble();
    }

    return {
      'revenue': revenue,
      'count': completedBookings.docs.length,
    };
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await getRevenueReport(_startDate, _endDate);

      setState(() {
        _totalRevenue = report['revenue'];
        _totalBookings = report['count'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _generateReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selection
            Row(
              children: [
                Expanded(
                  child: _buildDateButton('Start Date', _startDate, true),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildDateButton('End Date', _endDate, false)),
              ],
            ),
            const SizedBox(height: 24),

            // Generate report button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateReport,
                child: const Text('Generate Report'),
              ),
            ),
            const SizedBox(height: 24),

            // Report results
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildReportItem(
                        'Total Revenue',
                        '\$${_totalRevenue.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildReportItem(
                        'Total Bookings',
                        _totalBookings.toString(),
                      ),
                      const Divider(),
                      _buildReportItem(
                        'Average per Booking',
                        _totalBookings > 0
                            ? '\$${(_totalRevenue / _totalBookings).toStringAsFixed(2)}'
                            : '\$0.00',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime date, bool isStartDate) {
    return OutlinedButton(
      onPressed: () => _selectDate(context, isStartDate),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(label),
            const SizedBox(height: 4),
            Text(DateFormat('MMM dd, yyyy').format(date)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}