import 'package:attendance_management_system/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class StudentFirst extends StatefulWidget {
  static String id = 'student_first';
  @override
  _StudentFirstState createState() => _StudentFirstState();
}

class _StudentFirstState extends State<StudentFirst> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String loggedInUserId;
  int present = 0;
  int absent = 0;
  String name;
  String attendance = '0';
  bool showSpinner = false;
  void getUserNameAndAttendance() async{
    var data = await _firestore.collection('users').doc(loggedInUserId).get();
    if(data.exists && data.data().isNotEmpty){
      setState(() {
        name = data.data()['name'];
        present = data.data()['present'];
        absent = data.data()['absent'];
        if(present+absent != 0){
          attendance = (present/(present+absent)*100).toStringAsFixed(2);
        }
        showSpinner = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loggedInUserId = _auth.currentUser.email.split('@')[0];
    getUserNameAndAttendance();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Attendance System'),
        backgroundColor: kAppBarBackgroundColor,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: (){
                _auth.signOut();
                Navigator.pop(context);
              })
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              name!=null?
              Text('Hello $name', style: kTableTextStyle,):CircularProgressIndicator(),
              if(name!=null)
                Text("Your attendance is $attendance%", style: kTableTextStyle,)
            ],
          ),
        ),
      ),
    );
  }
}
