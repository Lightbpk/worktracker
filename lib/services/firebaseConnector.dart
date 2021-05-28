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

  void addProject(String id, String clientName, String deadline) async{
    getMainRef();
    await db.child("work-process").child("contract_$id").set({
      'contractID': id,
      'name': clientName,
      'deadline' : deadline,
    });
  }

}