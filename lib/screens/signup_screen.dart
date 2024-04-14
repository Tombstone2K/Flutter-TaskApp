//Signup screen with text fields and controllers. SignUp through Firebase

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:taskmgmt/myHomePage.dart';
import '../HiveStruct/TaskStruct.dart';
import '../globalVar.dart';
import '/reusable_widgets/reusable_widget.dart';
import '/utils/color_utils.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email Id", Icons.email_outlined, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () {

                  if (_userNameTextController.text.trim()=="" || _passwordTextController.text.trim()=="" || _emailTextController.text.trim()==""){
                    snackBarMsg(context, "Fields cannot be left empty");
                  }
                  else{
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text)
                        .then((value) async {
                      snackBarMsg(context,"Created New Account");
                      taskBox = await Hive.openBox<TaskStruct>(_emailTextController.text.trim());
                      Future.microtask(() {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Tasky')));
                      });
                    }).onError((error, stackTrace) {
                      snackBarMsg(context,"Error -  ${error.toString().substring(error.toString().indexOf(' ') + 1)}");

                    });
                  }

                })
              ],
            ),
          ))),
    );
  }
}
