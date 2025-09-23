// screens/customer/car_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easydrive/providers/car_provider.dart';
import 'package:easydrive/widgets/car_card.dart';

class CarListScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const CarListScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  @override
  void initState() {
    super.initState();
    // Filter cars based on selected dates
    Future.microtask(() {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      carProvider.filterCars(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Available Cars')),
      body: Column(
        children: [
          // Date display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Car list
          Expanded(child: _buildCarList(carProvider)),
        ],
      ),
    );
  }

  Widget _buildCarList(CarProvider carProvider) {
    if (carProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (carProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${carProvider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => carProvider.filterCars(
                startDate: widget.startDate,
                endDate: widget.endDate,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (carProvider.cars.isEmpty) {
      return const Center(
        child: Text('No cars available for the selected dates'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => carProvider.filterCars(
        startDate: widget.startDate,
        endDate: widget.endDate,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: carProvider.cars.length,
        itemBuilder: (context, index) {
          final car = carProvider.cars[index];
          return CarCard(car: car);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
