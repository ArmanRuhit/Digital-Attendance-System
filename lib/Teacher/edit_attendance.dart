import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditAttendance extends StatefulWidget {
  static String id = 'edit_attendance';
  @override
  _EditAttendanceState createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var now = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String selectedClass = 'Class 1';
  List<bool> _isPresent = [];
  List<bool> _isPresentCopy = [];
  List<dynamic> studentId = [];

  bool _hasDate = false;
  bool _hasAttendanceData = false;
  bool _searchButtonPressed = false;
  bool showSpinner = false;
  String month;

  void checkDate() async{

    List data = [];
    var data2 = await _firestore.collection('Dates').doc(month).collection(selectedClass).doc(selectedClass).get();
    if(data2.exists && data2.data().isNotEmpty){
      data = data2.data()['dates'];
    }
    if(data.isNotEmpty){
      for(var date in data){
        if(date == now){
        setState(() {
          _hasDate = true;
        });
        break;
        }
      }
      print(_hasDate);
    }
  }

  void getAttendanceData() async{
    List attendanceData = [];
    var data = await _firestore.collection('dateAttendance').doc(selectedClass).collection(now).get();
    if(data.docs.isNotEmpty || data != null){
      data.docs.forEach((element) {
        print(element.data().isEmpty);
        attendanceData.add(element.data());
        studentId.add(element.data()['id']);
        _isPresent.add(element.data()['present'] == 1? true:false);
        setState(() {
          _hasAttendanceData = true;
        });
      });
    }
    print(studentId);
    print(_isPresent);
    _isPresentCopy.addAll(_isPresent);
  }

  void AssignAttendance() async{
    String month = months[int.parse(now.split('-')[1])-1];
    int presentVal;
    int absentVal;
    for(int i = 0; i<studentId.length; i++){
      print(studentId[i]+' '+_isPresent[i].toString()+' '+_isPresentCopy[i].toString());
      if(_isPresent[i] == true && _isPresentCopy[i] == false){
        var data = await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(studentId[i])
            .get();
        if(data.exists && data.data().isNotEmpty){
          absentVal = data.data()['absent'] == 0 ? 0:  data.data()['absent'] - 1;
          presentVal = data.data()['present']+1;
          await _firestore.collection('Attendance').doc(month).collection(selectedClass).doc(studentId[i]).update({
            'present': presentVal,
            'absent': absentVal
          }).then((value) {
            print('Attendance Data Added to Attendance 1');
          });
        }

        var data2 = await _firestore.collection('users').doc(studentId[i]).get();
        if(data2.exists && data2.data().isNotEmpty){
          absentVal = data2.data()['absent'] == 0 ? 0:  data.data()['absent'] - 1;
          presentVal = data2.data()['present']+1;
          await _firestore.collection('users').doc(studentId[i]).update({
            'present':presentVal,
            'absent': absentVal
          }).then((value){
            print('Attendance Data added to user 1');
          });
        }

        await _firestore.collection('dateAttendance').doc(selectedClass).collection(now).doc(studentId[i]).set({
          'id': studentId[i],
          'present': 1,
          'absent': 0
        }).then((value){
          print('Date attendance updated 1');
        });
      }
      else if(_isPresent[i] == false && _isPresentCopy[i] == true){
        var data = await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(studentId[i])
            .get();
        if(data.exists && data.data().isNotEmpty){
          presentVal = data.data()['present'] == 0 ? 0:  data.data()['present'] - 1;
          absentVal = data.data()['absent']+1;
          await _firestore.collection('Attendance').doc(month).collection(selectedClass).doc(studentId[i]).update({
            'present': presentVal,
            'absent': absentVal
          }).then((value) {
            print('Attendance Data Added to Attendance 2');
          });
        }

        var data2 = await _firestore.collection('users').doc(studentId[i]).get();
        if(data2.exists && data2.data().isNotEmpty){
          presentVal = data2.data()['present'] == 0 ? 0:  data.data()['present'] - 1;
          absentVal = data2.data()['absent']+1;
          await _firestore.collection('users').doc(studentId[i]).update({
            'present':presentVal,
            'absent': absentVal
          }).then((value){
            print('Attendance Data added to user 2');
          });
        }

        await _firestore.collection('dateAttendance').doc(selectedClass).collection(now).doc(studentId[i]).set({
          'id': studentId[i],
          'present': 0,
          'absent': 1
        }).then((value) {
          print('Date attendance updated 2');
        });
      }
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text("Today's Date: ",
                  style: TextStyle(
                      fontSize: 20
                  ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text("$now",
                  style: TextStyle(
                      fontSize: 20
                  ),),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder(
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
                                  studentId = [];
                                  _isPresent = [];
                                  _isPresentCopy = [];
                                  _hasDate = false;
                                  _hasAttendanceData = false;
                                  _searchButtonPressed = false;
                                  // _calledCheckDate = false;
                                });
                              },
                              value: selectedClass,
                            );
                          }}
                    ),
                    ButtonWidget(
                      buttonLabel: 'Search',
                      onPressed: () async{
                        studentId = [];
                        _isPresent = [];
                        _isPresentCopy = [];
                        setState(() {
                          showSpinner = true;
                        });
                        month = months[int.parse(now.split('-')[1])-1];
                        await getAttendanceData();
                        setState(() {
                          _searchButtonPressed = true;
                          showSpinner = false;
                        });
                        if(_searchButtonPressed == true && _hasAttendanceData == false)
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Attention'),
                                content: Text('Attendance has not been recorded yet'),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                  }, child: Text('Ok'))
                                ],
                              )
                          );
                      },
                    )
                  ],
                ),
              ),
              if(_hasAttendanceData == true)
                ListView.builder(
                  // scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: studentId.length,
                  itemBuilder: (context, index){
                    return CheckboxListTile(
                        title: Text(studentId[index]),
                        value: _isPresent[index],
                        onChanged: (value){
                          setState(() {
                            _isPresent[index] = value;
                          });
                        });
                  },
                ),

              if(_searchButtonPressed == true && _hasAttendanceData == true)
              ButtonWidget(
                buttonLabel: 'Submit',
                onPressed: _hasAttendanceData == false? null: ()async{
                  setState(() {
                    showSpinner = true;
                  });
                  await AssignAttendance();
                  setState(() {
                    // _calledCheckDate = false;
                    studentId = [];
                    _isPresent = [];
                    _isPresentCopy = [];
                    _searchButtonPressed = false;
                    _hasAttendanceData = false;
                    showSpinner = false;
                  });
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Congratulations'),
                        content: Text('Record Updated Successfully'),
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
        ),
      ),
    );
  }
}
