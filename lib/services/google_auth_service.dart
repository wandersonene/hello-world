import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart' show kIsWeb; // For web-specific logic if needed

class GoogleAuthService with ChangeNotifier {
  // For web, you'd typically configure the OAuth Client ID here or ensure it's set up in your index.html
  // For mobile, this Client ID is not explicitly set in the code but via google-services.json / Info.plist
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope, // Access to files created or opened by the app.
      // drive.DriveApi.driveAppdataScope, // Access to app data folder (hidden from user)
      // Consider drive.DriveApi.driveScope for full access if absolutely necessary and justified.
    ],
    // clientId: kIsWeb ? "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com" : null, // Example for web
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  GoogleAuthService() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      notifyListeners();
    });
    // Silently sign in the user if they've signed in before
    _googleSignIn.signInSilently();
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      _currentUser = account;
      notifyListeners();
      return account;
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // Handle specific errors (e.g., PlatformException for network issues, sign-in cancelled)
      _currentUser = null;
      notifyListeners();
      throw Exception('Failed to sign in with Google: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (error) {
      print('Error during Google Sign-Out: $error');
      throw Exception('Failed to sign out: $error');
    }
  }

  // Call this to get an authenticated client for Google APIs
  Future<Map<String, String>?> getAuthHeaders() async {
    if (_currentUser == null) {
      // Attempt to sign in silently or prompt user
      await signInSilently();
      if(_currentUser == null) {
        print("User not signed in. Cannot get auth headers.");
        return null;
      }
    }
    final GoogleSignInAuthentication auth = await _currentUser!.authentication;
    return {
      'Authorization': 'Bearer ${auth.accessToken}',
      // 'X-Goog-AuthUser': '0', // Optional, for specific use cases
    };
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = account;
        notifyListeners();
      }
      return account;
    } catch (error) {
      print('Error during silent sign-in: $error');
      // Don't throw here, silent sign-in failure is common if user never signed in.
      return null;
    }
  }

  // This method can be used by DriveService to get an authenticated client
  // However, GoogleSignIn itself provides authenticated access.
  // The `googleapis` package often uses `AuthClient` which can be created from access tokens.
  // For Drive API, the `DriveApi` constructor takes an `AuthClient`.
  // `google_sign_in` provides `authHeaders` which can be used with a custom client,
  // or its `authentication` object can provide an `accessToken`.
  // Let's ensure DriveService can use these headers.
}
