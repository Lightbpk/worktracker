import 'package:firebase_auth/firebase_auth.dart';

import '../user.dart';

class AuthService{
    final FirebaseAuth _fAuth = FirebaseAuth.instance;

    Future<UserWT> signInEmailPassword(String email, String password) async{
        try{
            UserCredential result = await _fAuth.signInWithEmailAndPassword(email: email, password: password);
            User user  = result.user;
            return UserWT.fromFirebase(user);
        }catch(e){
            print(e);
            return null;
        }
    }
    Future<UserWT> registerEmailPassword(String email, String password) async{
        try{
            UserCredential result = await _fAuth.createUserWithEmailAndPassword(email: email, password: password);
            User user  = result.user;
            return UserWT.fromFirebase(user);
        }catch(e){
            print(e);
            return null;
        }
    }
    Future logOut() async{
        await _fAuth.signOut();
    }
    Stream<UserWT> get currentUser{
        return _fAuth.authStateChanges()
            .map((User user) => user != null ? UserWT.fromFirebase(user): null); // мапится только  юзер
    }
}