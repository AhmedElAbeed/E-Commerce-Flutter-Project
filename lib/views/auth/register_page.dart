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

  // Color scheme
  final Color _primaryColor = Colors.indigo.shade800;
  final Color _secondaryColor = Colors.blueAccent.shade400;
  final Color _accentColor = Colors.white;
  final Color _textColor = Colors.grey.shade800;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<UserAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: TextStyle(color: _primaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _primaryColor),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Create Account to Continue!",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                buildNameField(),
                SizedBox(height: 20),
                buildEmailField(),
                SizedBox(height: 20),
                buildPasswordField(),
                SizedBox(height: 20),
                buildConfirmPasswordField(),
                SizedBox(height: 30),
                buildRegisterButton(size, authProvider),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: _secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
    style: TextStyle(color: _textColor),
    validator: (value) =>
    value!.isEmpty || value.length < 3 ? "Enter valid name (min. 3 characters)" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.account_circle, color: _primaryColor),
      hintText: "Username",
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  );

  Widget buildEmailField() => TextFormField(
    controller: _email,
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(color: _textColor),
    validator: (value) {
      if (value!.isEmpty) return "Please enter your email";
      if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+").hasMatch(value)) {
        return "Please enter a valid email";
      }
      return null;
    },
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.mail, color: _primaryColor),
      hintText: "Email",
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),
  );

  Widget buildPasswordField() => TextFormField(
    controller: _password,
    obscureText: passwordObscured,
    style: TextStyle(color: _textColor),
    validator: (value) =>
    value!.length < 6 ? "Password must be at least 6 characters" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.vpn_key, color: _primaryColor),
      hintText: "Password",
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      suffixIcon: IconButton(
        icon: Icon(
          passwordObscured ? Icons.visibility_off : Icons.visibility,
          color: _primaryColor,
        ),
        onPressed: () => setState(() => passwordObscured = !passwordObscured),
      ),
    ),
  );

  Widget buildConfirmPasswordField() => TextFormField(
    controller: _confirmPassword,
    obscureText: passwordObscured,
    style: TextStyle(color: _textColor),
    validator: (value) => value != _password.text ? "Passwords don't match" : null,
    decoration: InputDecoration(
      prefixIcon: Icon(Icons.vpn_key, color: _primaryColor),
      hintText: "Confirm Password",
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      suffixIcon: IconButton(
        icon: Icon(
          passwordObscured ? Icons.visibility_off : Icons.visibility,
          color: _primaryColor,
        ),
        onPressed: () => setState(() => passwordObscured = !passwordObscured),
      ),
    ),
  );

  Widget buildRegisterButton(Size size, UserAuthProvider authProvider) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: _primaryColor,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 18),
        onPressed: isLoading
            ? null
            : () async {
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
        child: isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: _accentColor,
            strokeWidth: 2,
          ),
        )
            : Text(
          "Sign Up",
          style: TextStyle(
            color: _accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}