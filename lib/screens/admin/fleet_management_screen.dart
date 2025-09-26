// screens/admin/fleet_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easydrive/models/car_model.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search cars',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Stats summary
          _buildStatsSummary(),

          // Cars list
          Expanded(child: _buildCarsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCarDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final cars = snapshot.data!.docs
            .map((doc) => CarModel.fromFirestore(doc))
            .toList();

        final availableCars = cars
            .where((car) => car.status == 'Available')
            .length;
        final bookedCars = cars.where((car) => car.status == 'Booked').length;
        final maintenanceCars = cars
            .where((car) => car.status == 'Maintenance')
            .length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', cars.length, Colors.blue),
              _buildStatItem('Available', availableCars, Colors.green),
              _buildStatItem('Booked', bookedCars, Colors.orange),
              _buildStatItem('Maintenance', maintenanceCars, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCarsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cars')
          .orderBy('brand')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No cars in fleet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Tap the + button to add your first car',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        List<CarModel> cars = snapshot.data!.docs
            .map((doc) => CarModel.fromFirestore(doc))
            .toList();

        // Filter cars based on search query
        if (_searchQuery.isNotEmpty) {
          cars = cars.where((car) {
            return car.brand.toLowerCase().contains(_searchQuery) ||
                car.model.toLowerCase().contains(_searchQuery) ||
                car.type.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (cars.isEmpty) {
          return const Center(child: Text('No cars match your search'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return _buildCarCard(car);
          },
        );
      },
    );
  }

  Widget _buildCarCard(CarModel car) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: car.imageUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  car.imageUrls[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_car, size: 30),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_car, size: 30),
              ),
        title: Text(
          '${car.brand} ${car.model}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${car.type} • \$${car.pricePerDay}/day'),
            if (car.features.isNotEmpty)
              Text(
                'Features: ${car.features.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            car.status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: _getStatusColor(car.status),
        ),
        onTap: () => _showEditCarDialog(car),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Booked':
        return Colors.orange;
      case 'Maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddCarDialog() {
    showDialog(context: context, builder: (context) => AddEditCarDialog());
  }

  void _showEditCarDialog(CarModel car) {
    showDialog(
      context: context,
      builder: (context) => AddEditCarDialog(car: car),
    );
  }
}

class AddEditCarDialog extends StatefulWidget {
  final CarModel? car;

  const AddEditCarDialog({this.car, super.key});

  @override
  State<AddEditCarDialog> createState() => _AddEditCarDialogState();
}

class _AddEditCarDialogState extends State<AddEditCarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featureController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _status = 'Available';
  List<String> _features = [];
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.model;
      _typeController.text = widget.car!.type;
      _priceController.text = widget.car!.pricePerDay.toString();
      _descriptionController.text = widget.car!.description;
      _status = widget.car!.status;
      _features = List.from(widget.car!.features);
      _imageUrls = List.from(widget.car!.imageUrls);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.car == null ? 'Add New Car' : 'Edit Car',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Basic Info ──────────────────────────────
                _buildSectionHeader('Basic Information'),
                _buildTextField(
                  _brandController,
                  'Brand*',
                  'e.g., Toyota',
                  true,
                ),
                _buildTextField(
                  _modelController,
                  'Model*',
                  'e.g., Camry',
                  true,
                ),
                _buildTextField(
                  _typeController,
                  'Type*',
                  'e.g., SUV, Sedan',
                  true,
                ),
                _buildTextField(
                  _priceController,
                  'Price per day*',
                  'e.g., 50.00',
                  true,
                  TextInputType.number,
                ),
                _buildTextField(
                  _descriptionController,
                  'Description',
                  'Describe the car...',
                  false,
                  null,
                  3,
                ),

                // ── Features ──────────────────────────────
                _buildSectionHeader('Features'),
                _buildFeaturesSection(),

                // ── Images ──────────────────────────────
                _buildSectionHeader('Images'),
                _buildImageUrlsSection(),

                // ── Status ──────────────────────────────
                _buildSectionHeader('Status'),
                _buildStatusDropdown(),

                const SizedBox(height: 24),

                // ── Action Buttons ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveCar,
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: Text(
                        widget.car == null ? 'Add Car' : 'Update Car',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    bool isRequired, [
    TextInputType? keyboardType,
    int maxLines = 1,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (keyboardType == TextInputType.number &&
              value != null &&
              value.isNotEmpty) {
            final num = double.tryParse(value);
            if (num == null || num <= 0) {
              return 'Please enter a valid price';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _featureController,
                decoration: InputDecoration(
                  labelText: 'Add feature',
                  hintText: 'e.g., GPS, Bluetooth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _features.add(value.trim());
                      _featureController.clear();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {
                if (_featureController.text.isNotEmpty) {
                  setState(() {
                    _features.add(_featureController.text.trim());
                    _featureController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_features.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _features.map((feature) {
              return Chip(
                label: Text(feature),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _features.remove(feature);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageUrlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Add image URL',
                  hintText: 'https://example.com/car.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _imageUrls.add(value.trim());
                      _imageUrlController.clear();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {
                if (_imageUrlController.text.isNotEmpty) {
                  setState(() {
                    _imageUrls.add(_imageUrlController.text.trim());
                    _imageUrlController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_imageUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Image URLs:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          ..._imageUrls.map((url) {
            return ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: Text(
                url,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  setState(() {
                    _imageUrls.remove(url);
                  });
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _status,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['Available', 'Booked', 'Maintenance']
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
    );
  }

  void _saveCar() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_brandController.text.isEmpty ||
          _modelController.text.isEmpty ||
          _typeController.text.isEmpty ||
          _priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final carData = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'type': _typeController.text,
        'pricePerDay': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
        'status': _status,
        'isAvailable': _status == 'Available',
        'features': _features,
        'imageUrls': _imageUrls,
      };

      if (widget.car == null) {
        // Add new car
        FirebaseFirestore.instance
            .collection('cars')
            .add(carData)
            .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Car added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding car: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            });
      } else {
        // Update existing car
        FirebaseFirestore.instance
            .collection('cars')
            .doc(widget.car!.id)
            .update(carData)
            .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Car updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating car: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            });
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _featureController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}