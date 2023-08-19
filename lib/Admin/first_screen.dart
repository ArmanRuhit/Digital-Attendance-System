import 'package:attendance_management_system/Admin/remove_id.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_student.dart';
import 'add_teacher.dart';

class AdminFirst extends StatefulWidget {
  static String id = 'admin_first';
  @override
  _AdminFirstState createState() => _AdminFirstState();
}

class _AdminFirstState extends State<AdminFirst> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User loggedInUser;
  String name;
  void getCurrentUser(){
    final user = _auth.currentUser;
    if(user!=null){
      loggedInUser = user;
      name = loggedInUser.email.split("@")[0];
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $name"),
        backgroundColor: kAppBarBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              buttonLabel: 'Add Student',
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, AddStudents.id);
                });
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            ButtonWidget(
              buttonLabel: 'Add Teacher',
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, AddTeacher.id);
                });
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            ButtonWidget(
              buttonLabel: 'Remove Teacher/Student',
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, RemoveUser.id);
                });
              },
            ),
            SizedBox(
              height: 15.0,
            ),
            ButtonWidget(
              buttonLabel: 'Log out',
              onPressed: (){
                setState(() {
                  _auth.signOut();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
