import 'package:flutter/material.dart';

class SearchFilter extends StatefulWidget {
  final Function(DateTime, DateTime, List<String>) onFilterChanged;
  final List<String> availableCarTypes;

  const SearchFilter({
    super.key,
    required this.onFilterChanged,
    required this.availableCarTypes,
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final Map<String, bool> _selectedTypes = {};

  @override
  void initState() {
    super.initState();
    // Initialize all types as unselected
    for (var type in widget.availableCarTypes) {
      _selectedTypes[type] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Cars',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDateRangePicker(),
            const SizedBox(height: 16),
            _buildCarTypeFilter(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rental Dates:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(true),
                child: Text(_formatDate(_startDate)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(false),
                child: Text(_formatDate(_endDate)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Car Types:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.availableCarTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: _selectedTypes[type] ?? false,
              onSelected: (selected) {
                setState(() {
                  _selectedTypes[type] = selected;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate.add(const Duration(days: 1)))) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_startDate)) {
            _endDate = picked;
          }
        }
      });
    }
  }

  void _applyFilters() {
    final selectedTypes = _selectedTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    widget.onFilterChanged(_startDate, _endDate, selectedTypes);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}