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
  String deeplevel = '';
  bool isLoaded = false;
  bool isLoadedUserList = false;
  Widget mainWidget = CircularProgressIndicator();
  List<Contract> contractsList;
  List<BuildNode> nodesList;
  List<Task> tasksList = [];
  List<WTUser> usersList;
  List<String> usersIDList = [];
  List<DropdownMenuItem> userDropMenuItems;
  Task currentTask;
  String status = "status not set";
  String date = "date not set";
  Contract currentContract;
  BuildNode currentNode;
  List<String> dropdownMenuUsers = ['0'];
  String dropdownAssignValue,dropDownGuiltyValue;
  String dirComment;
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
          leading:
            TextButton.icon(
              onPressed: (){
                back();
              },
              icon: Icon(Icons.arrow_back,color: Colors.white,),
              label: SizedBox.shrink(),
            ),
          title: new Text("Директор: " + widget.userDir.getFamalyIO(), style: TextStyle(fontSize: 13),),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () {
                AuthService().logOut();
                },
              icon: Icon(Icons.exit_to_app,color: Colors.white,),
              label: SizedBox.shrink()),
            TextButton.icon(
                onPressed: (){
                  refresh();
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: SizedBox.shrink(),
            )
          ],
        ),
        body:
          mainWidget,
      );
    }
  }

  Widget _buildContractsList() {
    deeplevel ='contractList';
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
    deeplevel = 'nodeList';
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
    deeplevel = 'taskList';
    return ListView.builder(itemBuilder: (context, i) {
//  ------------------------------------------------------
    //Tail bar status + user
      if (i < tasksList.length) {
        String subtitleText = tasksList[i].status +
            " " +
            getUserFioByID(tasksList[i].assignedUserID);
        //==================================================
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
    currentTask = task;
    print('status = ' + status);
    String str = getUserFioByID(task.assignedUserID);
    print('assigned = ' + task.assignedUserID);
    deeplevel = "taskContent";
    print(deeplevel);
    return new GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
    child:Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Задача: ' + task.taskName , style: TextStyle(fontSize: 20)),
            Text(' Статус '+task.statusText()),
        ],),
        Divider(),
         taskContentWidget(task),
        Column(crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(children: [
              TextButton.icon(
                  onPressed: () {
                    mainWidget = Column(
                      children: [
                        fieldStartTimeTaskPlan = BasicDateTimeField.dd('Время начала задания',
                            DateTime.fromMicrosecondsSinceEpoch(currentNode.nodeDeadline)),
                        fieldEndTaskTimePlan = BasicDateTimeField.dd(
                            'Запланированное время завершения',
                            DateTime.fromMicrosecondsSinceEpoch(currentNode.nodeDeadline)),
                        TextButton.icon(label: Text("Установить"), onPressed: (){
                          isLoaded = true;
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
                        }, icon: Icon(Icons.access_alarms))
                      ],
                    );
                  },
                  icon: Icon(Icons.set_meal),
                  label: Text('Установки времени')),
            ],),
          ],),

      ],
    ),);
  }

  Widget usersDropList(Task task, BuildNode node) {
    userDropMenuItems = buildUsersDropMenuItems();
    //print("-userDropMenuItems-");
    //print(userDropMenuItems);
    return DropdownButton(
      value: dropdownAssignValue,
      onChanged: (newValue) {
        setState(() {
          dropdownAssignValue = newValue;
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
    return DropdownButton(
      value: dropDownGuiltyValue,
      onChanged: (newValue) {
        setState(() {
          dropDownGuiltyValue = newValue;
            task.guiltyUserID = newValue;
            DataBaseConnector().setTaskGuiltyUser(task, node, currentContract);
            mainWidget= _buildTaskTail(task, currentNode);
            isLoaded = true;
        });
      },
      items: userDropMenuItems,
    );
  }
  Widget taskContentWidget(Task task) {
    Widget statusWidget;

    switch (task.status) {
      case 'inwork':{
        statusWidget = inWorkWidget(task);
        break;
      }
      case 'done':
        statusWidget = doneWidget(task);
        break;
      case 'rework':
        //print(task.taskFullInfo());
        statusWidget = reWorkPauseWidget(task,false);
        break;
      case 'pause':
        statusWidget = reWorkPauseWidget(task,true);
        break;
      default :
        statusWidget =  notSetWidget(task);
        break;
    }
    return statusWidget;
  }
  Widget inWorkWidget(Task task){
    WorkTimer workTimerPassedTime = new WorkTimer(task.lastStatusTime);
    WorkTimer workTimerLeftTime = new WorkTimer(task.endTimeTaskPlan);
    String userFamalyIO = getUserFioByID(task.assignedUserID);
    return Column(
      children: [
        Row(children: [
          Text("Исполнитель : "),
          TextButton(onPressed: (){
            setState(() {
              mainWidget = usersDropList(task, currentNode);
              isLoaded = true;
            });
          }, child: Text("$userFamalyIO", style: TextStyle(fontSize: 21, color: Colors.blue),))
        ],),
        Row(children: [
          Text('В процессе '),
          Text(' '+workTimerPassedTime.hhMMssPassed()),
        ],),
        Row(children: [
          Text('Осталось '),
          Text(''+workTimerLeftTime.hhMMssLeft()),
        ],),
        Row(children: [
          Text('Завершение по плану: ' + task.getEndTimeText()),
        ],),
      ],
    );
  }
  Widget doneWidget(Task task){
    String userFamalyIO = getUserFioByID(task.assignedUserID);
    return Column(children: [
      Row(children: [
        Text("Исполнитель : "),
        TextButton(
            onPressed: (){},
            child: Text("$userFamalyIO", style: TextStyle(fontSize: 21),))
      ],),
      Text('Завершено: '+ task.getLastStatusTimeText()),
      Text('Завершение по плану: ' + task.getEndTimeText()),
    ],);
    //Text('Статус: Законченно ' + task.getLastStatusTimeText());
  }
  Widget reWorkPauseWidget(Task task, bool pause){
    String strStatus;
    String strType;
    if(pause){
      strStatus = 'Простой с ';
      strType = task.pauseType;
    }else{
        strStatus = 'В дороботке ';
        strType = task.reworkType;
      }
    WorkTimer workTimerPassedTime = new WorkTimer(task.lastStatusTime);
    WorkTimer workTimerLeftTime = new WorkTimer(task.endTimeTaskPlan);
    String userFamalyIO = getUserFioByID(task.assignedUserID);
    String guiltyFamaliIO = getUserFioByID(task.guiltyUserID);
    return Column(
      children: [
        Row(children: [
          Text("Исполнитель : "),
          TextButton(onPressed: (){
            setState(() {
              mainWidget = usersDropList(task, currentNode);
              isLoaded = true;
            });
          }, child: Text("$userFamalyIO", style: TextStyle(fontSize: 21, color: Colors.blue),))
        ],),
        Row(children: [
          Text(strStatus),
          Text(' '+workTimerPassedTime.hhMMssPassed()),
        ],),
        Row(children: [
          Text('Осталось '),
          Text(''+workTimerLeftTime.hhMMssLeft()),
        ],),
        Row(children: [
          Text('Завершение по плану: ' + task.getEndTimeText()),
        ],),
        Divider(),
        Text(strType),
        Text('Комментарий: '),
        Row(children: [
          Flexible(child: Text(""+task.taskComment)),
          Icon(Icons.mode_comment_outlined),
        ],
        ),
        Row(children: [
          Icon(Icons.mode_comment_outlined),
          Flexible(child:Text('Директор: '+ task.dirComment) ),
        ],),
        Divider(),
        Row(children: [
          Text("Виновный"),
          TextButton(onPressed: (){
            setState(() {
              mainWidget = guiltyDropList(task, currentNode);
              isLoaded = true;
            });
          }, child: Text('$guiltyFamaliIO',style: TextStyle(color: Colors.red ,fontSize: 21),))
        ],),
        Text("Ваш комментарий"),
        TextField(
          maxLines: 3,
          maxLength: 255,
          decoration: InputDecoration(icon: Icon(Icons.mode_comment_outlined) ,fillColor: Colors.blueGrey),
          onChanged: (text){
            dirComment = text;
            task.dirComment = dirComment;
            DataBaseConnector().setTaskDirComment(task, currentNode, currentContract);
          },
          onSubmitted: (text){
            dirComment = text;
            task.dirComment = dirComment;
            DataBaseConnector().setTaskDirComment(task, currentNode, currentContract);

          },
        ),
      ],);
  }

  Widget notSetWidget(Task task) {
    String userFamalyIO = getUserFioByID(task.assignedUserID);
    return Column(
      children: [
        Row(children: [
          Text("Исполнитель : "),
          TextButton(onPressed: (){
            setState(() {
              mainWidget = usersDropList(task, currentNode);
              isLoaded = true;
            });
          }, child: Text("$userFamalyIO", style: TextStyle(fontSize: 21, color: Colors.blue),))
        ],),
        Row(children: [
          Text('В процессе '),
          //Text(' '+workTimerPassedTime.hhMMssPassed()),
        ],),
        Row(children: [
          Text('Осталось '),
          //Text(''+workTimerLeftTime.hhMMssLeft()),
        ],),
        Row(children: [
          Text('Завершение по плану: ' + task.getEndTimeText()),
        ],),
      ],
    );
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
    dropdownAssignValue = usersIDList.first;
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
      if (dropdownAssignValue == null) dropdownAssignValue = usersList.first.id;
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
      dropdownAssignValue = '0';
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

  void refresh(){
    if(deeplevel == 'taskContent'){
      setState(() {
        timePassed = WorkTimer(currentTask.lastStatusTime).hhMMssPassed();
        timeLeft = WorkTimer(currentTask.endTimeTaskPlan).hhMMssLeft();
        mainWidget = _buildTaskTail(currentTask, currentNode);
        isLoaded = true;
      });
    }
  }

  void back() async{
    switch(deeplevel){
      case 'taskContent': {
        tasksList = await readTasks(currentNode);
        setState(() {
          if(currentTask.parentNodeName == currentContract.id){
            mainWidget = _buildNodesList();
            isLoaded = true;
          }else{
            mainWidget = _buildTasksList(currentNode);
            isLoaded = true;
          }
        });
        break;
      }
      case 'taskList': {
        setState(() {
          mainWidget = _buildNodesList();
          isLoaded = true;
        });
        break;
      }
      case 'nodeList': {
        setState(() {
          mainWidget = _buildContractsList();
          isLoaded = true;
        });
        break;
      }
      default :{}
    }
  }
}
