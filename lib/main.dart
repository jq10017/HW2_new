import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'message_boards_screen.dart';
import 'message_board.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Boards App',

      routes: {
        "/cardgames": (context) =>
            const MessageBoard(boardName: "cardGames", title: "Card Games"),
        "/videogames": (context) =>
            const MessageBoard(boardName: "videoGames", title: "Video Games"),
        "/boardgames": (context) =>
            const MessageBoard(boardName: "boardGames", title: "Board Games"),
        "/triviagames": (context) =>
            const MessageBoard(boardName: "triviaGames", title: "Trivia Games"),
      },

      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const MessageBoardsScreen();
        }
        return const LoginRegisterScreen();
      },
    );
  }
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showLogin ? "Login" : "Register"),
        centerTitle: true,
      ),
      body: Center(
        child: showLogin
            ? LoginForm(onSwitch: () => setState(() => showLogin = false))
            : RegisterForm(onSwitch: () => setState(() => showLogin = true)),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const RegisterForm({super.key, required this.onSwitch});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final email = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final role = TextEditingController();

  bool loading = false;
  String errorMessage = "";

  Future<void> registerUser() async {
    try {
      setState(() => loading = true);

      final auth = FirebaseAuth.instance;

      final cred = await auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "firstName": firstName.text.trim(),
        "lastName": lastName.text.trim(),
        "role": role.text.trim(),
        "email": email.text.trim(),
        "avatar": "🙂", // default avatar
        "registeredAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return paddingWrapper(
      Column(
        children: [
          TextField(controller: firstName, decoration: inputStyle("First Name")),
          TextField(controller: lastName, decoration: inputStyle("Last Name")),
          TextField(controller: role, decoration: inputStyle("Role")),
          TextField(controller: email, decoration: inputStyle("Email")),
          TextField(controller: password, decoration: inputStyle("Password"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loading ? null : registerUser,
            child: loading ? const CircularProgressIndicator() : const Text("Register"),
          ),
          const SizedBox(height: 14),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: widget.onSwitch,
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginForm({super.key, required this.onSwitch});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  String errorMessage = "";

  Future<void> loginUser() async {
    try {
      setState(() => loading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return paddingWrapper(
      Column(
        children: [
          TextField(controller: email, decoration: inputStyle("Email")),
          TextField(controller: password, decoration: inputStyle("Password"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loading ? null : loginUser,
            child: loading ? const CircularProgressIndicator() : const Text("Login"),
          ),
          const SizedBox(height: 14),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: widget.onSwitch,
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }
}

InputDecoration inputStyle(String label) {
  return InputDecoration(
    border: const OutlineInputBorder(),
    labelText: label,
  );
}

Widget paddingWrapper(Widget child) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: SingleChildScrollView(child: child),
  );
}
