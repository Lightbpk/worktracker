 import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/Pages/user-page.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/user.dart';

import 'Pages/auth-page.dart';
import 'Pages/main-page.dart';
import 'Pages/admin-page.dart';


class StartPage extends StatelessWidget{

  @override

  Widget build(BuildContext context) {
    final WTUser userWT = Provider.of<WTUser>(context);
    final bool isLoggedIn = userWT != null;
    if(isLoggedIn){
      String currentRole='not set';
       DataBaseConnector().getMainRef().child("userIDs")
          .child(userWT.id).child('role').once().then((DataSnapshot snapshot) {
            if(snapshot.key == 'role'){
              currentRole = snapshot.value.toString();
              print(currentRole);
            }
       });
         if(currentRole == 'admin'){
           return AdminPage();
         } else {
         print(currentRole);
         return UserPage();
         }
            }
    else return AuthPage(title:'Authentication');
  }
}