import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool passwordObscured = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<UserAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text("Welcome",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text("Create Account to Continue!",
                    style: TextStyle(color: Colors.grey[700], fontSize: 18)),
                const SizedBox(height: 25),
                buildNameField(),
                const SizedBox(height: 20),
                buildEmailField(),
                const SizedBox(height: 20),
                buildPasswordField(),
                const SizedBox(height: 20),
                buildConfirmPasswordField(),
                const SizedBox(height: 30),
                buildRegisterButton(size, authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNameField() => TextFormField(
    controller: _name,
    keyboardType: TextInputType.name,
    validator: (value) => value!.isEmpty || value.length < 3 ? "Enter valid name (min. 3 characters)" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.account_circle),
      hintText: "Username",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget buildEmailField() => TextFormField(
    controller: _email,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      if (value!.isEmpty) return "Please enter your email";
      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+").hasMatch(value)) return "Please enter a valid email";
      return null;
    },
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.mail),
      hintText: "Email",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget buildPasswordField() => TextFormField(
    controller: _password,
    obscureText: passwordObscured,
    validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.vpn_key),
      hintText: "Password",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      suffixIcon: IconButton(
        icon: Icon(passwordObscured ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => passwordObscured = !passwordObscured),
      ),
    ),
  );

  Widget buildConfirmPasswordField() => TextFormField(
    controller: _confirmPassword,
    obscureText: passwordObscured,
    validator: (value) => value != _password.text ? "Passwords don't match" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.vpn_key),
      hintText: "Confirm Password",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      suffixIcon: IconButton(
        icon: Icon(passwordObscured ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => passwordObscured = !passwordObscured),
      ),
    ),
  );

  Widget buildRegisterButton(Size size, UserAuthProvider authProvider) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() => isLoading = true);
          try {
            await authProvider.register(
              _email.text.trim(),
              _password.text.trim(),
              _name.text.trim(),
            );

            Fluttertoast.showToast(msg: "Account created successfully!");
            if (mounted) Navigator.pop(context);
          } catch (e) {
            Fluttertoast.showToast(msg: "Error: ${e.toString()}");
          } finally {
            if (mounted) setState(() => isLoading = false);
          }
        }
      },
      child: Container(
        height: size.height / 14,
        width: size.width / 1.2,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}