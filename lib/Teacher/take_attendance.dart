import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class TakeAttendance extends StatefulWidget {
  static String id = 'take_attendance';
  @override
  _TakeAttendanceState createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends State<TakeAttendance> {
  String selectedClass = 'Class 1';
  List<bool> _isPresent = [];
  List<dynamic> studentId = [];
  List<dynamic> presentId = [];
  List<dynamic> absentId = [];
  var now = DateFormat('dd-MM-yyyy').format(DateTime.now());
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String month = ;
  bool _hasDate = false;
  bool showSpinner = false;
  void AssignAttendance() async{
    int present = 0, absent = 0, index = 0;
    for(var status in _isPresent){
      if(status == true){
        presentId.add(studentId[index]);
      } else{
        absentId.add(studentId[index]);
      }
      index++;
    }
    // print(presentId);
    // print(absentId);
    //add date
    print(months[int.parse(now.split('-')[1])-1]);
    String month = months[int.parse(now.split('-')[1])-1];
    List<dynamic> data;
    await _firestore.collection('Dates').doc(month).collection(selectedClass).doc(selectedClass).get().then((value){
      if(!value.exists){
        data = null;
        print('$month has no data');
      }
      else{
        data = value.data()['dates'];
        print(data.runtimeType);
      }
    });
    if(data == null) {
      await _firestore.collection('Dates').doc(month).collection(selectedClass).doc(selectedClass).set({
        'dates': [now]
      });
    } else{
      for(var date in data){
        // print(date);
        print(date == now);
        if(date == now){
          print('Date is already in database2');
          _hasDate = true;
          break;
        }
        else{
          _hasDate = false;
        }
      }
      if(!_hasDate){
        data.add(now);
        await _firestore.collection('Dates').doc(month).collection(selectedClass).doc(selectedClass).set({
          'dates': data
        });
      }
    }
    //add present
    // print('Printing Present Id');
    // print(presentId);
    for(var presentData in presentId) {
      // print("hello");
      print(presentData);
      int presentVal;
      var data2 = await _firestore.collection('Attendance').doc(month)
          .collection(selectedClass).doc(presentData)
          .get();
      if (!data2.exists || data2.data().isEmpty) {
        await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(presentData).set({
          'id':presentData,
          'present': 1,
          'absent': 0
        });
      } else{
        presentVal = data2.data()['present']+1;
        await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(presentData).update({
          'present': presentVal
        });
        print(presentVal);
      }

      var data3 = await _firestore.collection('users').doc(presentData).get();
      if(data3.exists){
        presentVal = data3.data()['present']+1;
        await _firestore.collection('users').doc(presentData).update({
          'present': presentVal
        });
      }

      await _firestore.collection('dateAttendance').doc(selectedClass).collection(now).doc(presentData).set({
        'id': presentData,
        'present': 1,
        'absent': 0
      });
    }

    //add absent
    for(var absentData in absentId) {
      // print("hello");
      print(absentData);
      int absentVal;
      var data2 = await _firestore.collection('Attendance').doc(month)
          .collection(selectedClass).doc(absentData)
          .get();
      if (!data2.exists || data2.data().isEmpty) {
        await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(absentData).set({
          'id':absentData,
          'present': 0,
          'absent': 1
        });
      } else{
        absentVal = data2.data()['absent']+1;
        await _firestore.collection('Attendance').doc(month)
            .collection(selectedClass).doc(absentData).update({
          'absent': absentVal
        });
        print(absentVal);
      }

      var data3 = await _firestore.collection('users').doc(absentData).get();
      if(data3.exists){
        absentVal = data3.data()['absent']+1;
        await _firestore.collection('users').doc(absentData).update({
          'absent': absentVal
        });
      }
      await _firestore.collection('dateAttendance').doc(selectedClass).collection(now).doc(absentData).set({
        'id': absentData,
        'present': 0,
        'absent': 1
      });
    }
    //add attendance

    setState(() {
      _hasDate = true;
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                // scrollDirection: Axis.vertical,
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                                      _hasDate = false;

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
                            setState(() {
                              showSpinner = true;
                            });
                            print('Search button has been pressed');
                            List<dynamic> dates;
                            var dates1 = await _firestore.collection('Dates').doc(months[int.parse(now.split('-')[1])-1]).collection(selectedClass).doc(selectedClass).get();
                            print(dates1.exists);
                            if(dates1.exists && dates1.data().isNotEmpty){
                              print('dates1 has data');
                              dates = dates1.data()['dates'];
                              print("hello22");
                              for(var date in dates){
                                // print(date);
                                print(date == now);
                                if(date == now){
                                  print('Date is already in database');
                                  setState(() {
                                    _hasDate = true;
                                    print(_hasDate);
                                  });
                                  break;
                                }
                              }
                            }
                            if(!_hasDate){
                              var data = await _firestore.collection("studentList").doc(selectedClass).get();

                              if(!data.exists || data.data()['id'].isEmpty) {
                                print("No Students here");
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("Failed"),
                                      content: Text('Student Not Added yet'),
                                      actions: [
                                        TextButton(onPressed: (){
                                          Navigator.of(context).pop();
                                        }, child: Text("Ok"))
                                      ],
                                    ));
                              }
                              else{
                                setState(() {
                                  studentId = data.data()['id'];
                                  studentId.sort();
                                  _isPresent = List.filled(studentId.length, false);
                                  print(_isPresent[0]);
                                });
                              }
                            }
                            setState(() {
                              showSpinner = false;
                            });
                            if(_hasDate)
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Attention"),
                                    content: Text('Attendance has already been recorded'),
                                    actions: [
                                      TextButton(onPressed: (){
                                        Navigator.of(context).pop();
                                      }, child: Text("Ok"))
                                    ],
                                  ));
                            _hasDate = false;
                          },
                        ),

                      ],
                    ),
                  ),

                  studentId.isNotEmpty && !_hasDate==true?
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
                    ):Text(''),
                  if(_hasDate == false && studentId.isNotEmpty)
                  ButtonWidget(
                    buttonLabel: 'Submit',
                    onPressed: _hasDate == true ?null:() async{
                      setState(() {
                        showSpinner = true;
                      });
                      await AssignAttendance();
                      setState(() {
                        studentId = [];
                        presentId = [];
                        absentId = [];
                        showSpinner = false;

                      });
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Congratulations"),
                              content: Text('Attendance Recorded Successfully'),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text("Ok"))
                              ],
                            ));
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
