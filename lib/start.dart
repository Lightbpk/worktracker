 import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/Pages/dir-page.dart';
import 'package:worktracker/Pages/user-page.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/entities/user.dart';

import 'Pages/auth-page.dart';
import 'Pages/admin-page.dart';

 class StartPage extends StatefulWidget {
   @override
   _StartPageState createState() => _StartPageState();
 }


class _StartPageState extends State<StartPage> {
  String currentRole='not set';
  WTUser loggedUserOnlyID, loggedUserMeta;
  bool isLoggedIn = false;
  bool roleReading = true;


  @override
  Widget build(BuildContext context) {
    loggedUserOnlyID = Provider.of<WTUser>(context);
    bool isLoggedIn = loggedUserOnlyID != null;
    readUserRole();
    if(isLoggedIn){
      //print('user not null');
      if(roleReading){
        print('reading Roles...');
        return Center(child: CircularProgressIndicator(),);
      }else{
        if(currentRole == 'admin'){
          //print('admin logged');
          return AdminPage(loggedUserMeta);
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminPage()));
        }else if(currentRole == 'dir'){
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> DirectorPage()));
          return DirectorPage(loggedUserMeta);
        }
        else {
          return UserPage(loggedUserMeta);
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> UserPage()));
        }
      }
    }
    else return AuthPage(title:'Authentication');
  }
  void readUserRole()async{
    loggedUserMeta = await DataBaseConnector().getUserByID(loggedUserOnlyID.id);
    //print("tempuser "+loggedUserMeta.surName);
        setState(() {
          loggedUserOnlyID = loggedUserMeta;
          currentRole = loggedUserMeta.role;
          roleReading = false;
        });
      }
}