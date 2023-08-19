import 'package:attendance_management_system/Admin/remove_id.dart';
import 'package:attendance_management_system/Student/first_screen.dart';
import 'package:attendance_management_system/Teacher/attendance_record.dart';
import 'package:attendance_management_system/Teacher/edit_attendance.dart';
import 'package:attendance_management_system/Teacher/first_screen.dart';
import 'package:attendance_management_system/Teacher/record_by_class.dart';
import 'package:attendance_management_system/Teacher/record_by_id.dart';
import 'package:attendance_management_system/Teacher/record_by_month.dart';
import 'package:attendance_management_system/Teacher/take_attendance.dart';
import 'package:attendance_management_system/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'package:attendance_management_system/Admin/first_screen.dart';
import 'package:attendance_management_system/Admin/add_student.dart';
import 'package:attendance_management_system/Admin/add_teacher.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        AdminFirst.id: (context) => AdminFirst(),
        AddStudents.id: (context) => AddStudents(),
        AddTeacher.id: (context) => AddTeacher(),
        TeacherFirst.id: (context) => TeacherFirst(),
        TakeAttendance.id: (context) => TakeAttendance(),
        EditAttendance.id: (context) => EditAttendance(),
        AttendanceRecord.id: (context) => AttendanceRecord(),
        RecordById.id: (context) => RecordById(),
        RecordByMonth.id: (context) => RecordByMonth(),
        RecordByClass.id: (context) => RecordByClass(),
        StudentFirst.id: (context) => StudentFirst(),
        SplashScreen.id: (context) => SplashScreen(),
        RemoveUser.id: (context) => RemoveUser(),
      },
    );
  }
}
