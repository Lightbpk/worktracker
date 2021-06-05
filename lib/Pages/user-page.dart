import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/stage.dart';

class UserPage extends StatefulWidget{
  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {
bool isLoaded = false;
Widget mainWidget = CircularProgressIndicator();
List<Contract> contractsList;
List<BuildNode> nodesList;
List<Stage> defStageList = [new Stage("Задача1"),new Stage("Задача2"),new Stage("Задача3")];
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
        title: new Text("Учетка Юзер"),
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
          title: Text(contractsList[i].id),
          subtitle: Text(contractsList[i].name),
          onTap: () {
            print('Taped ' + contractsList[i].id);
            //isLoaded= false;
            isLoaded = false;
            readNodes(contractsList[i].id);
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
      if (i < nodesList.length) {
        String subTitle = nodesList[i].nodeDeadline;
        return ListTile(
          title: Text(nodesList[i].nodeName),
          subtitle: Text("Deadline "+subTitle.substring(0,subTitle.length - 7)),// dateTrim без секунд
          onTap: () {
            setState(() {
              mainWidget = _buildStageList(nodesList[i]);
              isLoaded = true;
            });
            print('Taped ' + nodesList[i].nodeName);
          },
        );
      }
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
  Widget _buildStageList(BuildNode node){
    return ListView.builder(itemBuilder: (context, i){
      if(i < node.stages.length)
        return ListTile(
          title: Text(node.stages[i].stageName),
          subtitle: Text(node.stages[i].status+" c "+node.stages[i].lastStatusTime),
          onTap: () {
            print('Taped ' + node.stages[i].stageName);
            setState(() {
              mainWidget =_buildStageTail(node.stages[i],node);
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

  Widget _buildStageTail(Stage stage,BuildNode currentNode){
    print('status = '+ status);
    return Column(children: [
      Text(stage.stageName),
      TextButton.icon(onPressed: (){
          stage.status = "В работе";
          //status = "В работе";
            this.setState(() {
              print(status);
              DateTime dateTime = DateTime.now();
              stage.lastStatusTime = dateTime.toString();
            });
            makeToast(stage.status, Colors.green);
      },
          icon: Icon(Icons.play_arrow),
          label: Text('Начать')),
      TextButton.icon(onPressed: (){

        this.setState(() {
          stage.status = 'простой';
          DateTime dateTime = DateTime.now();
          stage.lastStatusTime = dateTime.toString();
        });
        makeToast(stage.status, Colors.red);
      },
          icon: Icon(Icons.pause),
          label: Text('Пауза')),
      TextButton.icon(onPressed: (){
        this.setState(() {
          stage.status = "доработка";
          DateTime dateTime = DateTime.now();
          stage.lastStatusTime = dateTime.toString();
        });
        makeToast(stage.status, Colors.yellow);
      },
          icon: Icon(Icons.edit),
          label: Text('Доработка')),
      TextButton.icon(onPressed: (){
        this.setState(() {
          isLoaded = true;
          stage.status = "закончено";
          DateTime dateTime = DateTime.now();
          stage.lastStatusTime = dateTime.toString();
        });
        makeToast(stage.status, Colors.lightBlue);
      },
          icon: Icon(Icons.stop),
          label: Text('Стоп')),
      Text(stage.status),
      Text(stage.lastStatusTime),
      TextButton.icon(onPressed: (){
        setState(() {
          mainWidget =_buildStageList(currentNode);
          isLoaded = true;
        });
      },
          icon: Icon(Icons.arrow_back),
          label: Text("Назад"))
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

  void makeToast(String status, Color color)
  {
    Fluttertoast.showToast(msg: "Установлен Статус "+status,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
