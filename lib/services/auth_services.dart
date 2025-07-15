import 'package:chateo/services/user_database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  get firebaseAuth => _firebaseAuth;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  //  Register user
  Future<void> signUpSubmit({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendVerification();
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send verification email
  Future<void> sendVerification() async {
    try {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // verify successfully
  Future<bool> verifyEmailSuccessful() async {
    await _firebaseAuth.currentUser?.reload(); // Reload user data
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  // Login user
  Future<void> submitLogin({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Reset password
  Future<void> passwordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // google sign in
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      //   return false;
      // }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if the user exists in Firestore and add them if they don't
      await _usersCollection
          .where('email', isEqualTo: googleUser.email)
          .get()
          .then((doc) {
        if (doc.docs.isEmpty) {
          _userDatabaseServices.storeUserData(
            email: googleUser.email,
            name: googleUser.displayName ?? 'Unknown User',
          );
        } else {
          return true;
        }
      });
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // log out
  Future<void> logOut() async {
    GoogleSignIn googleUser = GoogleSignIn();
    try {
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
        await googleUser.signOut();
      } else {
        await googleUser.signOut();
      }
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

// delete user account
  Future<void> deleteUserAccount() async {
    try {
      _userDatabaseServices.deleteUserAccount();
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
