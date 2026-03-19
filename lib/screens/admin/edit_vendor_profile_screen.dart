import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen for editing vendor profile information
class EditVendorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditVendorProfileScreen({
    super.key,
    required this.profileData,
  });

  @override
  State<EditVendorProfileScreen> createState() =>
      _EditVendorProfileScreenState();
}

class _EditVendorProfileScreenState extends State<EditVendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    _shopNameController.text = widget.profileData['shopName'] as String? ?? '';
    _ownerNameController.text = widget.profileData['ownerName'] as String? ?? '';
    _phoneController.text = widget.profileData['phone'] as String? ?? '';
    _addressController.text = widget.profileData['address'] as String? ?? '';
    _descriptionController.text =
        widget.profileData['description'] as String? ?? '';
    _imageUrlController.text = widget.profileData['imageUrl'] as String? ?? '';
    _isActive = widget.profileData['isActive'] as bool? ?? true;
    
    // Debug print
    print('📝 Loaded profile data for editing:');
    print('  Shop Name: "${_shopNameController.text}"');
    print('  Owner Name: "${_ownerNameController.text}"');
    print('  Phone: "${_phoneController.text}"');
    print('  Address: "${_addressController.text}"');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'shopName': _shopNameController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Preview
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepOrange, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageUrlController.text.isNotEmpty
                            ? NetworkImage(_imageUrlController.text)
                            : null,
                        child: _imageUrlController.text.isEmpty
                            ? Icon(
                                Icons.store,
                                size: 60,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile Image',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Image URL Field
              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL',
                icon: Icons.image,
                hint: 'https://example.com/image.jpg',
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Shop Name
              _buildTextField(
                controller: _shopNameController,
                label: 'Shop Name',
                icon: Icons.store,
                hint: 'Enter shop name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shop name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Owner Name
              _buildTextField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
                hint: 'Enter owner name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Owner name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                hint: '+1234567890',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Address
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                hint: 'Enter shop address',
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                hint: 'Tell customers about your business',
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // Active Status Toggle
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Active Status',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'Your shop is visible to customers'
                        : 'Your shop is hidden from customers',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  value: _isActive,
                  activeColor: Colors.deepOrange,
                  secondary: Icon(
                    _isActive ? Icons.visibility : Icons.visibility_off,
                    color: Colors.deepOrange,
                  ),
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.poppins(),
    );
  }
}
