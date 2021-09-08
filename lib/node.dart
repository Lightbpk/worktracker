import 'package:worktracker/services/data-time-field.dart';

class BuildNode {
  String nodePosition;
  String nodeName;
  int nodeDeadline = 0;
  bool checked = false;
  BasicDateTimeField field;

  BuildNode(String nodeName,String nodePosition){
    this.nodeName = nodeName;
    this.nodePosition = nodePosition;
  }

  String getDeadlineText(){
    if(nodeDeadline == 0) return "null";
    else return DateTime.fromMicrosecondsSinceEpoch(nodeDeadline).toString();
  }
}