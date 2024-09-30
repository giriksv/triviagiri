import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../utils/categoryutils.dart';
import 'waiting_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  final String email;
  final int maxUsers;

  CreateRoomScreen({required this.email, required this.maxUsers});

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  String? _selectedCategory;
  String? _userName;
  int? _maxUsers;
  String? _roomId; // Room ID to be generated

  final List<String> _categories = CategoryUtils.categories;
  final List<int> _maxUsersOptions = [2, 3, 4];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch the user's name from Firestore
  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          _userName = userSnapshot['name'];
        });
      }
    } catch (e) {
      // Handle any errors
      print('Error fetching user name: $e');
    }
  }

  // Create a room with the specified details
  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      _roomId = _generateRoomCode(); // Generate room ID

      try {
        // Initialize room and add the current user with roomPoints 0
        await FirebaseFirestore.instance.collection('rooms').doc(_roomId).set({
          'roomName': _roomNameController.text,
          'maxUsers': _maxUsers,
          'category': _selectedCategory,
          'users': [
            {
              'email': widget.email,
              'name': _userName ?? 'Unknown',
              'roomPoints': 0, // Initialize roomPoints for the user
            }
          ],
          'invitedUsers': [], // Initialize invited users array
        });

        // Navigate to the WaitingScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingScreen(
              roomName: _roomNameController.text,
              roomId: _roomId!, // Pass the roomId
              members: [
                {
                  'email': widget.email,
                  'name': _userName ?? 'Unknown',
                  'roomPoints': 0,
                }
              ],
              maxUsers: _maxUsers!, email: '',
            ),
          ),
        );
      } catch (e) {
        // Handle Firestore errors
        print('Error creating room: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: $e')),
        );
      }
    }
  }

  // Generate a unique room code
  String _generateRoomCode() {
    return (Random().nextInt(9000000) + 1000000).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: InputDecoration(labelText: 'Room Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _maxUsers,
                hint: Text("Select Max Users"),
                items: _maxUsersOptions.map((int max) {
                  return DropdownMenuItem<int>(
                    value: max,
                    child: Text(max.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _maxUsers = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select max users';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text("Select Category"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRoom,
                child: Text("Create Room"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}