import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_profile_screen.dart';
import 'message_boards_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- Change Password ---
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text);
      await user.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Password change failed.';
      if (e.code == 'wrong-password') message = 'Incorrect current password.';
      if (e.code == 'weak-password') message = 'New password too weak.';
      if (e.code == 'requires-recent-login') message = 'Please sign in again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Change Email ---
  Future<void> _changeEmail() async {
    final newEmail = _newEmailController.text.trim();
    if (newEmail.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a new email.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email updated successfully!')));

      _newEmailController.clear();
      _oldPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Email update failed.';
      if (e.code == 'invalid-email') message = 'Invalid email format.';
      if (e.code == 'email-already-in-use') message = 'Email already in use.';
      if (e.code == 'requires-recent-login') message = 'Please sign in again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();

  // Navigate to login screen and remove all previous routes
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
    (route) => false,
  );
}


  void _onMenuSelected(String value) {
    final user = FirebaseAuth.instance.currentUser!;
    if (value == 'home') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MessageBoardsScreen()),
        (route) => false,
      );
    } else if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
      );
    } else if (value == 'logout') {
      _signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Message Boards')),
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newEmailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.email),
                    label: const Text('Update Email (requires current password)'),
                    onPressed: _changeEmail,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter new password';
                      if (v.length < 6) return 'Password must be 6+ characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _changePassword,
                          icon: const Icon(Icons.lock_reset),
                          label: const Text('Update Password'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
