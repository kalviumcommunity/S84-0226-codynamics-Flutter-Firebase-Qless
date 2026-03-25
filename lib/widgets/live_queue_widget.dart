import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveQueueWidget extends StatefulWidget {
  const LiveQueueWidget({super.key});

  @override
  State<LiveQueueWidget> createState() => _LiveQueueWidgetState();
}

class _LiveQueueWidgetState extends State<LiveQueueWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink(); // Not logged in
    }

    // Stream for the most recent active order of the current user
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'cooking', 'ready']) // Only active orders
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, orderSnapshot) {
        if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // No active orders
        }

        final orderDoc = orderSnapshot.data!.docs.first;
        final orderData = orderDoc.data() as Map<String, dynamic>;
        
        final String vendorId = orderData['vendorId'] ?? '';
        final int tokenNumber = orderData['tokenNumber'] ?? 0;
        final String tokenString = orderData['token'] ?? '';
        final String status = orderData['status'] ?? 'pending';
        
        if (status == 'ready') {
          return _buildReadyWidget(tokenString);
        }

        // We need today's date string to get the current queue token
        final now = DateTime.now();
        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final queueDocId = "${vendorId}_$todayStr";

        return StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('queue_tokens').doc(queueDocId).snapshots(),
          builder: (context, queueSnapshot) {
            if (!queueSnapshot.hasData || !queueSnapshot.data!.exists) {
              return const SizedBox.shrink();
            }

            final queueData = queueSnapshot.data!.data() as Map<String, dynamic>;
            final int currentServingToken = queueData['currentToken'] ?? 1;

            int peopleAhead = tokenNumber - currentServingToken;
            if (peopleAhead < 0) peopleAhead = 0;
            
            // Re-calculate live ETA
            final int estimatedWaitMins = peopleAhead * 5; 

            return _buildActiveQueueWidget(
              tokenId: tokenString, 
              currentServing: "T${currentServingToken.toString().padLeft(3, '0')}", 
              peopleAhead: peopleAhead, 
              eta: estimatedWaitMins
            );
          },
        );
      },
    );
  }

  Widget _buildReadyWidget(String token) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade500, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order Ready!',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Please collect your order. Token: $token',
                    style: GoogleFonts.poppins(color: Colors.green.shade900, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQueueWidget({
    required String tokenId, 
    required String currentServing, 
    required int peopleAhead, 
    required int eta
  }) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepOrange.shade100, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Token',
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      tokenId,
                      style: GoogleFonts.righteous(fontSize: 24, color: Colors.deepOrange),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Now Serving',
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11),
                      ),
                      Text(
                        currentServing,
                        style: GoogleFonts.righteous(fontSize: 18, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '$peopleAhead people ahead',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(
                      '~$eta mins',
                      style: GoogleFonts.poppins(
                        fontSize: 13, 
                        fontWeight: FontWeight.w600,
                        color: Colors.deepOrange
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: peopleAhead == 0 ? 1.0 : (1.0 / (peopleAhead + 1)), // Mock progress
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}
