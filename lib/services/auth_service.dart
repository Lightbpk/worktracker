import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
    final FirebaseAuth _fAuth = FirebaseAuth.instance;

    Future signInEmailPassword(String email, String password) async{
        try{
            //AuthResult result = await _fAuth.signInWithEmailAndPassword(email: email, password: password);
            //FirebaseUser user  = result.user;
        }catch(e){
            return null;
        }
    }
}