import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'models/item.dart';
import 'services/firestore_service.dart';
import 'widgets/item_form_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InventoryHomePage(),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        onSubmit: (item) async {
          await _service.addItem(item);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item added')),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(Item item) {
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        item: item,
        onSubmit: (updatedItem) async {
          await _service.updateItem(updatedItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item updated')),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    await _service.deleteItem(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search items',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchText = value.toLowerCase());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: StreamBuilder<List<Item>>(
              stream: _service.streamItems(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                final categories = {
                  'All',
                  ...items.map((item) => item.category).where((c) => c.isNotEmpty),
                }.toList();

                return DropdownButtonFormField<String>(
                  value: categories.contains(_selectedCategory)
                      ? _selectedCategory
                      : 'All',
                  decoration: const InputDecoration(
                    labelText: 'Filter by category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'All';
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _service.streamItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final items = snapshot.data ?? [];

                final filteredItems = items.where((item) {
                  final matchesSearch =
                      item.name.toLowerCase().contains(_searchText) ||
                      item.category.toLowerCase().contains(_searchText);

                  final matchesCategory = _selectedCategory == 'All' ||
                      item.category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items yet. Add your first inventory item.'),
                  );
                }

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text('No matching items found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isLowStock = item.quantity <= 5;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(item.quantity.toString()),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(item.name)),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Low Stock',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          'Category: ${item.category}\n'
                          'Price: \$${item.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}