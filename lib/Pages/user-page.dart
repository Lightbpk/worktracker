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
  WTUser currentUser;

  UserPage(WTUser user){
    currentUser = user;
    //print('constructed UserPage for User '+user.surName);
  }
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
          title: new Text("Юзер: "+widget.currentUser.getFamalyIO()),
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
          onTap: () async{
            print('Taped ' + contractsList[i].id);
            //isLoaded= false;
            isLoaded = false;
            currentContract = contractsList[i];
            tasksList = await readUserTasks(widget.currentUser.id);
            setState(() {
              mainWidget = _buildTasksList();
              isLoaded = true;
            });
            //readNodes(currentContract.id);
          },
        );
      else
        return ListTile(
          title: Text("-----------"),
        );
    });
  }



  Widget _buildTasksList() {
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
              mainWidget = _buildTaskTail(tasksList[i]);
              isLoaded = true;
            });
          },
        );
      } else if (i == tasksList.length) {
        return ListTile(
          title: Text("Назад"),
          onTap: () {
            setState(() {
              mainWidget = _buildContractsList();
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


  Widget _buildTaskTail(Task task) {
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
                DataBaseConnector().setTaskStatus(task,  currentContract);
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
                DataBaseConnector().setTaskStatus(task, currentContract);
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
                DataBaseConnector().setTaskStatus(task, currentContract);
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
                DataBaseConnector().setTaskStatus(task, currentContract);
              });
              makeToast(task.status, Colors.lightBlue);
            },
            icon: Icon(Icons.stop),
            label: Text('Стоп')),
        Text(task.status),
        Text(task.getLastStatusTimeText()),
        TextButton.icon(
            onPressed: () async{
              tasksList = await readUserTasks(widget.currentUser.id);
              setState(() {
                mainWidget = _buildTasksList();
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

  Future<List<Task>> readUserTasks(String userID) async {
    print("reading tasks for "+userID );
    return
        await DataBaseConnector().getUserTasks(currentContract.id, userID);
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
