import 'package:flutter/material.dart';
import 'api_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  UpdateProfileScreen(this.user);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isUpdating = false;
  bool _isPasswordUpdate = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['name'];
    _emailController.text = widget.user['email'];
  }

  void _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    String name = _nameController.text;
    String email = _emailController.text;

    String? oldPassword = _oldPasswordController.text.isNotEmpty
        ? _oldPasswordController.text
        : null;
    String? newPassword = _newPasswordController.text.isNotEmpty
        ? _newPasswordController.text
        : null;
    String? confirmNewPassword = _confirmNewPasswordController.text.isNotEmpty
        ? _confirmNewPasswordController.text
        : null;

    if (_isPasswordUpdate) {
      if (newPassword?.trim() != confirmNewPassword?.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New password and confirmation do not match'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUpdating = false;
        });
        return;
      }

      if (oldPassword == null || oldPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Old password is required'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUpdating = false;
        });
        return;
      }
    }

    try {
      await ApiService().updateUser(
        widget.user['id'],
        name,
        email,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword, // Pass the confirmation here
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            Text(
              'Update Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SwitchListTile(
              title: Text("Change Password"),
              value: _isPasswordUpdate,
              onChanged: (value) {
                setState(() {
                  _isPasswordUpdate = value;
                });
              },
            ),
            if (_isPasswordUpdate) ...[
              TextField(
                obscureText: !_isOldPasswordVisible,
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: !_isNewPasswordVisible,
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: !_isConfirmNewPasswordVisible,
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmNewPasswordVisible =
                            !_isConfirmNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            _isUpdating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Update'),
                  ),
          ],
        ),
      ),
    );
  }
}
