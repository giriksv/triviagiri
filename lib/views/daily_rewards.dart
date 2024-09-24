import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class DailyRewardsScreen extends StatefulWidget {
  @override
  _DailyRewardsScreenState createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> {
  String _waitTimeMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkWaitTime(); // Check wait time when the widget is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  Future<void> _claimReward() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(userEmail);

    try {
      final snapshot = await userDoc.get();
      final data = snapshot.data();

      if (data != null) {
        final lastClaim = (data['lastClaim'] as Timestamp?)?.toDate();

        // Calculate the next claim time
        final now = DateTime.now().toUtc(); // Use UTC for consistency
        final nextClaimTime = lastClaim != null
            ? DateTime(lastClaim.year, lastClaim.month, lastClaim.day + 1)
            : null;

        // Check if the next claim time is before now
        if (nextClaimTime != null && nextClaimTime.isAfter(now)) {
          _showAlert('You need to wait until tomorrow to claim again.');
          return;
        }

        // Update the user's points and set 'lastClaim' to the server's timestamp
        await userDoc.update({
          'points': FieldValue.increment(50),
          'lastClaim': FieldValue.serverTimestamp(), // Use server timestamp
        });

        _showAlert('You\'ve claimed 50 points!');
        setState(() {
          _waitTimeMessage = ''; // Clear wait time message after claiming
        });

        // Re-check the wait time after claiming
        _checkWaitTime();
      }
    } catch (e) {
      print('Error claiming reward: $e');
      _showAlert('Error claiming reward');
    }
  }

  Future<void> _checkWaitTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email;
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(userEmail);

    try {
      final snapshot = await userDoc.get();
      final data = snapshot.data();

      if (data != null) {
        final lastClaim = (data['lastClaim'] as Timestamp?)?.toDate();

        if (lastClaim == null) {
          setState(() {
            _waitTimeMessage = 'You can claim your reward now!';
          });
          return;
        }

        // Calculate the next claim time
        final now = DateTime.now().toUtc(); // Use UTC for consistency
        final nextClaimTime =
            DateTime(lastClaim.year, lastClaim.month, lastClaim.day + 1);

        // Check if the next claim time is before now
        if (nextClaimTime.isAfter(now)) {
          _updateWaitTimeMessage(nextClaimTime);
        } else {
          setState(() {
            _waitTimeMessage = 'You can claim your reward now!';
          });
        }
      }
    } catch (e) {
      print('Error retrieving wait time: $e');
      setState(() {
        _waitTimeMessage = 'Error retrieving wait time.';
      });
    }
  }

  void _updateWaitTimeMessage(DateTime nextClaimTime) {
    // Start the timer to update the wait time message every second
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now().toUtc();
      final difference = nextClaimTime.difference(now);

      if (difference.isNegative) {
        _timer?.cancel(); // Stop the timer if the waiting period is over
        setState(() {
          _waitTimeMessage = 'You can claim your reward now!';
        });
      } else {
        // Format to HH:mm:ss
        final hoursLeft = difference.inHours;
        final minutesLeft = difference.inMinutes % 60;
        final secondsLeft = difference.inSeconds % 60;

        setState(() {
          _waitTimeMessage =
              'Time left: ${hoursLeft.toString().padLeft(2, '0')}:${minutesLeft.toString().padLeft(2, '0')}:${secondsLeft.toString().padLeft(2, '0')}';
        });
      }
    });

    // Update immediately when called
    _updateWaitTimeImmediately(nextClaimTime);
  }

  void _updateWaitTimeImmediately(DateTime nextClaimTime) {
    final now = DateTime.now().toUtc();
    final difference = nextClaimTime.difference(now);
    if (difference.isNegative) {
      setState(() {
        _waitTimeMessage = 'You can claim your reward now!';
      });
    } else {
      // Format to HH:mm:ss
      final hoursLeft = difference.inHours;
      final minutesLeft = difference.inMinutes % 60;
      final secondsLeft = difference.inSeconds % 60;

      setState(() {
        _waitTimeMessage =
            'Time left: ${hoursLeft.toString().padLeft(2, '0')}:${minutesLeft.toString().padLeft(2, '0')}:${secondsLeft.toString().padLeft(2, '0')}';
      });
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
            SizedBox(height: 20),
            // Enhanced UI for wait time message
            Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _waitTimeMessage,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
