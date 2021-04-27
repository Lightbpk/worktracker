import 'package:firebase_core/firebase_core.dart';

class TakeFirebaseApp {
  static TakeFirebaseApp instance;

  TakeFirebaseApp() {
    init();
  }

  static TakeFirebaseApp getInstance(){
    if(instance == null){
      instance = new TakeFirebaseApp();
    }
  }

  void init() async{
    final FirebaseApp app = await Firebase.initializeApp();
  }
}