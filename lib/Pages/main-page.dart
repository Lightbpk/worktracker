import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<String> stagesList;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      WidgetsFlutterBinding.ensureInitialized();
      FirebaseApp app = await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        db = new FirebaseDatabase(app: app).reference();
        db
            .child("work-process")
            .child("contract_1")
            .child("stages")
            .once()
            .then((DataSnapshot snapshot) {
          snapshot.value.forEach((key, values) {
            stagesList.add(key);
          });
        });
        print('FirebaseApp Init - Ok');
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
        print('FirebaseApp Init - false');
      });
    }
  }

  @override
  void initState() {
    //initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: _buildStageList()
    );//Text(''),
  }

  Widget _buildStageList() {
    return ListView.builder(itemBuilder: (context, i) {
      if (i.isOdd) return Divider();
      else

        return ListTile(
          title: Text("stage ..."),
        );
    });
  }
}
