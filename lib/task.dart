class Task {
  String taskName;
  String status;
  int lastStatusTime;
  String parentNodeName;
  String assignedUser;
  int startTimeTaskPlan;
  int endTimeTaskPlan;

  Task(String taskName,String parentNodeName){
    this.taskName = taskName;
    this.parentNodeName = parentNodeName;
    status = 'not set';
    lastStatusTime = 0;
    assignedUser = "not set";
    startTimeTaskPlan = 0;
    endTimeTaskPlan = 0;
  }

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

}