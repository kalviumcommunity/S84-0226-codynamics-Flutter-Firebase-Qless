import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';

/// Enhanced user profile page with view/edit toggle
/// Matches the vendor profile design style
class EnhancedUserProfileScreen extends StatefulWidget {
  const EnhancedUserProfileScreen({super.key});

  @override
  State<EnhancedUserProfileScreen> createState() =>
      _EnhancedUserProfileScreenState();
}

class _EnhancedUserProfileScreenState extends State<EnhancedUserProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Are you sure you want to sign out?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && mounted) {
                await FirebaseAuth.instance.signOut();
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data?.data() ?? {};

          return _isEditing
              ? _EditProfileForm(
                  profileData: data,
                  uid: uid,
                  email: email,
                  onSave: () => setState(() => _isEditing = false),
                )
              : _ViewProfile(
                  profileData: data,
                  email: email,
                );
        },
      ),
    );
  }
}

/// View mode
class _ViewProfile extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final String email;

  const _ViewProfile({
    required this.profileData,
    required this.email,
  });

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
                    (profileData['name'] as String? ?? 'U')
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

          // Profile Fields
          if ((profileData['name'] as String?)?.isNotEmpty ?? false)
            _InfoCard(
              icon: Icons.person,
              label: 'Full Name',
              value: profileData['name'] ?? 'Not provided',
            ),
          _InfoCard(
            icon: Icons.email,
            label: 'Email',
            value: email,
          ),
          if ((profileData['phone'] as String?)?.isNotEmpty ?? false)
            _InfoCard(
              icon: Icons.phone,
              label: 'Phone',
              value: profileData['phone'] ?? 'Not provided',
            ),
          if ((profileData['address'] as String?)?.isNotEmpty ?? false)
            _InfoCard(
              icon: Icons.location_on,
              label: 'Address',
              value: profileData['address'] ?? 'Not provided',
            ),
          if ((profileData['gender'] as String?)?.isNotEmpty ?? false)
            _InfoCard(
              icon: Icons.wc,
              label: 'Gender',
              value: profileData['gender'] ?? 'Not provided',
            ),
          if ((profileData['dateOfBirth'] as String?)?.isNotEmpty ?? false)
            _InfoCard(
              icon: Icons.cake,
              label: 'Date of Birth',
              value: profileData['dateOfBirth'] ?? 'Not provided',
            ),
        ],
      ),
    );
  }
}

/// Info Card Widget
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

/// Edit mode
class _EditProfileForm extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String uid;
  final String email;
  final VoidCallback onSave;

  const _EditProfileForm({
    required this.profileData,
    required this.uid,
    required this.email,
    required this.onSave,
  });

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _genderController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _imageUrlController;

  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profileData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.profileData['phone'] ?? '');
    _addressController =
        TextEditingController(text: widget.profileData['address'] ?? '');
    _genderController =
        TextEditingController(text: widget.profileData['gender'] ?? '');
    _dateOfBirthController = TextEditingController(
        text: widget.profileData['dateOfBirth'] ?? '');
    _imageUrlController =
        TextEditingController(text: widget.profileData['imageUrl'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    setState(() => _isUploading = true);
    try {
      final downloadUrl = await StorageService.instance.uploadImage(
        File(pickedFile.path),
        'user_profiles',
      );
      if (downloadUrl != null) {
        setState(() {
          _imageUrlController.text = downloadUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red,
          ),
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

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set(
        {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'gender': _genderController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'imageUrl': _imageUrlController.text.trim(),
          'email': widget.email,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        widget.onSave();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        automaticallyImplyLeading: false,
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
              tooltip: 'Save Changes',
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
                        backgroundImage:
                            _imageUrlController.text.isNotEmpty
                                ? NetworkImage(_imageUrlController.text)
                                : null,
                        child: _imageUrlController.text.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_isUploading ? 'Uploading...' : 'Change Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                hint: 'Enter your full name',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (Read-only)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.deepOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.email,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                hint: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                hint: 'Enter your address',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Gender
              _buildTextField(
                controller: _genderController,
                label: 'Gender (Optional)',
                icon: Icons.wc,
                hint: 'Male / Female / Other',
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildTextField(
                controller: _dateOfBirthController,
                label: 'Date of Birth (Optional)',
                icon: Icons.cake,
                hint: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 24),

              // Save Button (Bottom)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save Profile',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
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
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }
}
