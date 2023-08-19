import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//returns list of classes
Future<List<dynamic>> getClasses() async{
  final _firestore = FirebaseFirestore.instance;
  List<dynamic> classes = [];
  var data = await _firestore.collection("classes").get().then((value) => value.docs.map((e) => e['classes']));
  print(data.first.runtimeType);
  classes = data.first;
  return classes;
}

Future<List<dynamic>> getStudentsList(selectedClass) async{
  print("Student list Called");
  final _firestore = FirebaseFirestore.instance;
  List<dynamic> students = [];
  await _firestore.collection('studentList').doc(selectedClass).get().then((value){
    if(value.exists){
      students = value.data()['id'];
      print("Database has students id");
    }
    if(students == null){
      students = [];
    }
  });
  if(students.isEmpty){
    print("returning null");
    return null;
  }
  else {
    print("return list of id");
    return students;
  }
}

List<DropdownMenuItem<dynamic>> getDropDownClasses(data) {
  List<DropdownMenuItem<dynamic>> dropdownItem = [];
  DropdownMenuItem newItem;
  data.forEach((e) =>{
    // print(e),
    newItem = DropdownMenuItem(
      child: Text(e),
      value: e,
    ),
    dropdownItem.add(newItem)
  });
  return dropdownItem;
}
