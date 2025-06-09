import 'package:flutter/foundation.dart'; // For kIsWeb and ChangeNotifier
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

// Custom Authenticated HTTP Client for use with googleapis package
class WebAuthenticatedHttpClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _client;

  WebAuthenticatedHttpClient(this._account) : _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _account.authHeaders;
    if (headers['Authorization'] != null) {
      request.headers['Authorization'] = headers['Authorization']!;
    }
    // Important for web: tells Google which user is making the request if multiple are logged in browser.
    // It might not always be '0'. Handled by google_sign_in usually.
    // request.headers['X-Goog-AuthUser'] = '0';
    return _client.send(request);
  }
   @override
  void close() {
    _client.close();
  }
}


class GoogleAuthServiceWeb with ChangeNotifier {
  // IMPORTANT: For Web, the OAuth Client ID must be configured in your Google Cloud Console
  // and you should ensure your app's authorized JavaScript origins and redirect URIs are correct.
  // The google_sign_in package for web handles much of this, but the GCP setup is crucial.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveReadonlyScope, // Read-only access is sufficient for MVP
      // drive.DriveApi.driveFileScope, // If app needs to create/open specific files it created
    ],
    // clientId: "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com", // Set this if not using default setup
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;
  drive.DriveApi? driveApi;

  GoogleAuthServiceWeb() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      if (_currentUser != null) {
        _initializeDriveApi();
      } else {
        driveApi = null;
      }
      notifyListeners();
    });
    // Attempt to sign in silently on startup
    signInSilently();
  }

  void _initializeDriveApi() {
    if (_currentUser == null) {
      driveApi = null;
      return;
    }
    // Create an authenticated client
    final authClient = WebAuthenticatedHttpClient(_currentUser!);
    driveApi = drive.DriveApi(authClient);
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        _initializeDriveApi();
        notifyListeners();
      }
      return account;
    } catch (error) {
      print('Error during Google Sign-In (Web): $error');
      _currentUser = null;
      driveApi = null;
      notifyListeners();
      throw Exception('Failed to sign in with Google: $error');
    }
  }

  Future<void> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = account;
        _initializeDriveApi();
        notifyListeners();
      }
    } catch (error) {
      print('Error during silent sign-in (Web): $error');
      // Don't throw, as this can fail if user has not signed in before or session expired
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      driveApi = null;
      notifyListeners();
    } catch (error) {
      print('Error during Google Sign-Out (Web): $error');
      throw Exception('Failed to sign out: $error');
    }
  }
}
