import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/entities/contract.dart';
import 'package:worktracker/entities/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/entities/task.dart';
import 'package:worktracker/entities/user.dart';

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
  List<String> reworkTypes = [
    'Ошибка КД',
    'Ошибка ЭлектроКД',
    'Ошибка Снабжение',
    'Ошибка Производство',
    'Ошибка Другое'];
  List<String> pauseTypes = [
    'Смена приоритета руководителем',
    'Ожидание согласования',
    'Ожидание комплектации внешн',
    'Ожидание комплектации внутр',
    'Ожидание инструмента',
    'Ожидание доработки – Ошибка КД',
    'Ожидание доработки – Ошибка ЭлектроКД',
    'Ожидание доработки – Ошибка Снабжение',
    'Ожидание доработки – Ошибка Исполнитель',
    'Другое'];

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
          subtitle: Text(subtitleText),
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
              task.status = "inwork";
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
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String currentPauseType = pauseTypes.last;
                    return StatefulBuilder(builder: (context, setState){
                      return AlertDialog(
                        title: new Text('Простой:'),
                        content: DropdownButton(
                          value: currentPauseType,
                          items: makeItems(pauseTypes),
                          onChanged: (newValue){
                            setState(() {
                              currentPauseType = newValue;
                            });
                          },
                        ),
                        actions: <Widget>[
                          TextField(
                            decoration: InputDecoration(hintText: "Комментарий"),
                            onChanged: (text){
                              task.pauseComment = text;
                            },),
                          TextButton(onPressed: (){
                            task.status = "pause";
                            task.pauseType = currentPauseType;
                            DateTime dateTime = DateTime.now();
                            task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                            DataBaseConnector().setTaskStatus(task, currentContract);
                            makeToast(task.status, Colors.red);
                            Navigator.of(context).pop();
                          }, child: Text('ok')),
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: Text('отмена'))
                        ],
                      );
                    });
                  });
            },
            icon: Icon(Icons.pause),
            label: Text('Пауза')),
        TextButton.icon(
            onPressed: () {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    String currentReworkType = reworkTypes.last;
                    return StatefulBuilder(builder: (context, setState){
                      return AlertDialog(
                        title: new Text('Доработка:'),
                        content: DropdownButton(
                          value: currentReworkType,
                          items: makeItems(reworkTypes),
                          onChanged: (newValue){
                            setState(() {
                              currentReworkType = newValue;
                            });
                          },
                        ),
                        actions: <Widget>[
                          TextField(
                            decoration: InputDecoration(hintText: "Комментарий"),
                            onChanged: (text){
                              task.reworkComment = text;
                          },),
                          TextButton(onPressed: (){
                              task.status = "rework";
                              task.reworkType = currentReworkType;
                              DateTime dateTime = DateTime.now();
                              task.lastStatusTime = dateTime.microsecondsSinceEpoch;
                              DataBaseConnector().setTaskStatus(task, currentContract);
                            makeToast(task.status, Colors.yellow);
                            Navigator.of(context).pop();
                          }, child: Text('ok')),
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: Text('отмена'))
                        ],
                      );
                    });
                  });
            },
            icon: Icon(Icons.edit),
            label: Text('Доработка')),
        TextButton.icon(
            onPressed: () {
              this.setState(() {
                isLoaded = true;
                task.status = "done";
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

  List<DropdownMenuItem> makeItems(List<String> typeItems){
    List<DropdownMenuItem> itemsList = List();
    typeItems.forEach((String typeStr) {
      itemsList.add(new DropdownMenuItem(
          child: Text(typeStr),
          value: typeStr,));
    });
    return itemsList;
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
