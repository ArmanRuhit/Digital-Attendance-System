import 'package:attendance_management_system/Teacher/attendance_record.dart';
import 'package:attendance_management_system/Teacher/edit_attendance.dart';
import 'package:attendance_management_system/Teacher/take_attendance.dart';
import 'package:attendance_management_system/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherFirst extends StatefulWidget {
  static String id = 'teacher_first';
  @override
  _TeacherFirstState createState() => _TeacherFirstState();
}

class _TeacherFirstState extends State<TeacherFirst> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digital Attendance System"),
        backgroundColor: kAppBarBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWidget(
              buttonLabel: 'Take Attendance',
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, TakeAttendance.id);

                });
              },
            ),
            ButtonWidget(
              buttonLabel: 'Edit Attendance',
              onPressed: (){
                setState(() {
                  Navigator.pushNamed(context, EditAttendance.id);
                });
              },
            ),
            ButtonWidget(
              buttonLabel: 'Attendance Record',
              onPressed: (){
                Navigator.pushNamed(context, AttendanceRecord.id);
              },
            ),
            ButtonWidget(
              buttonLabel: 'Log Out',
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
