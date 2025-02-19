import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login.dart';
import 'update_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profile;

  @override
  void initState() {
    super.initState();
    _profile = ApiService().getProfile();
  }

  // Method to delete profile
  void _deleteProfile(Map<String, dynamic> user) async {
    try {
      await ApiService().deleteProfile(user['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile deleted successfully')),
      );

      // Redirect to login screen after deleting profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete profile')),
      );
    }
  }

  // Method to go to update profile screen
  void _goToUpdateProfile(Map<String, dynamic> user) async {
    // Wait for the result from UpdateProfileScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(user),
      ),
    );

    // If the result is true (indicating a successful update), refresh the profile data
    if (result == true) {
      setState(() {
        _profile = ApiService().getProfile(); 
      });
    }
  }

  // Method to log out and redirect to login screen
  void _logout() async {
    // You can clear any stored authentication data here (like token)
    await ApiService()
        .logout(); // Assuming you have a logout method in ApiService

    // Redirect to login screen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No profile data'));
        }

        var user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Center(child: Text('Profile')), // Centering the profile text
            actions: [
              // Logout button in the app bar
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _logout, // Logout when clicked
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Add "User Information" heading
                    Center(
                      child: Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Display name in one card
                    _buildUserCard('Name', user['name']),
                    // Display email in another card
                    _buildUserCard('Email', user['email']),

                    SizedBox(height: 20),
                    // Button to go to update page
                    ElevatedButton(
                      onPressed: () => _goToUpdateProfile(user),
                      child: Text('Update Profile'),
                    ),
                    SizedBox(height: 20),
                    // Button to delete profile
                    ElevatedButton(
                      onPressed: () => _deleteProfile(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Button background color
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: Text('Delete Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function to build user information card
  Widget _buildUserCard(String title, String value) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
