import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shop_menu_screen.dart';

class AvailableShopsScreen extends StatefulWidget {
  const AvailableShopsScreen({super.key});

  @override
  State<AvailableShopsScreen> createState() => _AvailableShopsScreenState();
}

class _AvailableShopsScreenState extends State<AvailableShopsScreen> {
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  List<String> _cuisines = ['All'];
  List<DocumentSnapshot<Map<String, dynamic>>> _allShops = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse Shops',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search shops...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.deepOrange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepOrange.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(),
            ),
          ),
          // Filters
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('vendors')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Set<String> cuisineSet = {'All'};
                for (var doc in snapshot.data?.docs ?? []) {
                  final cuisine = doc['cuisine'] ?? 'Restaurant';
                  if (cuisine is String && cuisine.isNotEmpty) {
                    cuisineSet.add(cuisine);
                  }
                }
                _cuisines = cuisineSet.toList()..sort();
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _cuisines.map((cuisine) {
                    final isSelected = _selectedCuisine == cuisine;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cuisine),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCuisine = cuisine);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.deepOrange,
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        side: BorderSide(
                          color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          // Shops List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('vendors')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading shops',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                final allShops = snapshot.data?.docs ?? [];

                // Filter shops
                final filteredShops = allShops.where((shop) {
                  final shopData = shop.data();
                  final shopName = (shopData['shopName'] ?? '').toString().toLowerCase();
                  final cuisine = shopData['cuisine'] ?? 'Restaurant';
                  final query = _searchQuery.toLowerCase();

                  final matchesSearch = shopName.contains(query);
                  final matchesCuisine = _selectedCuisine == 'All' || cuisine == _selectedCuisine;

                  return matchesSearch && matchesCuisine;
                }).toList();

                if (filteredShops.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedCuisine == 'All'
                              ? 'No shops available yet'
                              : 'No shops match your search',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isNotEmpty || _selectedCuisine != 'All')
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _selectedCuisine = 'All';
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Clear Filters',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return _ShopCard(shop: shop);
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

/// Individual Shop Card Widget
class _ShopCard extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopData = shop.data() ?? {};
    final shopId = shop.id;
    final shopName = shopData['shopName'] ?? 'Unknown Shop';
    final description = shopData['description'] ?? '';
    final imageUrl = shopData['imageUrl'] ?? '';
    final cuisine = shopData['cuisine'] ?? 'Restaurant';
    final rating = (shopData['rating'] ?? 0.0).toDouble();
    final isOpen = shopData['isOpen'] ?? true;
    final reviews = (shopData['reviewCount'] ?? 0) as int;

    return GestureDetector(
      onTap: isOpen
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShopMenuScreen(
                    vendorId: shopId,
                    shopName: shopName,
                  ),
                ),
              );
            }
          : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isOpen ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                Icons.store_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Colors.green.shade500
                          : Colors.red.shade500,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Shop Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Text(
                    shopName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Cuisine and Rating Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cuisine,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Star Rating
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviews)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // View Menu Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isOpen
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ShopMenuScreen(
                                    vendorId: shopId,
                                    shopName: shopName,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isOpen ? 'View Menu & Order' : 'Shop Closed',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
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
