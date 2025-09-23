import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easydrive/models/car_model.dart';
import 'package:easydrive/models/booking_model.dart';
import 'package:easydrive/providers/auth_provider.dart';
import 'package:easydrive/services/database_service.dart';

class BookingScreen extends StatefulWidget {
  final CarModel car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime? _startDate;
  DateTime? _endDate;
  int _duration = 1;
  double _totalPrice = 0;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    _calculateTotal();
  }

  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!).inDays;
      setState(() {
        _duration = duration > 0 ? duration : 1;
        _totalPrice = widget.car.pricePerDay * _duration;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : _endDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!.add(const Duration(days: 1)))) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date must be after start date')),
            );
          }
        }
        _calculateTotal();
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would integrate with a payment gateway here
    // For demo purposes, we'll simulate a successful payment
    final paymentSuccess = await _simulatePayment(_totalPrice);

    if (paymentSuccess) {
      await _confirmBooking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<bool> _simulatePayment(double amount) async {
    // Simulate payment processing - in real app, integrate with Stripe, PayPal, etc.
    return true; // Always success for demo
  }

  Future<void> _confirmBooking() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book a car')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates')),
      );
      return;
    }

    // Check if car is still available
    final isAvailable = await _databaseService.isCarAvailableForDates(
      widget.car.id,
      _startDate!,
      _endDate!,
    );

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This car is no longer available for the selected dates')),
      );
      return;
    }

    // Create booking with payment information
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user!.id,
      carId: widget.car.id,
      carModel: '${widget.car.brand} ${widget.car.model}',
      startDate: _startDate!,
      endDate: _endDate!,
      totalPrice: _totalPrice,
      status: 'Confirmed', // Change to 'Confirmed' after payment
      createdAt: DateTime.now(),
      isPaid: true, // Mark as paid
      paymentDate: DateTime.now(), // Set payment timestamp
      paymentMethod: _selectedPaymentMethod, // Store payment method
    );

    try {
      await _databaseService.createBooking(booking);
      
      // Update car status to 'Booked'
      await _updateCarStatus(widget.car.id, 'Booked');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed successfully!')),
      );
      
      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating booking: $e')),
      );
    }
  }

  Future<void> _updateCarStatus(String carId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'status': status,
        'isAvailable': status == 'Available',
      });
    } catch (e) {
      print('Error updating car status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.car.imageUrls.isNotEmpty 
                            ? widget.car.imageUrls[0] 
                            : 'https://via.placeholder.com/150',
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.car.brand} ${widget.car.model}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(widget.car.type),
                          Text(
                            'Status: ${widget.car.status}',
                            style: TextStyle(
                              color: widget.car.status == 'Available' 
                                  ? Colors.green 
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Date selection
            const Text(
              'Select Rental Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateButton('Start Date', _startDate, true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateButton('End Date', _endDate, false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Payment method selection
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 16),
            
            // Duration and price summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration:'),
                        Text('$_duration days'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price per day:'),
                        Text('\$${widget.car.pricePerDay.toStringAsFixed(2)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$$_totalPrice',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedPaymentMethod != null) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Method:'),
                          Text(
                            _selectedPaymentMethod!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Payment button
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const ElevatedButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 12),
                          Text('Processing Payment...'),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Pay & Confirm Booking',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, bool isStartDate) {
    return OutlinedButton(
      onPressed: () => _selectDate(context, isStartDate),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              date != null 
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final List<Map<String, dynamic>> paymentMethods = [
      {'name': 'Credit Card', 'icon': Icons.credit_card},
      {'name': 'Debit Card', 'icon': Icons.credit_card},
      {'name': 'PayPal', 'icon': Icons.payment},
      {'name': 'Cash', 'icon': Icons.money},
    ];

    return Wrap(
      spacing: 8,
      children: paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method['name'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(method['icon'] as IconData, size: 16),
              const SizedBox(width: 4),
              Text(method['name']!),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedPaymentMethod = selected ? method['name'] : null;
            });
          },
          selectedColor: Colors.blue[100],
        );
      }).toList(),
    );
  }
}