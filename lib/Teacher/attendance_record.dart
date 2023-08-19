import 'package:attendance_management_system/Teacher/record_by_class.dart';
import 'package:attendance_management_system/Teacher/record_by_id.dart';
import 'package:attendance_management_system/Teacher/record_by_month.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AttendanceRecord extends StatefulWidget {
  static String id = 'attendance_record';
  @override
  _AttendanceRecordState createState() => _AttendanceRecordState();
}

class _AttendanceRecordState extends State<AttendanceRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Attendance System'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                buttonLabel: 'By Id',
                onPressed: (){
                  Navigator.pushNamed(context, RecordById.id);
                },
              ),
              ButtonWidget(
                buttonLabel: 'By Month',
                onPressed: (){
                  Navigator.pushNamed(context, RecordByMonth.id);
                },
              ),
              ButtonWidget(
                buttonLabel: 'By Class',
                onPressed: (){
                  Navigator.pushNamed(context, RecordByClass.id);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
