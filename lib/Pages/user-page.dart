import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/task.dart';
import 'package:worktracker/user.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoaded = false;
  Widget mainWidget = CircularProgressIndicator();
  List<Contract> contractsList;
  List<BuildNode> nodesList;
  List<Task> tasksList=[];
  String status = "status not set";
  String date = "date not set";
  WTUser currentUser;
  Contract currentContract;
  BuildNode currentNode;



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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: new Text("Пользователь: "+currentUser.surName),
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
            currentContract = contractsList[i];
            readNodes(currentContract.id);
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
        String subTitleText = nodesList[i].getDeadlineText();
        if(subTitleText=='null'){
          subTitleText = ' not set deadline';
        }
        print("subTitle +"+subTitleText);
        return ListTile(
          title: Text(nodesList[i].nodeName),
          subtitle: Text(
              "Deadline " + subTitleText.substring(0, subTitleText.length - 7)),
          // dateTrim без секунд
          onTap: () async{
            currentNode = nodesList[i];
            tasksList = await readUserTasks(currentNode,currentUser.id);
            setState(() {
              mainWidget = _buildTasksList(currentNode);
              isLoaded = true;
            });
            print('Taped ' + nodesList[i].nodeName);
          },
        );
      } else if (i == nodesList.length) {
        return ListTile(
          title: Text("назад"),
          onTap: () {
            setState(() {
              mainWidget = _buildContractsList();
              isLoaded = true;
            });
          },
        );
      } else
        return ListTile(
          title: Text("-----------"),
        );
    });
  }


  Widget _buildTasksList(BuildNode node) {
    return ListView.builder(itemBuilder: (context, i) {
      if (i < tasksList.length) {
        String subtitleText =
            tasksList[i].status + " c " + tasksList[i].getLastStatusTimeText();
        return ListTile(
          title: Text(tasksList[i].taskName),
          subtitle: Text(subtitleText.substring(0, subtitleText.length - 10)),
          onTap: () {
            print('Taped ' + tasksList[i].taskName);
            setState(() {
              mainWidget = _buildTaskTail(tasksList[i], node);
              isLoaded = true;
            });
          },
        );
      } else if (i == tasksList.length) {
        return ListTile(
          title: Text("Назад"),
          onTap: () {
            setState(() {
              mainWidget = _buildNodesList();
              isLoaded = true;
            });
          },
        );
      } else
        return ListTile(
          title: Text('---------'),
        );
    });
  }


  Widget _buildTaskTail(Task task, BuildNode currentNode) {
    print('status = ' + status);
    return Column(
      children: [
        Text(task.taskName),
        TextButton.icon(
            onPressed: () {
              task.status = "В работе";
              this.setState(() {
                print(status);
                DateTime dateTime = DateTime.now();
                task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                DataBaseConnector().setTaskStatus(task, currentNode, currentContract);
              });
              makeToast(task.status, Colors.green);
            },
            icon: Icon(Icons.play_arrow),
            label: Text('Начать')),
        TextButton.icon(
            onPressed: () {
              this.setState(() {
                task.status = 'простой';
                DateTime dateTime = DateTime.now();
                task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                DataBaseConnector().setTaskStatus(task, currentNode, currentContract);
              });
              makeToast(task.status, Colors.red);
            },
            icon: Icon(Icons.pause),
            label: Text('Пауза')),
        TextButton.icon(
            onPressed: () {
              this.setState(() {
                task.status = "доработка";
                DateTime dateTime = DateTime.now();
                task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                DataBaseConnector().setTaskStatus(task, currentNode, currentContract);
              });
              makeToast(task.status, Colors.yellow);
            },
            icon: Icon(Icons.edit),
            label: Text('Доработка')),
        TextButton.icon(
            onPressed: () {
              this.setState(() {
                isLoaded = true;
                task.status = "закончено";
                DateTime dateTime = DateTime.now();
                task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                DataBaseConnector().setTaskStatus(task, currentNode, currentContract);
              });
              makeToast(task.status, Colors.lightBlue);
            },
            icon: Icon(Icons.stop),
            label: Text('Стоп')),
        Text(task.status),
        Text(task.getLastStatusTimeText()),
        TextButton.icon(
            onPressed: () async{
              tasksList = await readUserTasks(currentNode, currentUser.id);
              setState(() {
                mainWidget = _buildTasksList(currentNode);
                isLoaded = true;
              });
            },
            icon: Icon(Icons.arrow_back),
            label: Text("Назад"))
      ],
    );
  }

  void readContractsList() async {
    contractsList = await DataBaseConnector().getContracts();
    setState(() {
      mainWidget = _buildContractsList();
      isLoaded = true;
    });
  }

  void readNodes(String contract) async {
    nodesList = await DataBaseConnector().getNodes(contract);
    setState(() {
      mainWidget = _buildNodesList();
      isLoaded = true;
    });
  }


  Future<List<Task>> readTasks(BuildNode node) async {
    return
        await DataBaseConnector().getTasks(currentContract.id, node);
  }
  Future<List<Task>> readUserTasks(BuildNode node, userID) async {
    return
        await DataBaseConnector().getUserTasks(currentContract.id, node, userID);
  }



  void makeToast(String status, Color color) {
    Fluttertoast.showToast(
        msg: "Установлен Статус " + status,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
