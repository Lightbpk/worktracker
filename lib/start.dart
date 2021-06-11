 import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worktracker/Pages/user-page.dart';
import 'package:worktracker/user.dart';

import 'Pages/auth-page.dart';
import 'Pages/main-page.dart';
import 'Pages/admin-page.dart';


class StartPage extends StatelessWidget{

  @override

  Widget build(BuildContext context) {
    final WTUser userWT = Provider.of<WTUser>(context);
    final bool isLoggedIn = userWT != null;
    if(isLoggedIn){
      if(userWT.id == "69ki0j90NMaHVoj6T71I5Va97U43") return AdminPage();
      else return UserPage();
    }
    else return AuthPage(title:'Authentication');
  }
}