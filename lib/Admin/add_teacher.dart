import 'package:flutter/material.dart';
import 'package:attendance_management_system/button_widget.dart';
import 'package:attendance_management_system/constants.dart';
import 'package:attendance_management_system/methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddTeacher extends StatefulWidget {
  static String id = 'add_teacher';
  @override
  _AddTeacherState createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  String name;
  String id;
  String password;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool showSpinner = false;
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
                  buttonLabel: "Add Teacher",
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
                          'type': 'teacher',
                          'name': name,
                          'id':id
                        }).then((value){
                          print("Teacher added");
                        }).catchError((onError){
                          print(onError);
                        });
                        setState(() {
                          _nameController.clear();
                          _idController.clear();
                          _passwordController.clear();
                          showSpinner = false;
                        });
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Congratulation"),
                              content: Text('Teacher Added Successfully'),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text("Ok"))
                              ],
                            ));
                      }
                    } catch(e) {
                      print(e);
                      setState(() {
                        showSpinner = false;
                        _nameController.clear();
                        _idController.clear();
                        _passwordController.clear();
                      });
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Teacher Add Failed"),
                            content: Text('Please try again'),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.of(context).pop();
                              }, child: Text("Ok"))
                            ],
                          )
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
