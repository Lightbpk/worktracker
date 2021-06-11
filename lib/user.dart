import 'package:firebase_auth/firebase_auth.dart';

class WTUser{
  String id;

  WTUser.fromFirebase(User user){
    id = user.uid;
  }
}