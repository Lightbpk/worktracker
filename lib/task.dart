class Task {
  String taskName;
  String status;
  String lastStatusTime;
  String parentNodeName;
  String assignedUser;

  Task(String taskName,String parentNodeName){
    this.taskName = taskName;
    this.parentNodeName = parentNodeName;
    status = 'not set';
    lastStatusTime = "not set";
    assignedUser = "not set";
  }
}