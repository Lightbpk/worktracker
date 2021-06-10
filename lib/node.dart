import 'package:worktracker/task.dart';

import 'Pages/admin-page.dart';

class BuildNode {
  String nodePosition;
  String nodeName;
  String nodeDeadline = "deadline not set";
  BasicDateTimeField field;
  BuildNode(String nodeName,String nodePosition){
    this.nodeName = nodeName;
    this.nodePosition = nodePosition;
  }

}