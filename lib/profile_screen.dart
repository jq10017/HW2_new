import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _newPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: widget.user.email!,
        password: _oldPasswordController.text,
      );
      await widget.user.reauthenticateWithCredential(credential);

      await widget.user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully!')),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Password change failed.';
      if (e.code == 'wrong-password') {
        message = 'Incorrect current password.';
      } else if (e.code == 'weak-password') {
        message = 'Your new password is too weak.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please sign in again before changing password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueAccent,
              child: Text(
                widget.user.email != null && widget.user.email!.isNotEmpty
                    ? widget.user.email![0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.user.email ?? 'No email',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 40),

            // Password Change Section
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your current password'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter a new password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _changePassword,
                          icon: Icon(Icons.lock_reset),
                          label: Text('Update Password'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
