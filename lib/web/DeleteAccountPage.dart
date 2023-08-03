import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:html' as html;

class DeleteAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // // Get the current URL
    // String currentUrl = html.window.location.href;
    //
    // // Use the current URL as needed
    // print('Current URL: $currentUrl');


    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showDeleteConfirmationDialog(context),
          child: Text('Delete Account'),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not authenticated, show a login dialog
      _showLoginDialog(context);
    } else {
      // User is authenticated, show the delete confirmation dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Account'),
            content: Text('Are you sure you want to delete your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _deleteAccount(context),
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showLoginDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    // Show an error message if either email or password is empty
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter email and password.'),
                    ));
                  } else {
                    // Sign in the user with the provided email and password
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (userCredential.user != null) {
                      // User authenticated successfully, proceed with account deletion
                      Navigator.pop(context); // Close the login dialog
                      _showDeleteConfirmationDialog(context);
                    } else {
                      // Show an error message if authentication fails
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Authentication failed.'),
                      ));
                    }
                  }
                } catch (e) {
                  // Show an error message for any exceptions during authentication
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Authentication failed: ${e.toString()}'),
                  ));
                }
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete the user account
        FirebaseFirestore.instance
            .collection("USER")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete();

        await user.delete();

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Account deleted successfully.'),
        ));
      }
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete account: ${e.toString()}'),
      ));
    }
  }
}
