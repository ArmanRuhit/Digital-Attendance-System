import 'package:attendance_management_system/constants.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecordByClass extends StatefulWidget {
  static String id = 'by_class';
  @override
  _RecordByClassState createState() => _RecordByClassState();
}

class _RecordByClassState extends State<RecordByClass> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedClass = 'Class 1';
  List studentId = [];
  List present = [];
  List absent = [];
  bool _searchButtonPressed = false;
  bool showSpinner = false;
  bool _hasAttendanceData = false;
  void getAttendaceData() async{
    var data = await _firestore.collection('users').where('class', isEqualTo: selectedClass).get();
    data.docs.forEach((element) {
      element.data().forEach((key, value) {
        if(key == 'id'){
          studentId.add(value);
        } else if(key == 'present'){
          present.add(value);
        } else if(key == 'absent'){
          absent.add(value);
        }
      });
      setState(() {
        _hasAttendanceData = true;
      });
    });
    print(studentId);
    print(present);
    print(absent);

  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Digital Attendance System'),
          backgroundColor: kAppBarBackgroundColor,
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(15),
            shrinkWrap: true,
            children: [
              Row(
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
                                // _searchButtonPressed = false;
                                selectedClass = value;
                                studentId = [];
                                present = [];
                                absent = [];
                                _hasAttendanceData = false;
                              });
                            },
                            value: selectedClass,
                          );
                        }}
                  ),
                  ButtonWidget(
                    buttonLabel: 'Search',
                    onPressed: () async{
                      setState(() {
                        showSpinner = true;
                        _searchButtonPressed = true;
                        studentId = [];
                        present = [];
                        absent = [];
                      });
                      await getAttendaceData();
                      setState(() {
                        showSpinner = false;
                      });
                      if(studentId.isEmpty)
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
                  )
                ],
              ),
              if(_searchButtonPressed == true && studentId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(.8),
                      1: FlexColumnWidth(.7),
                      2: FlexColumnWidth(.7)
                    },
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Text('', style: kTableTextStyle,),
                          Text('present', style: kTableTextStyle,),
                          Text('absent', style: kTableTextStyle,),
                          Text('percentage', style: kTableTextStyle,),
                        ]
                      ),
                      for(int i = 0; i<studentId.length; i++)
                        TableRow(
                          children: [
                            Text(studentId[i], style: kTableTextStyle,),
                            Text(present[i].toString(), style: kTableTextStyle,),
                            Text(absent[i].toString(), style: kTableTextStyle,),
                            Text(((present[i])/(present[i]+absent[i])*100).toStringAsFixed(2), style: kTableTextStyle,)
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
