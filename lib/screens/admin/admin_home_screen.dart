import 'package:easydrive/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easydrive/providers/auth_provider.dart';
import 'package:easydrive/screens/admin/fleet_management_screen.dart';
import 'package:easydrive/screens/admin/booking_management_screen.dart';
import 'package:easydrive/screens/admin/reports_screen.dart';
import 'package:easydrive/screens/admin/admin_chat_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || !user.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Access denied. Admin privileges required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
          ElevatedButton(
            onPressed: () {
              DatabaseService().addSampleCars();
            },
            child: Text('Add Sample Cars'),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            context,
            icon: Icons.directions_car,
            title: 'Fleet Management',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FleetManagementScreen(),
              ),
            ),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.book_online,
            title: 'Bookings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingManagementScreen(),
              ),
            ),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart,
            title: 'Reports',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportsScreen()),
            ),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.chat,
            title: 'Customer Support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminChatScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
