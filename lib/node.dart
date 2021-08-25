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
    return DateTime.fromMicrosecondsSinceEpoch(nodeDeadline).toString();
  }
}