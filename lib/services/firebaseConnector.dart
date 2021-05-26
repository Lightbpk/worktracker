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
    return _instance;
  }
  void refresh(){
    db = FirebaseDatabase(app: myFirebaseApp)
        .reference();
  }

  Future <List<String>> getStages() async{
    refresh();
    try {
      List<String> stagesList = [];
      refresh();
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
  }
}