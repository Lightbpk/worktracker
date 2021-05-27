import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';

class UserPage extends StatefulWidget{
  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {
bool isLoaded =  false;

  @override
  Widget build(BuildContext context) {
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
      body: loader(),
    );
  }

  Widget loader(){
      if(isLoaded){
             return _buildContractsList();
      }
       else {
              return CircularProgressIndicator();
      }
  }

  Widget _buildContractsList() {
    List<String> contractsList = ['-','-'];
    readContractsList().then((value) => contractsList = value);
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

  Future<List<String>> readContractsList() async {
    List<String> contractList = await DataBaseConnector().getContracts();
    isLoaded = true;
    return contractList;
  }
}
