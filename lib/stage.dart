class Stage {
  String stageName;
  String status;
  String lastStatusTime;

  Stage(String stageName){
    this.stageName = stageName;
    status = 'not set';
    lastStatusTime = "not set";
  }
}