import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/task.dart';
import 'package:worktracker/user.dart';

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
  
  void addUID(String id,String surName, String name, String fatherName){
    getMainRef().child("userIDs").child(id).child("role").set("not set");
    getMainRef().child("userIDs").child(id).child("surName").set(surName);
    getMainRef().child("userIDs").child(id).child("name").set(name);
    getMainRef().child("userIDs").child(id).child("fatherName").set(fatherName);
  }

  Future <WTUser> getUserByID(String id) async{
    //print('getting user for id '+id);
    getMainRef();
    WTUser user;
    await db.child("userIDs").once().then((DataSnapshot snapshot){
      snapshot.value.forEach((key, value){
        if(key == id){
          user =new WTUser(id);
          Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
          user.name = mapValue['name'];
          user.surName = mapValue['surName'];
          user.fatherName = mapValue['fatherName'];
          user.role = mapValue['role'];
        }
      });
    });

    return user;
  }

  Future <List<WTUser>> getAllUsers() async{
    getMainRef();
    List<WTUser> userList = [];
    await  db.child("userIDs").once().then((DataSnapshot snapshot){
      snapshot.value.forEach((key, value){
        WTUser wtUser = new WTUser(key);
        Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
        wtUser.name = mapValue['name'];
        wtUser.surName = mapValue['surName'];
        wtUser.fatherName = mapValue['fatherName'];
        wtUser.role = mapValue['role'];
        userList.add(wtUser);
        print("Getting user "+ wtUser.id);
        print("name user "+ wtUser.name);
        print("surname user "+ wtUser.surName);
        print("fathername user "+ wtUser.fatherName);
      });
    });
    return userList;
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

  Future <List<BuildNode>> getNodes(String contract) async{
    getMainRef();
    List<BuildNode> nodesList = [];
    print('getting nodes for : '+contract);
    await db.child("work-process").child(contract).child('nodes')
        .once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, value){
        Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
        BuildNode node = BuildNode(mapValue["nodeName"],key);
        node.nodeDeadline = mapValue["deadline"];
        nodesList.add(node);
        /*
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
    await db.child("work-process").child(contract).child('tasks')
        .once().then((DataSnapshot snapshot){
          snapshot.value.forEach((key, value){
            Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
            if(mapValue["parentNodeName"]==node.nodeName){
              Task task = new Task(key, node.nodeName);
              task.status = mapValue["status"];
              task.lastStatusTime = mapValue["lastStatusTime"];
              task.assignedUserID = mapValue["assignedUser"];
              task.startTimeTaskPlan = mapValue["startTimeTaskPlan"];
              task.endTimeTaskPlan = mapValue["endTimeTaskPlan"];
              tasksList.add(task);
              print("taskName = "+key);
              print("nodeName = "+node.nodeName);
            }
          });
    } );
    return tasksList;
  }

  Future <List<Task>> getUserTasks(String contract,  String userID) async{
    getMainRef();
    List<Task> tasksList = [];
    await db.child("work-process").child(contract).child('tasks')
        .once().then((DataSnapshot snapshot) {
          snapshot.value.forEach((key, value){
            Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
            if(mapValue['assignedUser'] == userID){
              Task task = new Task(key, mapValue["parentNodeName"]);
              task.status = mapValue["status"];
              task.lastStatusTime = mapValue["lastStatusTime"];
              task.assignedUserID = mapValue["assignedUser"];
              task.startTimeTaskPlan = mapValue["startTimeTaskPlan"];
              task.endTimeTaskPlan = mapValue["endTimeTaskPlan"];
              tasksList.add(task);
            }
          });
    });
    return tasksList;
  }

   void addProject(String id, String clientName, List<BuildNode> nodeList, List<Task> tasksList) async{
    getMainRef();
    await db.child("work-process").child(id).set({
      'contractID': id,
      'name': clientName,
    });
    //String string="nodeList[0].nodeName :nodeList[0].field.dateTimeValue.toString()";
    nodeList.forEach((node) {
      if(node.checked) {
        db.child("work-process").child(id).child("nodes")
            .child(node.nodePosition).child("nodeName").set(node.nodeName);
        if (node.field.dateTimeValue != null) {
          db.child("work-process").child(id).child("nodes")
              .child(node.nodePosition).child("deadline").set(
              node.field.dateTimeValue.microsecondsSinceEpoch);
        } else {
          db.child("work-process").child(id).child("nodes")
              .child(node.nodePosition).child("deadline").set(
              0);
        }
      }
    });
    tasksList.forEach((task) {
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("status").set(task.status);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("lastStatusTime").set(task.lastStatusTime);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("assignedUser").set(task.assignedUserID);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("parentNodeName").set(task.parentNodeName);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("startTimeTaskPlan").set(task.startTimeTaskPlan);
      db.child("work-process").child(id).child("tasks")
          .child(task.taskName).child("endTimeTaskPlan").set(task.endTimeTaskPlan);
    });
  }
  void setTaskStatus(Task task, Contract contract) async{
    getMainRef();
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("status").set(task.status);
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("lastStatusTime").set(task.lastStatusTime);
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("reworkType").set(task.reworkType);
  }
  void setTaskAssignedUser(Task task, BuildNode node, Contract contract) async{
    getMainRef();
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("assignedUser").set(task.assignedUserID);
  }
  void setStartTaskTime(Task task, BuildNode node, Contract contract) async{
    getMainRef();
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("startTimeTaskPlan").set(task.startTimeTaskPlan);
  }
  void setEndTaskTime(Task task, BuildNode node, Contract contract) async{
    getMainRef();
    await db.child("work-process").child(contract.id).child("tasks")
        .child(task.taskName).child("endTimeTaskPlan").set(task.endTimeTaskPlan);
  }
}