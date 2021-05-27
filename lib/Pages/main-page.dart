import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:worktracker/main.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({Key key, this.title}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _initialized = false;
  bool _error = false;
  DatabaseReference db;
  List<String> stagesList = ['null', 'null', 'null'];

/*  void readStages() async {
    stagesList = await DataBaseConnector().getStages();
    print(stagesList);
  }*/

  @override
  Widget build(BuildContext context) {
    //readStages();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            TextButton.icon(
                onPressed: () {
                  AuthService().logOut();
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                label: SizedBox.shrink())
          ],
        ),
        body: _buildStageList()); //Text(''),
  }

  Widget _buildStageList() {
      return ListView.builder(itemBuilder: (context, i) {
        if (i < stagesList.length)
          return ListTile(
            title: Text(stagesList[i]),
            onTap: () {
              print('Taped ' + stagesList[i]);
            },
          );
        else
          return ListTile(
            title: Text("----------"),
          );
      });
  }
}
