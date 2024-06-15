import 'package:flutter_app/models/api_response.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  void _registerUser() async {
    ApiResponse response = await register(
        nameController.text, emailController.text, passwordController.text);
    if (response.error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registered successfully!')));
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      passwordConfirmController.clear();
      _saveAndRedirectTologin();
    } else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
    setState(() {
      loading = false;
    });
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }

  void _saveAndRedirectTologin() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()), (route) => false);
  }

  Widget kLoginRegisterHint(String hint, String text, Function onPressed,
      {IconData? icon, Color? color}) {
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: RichText(
        text: TextSpan(
          text: hint,
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            if (icon != null) // Add the icon if provided
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget kTextButton(String text, Function onPressed,
      {IconData? icon, Color? color}) {
    return TextButton(
      onPressed: onPressed as void Function()?,
      style: TextButton.styleFrom(
        primary: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: color),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.green)), // Set border color to green
              ),
              child: TextFormField(
                controller: nameController,
                validator: (val) => val!.isEmpty ? 'Invalid name' : null,
                decoration: InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person,
                      color: Colors.green), // Add icon to the left
                  border: InputBorder.none, // Hide the default border
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.green)), // Set border color to green
              ),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val!.isEmpty ? 'Invalid email address' : null,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email,
                      color: Colors.green), // Add icon to the left
                  border: InputBorder.none, // Hide the default border
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.green)), // Set border color to green
              ),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Required at least 6 chars' : null,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock,
                      color: Colors.green), // Add icon to the left
                  border: InputBorder.none, // Hide the default border
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.green)), // Set border color to green
              ),
              child: TextFormField(
                controller: passwordConfirmController,
                obscureText: true,
                validator: (val) => val != passwordController.text
                    ? 'Confirm password does not match'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock,
                      color: Colors.green), // Add icon to the left
                  border: InputBorder.none, // Hide the default border
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : kTextButton(
                    'Register',
                    () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        _registerUser();
                      }
                    },
                    icon: Icons.person_add, // Add the icon here
                    color: Colors.green, // Add the color here
                  ),
            SizedBox(
              height: 20,
            ),
            kLoginRegisterHint(
              '',
              'Login',
              () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              },
              icon: Icons.login, // Add the icon here
              color: Colors.green, // Add the color here
            ),
          ],
        ),
      ),
    );
  }
}
