
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd HH:mm");
  String currentDateAndTime;
  DateTime dateTimeValue;
  String hintText = 'Введите дату';
  DateTime dateEnd = DateTime(2100);

  BasicDateTimeField(String newHintText){
    hintText = newHintText;
  }

  BasicDateTimeField.dd(String newHintText, DateTime dateEnd){
    hintText = newHintText;
    this.dateEnd = dateEnd;
  }

  int getDateTime(){
    return dateTimeValue.microsecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        decoration: InputDecoration(
            hintText: hintText ),
        onShowPicker: (context, currentValue) async {
          if(currentValue == null && DateTime.now().isBefore(dateEnd) ) currentValue = DateTime.now();
          else if(currentValue == null)currentValue = dateEnd;
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ,
              lastDate: dateEnd);
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue),
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

