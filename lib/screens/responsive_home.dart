import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get device dimension using MediaQuery
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Qless',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      // 2. Use LayoutBuilder for responsive constraints
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isTablet || isLandscape) {
            return _buildWideLayout(context, size);
          } else {
            return _buildMobileLayout(context, size);
          }
        },
      ),
    );
  }

  // Tablet/Wide Layout: Row with Side Panel and Grid
  Widget _buildWideLayout(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel (Header & Actions)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  _buildActionButtons(isRow: true),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Panel (Content Grid)
            Expanded(
              flex: 3,
              child: _buildFeatureGrid(crossAxisCount: 3, childAspectRatio: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            // Use Flexible/Expanded here? Not needed for scroll view, but good for full screen
            LayoutBuilder(
              builder: (ctx, constraints) {
                // Adjust grid based on width even within mobile layout
                int crossCount = constraints.maxWidth > 400 ? 3 : 2;
                return _buildFeatureGrid(
                  crossAxisCount: crossCount,
                  childAspectRatio: 1.0,
                );
              },
            ),
            const SizedBox(height: 20),
            _buildActionButtons(isRow: true),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Qless',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Queue-less ordering for smart vendors.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid({required int crossAxisCount, required double childAspectRatio}) {
    // Determine icons and labels
    final items = [
      {'icon': Icons.qr_code, 'label': 'Scanner'},
      {'icon': Icons.list_alt, 'label': 'Orders'},
      {'icon': Icons.history, 'label': 'History'},
      {'icon': Icons.analytics, 'label': 'Analytics'},
      {'icon': Icons.settings, 'label': 'Settings'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                items[index]['icon'] as IconData,
                size: 32,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 8),
              Text(
                items[index]['label'] as String,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons({required bool isRow}) {
    final buttons = [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('New Order'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan Token'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: Colors.deepOrange,
            side: const BorderSide(color: Colors.deepOrange),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ];

    return Row(children: buttons);
  }
}
