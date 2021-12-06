class Task {
  String taskName;
  String status;
  int lastStatusTime;
  String parentNodeName;
  String assignedUserID;
  int startTimeTaskPlan;
  int endTimeTaskPlan;
  String _reworkType;
  String _taskComment;
  String guiltyUserID;
  String _pauseType;
  String _dirComment;

  Task(String taskName,String parentNodeName){
    this.taskName = taskName;
    this.parentNodeName = parentNodeName;
    status = 'not set';
    lastStatusTime = 0;
    assignedUserID = "Ответственный не указанн";
    _reworkType = 'тип доработки не указан';
    _taskComment = "коммент отсутствует";
    guiltyUserID = "Виновынй не указан";
    _dirComment = 'коммент директора отсутствует';
    _pauseType = 'тип паузы не указан';
    startTimeTaskPlan = 0;
    endTimeTaskPlan = 0;
  }

  String get dirComment => _dirComment;

  set dirComment(String value) {
    if(value!=null) _dirComment = value;
  }

  String taskFullInfo(){
    return taskName +" "+status+" "+assignedUserID+" "+assignedUserID+" "+ _reworkType+ " "+
        _taskComment+ ' '+guiltyUserID +" "+ _dirComment+" "+_pauseType+" "+_taskComment+" "+
        "lastStatusTime $lastStatusTime startTimeTaskPlan $startTimeTaskPlan  endTimeTaskPlan $endTimeTaskPlan"
    ;
  }

  String statusText(){
    switch(status) {
      case 'inwork':
        return "В работе";
        break;
      case 'done' :
        return 'Завершено';
        break;
      case 'rework' :
        return 'Доработка';
        break;
      case 'pause' :
        return 'Пауза';
        break;
      default :
        return 'Не  установлен';
        break;
    }
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

  String get taskComment => _taskComment;


  set reworkType(String value) {
    if(value!=null) _reworkType = value;
  }

  String get pauseType => _pauseType;

  set taskComment(String value) {
    if(value!=null) _taskComment = value;
  }

  set pauseType(String value) {
    if(value!=null) _pauseType = value;
  }
}