import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signInWithGoogle();

  Future<String> sigInWithFaceBook();

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<bool> passwordValidate(String password);

  Future<void> changeEmail(String email);

  Future<void> changePassword(String password);

  Future<void> deleteUser();

  Future<void> sendPasswordResetMail(String email);
}

class AuthService implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookSignIn = new FacebookLogin();
  FirebaseUser activeUser;
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<String> signIn(String email, String password) async {
    try {
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      // savetoLocal(result.user.uid, email, password, result.user.displayName,result.user.photoUrl);
      return result.user.uid;
    } catch (e) {
      if (e is PlatformException) {
        return e.code;
      }
    }
  }

  // void savetoLocal(String uid,String email, String password, String displayname,String photoUrl) async {
  //   User _me=_pref.myinfo??User();
  //   _me.uid=uid;
  //   _me.userID=email;
  //   _me.userEmail=email;
  //   _me.userPwd=password;
  //   _me.userNick=displayname;
  //   _me.userState=Status.LOG_IN.index;
  //   _me.portraitData=photoUrl;
  //    _pref.saveStringToDisk(LocalStorageService.MyInfoKey, jsonEncode(_me));
  //   _userMger.checkUserExist(_me.userID).then((value) => {
  //    if(value==false)
  //         _userMger.addUser(_me)
  //   });
  // }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult result =
        await _firebaseAuth.signInWithCredential(credential);

    return result.user.uid;
  }

  Future<String> sigInWithFaceBook() async {
    try {
      final FacebookLoginResult facebookLoginResult =
          await _facebookSignIn.logIn(['email', 'public_profile']);
      FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
      AuthCredential authCredential = FacebookAuthProvider.getCredential(
          accessToken: facebookAccessToken.token);
      FirebaseUser result =
          (await _firebaseAuth.signInWithCredential(authCredential)).user;
      print('success' + result.uid);
      return result.uid;
    } catch (e) {
      if (e is PlatformException) {
        print('error' + e.code);
        return e.code;
      }
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      var user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return user.user.uid;
    } catch (signUpError) {
      if (signUpError is PlatformException) {
        return signUpError.code;
      }
    }
  }

  Future<FirebaseUser> updateUser(UserUpdateInfo userUpdateInfo) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) await user.updateProfile(userUpdateInfo);
    activeUser = await _firebaseAuth.currentUser();
    return activeUser;
  }

  Future<FirebaseUser> remedyUser(FirebaseUser _user) async {
    UserUpdateInfo _info = UserUpdateInfo();
    if (_user.displayName == null || _user.displayName == '') {
      _info.displayName = _user.email.substring(0, _user.email.indexOf('@'));
    }
    if (_user.photoUrl == null || _user.photoUrl == '') {
      _info.photoUrl = await FirebaseStorage.instance
          .ref()
          .child('profile')
          .child('photo.jpg')
          .getDownloadURL();
    }
    if (_info.displayName != null && _info.photoUrl != null)
      return await updateUser(_info);
    else
      return activeUser;
  }

  Future<FirebaseUser> getCurrentUser() async {
    try {
      activeUser = await _firebaseAuth.currentUser();
      if (activeUser != null) {
        if (activeUser.displayName == null || activeUser.photoUrl == null)
          return await remedyUser(activeUser);
      }
      return activeUser;
    } catch (e) {
      activeUser = null;
      print('activeuser is null');
      return null;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<bool> passwordValidate(String password) async {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(password);
  }

  @override
  Future<void> changeEmail(String email) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updateEmail(email).then((_) {
      print("Succesfull changed email");
    }).catchError((error) {
      print("email can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> changePassword(String password) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
    });
    return null;
  }

  @override
  Future<void> deleteUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.delete().then((_) {
      print("Succesfull user deleted");
    }).catchError((error) {
      print("user can't be delete" + error.toString());
    });
    return null;
  }

  @override
  Future<void> sendPasswordResetMail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    return null;
  }
}
