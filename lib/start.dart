 import 'package:flutter/widgets.dart';

import 'auth-page.dart';
import 'main-page.dart';

class StartPage extends StatelessWidget{

  @override

  Widget build(BuildContext context) {
    final bool isLoggedIn = true;
    return isLoggedIn ? MainPage(title:"MAIN PAGE") : AuthPage(title:'Authentication');
  }
}