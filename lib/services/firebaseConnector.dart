import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/stage.dart';

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
    db.child("work-process").once()
        .then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, values) {
        print("key - $key" );
        print("values - $values" );
      });});

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
        BuildNode node = BuildNode(key);
        Map<dynamic,dynamic> mapValue = Map<dynamic,dynamic>.from(value);
        print("value "+mapValue.toString());
        node.nodeDeadline = mapValue["deadline"];
        nodesList.add(node);
      });
    } );
    return nodesList;
  }

  Future <List<Stage>> getStages(String contract,BuildNode node) async{
    getMainRef();
    List<Stage> stageList = [];
    await db.child("work-process").child(contract).child('nodes')
        .child(node.nodeName).once().then((DataSnapshot snapshot){
          snapshot.value.forEach((key, value){
            if(key!='deadline'){
              stageList.add(Stage(key));
            }else print("deadline skip");
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

  void addProject(String id, String clientName, List<BuildNode> nodeList, List<Stage> stageList) async{
    getMainRef();
    await db.child("work-process").child(id).set({
      'contractID': id,
      'name': clientName,
    });
    //String string="nodeList[0].nodeName :nodeList[0].field.dateTimeValue.toString()";
    nodeList.forEach((node) {
      db.child("work-process").child(id).child("nodes")
          .child(node.nodeName).child("deadline").set(node.field.dateTimeValue.toString());
      stageList.forEach((Stage stage) {
        db.child("work-process").child(id).child("nodes")
            .child(node.nodeName).child(stage.stageName).child("status").set(stage.status);
        db.child("work-process").child(id).child("nodes")
            .child(node.nodeName).child(stage.stageName).child("lastStatusTime").set(stage.lastStatusTime);
      });
    });

  }
}