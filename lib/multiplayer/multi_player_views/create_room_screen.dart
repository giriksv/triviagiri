import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../utils/background_color_utils.dart';
import '../../utils/categoryutils.dart';
import '../../utils/custom_app_bar.dart';
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
  int? _maxUsers; // Store max users selected
  String? _userName;
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
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _maxUsers != null) {
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
              maxUsers: _maxUsers!,
              email: '',
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
    } else {
      // If the form is not valid, display a snackbar or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

  // Generate a unique room code
  String _generateRoomCode() {
    return (Random().nextInt(9000000) + 1000000).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(), // Use the custom AppBar
      backgroundColor: BackgroundColorUtils.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Added to make it scrollable on smaller screens
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Room",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 26),
                // Room Name Label and TextField
                Text(
                  "Room Name",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Room Name TextField styled
                TextFormField(
                  controller: _roomNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Room Name',
                    hintStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Curved edges
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Set background to white
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter room name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Max Users Dropdown styled
                Text(
                  "Select Max Users",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Max Users Dropdown Button
                DropdownButtonFormField<int>(
                  hint: Text(
                    "Select Maximum Users",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  value: _maxUsers,
                  items: _maxUsersOptions.map((int max) {
                    return DropdownMenuItem<int>(

                      value: max,
                      child: Text(
                        max.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
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
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 20),
                // Category Dropdown styled as a button
                Text(
                  "Select Category",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text(
                    "Select Category",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
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
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // Set background to white
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Curved edges
                      borderSide: BorderSide(color: Colors.black54),
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 30),
                // Create Room Button
                SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    onPressed: _createRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C2F54), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30), // Curved edges
                      ),
                      padding:
                      EdgeInsets.symmetric(vertical: 16), // Button height
                    ),
                    child: Text(
                      "Create Room",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
