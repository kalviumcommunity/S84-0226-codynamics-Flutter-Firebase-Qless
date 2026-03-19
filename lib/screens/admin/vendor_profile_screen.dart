import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/services/firestore_service.dart';
import 'package:qless/screens/admin/edit_vendor_profile_screen.dart';
import 'package:qless/screens/admin/firestore_debug_screen.dart';
import 'package:qless/screens/admin/fix_profile_screen.dart';

/// Reads a vendor's profile document once from the Firestore `users` collection
/// using a [FutureBuilder], demonstrating a one-time (non-streaming) read.
class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  int _refreshKey = 0;

  void _refreshProfile() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Firestore Data',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FirestoreDebugScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Fetch current data first
              final doc = await FirestoreService.instance.getUserProfile(uid);
              if (doc.exists && mounted) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditVendorProfileScreen(
                      profileData: doc.data()!,
                    ),
                  ),
                );
                // Refresh if edit was successful
                if (result == true) {
                  _refreshProfile();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        key: ValueKey(_refreshKey), // Force rebuild when key changes
        future: FirestoreService.instance.getUserProfile(uid),
        builder: (context, snapshot) {
          // ── Loading ────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ──────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          // ── No document ────────────────────────────────────────────────
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No profile found for this user.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: $uid',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Create a basic profile document
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .set({
                          'email': FirebaseAuth.instance.currentUser?.email ?? '',
                          'role': 'vendor',
                          'shopName': '',
                          'ownerName': '',
                          'isActive': true,
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                        _refreshProfile();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile created! Please edit to add details.'),
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
                    icon: const Icon(Icons.add),
                    label: const Text('Create Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Data ───────────────────────────────────────────────────────
          final data = snapshot.data!.data()!;
          
          // Debug: Print all data to see what's in Firestore
          print('📊 Firestore data for user $uid:');
          print(data);
          
          final imageUrl = data['imageUrl'] as String?;
          final shopName = data['shopName'] as String? ?? '';
          final ownerName = data['ownerName'] as String? ?? '';
          final email = FirebaseAuth.instance.currentUser?.email ?? '—';
          final phone = data['phone'] as String? ?? '';
          final address = data['address'] as String? ?? '';
          final description = data['description'] as String? ?? '';
          final isActive = data['isActive'] as bool? ?? true;
          
          // Debug: Print extracted values
          print('🏪 Shop Name: "$shopName"');
          print('👤 Owner Name: "$ownerName"');
          
          // Check if critical fields are missing
          final isMissingCriticalInfo = shopName.trim().isEmpty || ownerName.trim().isEmpty;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Warning banner if critical info is missing
                if (isMissingCriticalInfo)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade800),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Incomplete',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              Text(
                                'Please add your shop name and owner name',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FixProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _refreshProfile();
                            }
                          },
                          child: Text(
                            'Fix Now',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Header with gradient background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepOrange, Colors.deepOrange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Profile Image
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null || imageUrl.isEmpty
                                  ? Icon(
                                      Icons.store,
                                      size: 60,
                                      color: Colors.deepOrange,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                isActive ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Shop Name
                      Text(
                        shopName.trim().isEmpty ? 'Shop Name Not Set' : shopName,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Owner Name
                      Text(
                        ownerName.trim().isEmpty ? 'Owner Name Not Set' : ownerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Profile Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Information Section
                      _SectionHeader(title: 'Contact Information'),
                      const SizedBox(height: 12),
                      _ProfileTile(
                        icon: Icons.email,
                        label: 'Email',
                        value: email.isEmpty ? 'Not set' : email,
                      ),
                      _ProfileTile(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: phone.trim().isEmpty ? 'Not set' : phone,
                      ),
                      _ProfileTile(
                        icon: Icons.location_on,
                        label: 'Address',
                        value: address.trim().isEmpty ? 'Not set' : address,
                      ),

                      const SizedBox(height: 24),

                      // Business Details Section
                      _SectionHeader(title: 'Business Details'),
                      const SizedBox(height: 12),
                      _ProfileTile(
                        icon: Icons.description,
                        label: 'Description',
                        value: description.trim().isEmpty ? 'Not set' : description,
                        maxLines: 3,
                      ),
                      _ProfileTile(
                        icon: Icons.calendar_today,
                        label: 'Member Since',
                        value: data['createdAt'] != null
                            ? (data['createdAt'] as Timestamp)
                                .toDate()
                                .toString()
                                .split(' ')
                                .first
                            : '—',
                      ),

                      const SizedBox(height: 24),

                      // System Information Section
                      _SectionHeader(title: 'System Information'),
                      const SizedBox(height: 12),
                      _ProfileTile(
                        icon: Icons.vpn_key,
                        label: 'User ID',
                        value: uid,
                        isSmall: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSmall;
  final int maxLines;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isSmall = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepOrange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmall ? 11 : 15,
                      color: Colors.grey[800],
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
