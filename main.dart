import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.insertSampleData();
  runApp(FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      home: FoodOrderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FoodOrderPage extends StatefulWidget {
  @override
  _FoodOrderPageState createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _foodItems = [];
  double _targetCost = 0.0;
  List<Map<String, dynamic>> _selectedItems = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    final db = await _dbHelper.database;
    final items = await db.query('FoodItems');
    setState(() {
      _foodItems = items;
    });
  }

  Future<void> _saveOrder() async {
    final db = await _dbHelper.database;
    final selectedItemNames =
        _selectedItems.map((item) => item['name']).join(', ');
    await db.insert('Orders', {
      'date': _selectedDate.toIso8601String(),
      'items': selectedItemNames,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order saved successfully!')),
    );
  }

  Future<void> _queryOrder() async {
    final db = await _dbHelper.database;
    final orders = await db.query(
      'Orders',
      where: 'date = ?',
      whereArgs: [_selectedDate.toIso8601String()],
    );

    if (orders.isNotEmpty) {
      final items = orders.first['items'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order on ${_selectedDate.toLocal()}: $items')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No orders found for ${_selectedDate.toLocal()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Ordering App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _targetCost = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveOrder,
            child: Text('Save Order'),
          ),
          ElevatedButton(
            onPressed: _queryOrder,
            child: Text('Query Order'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                final item = _foodItems[index];
                return ListTile(
                  title: Text('${item['name']} (\$${item['cost']})'),
                  trailing: Checkbox(
                    value: _selectedItems.contains(item),
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          final currentCost = _selectedItems
                              .fold<double>(0.0, (sum, item) => sum + item['cost']);
                          if (currentCost + item['cost'] <= _targetCost) {
                            _selectedItems.add(item);
                          }
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
