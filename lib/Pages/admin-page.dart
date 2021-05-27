import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';

class AdminPage extends StatefulWidget {


  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _adminFormKey = GlobalKey<FormState>();
  String currentContractID;
  String currentClientName;
  String firstStageDeadLine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Админ"),
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
      body: Container(
        child: new Form(
          key: _adminFormKey,
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 15,),
              new Text("Номер договора"),
              new TextFormField(
                decoration: InputDecoration(hintText: "Введите номер договора"),
                onChanged: (text) {
                  currentContractID = text;
                },
              ),
              new SizedBox(height: 10,),
              new Text("Заказчик"),
              new TextFormField(
                decoration: InputDecoration(hintText: "Введите наименование заказчика"),
                onChanged: (text) {
                  currentClientName = text;
                },
              ),
              new SizedBox(height: 10,),
              new Text("Оформление документов до..."),
              BasicDateTimeField(),
              new SizedBox(height: 10,),
              new Text("Разработка КД и электроКД до..."),
              BasicDateTimeField(),
              new SizedBox(height: 10,),
              new Text("Снабжение комплектующими до..."),
              BasicDateTimeField(),
              new SizedBox(height: 10,),
              new Text("Сборка оборудования согласно ТК до..."),
              BasicDateTimeField(),
              new SizedBox(height: 10,),
              new Text("Тестирование оборудования до..."),
              BasicDateTimeField(),
              new SizedBox(height: 10,),
              new TextButton.icon(
                  onPressed: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        title: new Text("Внесение проэкта в БД"),
                        content: new Text('Вы увренны что хотите внести данные по проэкту в БД?'),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: new Text("отмена")),
                          FlatButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                                addContract();
                              },
                              child: new Text("ОК"))
                        ],
                      );
                    });
                  },
                  icon: Icon(Icons.add_road),
                  label: new Text('Добавить проэкт'))
            ],
          ),
        ),
      ),
    );
  }
  void addContract(){
    DataBaseConnector().addProject(currentContractID,currentClientName);
  }
}
class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        decoration: InputDecoration(hintText: "Введите дату Deadline (${format.pattern})"),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    ]);
  }
}

