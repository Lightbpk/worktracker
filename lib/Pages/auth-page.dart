import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:worktracker/entities/user.dart';
import 'package:worktracker/services/auth_service.dart';
import 'package:worktracker/services/firebaseConnector.dart';



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
  final _regFormKey = GlobalKey<FormState>();
  String email = "",
      password = "",
      userSurname = "",
      userName = "",
      userFatherName = "";
  bool isLoginPage = true;
  Widget mainWidget;

  @override
  Widget build(BuildContext context) {
    if (isLoginPage){
      mainWidget = loggerWidget();
    }
    else{
      mainWidget = registerWidget();
    }
    return mainWidget;
  }


  Widget loggerWidget(){
    {
      print('logger widget start');
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
                  height: 10.0,
                ),
                new SizedBox(
                  height: 10.0,
                ),
                new TextButton.icon(
                    onPressed: () {
                      _loginButtonAction();
                    },
                    label: new Text("??????????????!"),
                    icon: Icon(Icons.arrow_circle_up)),
                new TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isLoginPage = false;
                      });
//                      _registerButtonAction();
                    },
                    label: new Text("??????????????????????"),
                    icon: Icon(Icons.app_registration)),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget registerWidget() {
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: new Form(
          key: _regFormKey,
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
              new TextFormField(
                decoration: InputDecoration(
                  hintText: "??????????????",
                ),
                onChanged: (text) {
                  userSurname = text;
                  //print("Current password :$text");
                },
              ),
              new SizedBox(
                height: 10.0,
              ),
              new TextFormField(
                decoration: InputDecoration(
                  hintText: "??????",
                ),
                onChanged: (text) {
                  userName = text;
                  //print("Current password :$text");
                },
              ),
              new TextFormField(
                decoration: InputDecoration(
                  hintText: "????????????????",
                ),
                onChanged: (text) {
                  userFatherName = text;
                  //print("Current password :$text");
                },
              ),
              new SizedBox(
                height: 10.0,
              ),
              new TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _registerButtonAction();
                    });
                  },
                  label: new Text("??????????????????????"),
                  icon: Icon(Icons.app_registration)),
              new TextButton.icon(onPressed: (){
                setState(() {
                  isLoginPage = true;
                });
                //Navigator.of(context).pop();
              },
                  icon: Icon(Icons.backspace),
                  label: new Text("??????????"))
            ],
          ),
        ),
      ),
    );
  }

  void _loginButtonAction() async {
    AuthService _authService = AuthService();
    if (emailPassValidator()) {
      WTUser userWT =
      await _authService.signInEmailPassword(email.trim(), password.trim());
      if (userWT == null) {
        sendErrToast("???????????????????????? ???? ????????????");
      }
    }
  }


  void _registerButtonAction() async {
    AuthService _authService = AuthService();
    if (emailPassValidator()) {
      WTUser userWT =
      await _authService.registerEmailPassword(email.trim(), password.trim());
      DataBaseConnector().addUID(userWT.id,userSurname,userName,userFatherName);
      if (userWT == null) {
        sendErrToast("???????????? ??????????????????????");
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

  bool emailPassValidator() {
    if (email.isEmpty) {
      sendErrToast("?????????????? Email");
      return false;
    }
    if (password.isEmpty) {
      sendErrToast("?????????????? ????????????");
      return false;
    }
    String p =
        "[a-zA-Z0-9+.\_\%-+]{1,256}@[a-zA-Z0-9][a-zA-Z0-9-]{0,64}(.[a-zA-Z0-9][a-zA-Z0-9-]{0,25})+";
    RegExp regExp = new RegExp(p);
    if (!regExp.hasMatch(email)) {
      sendErrToast(" ???? ????????????????????  Email");
      return false;
    }
    if (password.length < 6) {
      sendErrToast("???????????? ???? ?????????? 6 ????????????????");
      return false;
    }
    return true;
  }
}
