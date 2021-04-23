import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/services/auth_service.dart';

import '../user.dart';

class AuthPage extends StatefulWidget {
  final String title;

  AuthPage({Key key, this.title}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String currentEmail;
  String currentPassword;
  final _authFormKey = GlobalKey<FormState>();
  String email = "",
      password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: new Form(
          key: _authFormKey,
          child: Column(
            children: <Widget>[
              new SizedBox(
                height: 50.0,
              ),
              new TextFormField(
                decoration: InputDecoration(hintText: "Email"),
                onChanged: (text) {
                  email = text;
                  //print("Current email: $text");
                },
              ),
              new SizedBox(
                height: 20.0,
              ),
              new TextFormField(
                decoration: InputDecoration(
                  hintText: "Password",
                ),
                onChanged: (text) {
                  password = text;
                  //print("Current password :$text");
                },
                obscureText: true,
              ),
              new SizedBox(
                height: 20.0,
              ),
              new TextButton.icon(
                onPressed: () {
                  _loginButtonAction();
                },
                label: new Text('Погнали!'),
                icon: Icon(Icons.arrow_circle_up),
              ),
              new TextButton.icon(
                  onPressed: () {
                    _registerButtonAction();
                  },
                  label: new Text("Регистрация"),
                  icon: Icon(Icons.app_registration)),
            ],
          ),
        ),
      ),
    );
  }

  void _loginButtonAction() async {
    AuthService _authService = AuthService();
    if(emailPassValidator()) {
      UserWT userWT =
      await _authService.signInEmailPassword(email.trim(), password.trim());
      if (userWT == null) {
        sendErrToast("Пользователь не найден");
      }
    }
  }


  void _registerButtonAction() async {
    AuthService _authService = AuthService();
    if(emailPassValidator()) {
      UserWT userWT =
      await _authService.registerEmailPassword(email.trim(), password.trim());
      if (userWT == null) {
        sendErrToast("Ошибка Регистрации");
      }
    }
  }

  void sendErrToast(String msgText) {
    Fluttertoast.showToast(
        msg: msgText,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  bool emailPassValidator(){
    if(email.isEmpty){
      sendErrToast("Пустрой Email");
      return false;
    }
    if(password.isEmpty){
      sendErrToast("Пустрой пароль");
      return false;
    }
    String p =
        "[a-zA-Z0-9+.\_\%-+]{1,256}@[a-zA-Z0-9][a-zA-Z0-9-]{0,64}(.[a-zA-Z0-9][a-zA-Z0-9-]{0,25})+";
    RegExp regExp = new RegExp(p);
    if (!regExp.hasMatch(email)){
      sendErrToast(" Не корректный  Email");
      return false;
    }
    if(password.length < 6){
      sendErrToast("Пароль не менее 6 символов");
      return false;
    }
    return true;
  }
}
