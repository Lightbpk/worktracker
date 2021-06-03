import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worktracker/node.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget currentWidget;
  final _adminFormKey = GlobalKey<FormState>();
  bool loadStartWidget = true;
  String currentContractID;
  String currentClientName;
  BasicDateTimeField firstNodeDeadLine;
  List<BuildNode> nodeList = [
    new BuildNode("Оформление документов"),
    new BuildNode("Разработка КД и электроКД "),
    new BuildNode("Снабжение комплектующими"),
    new BuildNode("Сборка оборудования согласно ТК"),
    new BuildNode("Тестирование оборудования"),
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
              currentWidget = ListView.builder(itemBuilder: (context, i){
                if(i < nodeList.length) return ListTile(title: Text(nodeList[i].nodeName),);
                else return ListTile(title: Text(''));
              });
            });
          }, icon: Icon(Icons.timeline), label: Text("Установить дэдлайны")),
          new TextButton.icon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text("Внесение проекта в БД"),
                        content: new Text(
                            'Вы уверены что хотите внести данные по проекту в БД?'),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: new Text("отмена")),
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _adminFormKey.currentState.save();
                                addContract();
                              },
                              child: new Text("ОК"))
                        ],
                      );
                    });
              },
              icon: Icon(Icons.add_road),
              label: new Text('Добавить проект')),

        ],
      ),
    );
  }

  void addContract() {
    DataBaseConnector().addProject(
        currentContractID, currentClientName, nodeList);
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
