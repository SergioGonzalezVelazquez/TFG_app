import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tfg_app/models/exercise.dart';
import 'package:tfg_app/models/therapy.dart';
import 'package:tfg_app/models/user.dart';
import 'package:tfg_app/models/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_app/services/firestore.dart';
import 'package:tfg_app/utils/datetime_extensions.dart';

// Gets user and patient collections references
final usersRef = Firestore.instance.collection('users');
final patientRef = Firestore.instance.collection('patient');

class AuthService {
  /// Entry point of the Firebase Authentication SDK.
  FirebaseAuth _firebaseAuth;

  User _user;

  /// Factory constructor which returns a singleton instance of the service
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  bool _initialized = false;

  /// Getters.
  User get user => this._user;
  bool get isAuth => this._user != null;
  PatientStatus get patietStatus => this.user?.patient?.status;
  StreamSubscription<DocumentSnapshot> _patientSubscription;
  StreamController<PatientStatus> _patientStatusStream =
      StreamController<PatientStatus>.broadcast();
  StreamController<PatientStatus> get patientStatusStream =>
      this._patientStatusStream;

  Future<void> _initializePatientListener(String userId) async {
    // Get patient Data
    DocumentSnapshot patientDoc = await patientRef.document(userId).get();
    await _getPatientData(patientDoc);

    // Check daily streak
    DateTime lastExposure = this._user.patient.lastExerciseCompleted;
    if (lastExposure != null &&
        !isToday(lastExposure) &&
        !isYesterday(lastExposure)) {
      this._user.patient.currentDailyStreak = 0;
      await this.updatePatient({"currentDailyStreak": 0});
    }

    // initialize subscription
    _patientSubscription = patientRef
        .document(_user.id)
        .snapshots()
        .listen((DocumentSnapshot doc) async {
      print("llega un patient");
      await _getPatientData(doc);
    });
  }

  Future<void> _getPatientData(DocumentSnapshot doc) async {
    this._user.patient = new Patient.fromDocument(doc);
    _patientStatusStream.sink.add(this._user?.patient?.status);

    if ([
      PatientStatus.hierarchy_pending,
      PatientStatus.hierarchy_completed,
      PatientStatus.in_exercise
    ].contains(this._user.patient.status)) {
      Therapy therapy = await getPatientCurrentTherapy();
      this._user.patient.currentTherapy = therapy;

      // CAMBIAR PARA QUE LOS EJERCICIOS SEAN UN STREAM BUILDER
      if (this._user.patient.status == PatientStatus.in_exercise) {
        List<Exercise> exercises = await getPatientExercises();
        this._user.patient.exercises = exercises;
        print("EJERCICIOS " + exercises.length.toString());
      }
    }
  }

  /// Initialize service
  Future<void> init() async {
    print("auth service init");
    if (!_initialized) {
      _initialized = true;

      // Obtain an instance of FirebaseAuth
      _firebaseAuth = FirebaseAuth.instance;

      // Get the currently signed-in user
      print("await get signed in user");
      await _getSignedInUser();
      print("fin get signed in user");

      if (isAuth) {
        print("isAuth");
        await _initializePatientListener(_user.id);
      } else {
        print("no auth");
      }
    }
  }

  void dispose() {
    print("auth dispose");
    _initialized = false;
    _patientSubscription.cancel();
    _patientStatusStream.close();
  }

  /// Get the currently signed-in user
  /// According to Google's official documentation, the recommended way to get
  /// the current user is by calling the getCurrentUser method.
  /// If no user is signed in, getCurrentUser returns null
  Future<void> _getSignedInUser() async {
    FirebaseUser currentUser = await this._firebaseAuth.currentUser();

    if (currentUser != null) {
      // User is signed in
      DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();

      if (doc.exists) {
        this._user = User.fromDocument(doc);

        // Get patient data for this user
        // await _getPatientData();
      }
    }
  }

  /// create document in 'patient' collection for current auth user
  /// firebase cloud functions trigger this event and will calculate
  /// the type of patient based on pretest questionnaire answers
  Future<void> _createPatientDocument(String userId) async {
    String status = PatientStatus.pretest_pending.toString().split(".")[1];
    await patientRef.document(userId).setData(
        {"status": status, "bestDailyStreak": 0, "currentDailyStreak": 0});
    //await _initializePatientListener(userId);
  }

  Future<void> updatePatient(Map<String, dynamic> data) async {
    await patientRef.document(this._user.id).updateData(data);
  }

  Future<void> updatePatientStatus(PatientStatus status) async {
    String strStatus = status.toString().split(".")[1];
    await patientRef
        .document(this._user.id)
        .updateData({"status": strStatus}).then((value) async {
      //await this._getPatientData();
    });
  }

  /// Use the Google sign in data to authenticate a
  /// FirebaseUser and then return that user.
  /// https://firebase.google.com/docs/auth/android/google-signin
  /// https://fireship.io/lessons/flutter-firebase-google-oauth-firestore/
  Future<void> signInWithGoogle() async {
    print("singInWithGoogle");
    // Step 1. Login with Google. This shows Google’s native login screen and provides
    // the idToken and accessToken
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      /// Step 2. Login to Firebase. Get an ID token from the GoogleSignInAccount object,
      /// exchange it for a Firebase credential, and authenticate with Firebase
      /// using the Firebase credential
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(currentUser.email != null);
      assert(!currentUser.isAnonymous);
      assert(await currentUser.getIdToken() != null);

      /// Step 3: Create Firestore if user document does not exists.
      await this.createUserDocument();
    }
  }

  /// Use the Facebook sign in data to authenticate a
  /// FirebaseUser and then return that user.
  Future<void> signInWithFacebook() async {
    // Step 1. Login with Facebook. This shows Facebook native login screen and provides
    // the idToken and accessToken
    final facebookLogin = FacebookLogin();
    final facebookAuth = await facebookLogin.logIn(['email']);

    if (facebookAuth.status != FacebookLoginStatus.loggedIn) return null;

    /// Step 2. Login to Firebase. Get an ID token from the FacebookLogin object,
    /// exchange it for a Firebase credential, and authenticate with Firebase
    /// using the Firebase credential
    AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAuth.accessToken.token);

    await _firebaseAuth.signInWithCredential(credential);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);
    assert(await currentUser.getIdToken() != null);

    /// Step 3: Create Firestore if user document does not exists.
    await this.createUserDocument();
  }

  /// Method which takes in an email address and password,
  /// validates them, and then signs a user in with the
  /// signInWithEmailAndPassword method.
  Future<void> signInWithEmail(String email, String password) async {
    // If successful, it also signs the user in into the app
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);

    await this.createUserDocument();
  }

  /// Register users with their email addresses and passwords.
  /// Then send an email verification
  Future<bool> registerWithEmail(
      String name, String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(currentUser.email != null);
    assert(!currentUser.isAnonymous);
    await currentUser.sendEmailVerification();

    // Update the name field of the user
    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = name;
    currentUser.updateProfile(userUpdateInfo);

    // User document will be created when email is verified
    return true;
  }

  Future<void> createUserDocument() async {
    print("create user document");
    FirebaseUser currentUser = await _firebaseAuth.currentUser();

    print("currentUser Id: " + currentUser.uid);

    DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();
    bool exists = doc.exists;
    // Firt time user is logged-in
    if (!doc.exists) {
      print("doc exists");
      await usersRef.document(currentUser.uid).setData({
        "id": currentUser.uid,
        "photo": currentUser.photoUrl,
        "email": currentUser.email,
        "name": currentUser.displayName,
        "created_at": DateTime.now()
      });
    } else {
      print("doc exists");
    }

    doc = await usersRef.document(currentUser.uid).get();
    this._user = User.fromDocument(doc);
    if (!exists) {
      await this._createPatientDocument(currentUser.uid);
    }
    await _initializePatientListener(_user.id);

    // Save user id in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
  }

  /// Returns true if the user's email is verified.
  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  /// Send email to the user for verification after they have signed up
  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  /// Send email to reset password it user forget it
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Update a user's basic profile information—the user's
  /// display name and profile photo URL—with the Firebase updateProfile method
  Future<void> updateProfile({String name, String photo}) async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    Map<String, dynamic> updatedData = {};
    if (name != null) updatedData['name'] = name;

    usersRef.document(currentUser.uid).updateData(updatedData);

    DocumentSnapshot doc = await usersRef.document(currentUser.uid).get();
    this._user = User.fromDocument(doc);
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    this._user = null;

    // Delete user id in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
  }
}
