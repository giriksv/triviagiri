import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteDialog extends StatefulWidget {
  final String roomId;
  final String category;
  final List<String> invitedUsers; // List of already invited users
  final List<String> currentMembersEmails; // List of current members

  InviteDialog({
    required this.roomId,
    required this.category,
    required this.invitedUsers,
    required this.currentMembersEmails, required String email,
  });

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  bool _isLoading = false; // Loading state for invites
  List<Map<String, dynamic>> _users = []; // List of users to invite
  String inviterEmail = ''; // Variable to store the inviter's email
  String inviterName = ''; // Variable to store the inviter's name
  int maxUsers = 5; // Assuming max users are fixed for the room

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch available users when the dialog initializes
    _fetchInviterDetails(); // Fetch the inviter's email and name
  }

  // Fetch the inviter's email and name from the room's users array
  Future<void> _fetchInviterDetails() async {
    try {
      DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();

      if (roomSnapshot.exists) {
        var users = roomSnapshot['users'] as List;
        if (users.isNotEmpty) {
          inviterEmail = users[0]['email']; // Assuming the inviter's email is at index 0
          inviterName = users[0]['name'] ?? 'Unknown'; // Assuming the inviter's name
          print('Inviter Details fetched: $inviterEmail, $inviterName');
        } else {
          print('No users found in the room.');
        }
      } else {
        print('Room does not exist.');
      }
    } catch (e) {
      print('Error fetching inviter details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch inviter details')),
      );
    }
  }

  // Fetch all users except the current user, already invited users, and current members
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> users = userSnapshot.docs.map((doc) {
        return {
          'email': doc.id, // Assuming email is the document ID
          'name': doc['name'] ?? 'Unknown',
        };
      }).toList();

      // Remove current user, already invited users, and current members
      users.removeWhere((user) =>
      user['email'] == inviterEmail || // Use the fetched inviter email
          widget.invitedUsers.contains(user['email']) ||
          widget.currentMembersEmails.contains(user['email']));

      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users')),
      );
    }
  }

  // Handle sending an invite
  Future<void> _sendInvite(String inviteeEmail, String inviteeName) async {
    print('Room ID: ${widget.roomId}');
    print('Inviter Email: $inviterEmail');
    print('Invitee Email: $inviteeEmail');

    if (widget.roomId.isEmpty || inviterEmail.isEmpty || inviteeEmail.isEmpty) {
      print('Error: One of the required parameters is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Required parameters are missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update the room with the invited user
      await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
        'invitedUsers': FieldValue.arrayUnion([inviteeEmail]),
      });

      // Add notification for the invited user
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(inviteeEmail)
          .collection('userNotifications')
          .add({
        'type': 'invite',
        'senderEmail': inviterEmail,
        'senderName': inviterName,
        'roomId': widget.roomId,
        'category': widget.category,
        'maxUsers': maxUsers,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite sent to $inviteeName')),
      );

      Navigator.pop(context); // Close the dialog after sending the invite
    } catch (e) {
      print('Error sending invite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invite')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Build the invite dialog UI
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Invite'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Text('No users available to invite')
          : Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return ListTile(
              leading: Icon(Icons.person),
              title: Text(user['name']),
              subtitle: Text(user['email']),
              trailing: ElevatedButton(
                onPressed: () {
                  _sendInvite(user['email'], user['name']);
                },
                child: Text('Send Invite'),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
