import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tfg_app/models/user.dart';

// Provides an instance of this class corresponding to the default app.
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User user;

// Gets users collection reference
final usersRef = Firestore.instance.collection('users');

// Initializes global sign-in configuration settings.
final GoogleSignIn googleSignIn = GoogleSignIn();

bool isAuth() {
  return user != null;
}

/// Use the Google sign in data to authenticate a
/// FirebaseUser and then return that user.
Future<User> signInWithGoogle() async {
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  await firebaseAuth.signInWithCredential(credential);

  final FirebaseUser currentUser = await firebaseAuth.currentUser();
  assert(currentUser.email != null);
  assert(!currentUser.isAnonymous);
  assert(await currentUser.getIdToken() != null);

  if (googleUser != null) {
    // if user does not exist  in users collection, make new user documents in users collections
    user = await createUserDocument();
    return user;
  } else {
    print("account null");
    return null;
  }
}

Future<User> signInWithFacebook() async {
  final facebookLogin = FacebookLogin();
  final facebookAuth = await facebookLogin.logIn(['email']);

  if (facebookAuth.status != FacebookLoginStatus.loggedIn) return null;

  AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: facebookAuth.accessToken.token);

  await firebaseAuth.signInWithCredential(credential);

  final FirebaseUser currentUser = await firebaseAuth.currentUser();
  assert(currentUser.email != null);
  assert(!currentUser.isAnonymous);
  assert(await currentUser.getIdToken() != null);

  await createUserDocument();

  return user;
}

Future<User> createUserDocument() async {
  final FirebaseUser currentUser = await firebaseAuth.currentUser();

  DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();
  if (!doc.exists) {
    usersRef.document(currentUser.uid).setData({
      "id": currentUser.uid,
      "photo": currentUser.photoUrl,
      "email": currentUser.email,
      "name": currentUser.displayName,
      "created_at": DateTime.now()
    });
  }
  doc = await usersRef.document(currentUser.uid).get();
  user = User.fromDocument(doc);
  return user;
}

/// Register users with their email addresses and passwords.
/// Then send an email verification
Future<bool> registerWithEmail(
    String name, String email, String password) async {
  await firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password);

  final FirebaseUser currentUser = await firebaseAuth.currentUser();
  assert(currentUser.email != null);
  assert(!currentUser.isAnonymous);
  await currentUser.sendEmailVerification();

  // Update the name filed of the user
  UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
  userUpdateInfo.displayName = name;
  currentUser.updateProfile(userUpdateInfo);

  return true;
}

/// Sign In user with their email addresses and passwords.
Future<User> signInWithEmail(String email, String password) async {
  await firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password);

  final FirebaseUser currentUser = await firebaseAuth.currentUser();
  assert(currentUser.email != null);
  assert(!currentUser.isAnonymous);

  DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();
  if (!doc.exists) {
    return await createUserDocument();
  }
  user = User.fromDocument(doc);
  return user;
}

Future<void> updateProfile({String name, String photo}) async {
  final FirebaseUser currentUser = await firebaseAuth.currentUser();

  Map<String, dynamic> updatedData = {};
  if (name != null) updatedData['name'] = name;

  usersRef.document(currentUser.uid).updateData(updatedData);

  DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();
  user = User.fromDocument(doc);
}

Future<void> sendEmailVerification() async {
  FirebaseUser user = await firebaseAuth.currentUser();
  user.sendEmailVerification();
}

Future<bool> isEmailVerified() async {
  FirebaseUser user = await firebaseAuth.currentUser();
  return user.isEmailVerified;
}

Future<void> resetPassword(String email) async {
  await firebaseAuth.sendPasswordResetEmail(email: email);
}

/// Signs out the current user
Future<void> signOut() async {
  await firebaseAuth.signOut();
  user = null;
}

String signInCredentialsErrorMsg(error) {
  String authError;
  switch (error.code.toString().toUpperCase()) {
    case 'NETWORK_ERROR':
      authError =
          'No se pudo conectar. Compruebe su conexión a Internet e intentelo de nuevo más tarde.';
      break;
    case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
      authError =
          'Esta cuenta está asociada a . Por favor, inicie sesión con ella.';
      break;
    case 'ERROR_OPERATION_NOT_ALLOWED':
      authError = 'ERROR_OPERATION_NOT_ALLOWED';
      break;
    case 'ERROR_INVALID_ACTION_CODE':
      authError = 'ERROR_INVALID_ACTION_CODE';
      break;
    default:
      authError = 'No se pudo iniciar sesión. Inténtelo de nuevo más tarde';
      break;
  }
  return authError;
}

String signInEmailErrorMsg(error) {
  String authError;
  switch (error.code.toString().toUpperCase()) {
    case 'ERROR_NETWORK_REQUEST_FAILED':
      authError =
          'No se pudo conectar. Compruebe su conexión a Internet e intentelo de nuevo más tarde.';
      break;
    case 'ERROR_INVALID_EMAIL':
      authError = 'Introduce una cuenta de correo electrónico válida';
      break;
    case 'ERROR_WRONG_PASSWORD':
      authError = 'La contraseña que has introducido es incorrecta';
      break;
    case 'ERROR_USER_NOT_FOUND':
      authError =
          'El correo electrónico que has introducido no coincide con ninguna cuenta';
      break;
    case 'ERROR_USER_DISABLED':
      authError =
          'El usuario vinculado a esa cuenta de correo ha sido desactivado';
      break;
    default:
      authError = 'Error';
      break;
  }
  return authError;
}

String signUpErrorMsg(error) {
  String authError;
  switch (error.code.toString().toUpperCase()) {
    case 'ERROR_NETWORK_REQUEST_FAILED':
      authError =
          'No se pudo conectar. Compruebe su conexión a Internet e intentelo de nuevo más tarde.';
      break;
    case 'ERROR_WEAK_PASSWORD':
      authError = 'Tu contraseña debe tener al menos 6 caracteres';
      break;
    case 'ERROR_INVALID_EMAIL':
      authError = 'Introduce una cuenta de correo electrónico válida';
      break;
    case 'ERROR_EMAIL_ALREADY_IN_USE':
      authError = 'Ya hay una cuenta registrada con esa dirección de correo';
      break;
    default:
      authError =
          'No se pudo completar el registro. Inténtalo de nuevo más tarde.';
      break;
  }
  return authError;
}

/// Sign out of the current Google account
void signOutGoogle() async {
  await googleSignIn.signOut();
}
