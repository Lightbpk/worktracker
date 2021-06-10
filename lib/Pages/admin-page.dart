import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/task.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget currentWidget;
  bool loadStartWidget = true;
  String currentContractID;
  String currentClientName;
  BasicDateTimeField firstNodeDeadLine;
  List<BuildNode> nodeList = [
    new BuildNode("Оформление документов","01"),
    new BuildNode("Разработка КД и электроКД","02"),
    new BuildNode("Снабжение комплектующими","03"),
    new BuildNode("Заготовительно изготовительные Операции","04"),
    new BuildNode("Сборка оборудования согласно ТК","05"),
    new BuildNode("Сборка Шкафа обвязка Электрикой","06"),
    new BuildNode("Наладка оборудования","07"),
    new BuildNode("Тестирование оборудования","08"),
    new BuildNode("Демонтаж, упаковка и отгрузка оборудования","09"),
  ];

  @override
  Widget build(BuildContext context) {
    if(loadStartWidget){
      currentWidget = _startWidget();
    }
    return Scaffold(
      appBar: AppBar(
        title: new Text("Учётка Админ"),
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
      body: currentWidget,

    );
  }
  Widget _startWidget(){
    return Container(
      child: new Column(
        children: <Widget>[
          new SizedBox(
            height: 15,
          ),
          new Text("Номер договора"),
          new TextFormField(
            decoration: InputDecoration(hintText: "Введите номер договора"),
            onChanged: (text) {
              currentContractID = text;
            },
          ),
          new SizedBox(
            height: 10,
          ),
          new Text("Заказчик"),
          new TextFormField(
            decoration:
            InputDecoration(hintText: "Введите наименование заказчика"),
            onChanged: (text) {
              currentClientName = text;
            },
          ),
          new TextButton.icon(onPressed: (){
            setState(() {
              loadStartWidget = false;
              _nodeListWidget();
            });
          }, icon: Icon(Icons.timeline), label: Text("Установить дэдлайны")),
        ],
      ),
    );
  }

  void _nodeListWidget(){
    currentWidget = ListView.builder(itemBuilder: (context, i){
      if(i < nodeList.length) return ListTile(
        subtitle: nodeList[i].field = BasicDateTimeField(),
        title: Text(nodeList[i].nodeName,));
      else if(i == nodeList.length) return ListTile(title: Text("Назад"),
        onTap: (){
          setState(() {
            loadStartWidget = true;
          });
        },);
      else if(i == nodeList.length+1) return ListTile(trailing:           new TextButton.icon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text("Внесение проекта в БД"),
                    content: new Text(
                        'Вы уверены что хотите внести данные по проекту в БД?'),
                    actions: <Widget>[
                      OutlineButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: new Text("отмена")),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            addContract();
                            setState(() {
                              loadStartWidget = true;
                              Fluttertoast.showToast(msg: "Договор $currentContractID внесен в БД",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          },
                          child: new Text("ОК"))
                    ],
                  );
                });
          },
          icon: Icon(Icons.add_road),
          label: new Text('Добавить в БД')),);
      else return ListTile(title: Text(''));
    });
  }

  void addContract() {
    List<Task> defTaskList =  makeDefaultTaskList(nodeList);
    DataBaseConnector().addProject(
        currentContractID, currentClientName, nodeList, defTaskList);
  }

  List<Task> makeDefaultTaskList(List<BuildNode> nodeList)
  {
    List<Task> defaultTasksList= [];
    nodeList.forEach((node) {
      defaultTasksList.add(new Task("Задача1_"+node.nodePosition,node.nodeName));
      defaultTasksList.add(new Task("Задача2_"+node.nodePosition,node.nodeName));
      defaultTasksList.add(new Task("Задача3_"+node.nodePosition,node.nodeName));
    });
    return defaultTasksList;
  }
}

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  String currentDateAndTime;
  DateTime dateTimeValue;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        decoration: InputDecoration(
            hintText: "Введите дату Deadline (${format.pattern})"),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            currentDateAndTime = date.toString() + time.toString();
            dateTimeValue = DateTimeField.combine(date, time);
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}

