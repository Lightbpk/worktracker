import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/start.dart';

import 'entities/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp myFirebaseApp = await Firebase.initializeApp();
  DataBaseConnector().getConnection(myFirebaseApp);
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<WTUser>.value(    //регистреция на прослушку стима
        value: AuthService().currentUser,
        child: MaterialApp(
          title: 'Work Tracker',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: StartPage(),
        ));
  }
}
