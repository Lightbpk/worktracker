class Task {
  String taskName;
  String status;
  String lastStatusTime;
  String parentNodeName;
  String assignedUser;
  int startTimeTaskPlan;
  int endTimeTaskPlan;

  Task(String taskName,String parentNodeName){
    this.taskName = taskName;
    this.parentNodeName = parentNodeName;
    status = 'not set';
    lastStatusTime = "not set";
    assignedUser = "not set";
    startTimeTaskPlan = 0;
    endTimeTaskPlan = 0;
  }

  String getStartTimeText(){
    return DateTime.fromMicrosecondsSinceEpoch(startTimeTaskPlan).toString();
  }
  String getEndTimeText(){
    return DateTime.fromMicrosecondsSinceEpoch(endTimeTaskPlan).toString();
  }

}