 import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/user.dart';

import 'Pages/auth-page.dart';
import 'Pages/main-page.dart';

class StartPage extends StatelessWidget{

  @override

  Widget build(BuildContext context) {
    final UserWT userWT = Provider.of<UserWT>(context);
    final bool isLoggedIn = userWT != null;
    return isLoggedIn ? MainPage(title:"MAIN PAGE") : AuthPage(title:'Authentication');
  }
}