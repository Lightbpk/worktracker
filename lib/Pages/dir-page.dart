import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/contract.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/task.dart';
import 'package:worktracker/user.dart';

class DirectorPage extends StatefulWidget {
  @override
  _DirectorPageState createState() => _DirectorPageState();
}

class _DirectorPageState extends State<DirectorPage> {
  bool isLoaded = false;
  bool isLoadedUserList = false;
  Widget mainWidget = CircularProgressIndicator();
  List<Contract> contractsList;
  List<BuildNode> nodesList;
  List<Task> tasksList = [];
  List<WTUser> usersList = [];
  List<String> usersFIOList = [];
  String status = "status not set";
  String date = "date not set";
  Contract currentContract;
  BuildNode currentNode;
  List<String> dropdownMenuUsers = ['Иванов','Петров','Сидиоров','Работягов','Леньтяйко'];
  String dropdownValue = 'Иванов';
  int inc = 1;

  @override
  void initState() {
    super.initState();
    readContractsList();
    readUsers();
    print('init');
  }

  @override
  Widget build(BuildContext context) {
    //print('MAINWIDGET = '+ mainWidget.toString());
    if (!isLoaded) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: new Text("Учетка Директора"),
          actions: <Widget>[
            TextButton.icon(
                onPressed: () {
                  AuthService().logOut();
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                label: SizedBox.shrink()),
            Text('$inc'),
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
        String subTitleText = nodesList[i].nodeDeadline;
        if (subTitleText == 'null') {
          subTitleText = ' not set deadline';
        }
        print("subTitle +" + subTitleText);
        return ListTile(
          title: Text(nodesList[i].nodeName),
          subtitle: Text(
              "Deadline " + subTitleText.substring(0, subTitleText.length - 7)),
          // dateTrim без секунд
          onTap: () async {
            currentNode = nodesList[i];
            tasksList = await readTasks(currentNode);
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
            tasksList[i].status + " c " + tasksList[i].lastStatusTime;
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
      //readUsers();
      print('status = ' + status);
      return Column(
        children: [
          Text(task.taskName),
          Text('Ответственный ' + dropdownValue),
          Text(task.status),
          Text(task.lastStatusTime),
          usersDropList(task,currentNode),
          TextButton.icon(
              onPressed: () async {
                tasksList = await readTasks(currentNode);
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

  Widget usersDropList(Task task,BuildNode node){
    return DropdownButton(
      value: dropdownValue,
      onChanged: (newValue){
        setState(() {
          dropdownValue= newValue;
          mainWidget = _buildTaskTail(task, currentNode);
        });
      },
      items: dropdownMenuUsers.map(
        (String selectedUser){
          return DropdownMenuItem(
              child: new Text(selectedUser),
              value: selectedUser,
          );
        }
    ).toList(),
    );
  }

  void readUsers() async{
    usersList = await DataBaseConnector().getAllUsers();
    usersList.forEach((WTUser user) {
     usersFIOList.add(user.surName+" "+user.name.substring(0,1)+'.'+user.fatherName.substring(0,1)+'.');
     // usersFIOList.add(user.surName);
    });
    dropdownMenuUsers = usersFIOList;
    print(usersFIOList);
    print('reading Users done');
    dropdownValue= usersFIOList.first;
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
    return await DataBaseConnector().getTasks(currentContract.id, node);
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
