import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Displays live menu items from the Firestore `menu_items` collection.
/// Uses a [StreamBuilder] so the UI updates instantly on any Firestore change.
class MenuItemsScreen extends StatefulWidget {
  const MenuItemsScreen({super.key});

  @override
  State<MenuItemsScreen> createState() => _MenuItemsScreenState();
}

class _MenuItemsScreenState extends State<MenuItemsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  Future<String?> _uploadImage(File imageFile) async {
    try {
      setState(() => _isUploading = true);
      
      final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('menu_items')
          .child(vendorId)
          .child(fileName);

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      
      setState(() => _isUploading = false);
      return downloadUrl;
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog(Function(File?) onImageSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Image Source',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
                onImageSelected(_selectedImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
                onImageSelected(_selectedImage);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, {DocumentSnapshot? existingItem}) {
    final isEditing = existingItem != null;
    final existingData = existingItem?.data() as Map<String, dynamic>?;
    
    final nameController = TextEditingController(text: existingData?['name'] ?? '');
    final priceController = TextEditingController(
      text: existingData?['price']?.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: existingData?['category'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingData?['description'] ?? '',
    );
    final imageUrlController = TextEditingController(
      text: existingData?['imageUrl'] ?? '',
    );
    File? selectedImage;
    bool isAvailable = existingData?['isAvailable'] ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Menu Item' : 'Add Menu Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹) *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Image selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Image',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    else if (imageUrlController.text.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrlController.text,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  imageUrlController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () {
                                    _showImageSourceDialog((image) {
                                      setDialogState(() {
                                        selectedImage = image;
                                      });
                                    });
                                  },
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Pick from Device'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  final urlController = TextEditingController(
                                    text: imageUrlController.text,
                                  );
                                  return AlertDialog(
                                    title: const Text('Enter Image URL'),
                                    content: TextField(
                                      controller: urlController,
                                      decoration: const InputDecoration(
                                        hintText: 'https://example.com/image.jpg',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setDialogState(() {
                                            imageUrlController.text =
                                                urlController.text;
                                            selectedImage = null;
                                          });
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('Enter URL'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (value) {
                    setDialogState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          priceController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in name and price'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      if (vendorId.isEmpty) return;

                      // Upload image if selected
                      String? uploadedImageUrl;
                      if (selectedImage != null) {
                        uploadedImageUrl = await _uploadImage(selectedImage!);
                        if (uploadedImageUrl == null) return; // Upload failed
                      }

                      final itemData = {
                        'vendorId': vendorId,
                        'name': nameController.text.trim(),
                        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                        'category': categoryController.text.trim().isEmpty
                            ? 'Uncategorized'
                            : categoryController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'imageUrl': uploadedImageUrl ?? imageUrlController.text.trim(),
                        'isAvailable': isAvailable,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      try {
                        if (isEditing) {
                          // Update existing item
                          await FirebaseFirestore.instance
                              .collection('menu_items')
                              .doc(existingItem.id)
                              .update(itemData);
                        } else {
                          // Add new item
                          itemData['createdAt'] = FieldValue.serverTimestamp();
                          await FirebaseFirestore.instance
                              .collection('menu_items')
                              .add(itemData);
                        }

                        if (context.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Item updated successfully'
                                    : 'Item added successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Item' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(itemId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Menu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vendorId.isNotEmpty
            ? FirebaseFirestore.instance
                .collection('menu_items')
                .where('vendorId', isEqualTo: vendorId)
                .snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          // ── Loading ────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ──────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading menu:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          // ── Empty ──────────────────────────────────────────────────────
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No menu items found.\nAdd items in Firestore to see them here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // ── Data ───────────────────────────────────────────────────────
          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = data['name'] as String? ?? 'Unnamed Item';
              final price = (data['price'] as num?)?.toDouble() ?? 0.0;
              final category = data['category'] as String? ?? 'Uncategorized';
              final isAvailable = data['isAvailable'] as bool? ?? true;
              final imageUrl = data['imageUrl'] as String?;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                CircleAvatar(
                              backgroundColor: isAvailable
                                  ? Colors.deepOrange.shade100
                                  : Colors.grey.shade200,
                              child: Icon(
                                Icons.fastfood,
                                color: isAvailable
                                    ? Colors.deepOrange
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: isAvailable
                              ? Colors.deepOrange.shade100
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.fastfood,
                            color: isAvailable
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),
                        ),
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    category,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Sold Out',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isAvailable
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddItemDialog(context, existingItem: doc);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, doc.id, name);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
