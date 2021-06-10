import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/task.dart';

class DataBaseConnector {
  DataBaseConnector _instance;
  FirebaseApp myFirebaseApp;
  DatabaseReference db;
  _DataBaseConnector(){}



  DataBaseConnector getConnection(FirebaseApp app){
    myFirebaseApp = app;
    if(_instance == null){
      _instance = DataBaseConnector();
      print('create new instance');
    }
    else print('getting exist instance');
    getMainRef();
    return _instance;
  }

  DatabaseReference getMainRef(){
    db = FirebaseDatabase(app: myFirebaseApp)
        .reference();
    return db;
  }

  Future <List<BuildNode>> getNodes(String contract) async{
    getMainRef();
    List<BuildNode> nodesList = [];
    print('getting nodes for : '+contract);
    await db.child("work-process").child(contract).child('nodes')
        .once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, value){

      /*  BuildNode node = BuildNode(key,1);//!!!!!!!!!!!!!!!  1 временно
        Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
        print("value "+mapValue.toString());
        node.nodeDeadline = mapValue["deadline"];
        nodesList.add(node);*/
      });
    } );
    return nodesList;
  }

  Future <List<Task>> getTasks(String contract,BuildNode node) async{
    getMainRef();
    List<Task> tasksList = [];
    await db.child("work-process").child(contract).child('nodes')
        .child(node.nodeName).once().then((DataSnapshot snapshot){
          snapshot.value.forEach((key, value){
            print("key "+key);
            print("value "+Map<dynamic,dynamic>.from(value).toString());
          });
    } );
  }

  Future <List<Contract>> getContracts() async{
    getMainRef();
    try {
      List<Contract> contractsList = [];
      await db.child("work-process")
          .once()
          .then((DataSnapshot snapshot) {
        snapshot.value.forEach((key, value) {
          Contract currentContract = new Contract(key);
          contractsList.add(currentContract);
          db.child("work-process").child(key).child("name")
              .once().then((DataSnapshot nameSnap){
                currentContract.name =  nameSnap.value;
              });
        });
      });
      return contractsList;
    }catch (e){
      print(e);
      return null;
    }
  }

  void addProject(String id, String clientName, List<BuildNode> nodeList, List<Task> tasksList) async{
    getMainRef();
    await db.child("work-process").child(id).set({
      'contractID': id,
      'name': clientName,
    });
    //String string="nodeList[0].nodeName :nodeList[0].field.dateTimeValue.toString()";
    nodeList.forEach((node) {
      db.child("work-process").child(id).child("nodes")
          .child(node.nodePosition).child("nodeName").set(node.nodeName);
      db.child("work-process").child(id).child("nodes")
          .child(node.nodePosition).child("deadline").set(node.field.dateTimeValue.toString());
    });
    tasksList.forEach((task) {
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("status").set(task.status);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("lastStatusTime").set(task.lastStatusTime);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("parentNodeName").set(task.parentNodeName);
    });
  }
}