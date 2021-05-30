import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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

  Future <List<String>> getNodes(String contract) async{
    getMainRef();
    List<String> nodesList = [];
    print('getting nodes for : '+contract);
    await db.child("work-process").child(contract).child('nodes')
        .once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, value){
        nodesList.add(key);
        print('key : '+key);
      });
    } );
    return nodesList;
  }

  Future <List<String>> getContracts() async{
    getMainRef();
    try {
      List<String> contractsList = [];
      DatabaseReference contract1 = db.child("work-process")
          .child("contract_1");
      await db.child("work-process")
          .once()
          .then((DataSnapshot snapshot) {
        snapshot.value.forEach((key, values) {
          contractsList.add(key);
        });
      });
      return contractsList;
    }catch (e){
      print(e);
      return ['---'];
    }
  }

  void addProject(String id, String clientName, List<BuildNode> nodeList) async{
    getMainRef();
    await db.child("work-process").child("contract_$id").set({
      'contractID': id,
      'name': clientName,
    });
    String string="";
    nodeList.forEach((node) {
      string += node.nodeName+":"+node.field.dateTimeValue.toString()+",";
    });
    db.child("work-process").child('contract_$id').child("nodes").set({
      nodeList[0].nodeName :nodeList[0].field.dateTimeValue.toString(),
      nodeList[1].nodeName :nodeList[1].field.dateTimeValue.toString(),
      nodeList[2].nodeName :nodeList[2].field.dateTimeValue.toString(),
      nodeList[3].nodeName :nodeList[3].field.dateTimeValue.toString(),
      nodeList[4].nodeName :nodeList[4].field.dateTimeValue.toString(),
    });
  }
}