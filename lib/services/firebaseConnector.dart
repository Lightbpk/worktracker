import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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

/*  Future <List<String>> getStages() async{
    try {
      List<String> stagesList = [];
      DatabaseReference contract1 = db.child("work-process")
          .child("contract_1");
      await contract1
          .child("stages")
          .once()
          .then((DataSnapshot snapshot) {
        snapshot.value.forEach((key, values) {
          stagesList.add(key);
        });
      });
      return stagesList;
    }catch (e){
      print(e);
      return ['---'];
    }
  }*/

  void addProject(String id, String clientName) async{
    getMainRef();
    await db.child("work-process").set({
      'contractID': id,
      'name': clientName,
    });
  }
}