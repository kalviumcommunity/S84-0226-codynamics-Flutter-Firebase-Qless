import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menu_item_model.dart';
import '../../providers/vendor_provider.dart';

/// Screen for adding or editing a menu item
class AddEditItemScreen extends StatefulWidget {
  final MenuItemModel? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _priceController.text = widget.item!.price.toString();
      _categoryController.text = widget.item!.category;
      _imageUrlController.text = widget.item!.imageUrl;
      _isAvailable = widget.item!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = VendorProvider();

    try {
      if (_isEditing) {
        await provider.updateMenuItem(
          itemId: widget.item!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _categoryController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          isAvailable: _isAvailable,
        );
      } else {
        await provider.addMenuItem(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _categoryController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          isAvailable: _isAvailable,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Item updated!' : 'Item added!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item?', style: GoogleFonts.poppins()),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final provider = VendorProvider();
    await provider.deleteMenuItem(widget.item!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Item' : 'Add New Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteItem,
                  tooltip: 'Delete Item',
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.fastfood),
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category),
                hintText: 'e.g., Beverages, Snacks, Main Course',
              ),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.image),
                hintText: 'https://example.com/image.jpg',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('Available', style: GoogleFonts.poppins()),
              subtitle: Text(
                _isAvailable ? 'Customers can order this item' : 'Item is unavailable',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? 'Update Item' : 'Add Item',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
