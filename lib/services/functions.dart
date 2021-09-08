import 'package:flutter/material.dart';

Color statusColor(String status){
  Color statusColor;
  switch (status){
    case "inwork":
      statusColor = Colors.lightGreen;
      break;
    case "pause":
      statusColor = Colors.redAccent;
      break;
    case "rework":
      statusColor = Colors.yellowAccent;
      break;
    case "done":
      statusColor = Colors.green;
      break;
    default :
      statusColor = Colors.white;
      break;
  }
  return statusColor;
}