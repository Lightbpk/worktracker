import 'dart:async';

class WorkTimer
{
  Timer timer;
  int timePoint;

  WorkTimer(int timePoint){
    this.timePoint =timePoint;
  }

  int timePassed(){
    int timeNow = DateTime.now().microsecondsSinceEpoch;
    return timeNow - timePoint;
  }

  int timeLeft(){    print('timePoint $timePoint');
    int timeNow = DateTime.now().microsecondsSinceEpoch;
    return timePoint - timeNow;
  }

  String hhMMssLeft(){
    String strLeft= "";
    if(timePoint == 0){
      return strLeft;
    }
    int micSecNow = DateTime.now().microsecondsSinceEpoch;
    int micSecLeft = timePoint - micSecNow;
    DateTime leftTime = DateTime.fromMicrosecondsSinceEpoch(micSecLeft);
    DateTime nullTime = DateTime.fromMicrosecondsSinceEpoch(0);
    print("leftTime");
    print(leftTime);
    Duration difTime = leftTime.difference(nullTime);
    print("difTime");
    List<String> difList = difTime.toString().split(':');
    if(difList.length == 3) strLeft = difList[0] + " часов " + difList[1] + ' минут '+ difList[2].substring(0,difList[2].length - 7)+ 'сек';
    else if (difList.length == 2) strLeft = difList[0] + ' минут '+ difList[1].substring(0,difList[1].length - 7)+ 'сек';
    else if (difList.length == 1) strLeft = difList[0].substring(0,difList[0].length - 7) + ' сек ';
    else strLeft = 'error difList Length';
    return strLeft;
  }
  String hhMMssPassed(){
    String strPassed= "";
    if(timePoint == 0){
      return strPassed;
    }
    int micSecNow = DateTime.now().microsecondsSinceEpoch;
    int micSecPassed = timePoint - micSecNow;
    DateTime passedTime = DateTime.fromMicrosecondsSinceEpoch(micSecPassed);
    DateTime nullTime = DateTime.fromMicrosecondsSinceEpoch(0);
    Duration difTime = nullTime.difference(passedTime);
    List<String> difList = difTime.toString().split(':');
    if(difList.length == 3) strPassed = difList[0] + " часов " + difList[1] + ' минут '+ difList[2].substring(0,difList[2].length - 7)+ 'сек';
    else if (difList.length == 2) strPassed = difList[0] + ' минут '+ difList[1].substring(0,difList[1].length - 7)+ 'сек';
    else if (difList.length == 1) strPassed = difList[0].substring(0,difList[0].length - 7) + ' сек ';
    else strPassed = 'error difList Length';
    return strPassed;
  }
}