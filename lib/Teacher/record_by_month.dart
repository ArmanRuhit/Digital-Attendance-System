import 'package:attendance_management_system/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecordByMonth extends StatefulWidget {
  static String id = 'by_month';
  @override
  _RecordByMonthState createState() => _RecordByMonthState();
}

class _RecordByMonthState extends State<RecordByMonth> {
  String selectedClass = 'Class 1';
  String selectedMonth = months[0];
  bool _searchButtonPressed = false;
  List attendanceData = [];
  bool _hasAttendanceData = false;
  bool showSpinner = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void getAttendanceData()async{
    var data = await _firestore.collection('Attendance').doc(selectedMonth).collection(selectedClass).get();
    if(data.docs.isNotEmpty){
      attendanceData.addAll(data.docs);
      setState(() {
        _hasAttendanceData = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Attendance System'),
        backgroundColor: kAppBarBackgroundColor,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(15),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FutureBuilder(
                        future: getClasses(),
                        builder: (context, snapshot){
                          if(snapshot.data == null){
                            return Text("");
                          }
                          else {
                            return DropdownButton<dynamic>(
                              items: getDropDownClasses(snapshot.data),
                              onChanged: (value){
                                setState(() {
                                  _searchButtonPressed = false;
                                  selectedClass = value;
                                  attendanceData = [];
                                  _hasAttendanceData = false;
                                });
                              },
                              value: selectedClass,
                            );
                          }}
                    ),
                    DropdownButton(
                      value: selectedMonth,
                      items: [
                        for(var month in months)
                          DropdownMenuItem(
                              value: month,
                              child: Text(month)
                          )
                      ],
                      onChanged: (value){
                        print(value);
                        setState(() {
                          _searchButtonPressed = false;
                          selectedMonth = value;
                          attendanceData = [];
                          _hasAttendanceData = false;
                        });
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ButtonWidget(
                  buttonLabel: 'Search',
                  onPressed: ()async{
                    setState(() {
                      showSpinner = true;
                    });
                    attendanceData = [];
                    await getAttendanceData();
                    setState(() {
                      _searchButtonPressed = true;
                      showSpinner = false;
                    });
                    if(!_hasAttendanceData)
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Attention'),
                            content: Text('No Data Found'),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: Text('Ok'))
                            ],
                          ));
                  },
                ),
              ),
              if(_hasAttendanceData == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                          children: [
                            Text(''),
                            Text('Present', style: kTableTextStyle),
                            Text('Absent', style: kTableTextStyle,),
                          ]
                      ),
                      for(var data in attendanceData)
                        TableRow(
                            children: [
                              Text(data['id'], style: kTableTextStyle),
                              Text(data['present'].toString(), style: kTableTextStyle),
                              Text(data['absent'].toString(), style: kTableTextStyle),
                            ]
                        )
                    ],
                  ),
                )
            ],

          ),
        ),
      ),
    );
  }
}
