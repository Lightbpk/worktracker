import 'package:worktracker/stage.dart';

import 'Pages/admin-page.dart';

class BuildNode {
  String nodeName;
  String nodeDeadline = "deadline not set";
  List<Stage> stages = [new Stage("Задача1"),new Stage("Задача2"),new Stage("Задача3")];
  BasicDateTimeField field;
  BuildNode(String nodeName){
    this.nodeName = nodeName;
  }

}