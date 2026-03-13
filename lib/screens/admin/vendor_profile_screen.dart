import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qless/services/firestore_service.dart';

/// Reads a vendor's profile document once from the Firestore `users` collection
/// using a [FutureBuilder], demonstrating a one-time (non-streaming) read.
class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

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
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                    'No profile found for this user.\nCreate a document in Firestore → users → $uid',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // ── Data ───────────────────────────────────────────────────────
          final data = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Text(
                    (data['shopName'] as String? ?? 'V')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange),
                  ),
                ),
                const SizedBox(height: 24),

                _ProfileTile(
                  icon: Icons.store,
                  label: 'Shop Name',
                  value: data['shopName'] as String? ?? '—',
                ),
                _ProfileTile(
                  icon: Icons.person,
                  label: 'Owner Name',
                  value: data['ownerName'] as String? ?? '—',
                ),
                _ProfileTile(
                  icon: Icons.email,
                  label: 'Email',
                  value: FirebaseAuth.instance.currentUser?.email ?? '—',
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
                _ProfileTile(
                  icon: Icons.vpn_key,
                  label: 'UID',
                  value: uid,
                  isSmall: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSmall;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isSmall = false,
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
          style: GoogleFonts.poppins(
              fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isSmall ? 11 : 15,
          ),
        ),
      ),
    );
  }
}
