/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

class AuthenticationService {
  signIn.GoogleSignInAccount account;

  Future<User> authenticate() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    final signIn.GoogleSignIn googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveFileScope]);

    account = await googleSignIn.signIn();

    if (account != null) {
      final signIn.GoogleSignInAuthentication googleSignInAuthentication =
          await account.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }
}
*/
