import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecordById extends StatefulWidget {
  static String id = 'by_id';
  @override
  _RecordByIdState createState() => _RecordByIdState();
}

class _RecordByIdState extends State<RecordById> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedClass = 'Class 1';
  List<dynamic> studentId = [];
  List<dynamic> presentId = [];
  List<dynamic> absentId = [];
  List attendanceRecord = [];
  bool _searchButtonPressed = false;
  String id;
  List monthData = [];
  bool showSpinner = false;
  TextEditingController _idController = TextEditingController();
  void getAttendance() async{
    for(var month in months){
      var data = await _firestore.collection('Attendance').doc(month).collection(selectedClass).doc(id).get();
      print(month);
      if(!data.exists || data.data().isEmpty){
        print('$month has no data');
      } else{
        // print(data.data());
        monthData.add(month);
        attendanceRecord.add(data.data());
      }
      print(monthData);
      print(attendanceRecord);
    }
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digital Attendance System"),
        backgroundColor: kAppBarBackgroundColor,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: FutureBuilder(
                      future: getClasses(),
                      builder: (context, snapshot){
                        if(snapshot.data == null){
                          return Text("Error");
                        }
                        else {
                          return DropdownButton<dynamic>(
                            items: getDropDownClasses(snapshot.data),
                            onChanged: (value){
                              setState(() {
                                selectedClass = value;
                              });
                            },
                            value: selectedClass,
                          );
                        }}
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _idController,
                    onChanged: (value){
                      id = value;
                    },
                    decoration: kTextDecoration.copyWith(
                      hintText: 'Enter Id'
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ButtonWidget(
                    buttonLabel: 'Search',
                    onPressed: () async{
                      setState(() {
                        showSpinner = true;
                      });
                      attendanceRecord = [];
                      monthData = [];
                      await getAttendance();
                      setState(() {
                        _idController.clear();
                        _searchButtonPressed = true;
                        showSpinner = false;
                      });
                      if(_searchButtonPressed && monthData.isEmpty)
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Attention'),
                              content: Text('Data Not Found'),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text('Ok'))
                              ],
                            ));
                    },
                  ),
                ),
                if(_searchButtonPressed && monthData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Text(""),
                          Text("Present", style: TextStyle(
                            fontSize: 20
                          ),),
                          Text("Absent", style: TextStyle(
                              fontSize: 20
                          ),),
                        ]
                      ),
                      for(int i = 0; i<monthData.length;i++)
                        TableRow(
                          children: [
                            Text(monthData[i], style: TextStyle(
                                fontSize: 20
                            ),),
                            Text(attendanceRecord[i]['present'].toString(), style: TextStyle(
                                fontSize: 20
                            ),),
                            Text(attendanceRecord[i]['absent'].toString(), style: TextStyle(
                                fontSize: 20
                            ),),
                          ]
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
