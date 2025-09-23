// screens/customer/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easydrive/providers/car_provider.dart';
import 'package:easydrive/screens/customer/car_list_screen.dart';
import 'package:easydrive/screens/customer/profile_screen.dart';
import 'package:easydrive/screens/customer/booking_history_screen.dart';
import 'package:easydrive/widgets/car_card.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const BookingHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load cars when home screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final carProvider = context.watch<CarProvider>();
      carProvider.loadCars();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyDrive'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showDatePicker(context);
              },
            ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Navigate to car list with filters
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CarListScreen(startDate: picked.start, endDate: picked.end),
        ),
      );
    }
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    if (carProvider.isLoading && carProvider.cars.isEmpty) {
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
              onPressed: () => carProvider.loadCars(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (carProvider.cars.isEmpty) {
      return const Center(child: Text('No cars available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Available Cars',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => carProvider.loadCars(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: carProvider.cars.length,
              itemBuilder: (context, index) {
                final car = carProvider.cars[index];
                return CarCard(car: car);
              },
            ),
          ),
        ),
      ],
    );
  }
}
