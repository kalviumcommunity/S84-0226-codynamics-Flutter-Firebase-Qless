import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:qless/services/firestore_service.dart';
import 'shop_menu_screen.dart';
import 'user_profile_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  static const String _defaultShopBackground = 'assets/images/banner.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Shops',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.instance.vendorsStream(),
        builder: (context, vendorsSnapshot) {
          if (vendorsSnapshot.connectionState == ConnectionState.waiting) {
            return const FoodLoadingIndicator(size: 40);
          }

          if (vendorsSnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading shops: ${vendorsSnapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final vendorDocs = vendorsSnapshot.data?.docs ?? [];
          final activeVendors = vendorDocs.where((doc) {
            final data = doc.data();
            return data['isActive'] as bool? ?? true;
          }).toList();

          if (activeVendors.isEmpty) {
             return Center(
                child: Text(
                  'No shops available right now.',
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                ),
              );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activeVendors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = activeVendors[index];
              final data = doc.data();
              
              final shopName = (data['shopName'] as String?)?.trim().isNotEmpty == true
                  ? (data['shopName'] as String).trim()
                  : ((data['ownerName'] as String?)?.trim().isNotEmpty == true
                      ? (data['ownerName'] as String).trim()
                      : 'Vendor');
              
              final description = data['description'] as String? ?? 'Tap to view menu';
              final imageUrl = _resolveShopImageUrl(data, shopName);
              final rating = _buildMockRating(doc.id);
              final orderedCount = _buildMockOrders(doc.id);

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopMenuScreen(
                        vendorId: doc.id,
                        shopName: shopName,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 350,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _buildShopHeroImage(imageUrl),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                shopName,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF32A852),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating.toStringAsFixed(2),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '$orderedCount ordered from here',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade500, width: 1.4),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShopHeroImage(String imageUrl) {
    final normalizedUrl = imageUrl.trim();

    if (normalizedUrl.isNotEmpty) {
      if (normalizedUrl.startsWith('assets/')) {
        return Image.asset(
          normalizedUrl,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, trace) {
            return Image.asset(_defaultShopBackground, fit: BoxFit.cover);
          },
        );
      }

      return Image.network(
        normalizedUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, trace) {
          return Image.asset(_defaultShopBackground, fit: BoxFit.cover);
        },
      );
    }
    return Image.asset(_defaultShopBackground, fit: BoxFit.cover);
  }

  String _resolveShopImageUrl(Map<String, dynamic> data, String shopName) {
    final candidateFields = <String>[
      'imageUrl',
      'profileImageUrl',
      'shopImageUrl',
      'photoUrl',
      'avatarUrl',
    ];

    for (final field in candidateFields) {
      final value = (data[field] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    // Specific shop fallback: use local profile-style banner if no URL exists yet.
    if (shopName.toLowerCase().contains('cakerie')) {
      return 'assets/images/background.png';
    }

    return '';
  }

  double _buildMockRating(String seed) {
    final score = seed.codeUnits.fold<int>(0, (total, unit) => total + unit);
    final normalized = 41 + (score % 9);
    return normalized / 10;
  }

  int _buildMockOrders(String seed) {
    final score = seed.codeUnits.fold<int>(0, (total, unit) => total + (unit * 2));
    return 2500 + (score % 48000);
  }
}

