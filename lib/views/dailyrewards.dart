import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyRewardsScreen extends StatefulWidget {
  @override
  _DailyRewardsScreenState createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> {
  bool _isClaimed = false;

  Future<void> _claimReward() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userEmail);

    try {
      final snapshot = await userDoc.get();
      final data = snapshot.data();

      if (data != null) {
        final lastClaim = (data['lastClaim'] as Timestamp?)?.toDate();

        // Retrieve the server's current time from Firestore
        final serverNowSnapshot = await FirebaseFirestore.instance
            .collection('server_time')
            .doc('current_time')
            .get();
        final serverNow = serverNowSnapshot.data()?['time'] as Timestamp? ?? Timestamp.now();

        // Use the server timestamp for claim logic
        final now = serverNow.toDate();

        // Check if last claim was today (based on server timestamp)
        if (lastClaim != null &&
            lastClaim.year == now.year &&
            lastClaim.month == now.month &&
            lastClaim.day == now.day) {
          _showAlert('Reward already claimed for today!');
          return;
        }

        // Update the user's points and last claim date with server timestamp
        await userDoc.update({
          'points': FieldValue.increment(50),
          'lastClaim': serverNow,
        });

        _showAlert('You\'ve claimed 50 points!');
        setState(() {
          _isClaimed = true;
        });
      }
    } catch (e) {
      print('Error claiming reward: $e');
      _showAlert('Error claiming reward');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Daily Reward'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Rewards')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Claim your daily reward of 50 points!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _claimReward,
              child: Text('Claim Your Reward'),
            ),
          ],
        ),
      ),
    );
  }
}
