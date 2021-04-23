import 'package:firebase_auth/firebase_auth.dart';

class UserWT{
  String id;

  UserWT.fromFirebase(User user){
    id = user.uid;
  }
}