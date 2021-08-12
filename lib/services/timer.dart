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

  String hhMMssLeft(){
    String strLeft= "";
    int micSecNow = DateTime.now().microsecondsSinceEpoch;
    int micSecLeft = timePoint - micSecNow;
    DateTime leftTime = DateTime.fromMicrosecondsSinceEpoch(micSecLeft);
    DateTime nullTime = DateTime.fromMicrosecondsSinceEpoch(0);
    print("leftTime");
    print(leftTime);
    Duration difTime = leftTime.difference(nullTime);
    print("difTime");
    List<String> difList = difTime.toString().split(':');
    if(difList.length == 3) strLeft = difList[0] + " часов " + difList[1] + ' минут '+ difList[2]+ 'сек';
    else if (difList.length == 2) strLeft = difList[0] + ' минут '+ difList[1]+ 'сек';
    else if (difList.length == 1) strLeft = difList[0] + ' сек ';
    else strLeft = 'error difList Length';
    return strLeft;
  }
  String hhMMssPassed(){
    String strPassed= "";
    int micSecNow = DateTime.now().microsecondsSinceEpoch;
    int micSecPassed = timePoint - micSecNow;
    DateTime passedTime = DateTime.fromMicrosecondsSinceEpoch(micSecPassed);
    DateTime nullTime = DateTime.fromMicrosecondsSinceEpoch(0);
    Duration difTime = nullTime.difference(passedTime);
    List<String> difList = difTime.toString().split(':');
    if(difList.length == 3) strPassed = difList[0] + " часов " + difList[1] + ' минут '+ difList[2]+ 'сек';
    else if (difList.length == 2) strPassed = difList[0] + ' минут '+ difList[1]+ 'сек';
    else if (difList.length == 1) strPassed = difList[0] + ' сек ';
    else strPassed = 'error difList Length';
    return strPassed;
  }
}