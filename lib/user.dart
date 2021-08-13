import 'package:firebase_auth/firebase_auth.dart';

class WTUser{
  String id;
  String name = 'Имя';
  String surName = 'Фамилия';
  String fatherName = 'Отчество';
  String role = 'not set';

  WTUser(String id){
    this.id = id;
  }

  WTUser.fromFirebase(User user){
    id = user.uid;
  }

  String getFamalyIO(){
    return ""+this.surName+" "+this.name.substring(0,1)+
        '.'+this.fatherName.substring(0,1)+'.';
  }

}