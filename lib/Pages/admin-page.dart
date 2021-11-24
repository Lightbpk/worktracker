import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/entities/node.dart';
import 'package:worktracker/entities/user.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/data-time-field.dart';
import 'package:worktracker/services/firebaseConnector.dart';
import 'package:worktracker/entities/task.dart';


class AdminPage extends StatefulWidget {
  WTUser userAdmin;

  AdminPage(WTUser userAdmin) {
    this.userAdmin = userAdmin;
  }

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget currentWidget;
  bool loadStartWidget = true;
  String currentContractID;
  String currentClientName;
  BasicDateTimeField firstNodeDeadLine;

  // bool existEmptyDeadline = true;
  List<BuildNode> nodeList = [
    new BuildNode("Оформление документов", "01"),
    new BuildNode("Разработка КД и электроКД", "02"),
    new BuildNode("Снабжение комплектующими", "03"),
    new BuildNode("Заготовительно изготовительные Операции", "04"),
    new BuildNode("Сборка оборудования согласно ТК", "05"),
    new BuildNode("Сборка Шкафа обвязка Электрикой", "06"),
    new BuildNode("Наладка оборудования", "07"),
    new BuildNode("Тестирование оборудования", "08"),
    new BuildNode("Демонтаж, упаковка и отгрузка оборудования", "09"),
    new BuildNode("Отдельная задача1 ", "10", true),
    new BuildNode("Отдельная задача2 ", "11", true),
    new BuildNode("Отдельная задача3 ", "12", true),
  ];

  @override
  Widget build(BuildContext context) {
    if (loadStartWidget) {
      currentWidget = _startWidget();
    }
    return Scaffold(
      appBar: AppBar(
        title: new Text("Админ:" + widget.userAdmin.getFamalyIO()),
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

  Widget _startWidget() {
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
          new TextButton.icon(
              onPressed: () {
                setState(() {
                  loadStartWidget = false;
                  _nodeListWidget();
                });
              },
              icon: Icon(Icons.timeline),
              label: Text("Узлы и дэдлайны")),
        ],
      ),
    );
  }

  void _nodeListWidget() {
    print('nodelist build');
    currentWidget = ListView.builder(itemBuilder: (context, i) {
      if (i < nodeList.length) {
        BasicDateTimeField field;
        if (nodeList[i].field == null) {
          field = BasicDateTimeField('Введите дату Дэдлайна');
        } else {
          field = BasicDateTimeField('Введите дату Дэдлайна');
          field.dateTimeValue = nodeList[i].field.dateTimeValue;
        }
        return CheckboxListTile(
          subtitle: nodeList[i].field = field,
          title: Text(nodeList[i].nodeName),
          value: nodeList[i].checked,
          onChanged: (bool value) {
            setState(() {
              nodeList[i].checked = !nodeList[i].checked;
              _nodeListWidget();
              //print('checked ' +checked.toString());
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        );
      } else if (i == nodeList.length)
        return ListTile(
          title: Text("Назад"),
          onTap: () {
            setState(() {
              loadStartWidget = true;
            });
          },
        );
      else if (i == nodeList.length + 1)
        return ListTile(
          trailing: new TextButton.icon(
              onPressed: () {
                nodeList.forEach((BuildNode node) {
                  if (node.checked) {
                    if (node.field.dateTimeValue == null) {
                      makeToast("Указаны не все дэдлайны", Colors.red);
                    }
                  }
                });
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
                                  String msg =
                                      "Договор $currentContractID внесен в БД";
                                  makeToast(msg, Colors.green);
                                });
                              },
                              child: new Text("ОК"))
                        ],
                      );
                    });
              },
              icon: Icon(Icons.add_road),
              label: new Text('Добавить в БД')),
        );
      else
        return ListTile(title: Text(''));
    });
  }

  void addContract() {
    List<Task> defTaskList = makeDefaultTaskList(nodeList);
    DataBaseConnector().addProject(
        currentContractID, currentClientName, nodeList, defTaskList);
  }

  List<Task> makeDefaultTaskList(List<BuildNode> nodeList) {
    List<Task> defaultTasksList = [];
    nodeList.forEach((node) {
      if (node.checked) {
        defaultTasksList
            .add(new Task("Задача1_" + node.nodePosition, node.nodeName));
        defaultTasksList
            .add(new Task("Задача2_" + node.nodePosition, node.nodeName));
        defaultTasksList
            .add(new Task("Задача3_" + node.nodePosition, node.nodeName));
      }
    });
    return defaultTasksList;
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
