import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State <ForgotPasswordPage> createState() =>  ForgotPasswordPageState();
}

class  ForgotPasswordPageState extends State <ForgotPasswordPage> {

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();

  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(context: context, builder: (context){
          return const AlertDialog(
            content: Text('Password Reset Link Sent!! CHECK'),

          );
      },
      );
      } on FirebaseAuthException catch(e){
        print(e);
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: Text(e.message.toString()),

          );
        }) ;    
         }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Text ('Enter Your Email(Password Reset Link will be sent to this Email)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
          ),
          ),
          Padding (
            padding: const EdgeInsets.symmetric(horizontal: 25.20),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),

                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),

                ),
                hintText: 'Email',
                fillColor: Colors.grey[200],
                filled: true,

              ),
            ),
          ),
          const SizedBox(height: 10),

          MaterialButton(
            onPressed: passwordReset,
            color: Colors.deepPurple[200],
            child: const Text('Reset Password'),
             )

        ],

      ),
      
    );
  }
}