import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/entities/user.dart';

// OAuth Result Model
class OAuthResult {
  final String? accessToken;
  final String? idToken;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? providerId;
  final Map<String, dynamic>? additionalUserInfo;

  OAuthResult({
    this.accessToken,
    this.idToken,
    this.email,
    this.name,
    this.photoUrl,
    this.providerId,
    this.additionalUserInfo,
  });
}

// OAuth Service Interface
abstract class AuthService {
  Future<OAuthResult?> signInWithGoogle();
  Future<OAuthResult?> signInWithApple();
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<OAuthResult?> getCurrentUser();
}

class AuthServiceImpl implements AuthService {
  final GoogleSignIn _googleSignIn;
  
  AuthServiceImpl({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

  @override
  Future<OAuthResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      return OAuthResult(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
        email: account.email,
        name: account.displayName,
        photoUrl: account.photoUrl,
        providerId: account.id,
        additionalUserInfo: {
          'provider': 'google',
          'isNewUser': false, // Would need to check with backend
          'profile': {
            'email': account.email,
            'name': account.displayName,
            'picture': account.photoUrl,
          },
        },
      );
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<OAuthResult?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // This would be set from environment variables
          clientId: 'your.bundle.id',
          redirectUri: Uri.parse('https://your-app.com/auth/apple/callback'),
        ),
      );

      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      }

      return OAuthResult(
        accessToken: credential.authorizationCode,
        idToken: credential.identityToken,
        email: credential.email,
        name: fullName,
        providerId: credential.userIdentifier,
        additionalUserInfo: {
          'provider': 'apple',
          'isNewUser': false, // Apple doesn't provide this info reliably
          'profile': {
            'email': credential.email,
            'name': fullName,
            'given_name': credential.givenName,
            'family_name': credential.familyName,
          },
        },
      );
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          return null; // User cancelled
        }
      }
      throw AuthException('Apple sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      // Apple doesn't require explicit sign out
    } catch (e) {
      throw AuthException('Sign-out failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();
      return isGoogleSignedIn;
      // Note: Apple doesn't provide a way to check if user is still signed in
    } catch (e) {
      return false;
    }
  }

  @override
  Future<OAuthResult?> getCurrentUser() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      return OAuthResult(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
        email: account.email,
        name: account.displayName,
        photoUrl: account.photoUrl,
        providerId: account.id,
        additionalUserInfo: {
          'provider': 'google',
          'profile': {
            'email': account.email,
            'name': account.displayName,
            'picture': account.photoUrl,
          },
        },
      );
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }
}

// Custom Exception
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}