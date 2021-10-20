import 'package:firebase_auth/firebase_auth.dart';

import '../entities/user.dart';

class AuthService{
    final FirebaseAuth _fAuth = FirebaseAuth.instance;

    Future<WTUser> signInEmailPassword(String email, String password) async{
        try{
            UserCredential result = await _fAuth.signInWithEmailAndPassword(email: email, password: password);
            User user  = result.user;

            return WTUser.fromFirebase(user);
        }catch(e){
            print(e);
            return null;
        }
    }
    Future<WTUser> registerEmailPassword(String email, String password) async{
        try{
            UserCredential result = await _fAuth.createUserWithEmailAndPassword(email: email, password: password);
            User user  = result.user;
            return WTUser.fromFirebase(user);
        }catch(e){
            print(e);
            return null;
        }
    }
    Future logOut() async{
        await _fAuth.signOut();
    }
    Stream<WTUser> get currentUser{
        return _fAuth.authStateChanges()
            .map((User user) => user != null ? WTUser.fromFirebase(user): null); // мапится только  юзер
    }
}