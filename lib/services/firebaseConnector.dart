import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:worktracker/main.dart';

class TakeFirebaseApp {
  FirebaseApp app1 = FirebaseApp.app();
  static TakeFirebaseApp instance;
  DatabaseReference db;
  List<String> stagesList;
  


  TakeFirebaseApp(){

  }

  static TakeFirebaseApp getInstance(FirebaseApp app){
    if(instance == null){
      instance = new TakeFirebaseApp();
    }
    return instance;
  }

  String getDataSting(){
    db
        .child("work-process")
        .child("contract_1")
        .child("stages")
        .once()
        .then((DataSnapshot snapshot) {
      return  snapshot.value ;
    });
  }
}