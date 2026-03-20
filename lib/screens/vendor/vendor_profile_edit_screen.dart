import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/vendor_provider.dart';
import '../../services/storage_service.dart';

/// Screen for viewing and editing vendor profile
class VendorProfileEditScreen extends StatefulWidget {
  const VendorProfileEditScreen({super.key});

  @override
  State<VendorProfileEditScreen> createState() => _VendorProfileEditScreenState();
}

class _VendorProfileEditScreenState extends State<VendorProfileEditScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!.data()!;

          return _isEditing
              ? _EditProfileForm(profileData: data, uid: uid)
              : _ViewProfile(profileData: data);
        },
      ),
    );
  }
}

class _ViewProfile extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const _ViewProfile({required this.profileData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.deepOrange.shade100,
            backgroundImage: profileData['imageUrl'] != null &&
                    (profileData['imageUrl'] as String).isNotEmpty
                ? NetworkImage(profileData['imageUrl'])
                : null,
            child: profileData['imageUrl'] == null ||
                    (profileData['imageUrl'] as String).isEmpty
                ? Text(
                    (profileData['shopName'] as String? ?? 'V')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 24),

          _InfoCard(
            icon: Icons.store,
            label: 'Shop Name',
            value: profileData['shopName'] ?? 'N/A',
          ),
          _InfoCard(
            icon: Icons.person,
            label: 'Owner Name',
            value: profileData['ownerName'] ?? 'N/A',
          ),
          _InfoCard(
            icon: Icons.description,
            label: 'Description',
            value: profileData['description'] ?? 'No description',
          ),
          _InfoCard(
            icon: Icons.phone,
            label: 'Phone',
            value: profileData['phone'] ?? 'Not provided',
          ),
          _InfoCard(
            icon: Icons.location_on,
            label: 'Address',
            value: profileData['address'] ?? 'Not provided',
          ),
          _InfoCard(
            icon: Icons.email,
            label: 'Email',
            value: FirebaseAuth.instance.currentUser?.email ?? 'N/A',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}


class _EditProfileForm extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String uid;

  const _EditProfileForm({required this.profileData, required this.uid});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _imageUrlController;
  
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.profileData['shopName'] ?? '');
    _ownerNameController = TextEditingController(text: widget.profileData['ownerName'] ?? '');
    _descriptionController = TextEditingController(text: widget.profileData['description'] ?? '');
    _phoneController = TextEditingController(text: widget.profileData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.profileData['address'] ?? '');
    _imageUrlController = TextEditingController(text: widget.profileData['imageUrl'] ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile == null) return;

    setState(() => _isUploading = true);
    try {
      final downloadUrl = await StorageService.instance.uploadImage(
        File(pickedFile.path),
        'vendor_profiles',
      );
      if (downloadUrl != null) {
        setState(() {
          _imageUrlController.text = downloadUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Update profile in Firestore
      final provider = VendorProvider();
      await provider.updateVendorProfile(
        shopName: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Exit edit mode
        final parentState = context.findAncestorStateOfType<_VendorProfileEditScreenState>();
        parentState?.setState(() => parentState._isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _shopNameController,
            decoration: InputDecoration(
              labelText: 'Shop Name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.store),
            ),
            validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ownerNameController,
            decoration: InputDecoration(
              labelText: 'Owner Name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
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
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_on),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Profile Image URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.image),
                    hintText: 'e.g., https://example.com/image.jpg',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isUploading ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                child: _isUploading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
