import 'package:worktracker/stage.dart';

import 'Pages/admin-page.dart';

class BuildNode {
  String nodeName;
  String nodeDeadline;
  List<Stage> stage;
  BasicDateTimeField field;

  BuildNode(String nodeName){
    this.nodeName = nodeName;
  }

}