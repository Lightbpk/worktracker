 import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/Pages/dir-page.dart';
import 'package:worktracker/Pages/user-page.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/user.dart';

import 'Pages/auth-page.dart';
import 'Pages/admin-page.dart';

 class StartPage extends StatefulWidget {
   @override
   _StartPageState createState() => _StartPageState();
 }


class _StartPageState extends State<StartPage> {
  String currentRole='not set';
  WTUser userWT;
  bool isLoggedIn = false;
  bool roleReading = true;

  @override
  Widget build(BuildContext context) {
    userWT = Provider.of<WTUser>(context);
    bool isLoggedIn = userWT != null;
    readUserRole();
    if(isLoggedIn){
      //print('user not null');
      if(roleReading){
        print('reading Roles...');
        return CircularProgressIndicator();
      }else{
        if(currentRole == 'admin'){
          print('admin logged');
          return AdminPage();
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminPage()));
        }else if(currentRole == 'dir'){
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> DirectorPage()));
          return DirectorPage();
        }
        else {
          print("current role = " +currentRole);
          print("hash role = " +currentRole.hashCode.toString());
          print("hash admin = " + "admin".hashCode.toString());
          return UserPage();
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> UserPage()));
        }
      }
    }
    else return AuthPage(title:'Authentication');
  }
  void readUserRole()async{
    await DataBaseConnector().getMainRef().child("userIDs")
        .child(userWT.id).child('role').once().then((DataSnapshot snapshot) {
      if(snapshot.key == 'role'){
        setState(() {
          currentRole = snapshot.value.toString();
          roleReading = false;
        });
      }
    });
  }
}