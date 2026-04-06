import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemFormDialog extends StatefulWidget {
  final Item? item;
  final Function(Item item) onSubmit;

  const ItemFormDialog({
    super.key,
    this.item,
    required this.onSubmit,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.item?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      id: widget.item?.id ?? '',
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      price: double.parse(_priceController.text.trim()),
      category: _categoryController.text.trim(),
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    widget.onSubmit(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Item' : 'Add Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter quantity';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null) return 'Quantity must be a whole number';
                  if (parsed < 0) return 'Quantity cannot be negative';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter price';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null) return 'Price must be numeric';
                  if (parsed < 0) return 'Price cannot be negative';
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter category';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}