import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';

class UserPage extends StatefulWidget{
  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {
bool isLoaded = false;
Widget mainWidget = CircularProgressIndicator();
List<String> contractsList;

@override
  Widget build(BuildContext context) {
  readContractsList();
  if(!isLoaded) return CircularProgressIndicator();
    return Scaffold(
      appBar: AppBar(
        title: new Text("Юзер"),
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
      body: mainWidget,
    );
  }

  Widget _buildContractsList() {
    return ListView.builder(itemBuilder: (context, i) {
      if (i < contractsList.length)
        return ListTile(
          title: Text(contractsList[i]),
          onTap: () {
            print('Taped ' + contractsList[i]);
          },
        );
      else
        return ListTile(
          title: Text("-----------"),
        );
    });
  }

  void readContractsList() async {
    contractsList = await DataBaseConnector().getContracts();
    setState(() {
      mainWidget = _buildContractsList();
      isLoaded = true;
    });
  }
}
