import 'package:flutter/material.dart';
import '../../widgets/food_loading_indicator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  final String _vendorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Map<int, int> _ordersPerHour = {};
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  double _averageWaitTime = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('vendorId', isEqualTo: _vendorId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      Map<int, int> hourlyData = {};
      double revenue = 0.0;
      int ordersCount = 0;
      int totalWaitTime = 0;
      int completedOrders = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp?;
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final status = data['status'] as String? ?? 'pending';
        
        if (timestamp != null) {
          final orderTime = timestamp.toDate();
          
          hourlyData[orderTime.hour] = (hourlyData[orderTime.hour] ?? 0) + 1;
          revenue += amount;
          ordersCount++;

          if (status == 'completed' || status == 'ready') {
             totalWaitTime += (data['estimatedWaitTime'] as int? ?? 5);
             completedOrders++;
          }
        }
      }

      setState(() {
        _ordersPerHour = hourlyData;
        _totalRevenue = revenue;
        _totalOrders = ordersCount;
        _averageWaitTime = completedOrders > 0 ? (totalWaitTime / completedOrders) : 0.0;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint("Error fetching analytics: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getPeakHour() {
    if (_ordersPerHour.isEmpty) return 'N/A';
    int maxHour = _ordersPerHour.keys.first;
    for (var hour in _ordersPerHour.keys) {
      if (_ordersPerHour[hour]! > _ordersPerHour[maxHour]!) {
        maxHour = hour;
      }
    }
    final dateTime = DateTime(2023, 1, 1, maxHour);
    return DateFormat('h a').format(dateTime);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.righteous(fontSize: 22, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_ordersPerHour.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text("No orders today to display chart.", style: GoogleFonts.poppins()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: (_ordersPerHour.keys.toList()..sort()).map((hour) {
            final int count = _ordersPerHour[hour]!;
            final int maxCount = _ordersPerHour.values.reduce((a, b) => a > b ? a : b);
            final double widthRatio = count / maxCount;
            
            final dateTime = DateTime(2023, 1, 1, hour);
            final hrLabel = DateFormat('ha').format(dateTime);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(hrLabel, style: GoogleFonts.poppins(fontSize: 12)),
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widthRatio,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$count', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading 
        ? const FoodLoadingIndicator(size: 40)
        : RefreshIndicator(
            onRefresh: _fetchAnalyticsData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Today's Overview",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Revenue',
                        value: '₹${_totalRevenue.toStringAsFixed(2)}',
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Orders Today',
                        value: '$_totalOrders',
                        icon: Icons.receipt_long,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Avg Wait Time',
                        value: '~${_averageWaitTime.toStringAsFixed(0)} min',
                        icon: Icons.timer,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Peak Hour',
                        value: _getPeakHour(),
                        icon: Icons.trending_up,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Hourly Order Volume",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildBarChart(),
              ],
            ),
          ),
    );
  }
}