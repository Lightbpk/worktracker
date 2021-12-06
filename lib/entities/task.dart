class Task {
  String taskName;
  String status;
  int lastStatusTime;
  String parentNodeName;
  String assignedUserID;
  int startTimeTaskPlan;
  int endTimeTaskPlan;
  String _reworkType;
  String _reworkComment;
  String guiltyUserID;
  String _pauseType;
  String _pauseComment;
  String _dirComment;

  Task(String taskName,String parentNodeName){
    this.taskName = taskName;
    this.parentNodeName = parentNodeName;
    status = 'not set';
    lastStatusTime = 0;
    assignedUserID = "Ответственный не указанн";
    _reworkType = 'тип доработки не указан';
    _reworkComment = "коммент доработки отсутствует";
    guiltyUserID = "Виновынй не указан";
    _dirComment = 'коммент директора отсутствует';
    _pauseType = 'тип паузы не указан';
    _pauseComment = "коммент паузы не указан";
    startTimeTaskPlan = 0;
    endTimeTaskPlan = 0;
  }

  String get dirComment => _dirComment;

  set dirComment(String value) {
    if(value!=null) _dirComment = value;
  }

  String taskFullInfo(){
    return taskName +" "+status+" "+assignedUserID+" "+assignedUserID+" "+ _reworkType+ " "+
        _reworkComment+ ' '+guiltyUserID +" "+ _dirComment+" "+_pauseType+" "+_pauseComment+" "+
        "lastStatusTime $lastStatusTime startTimeTaskPlan $startTimeTaskPlan  endTimeTaskPlan $endTimeTaskPlan"
    ;
  }

  String get reworkType => _reworkType;

  String getLastStatusTimeText(){
    if(lastStatusTime != 0) return DateTime.fromMicrosecondsSinceEpoch(lastStatusTime)
        .toString().substring(0,19);
    else return "Не заданно";
  }

  String getStartTimeText(){
    String startTime = DateTime.fromMicrosecondsSinceEpoch(startTimeTaskPlan).toString();
    if(startTimeTaskPlan != 0) return startTime.substring(0,19);
    else return "Не задано";
  }
  String getEndTimeText(){
    String endTime = DateTime.fromMicrosecondsSinceEpoch(endTimeTaskPlan).toString();
    if(endTimeTaskPlan != 0) return endTime.substring(0,19);
    else return "Не задано";
  }

  String get reworkComment => _reworkComment;

  String get pauseComment => _pauseComment;

  set reworkType(String value) {
    if(value!=null) _reworkType = value;
  }

  String get pauseType => _pauseType;

  set reworkComment(String value) {
    if(value!=null) _reworkComment = value;
  }

  set pauseComment(String value) {
    if(value!=null) _pauseComment = value;
  }

  set pauseType(String value) {
    if(value!=null) _pauseType = value;
  }
}