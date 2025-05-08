import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/views/auth/forgot_password_page.dart';
import 'package:ecommerce/views/auth/register_page.dart';
import 'package:ecommerce/views/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordObscured = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color scheme
  final Color _primaryColor = Colors.indigo.shade800;
  final Color _secondaryColor = Colors.blueAccent.shade400;
  final Color _accentColor = Colors.white;
  final Color _textColor = Colors.grey.shade800;

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: _textColor),
      validator: (value) {
        if (value!.isEmpty) return ("Please Enter Your Email");
        if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+").hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) => emailController.text = value!,
      textInputAction: TextInputAction.next,
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

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: passwordObscured,
      style: TextStyle(color: _textColor),
      validator: (value) {
        if (value!.isEmpty) return ("Password is required for login");
        if (value.length < 6) return ("Enter Valid Password (Min. 6 Characters)");
        return null;
      },
      onSaved: (value) => passwordController.text = value!,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: _primaryColor),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              passwordObscured = !passwordObscured;
            });
          },
          icon: Icon(
            passwordObscured ? Icons.visibility_off : Icons.visibility,
            color: _primaryColor,
          ),
        ),
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
      ),
    );

    final loginButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: _primaryColor,
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 18),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: isLoading
            ? null
            : () {
          signIn(emailController.text, passwordController.text);
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
          "Login",
          style: TextStyle(
            fontSize: 18,
            color: _accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: _accentColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 150,
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  emailField,
                  SizedBox(height: 20),
                  passwordField,
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: _secondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  loginButton,
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: _secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Continue with",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          handleGoogleSignIn();
                        },
                        icon: Image.asset(
                          'assets/google.png',
                          width: 40,
                          height: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade50,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          Fluttertoast.showToast(
                              msg: "Facebook Login not yet implemented.");
                        },
                        icon: Image.asset(
                          'assets/fbook.png',
                          width: 40,
                          height: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade50,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
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
      ),
    );
  }

  // Email & Password SignIn
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen()));
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // Google SignIn
  Future<void> handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'profilePic': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Fluttertoast.showToast(msg: "Google Sign-In Successful");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Google Sign-In failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }
}