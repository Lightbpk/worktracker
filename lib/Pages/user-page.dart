import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:worktracker/node.dart';
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
List<BuildNode> nodesList;
List<String> defStageList = ['задача 1','задача2','задача3'];
String status="";
String date="";

@override
void initState() {
    readContractsList();
    print('init');
    super.initState();
  }

@override
  Widget build(BuildContext context) {
  if (!isLoaded) {
    return CircularProgressIndicator();
  }
  else {
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
}

  Widget _buildContractsList() {
    return ListView.builder(itemBuilder: (context, i) {
      if (i < contractsList.length)
        return ListTile(
          title: Text(contractsList[i]),
          onTap: () {
            print('Taped ' + contractsList[i]);
            //isLoaded= false;
            isLoaded = false;
            readNodes(contractsList[i]);
          },
        );
      else
        return ListTile(
          title: Text("-----------"),
        );
    });
  }
  Widget _buildNodesList() {
    return ListView.builder(itemBuilder: (context, i) {
      if (i < nodesList.length)
        return ListTile(
          title: Text(nodesList[i].nodeName),
          subtitle: Text(nodesList[i].nodeDeadline),
          onTap: () {
            setState(() {
              mainWidget =_buildStageList();
              isLoaded = true;
            });
            print('Taped ' + nodesList[i].nodeName);
          },
        );
      else if(i == nodesList.length){
        return ListTile(
          title: Text("назад"),
          onTap: (){
            setState(() {
              mainWidget =_buildContractsList();
              isLoaded = true;
            });
          },
        );
      }
      else
        return ListTile(
          title: Text("-----------"),
        );
    });
  }
  Widget _buildStageList(){
    return ListView.builder(itemBuilder: (context, i){
      if(i < defStageList.length)
        return ListTile(
          title: Text(defStageList[i]),
          onTap: () {
            print('Taped ' + defStageList[i]);
            setState(() {
              mainWidget =_buildStage(defStageList[i]);
              isLoaded = true;
            });
          },
        );
      else if(i == defStageList.length){
        return ListTile(
          title: Text("Назад"),
          onTap: (){
            setState(() {
              mainWidget =_buildNodesList();
              isLoaded = true;
            });
          },
        );
      }
      else
        return ListTile(
          title: Text('---------'),
        );
    });
  }

  Widget _buildStage(String stageName){
    print('status = '+ status);
    return Column(children: [
      Text(stageName),
      TextButton.icon(onPressed: (){
          status = "В работе";
          print(status);
          DateTime dateTime = DateTime.now();
          date = dateTime.toString();
setState(() {

});
      }, icon: Icon(Icons.play_arrow), label: Text('Начать')),
      TextButton.icon(onPressed: (){
        setState(() {
          status = 'простой';
          DateTime dateTime = DateTime.now();
          date = dateTime.toString();
        });
      }, icon: Icon(Icons.pause), label: Text('Пауза')),
      TextButton.icon(onPressed: (){
        setState(() {
          status = "доработка";
          DateTime dateTime = DateTime.now();
          date = dateTime.toString();
        });
      }, icon: Icon(Icons.edit), label: Text('Доработка')),
      TextButton.icon(onPressed: (){
        setState(() {
          status = "закончено";
          DateTime dateTime = DateTime.now();
          date = dateTime.toString();
        });
      }, icon: Icon(Icons.stop), label: Text('Стоп')),
      Text(status),
      Text(date),
      TextButton.icon(onPressed: (){
        setState(() {
          mainWidget =_buildStageList();
          isLoaded = true;
        });
      }, icon: Icon(Icons.arrow_back), label: Text("Назад"))
    ],);
  }

  void readNodes(String contract) async{
    nodesList = await DataBaseConnector().getNodes(contract);
    setState(() {
      mainWidget =_buildNodesList();
      isLoaded = true;
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
