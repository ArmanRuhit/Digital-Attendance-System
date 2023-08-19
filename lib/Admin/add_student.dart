import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddStudents extends StatefulWidget {
  static String id = 'add_students';

  @override
  _AddStudentsState createState() => _AddStudentsState();
}

class _AddStudentsState extends State<AddStudents> {
  List<String> classes = [];
  String name;
  String id;
  String password;
  String selectedClass = "Class 1";
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool showSpinner = false;


  // void getCls() async{
  //   classes = await getClasses();
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCls();
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
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
              horizontal: 24.0
            ),

            children: [
              TextField(
                controller: _nameController,
                onChanged: (value){
                  name = value;
                },
                decoration: kTextDecoration.copyWith(
                    hintText: 'Name'
                ),
              ),
              TextField(
                controller: _idController,
                onChanged: (value){
                  id = value;
                },
                decoration: kTextDecoration.copyWith(
                    hintText: 'ID'
                ),
              ),
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
                            });
                          },
                          value: selectedClass,
                      );
                    }}
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (value){
                  password = value;
                },
                decoration: kTextDecoration.copyWith(
                    hintText: 'Password'
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: ButtonWidget(
                  buttonLabel: "Add",
                  onPressed: () async{
                    setState(() {
                      showSpinner = true;
                    });
                    try{
                      final user = await _auth.createUserWithEmailAndPassword(
                          email: '$id@email.com',
                          password: password);
                      if(user!=null){
                          await _firestore.collection("users").doc(id).set({
                            'email': '$id@email.com',
                            'type': 'student',
                            'name': name,
                            'class': selectedClass,
                            'id':id,
                            'present': 0,
                            'absent': 0
                          }).then((value){
                            print("Student added");
                          }).catchError((onError){
                            print(onError);
                          });
                          List studentId = await getStudentsList(selectedClass);
                          if(studentId == null || studentId.isEmpty){
                            await _firestore.collection("studentList").doc(selectedClass).set({
                              'id':[id]
                            }).then((value){
                              print("Added new student to new class");});
                          } else{
                            studentId.add(id);
                            await _firestore.collection("studentList").doc(selectedClass).set({
                              'id':studentId
                            }).then((value){
                              print("Added new student");
                            });
                          }
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Congratulation"),
                                content: Text('Student Added Successfully'),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                  }, child: Text("Ok"))
                                ],
                              ));
                      }
                      setState(() {
                        _nameController.clear();
                        _idController.clear();
                        _passwordController.clear();
                        showSpinner = false;
                      });
                    } catch(e) {
                          print(e);
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Add Student Failed"),
                                content: Text('Please try again'),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                  }, child: Text("Ok"))
                                ],
                              ));
                          setState(() {
                            _idController.clear();
                            _passwordController.clear();
                            _nameController.clear();
                            showSpinner = false;
                          });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
