import 'package:worktracker/stage.dart';

import 'Pages/admin-page.dart';

class BuildNode {
  String nodeName;
  DateTime nodeDeadline;
  List<NodeStage> nodeStage;
  BasicDateTimeField field;

  BuildNode(String nodeName){
    this.nodeName = nodeName;
  }

}