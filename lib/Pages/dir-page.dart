import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/entities/contract.dart';
import 'package:worktracker/entities/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/data-time-field.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/services/functions.dart';
import 'package:worktracker/services/timer.dart';
import 'package:worktracker/entities/task.dart';
import 'package:worktracker/entities/user.dart';

class DirectorPage extends StatefulWidget {
  WTUser userDir;

  DirectorPage(WTUser userDir) {
    this.userDir = userDir;
  }

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
  List<WTUser> usersList;
  List<String> usersIDList = [];
  List<DropdownMenuItem> userDropMenuItems;
  String status = "status not set";
  String date = "date not set";
  Contract currentContract;
  BuildNode currentNode;
  List<String> dropdownMenuUsers = ['0'];
  String dropdownValue;
  int inc = 1;
  String timeLeft = '';
  String timePassed = '';
  BasicDateTimeField fieldStartTimeTaskPlan;
  BasicDateTimeField fieldEndTaskTimePlan;

  @override
  void initState() {
    super.initState();
    readContractsList();
    readUsers();
    userDropMenuItems = buildUsersDropMenuItems();
    print('init');
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: new Text("Директор: " + widget.userDir.getFamalyIO()),
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
        if (subTitleText == 'null') {
          subTitleText = 'not set deadlin';
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
              if(tasksList[0].taskName == currentNode.nodeName){
                mainWidget = _buildTaskTail(tasksList[0], currentNode);
                isLoaded = true;
              }else {
                mainWidget = _buildTasksList(currentNode);
                isLoaded = true;
              }
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
        String subtitleText = tasksList[i].status +
            " " +
            getUserFioByID(tasksList[i].assignedUserID);
        return ListTile(
          title: Text(tasksList[i].taskName),
          subtitle: Text(subtitleText),
          tileColor: statusColor(tasksList[i].status),
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
    String str = getUserFioByID(task.assignedUserID);
    print('assigned = ' + task.assignedUserID);
    print('str = $str');
    return Column(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Задача: ' + task.taskName, style: TextStyle(fontSize: 20)),
        ],),
        Divider(),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ответственный: $str', textAlign: TextAlign.left,),
            taskStatusWidget(task),
            Text('Начало по плану: ' + task.getStartTimeText()),
            Text('Завершение по плану: ' + task.getEndTimeText()),
            Text('Осталось $timeLeft'),
          ],),
        Divider(),
        Text("Выбор ответственного"),
        usersDropList(task, currentNode),
        Text("указать виновного"),
        guiltyDropList(task, currentNode),
        fieldStartTimeTaskPlan = BasicDateTimeField.dd('Время начала задания',
            DateTime.fromMicrosecondsSinceEpoch(currentNode.nodeDeadline)),
        fieldEndTaskTimePlan = BasicDateTimeField.dd(
            'Запланированное время завершения',
            DateTime.fromMicrosecondsSinceEpoch(currentNode.nodeDeadline)),
        Column(crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton.icon(
                onPressed: () {
                  if (fieldStartTimeTaskPlan != null &&
                      fieldEndTaskTimePlan.dateTimeValue != null) {
                    task.startTimeTaskPlan = fieldStartTimeTaskPlan.getDateTime();
                    task.endTimeTaskPlan = fieldEndTaskTimePlan.getDateTime();
                    DataBaseConnector()
                        .setStartTaskTime(task, currentNode, currentContract);
                    DataBaseConnector()
                        .setEndTaskTime(task, currentNode, currentContract);
                    setState(() {
                      timePassed = WorkTimer(task.lastStatusTime).hhMMssPassed();
                      timeLeft = WorkTimer(task.endTimeTaskPlan).hhMMssLeft();
                      mainWidget = _buildTaskTail(task, currentNode);
                      isLoaded = true;
                    });
                  } else {
                    makeToast('Укажите обе даты', Colors.red);
                  }
                },
                icon: Icon(Icons.set_meal),
                label: Text('установить')),
            TextButton.icon(
                onPressed: () async {
                  setState(() {
                    timePassed = WorkTimer(task.lastStatusTime).hhMMssPassed();
                    timeLeft = WorkTimer(task.endTimeTaskPlan).hhMMssLeft();
                    mainWidget = _buildTaskTail(task, currentNode);
                    isLoaded = true;
                  });
                },
                icon: Icon(Icons.refresh),
                label: Text("Обновить")),
            TextButton.icon(
                onPressed: () async {
                  tasksList = await readTasks(currentNode);
                  setState(() {
                    if(task.parentNodeName == currentContract.id){
                      mainWidget = _buildNodesList();
                      isLoaded = true;
                    }else{
                      mainWidget = _buildTasksList(currentNode);
                      isLoaded = true;
                    }
                  });
                },
                icon: Icon(Icons.arrow_back),
                label: Text("Назад"))
          ],),

      ],
    );
  }

  Widget usersDropList(Task task, BuildNode node) {
    userDropMenuItems = buildUsersDropMenuItems();
    //print("-userDropMenuItems-");
    //print(userDropMenuItems);
    return DropdownButton(
      value: dropdownValue,
      onChanged: (newValue) {
        setState(() {
          dropdownValue = newValue;
            task.assignedUserID = newValue;
            DataBaseConnector().setTaskAssignedUser(
                task, node, currentContract);
            mainWidget = _buildTaskTail(task, currentNode);
        });
      },
      items: userDropMenuItems,
    );
  }
  Widget guiltyDropList(Task task, BuildNode node) {
    userDropMenuItems = buildUsersDropMenuItems();
    //print("-userDropMenuItems-");
    //print(userDropMenuItems);
    return DropdownButton(
      value: dropdownValue,
      onChanged: (newValue) {
        setState(() {
          dropdownValue = newValue;
            task.guiltyUserID = newValue;
            DataBaseConnector().setTaskGuiltyUser(task, node, currentContract);
            mainWidget= _buildTaskTail(task, currentNode);
        });
      },
      items: userDropMenuItems,
    );
  }
  Widget taskStatusWidget(Task task) {
    Widget statusWidget;
    WorkTimer workTimer = new WorkTimer(task.lastStatusTime);
    switch (task.status) {
      case 'inwork':{
        statusWidget = Text('Статус: В Работе ' +workTimer.hhMMssPassed());
        break;
      }
      case 'done':
        statusWidget = Text('Статус: Законченно ' + task.getLastStatusTimeText());
        break;
      case 'rework':
        statusWidget = Column(
          children: [
            Text('Статус: Доработка ' + task.reworkType),
            Text(workTimer.hhMMssPassed()),
            Text('Комментарий: '+task.reworkComment)
          ],
        );
        break;
      case 'pause':
        statusWidget = Column(
          children: [
            Text('Статус: Простой ' + task.pauseType),
            Text(workTimer.hhMMssPassed()),
            Text('Комментарий: '+task.pauseComment)
          ],
        );
        break;
      default :
        statusWidget = Text('not set');
        break;
    }
    return statusWidget;
  }

  void readUsers() async {
    usersList = await DataBaseConnector().getAllUsers();
    usersList.forEach((WTUser user) {
      usersIDList.add(user.id);
      /* usersFIOList.add(user.surName+" "+user.name.substring(0,1)+
         '.'+user.fatherName.substring(0,1)+'.');*/
    });
    dropdownMenuUsers = usersIDList;
    print(usersIDList);
    print('reading Users done');
    dropdownValue = usersIDList.first;
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
    nodesList.sort(sortNodes);
    setState(() {
      mainWidget = _buildNodesList();
      isLoaded = true;
    });
  }

  Future<List<Task>> readTasks(BuildNode node) async {
    return await DataBaseConnector().getTasks(currentContract.id, node);
  }

  int sortNodes(BuildNode a, BuildNode b){
    if(int.parse(a.nodePosition) < int.parse(b.nodePosition)) return -1;
    else if(int.parse(a.nodePosition) > int.parse(b.nodePosition)) return 1;
    else return 0;
  }

  void makeToast(String status, Color color) {
    Fluttertoast.showToast(
        msg: status,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  List<DropdownMenuItem> buildUsersDropMenuItems() {
    List<DropdownMenuItem> items = List();
    if (usersList != null) {
      usersList.forEach((user) {
        DropdownMenuItem item = new DropdownMenuItem(
          child: Text(user.getFamalyIO()),
          value: user.id,
        );
        if (!items.contains(item)) items.add(item);
      });
      if (dropdownValue == null) dropdownValue = usersList.first.id;
      print('---User List---');
      usersList.forEach((element) {
        print(element.getFamalyIO());
      });
      print('--items--');
      items.forEach((element) {
        print(element.child);
        print(element.value);
      });
    } else {
      items.add(DropdownMenuItem(
        child: Text('Загрузка пользователей...'),
        value: '0',
      ));
      dropdownValue = '0';
      print("-items-");
      print(items);
    }
    return items;
  }

  String getUserFioByID(String id) {
    String userFio = 'Не назначен';
    usersList.forEach((user) {
      print("user id " + user.id);
      if (user.id == id) {
        print("get famalyio  " + user.getFamalyIO());
        userFio = user.getFamalyIO();
      }
    });
    return userFio;
  }
}
