import 'dart:async';

class WorkTimer
{
  Timer timer;
  int timePoint;

  WorkTimer(int timePoint){
    this.timePoint =timePoint;
  }

  int timePassed(){
    print('timePoint $timePoint');
    int timeNow = DateTime.now().microsecondsSinceEpoch;
    print('timePoint $timeNow');
    print('timePoint - timeNow');
    print(timeNow - timePoint);
    return timeNow - timePoint;
  }

  int timeLeft(){    print('timePoint $timePoint');
    int timeNow = DateTime.now().microsecondsSinceEpoch;
    print('timePoint $timeNow');
    print('timePoint - timeNow');
    print(timePoint - timeNow);
    return timePoint - timeNow;
  }

  String ddHHmmssLeft(){
    String strLeft= "";
    int micSecNow = DateTime.now().microsecondsSinceEpoch;
    int micSecLeft = timePoint - micSecNow;
    double secLeft = (micSecLeft / 1000000);
    double minLeft = (secLeft / 60);
    double hoursLeft = (minLeft / 60);
    double daysLeft = (hoursLeft / 24);
    if(daysLeft >= 1) strLeft = strLeft + 'Дней '+ daysLeft.round().toString();
    if((hoursLeft/daysLeft) >= 1)
      strLeft = strLeft + ' Часов '+(hoursLeft % daysLeft).toString();
    if(minLeft / hoursLeft >= 1 )
      strLeft = strLeft + ' Минут '+(minLeft % hoursLeft).toString();
    if(secLeft / hoursLeft >= 1 )
      strLeft = strLeft + ' Секунд '+(secLeft % minLeft).toString();
    return strLeft;
  }
  Duration d;
}