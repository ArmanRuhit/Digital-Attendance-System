import 'package:attendance_management_system/Student/first_screen.dart';
import 'package:attendance_management_system/Teacher/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_management_system/Admin/first_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String selectedUser;
  bool showSpinner = false;
  String email;
  String password;
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Attendance System'),
        backgroundColor: Color(0xFFF66900),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _idController,
                onChanged: (value){
                  print(value);
                  email = '$value@email.com';
                },
                decoration: kTextDecoration.copyWith(
                    hintText: 'Enter your ID'
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (value){
                  password = value;
                },
                decoration: kTextDecoration.copyWith(
                    hintText: 'Enter your password'
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Color(0xFFF66900),
                    padding: EdgeInsets.all(8.0),
                  ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.orangeAccent;
                            else
                              return null;
                          }
                      )
                  ),
                  onPressed: () async{
                    setState(() {
                      showSpinner = true;
                    });
                    try{
                      print(email+" "+password);
                      final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                      if(user!=null){
                        String type;
                        await _firestore.collection('users').where('email', isEqualTo: '$email')
                              .get().then((value) {

                                Iterable<String> data = value.docs.map((e) {
                                  return e['type'].toString();
                                });
                                type = data.first;
                                // print(data);
                          });
                        if(type == 'admin'){
                          Navigator.pushNamed(context, AdminFirst.id);
                        }
                        else if(type == 'teacher'){
                          Navigator.pushNamed(context, TeacherFirst.id);
                        }
                        else if(type == 'student'){
                          Navigator.pushNamed(context, StudentFirst.id);
                        }
                          setState(() {
                            showSpinner = false;
                          });
                      }
                    } catch(e){
                          print(e);
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Login Unsuccesfull'),
                                content: Text('Please try again'),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                      child: Text("Ok")),
                                ],
                              ));
                          setState(() {
                            showSpinner = false;
                          });
                    }
                    setState(() {
                      _idController.clear();
                      _passwordController.clear();
                    });
                  },
                  child: Text("Log In")
              )
            ],
          ),
        )
      )
    );
  }
}
