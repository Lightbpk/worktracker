import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {


  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _adminFormKey = GlobalKey<FormState>();
  String currentContractID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Админ"),
      ),
      body: Container(
        child: new Form(
          key: _adminFormKey,
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 15,),
              new TextFormField(
                decoration: InputDecoration(hintText: "Номер договора"),
                onChanged: (text) {
                  currentContractID = text;
                },
              ),
              BasicDateTimeField(),
            ],
          ),
        ),
      ),
    );
  }
}
class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Basic date & time field (${format.pattern})'),
      DateTimeField(
        format: format,
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