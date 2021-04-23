import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:worktracker/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  final String title;

  AuthPage({Key key, this.title}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthService _authService = AuthService();
  String currentEmail;
  String currentPassword;
  final _authFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
          child:
             new Form(
               key: _authFormKey,
               child: Column(
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new TextFormField(
                    decoration: InputDecoration(
                      hintText: "Email"
                  ),),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    decoration: InputDecoration(
                      hintText: "Password",
                  ),
                  obscureText: true,
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextButton.icon(onPressed: (){},
                      label: new Text('Погнали!'),
                      icon: Icon(Icons.arrow_circle_up),
                  )
                ],
               ),
        ),
      ),
    );
  }

  void _loginButtonAction() {}
}
