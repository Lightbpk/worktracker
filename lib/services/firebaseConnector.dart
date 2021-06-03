import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';

class DataBaseConnector {
  DataBaseConnector _instance;
  FirebaseApp myFirebaseApp;
  DatabaseReference db;
  _DataBaseConnector(){}



  DataBaseConnector getConnection(FirebaseApp app){
    myFirebaseApp = app;
    if(_instance == null){
      _instance = DataBaseConnector();
      print('instance - null create instance');
    }
    else print('instance not null');
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
        node.nodeDeadline = value;
        nodesList.add(node);
        print('key : '+key);
        print('value : '+value);
      });
    } );
    return nodesList;
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

  void addProject(String id, String clientName, List<BuildNode> nodeList) async{
    getMainRef();
    await db.child("work-process").child(id).set({
      'contractID': id,
      'name': clientName,
    });
    String string="";
    nodeList.forEach((node) {
      string += node.nodeName+":"+node.field.dateTimeValue.toString()+",";
    });
    db.child("work-process").child(id).child("nodes").set({
      nodeList[0].nodeName :nodeList[0].field.dateTimeValue.toString(),
      nodeList[1].nodeName :nodeList[1].field.dateTimeValue.toString(),
      nodeList[2].nodeName :nodeList[2].field.dateTimeValue.toString(),
      nodeList[3].nodeName :nodeList[3].field.dateTimeValue.toString(),
      nodeList[4].nodeName :nodeList[4].field.dateTimeValue.toString(),
    });
  }
}