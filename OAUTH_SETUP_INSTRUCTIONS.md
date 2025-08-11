# OAuth Authentication Setup Instructions

This document provides step-by-step instructions for setting up Google and Apple OAuth authentication in the Pulse trading app.

## Prerequisites

1. Create a `.env` file based on `.env.example`
2. Ensure you have developer accounts for Google and Apple

## Google Sign-In Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sign-In API

### Step 2: Configure OAuth Consent Screen

1. Go to APIs & Services > OAuth consent screen
2. Choose "External" user type
3. Fill in the required information:
   - App name: `Stock Signal: AI Trading Alert`
   - User support email: Your email
   - Developer contact information: Your email

### Step 3: Create OAuth Client IDs

#### For Android:
1. Go to APIs & Services > Credentials
2. Click "Create Credentials" > "OAuth client ID"
3. Select "Android" as application type
4. Package name: `com.stocksignal.pulse`
5. SHA-1 certificate fingerprint: 
   - For debug: Get from `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - For release: Use your production keystore SHA-1

#### For iOS:
1. Create another OAuth client ID
2. Select "iOS" as application type  
3. Bundle ID: `com.stocksignal.pulse`

#### For Web (Required for Flutter):
1. Create a third OAuth client ID
2. Select "Web application" as application type
3. No additional configuration needed for basic setup

### Step 4: Download Configuration Files

#### Android:
1. Download `google-services.json` from the Android OAuth client
2. Place it in `android/app/` directory
3. **Important**: This file is already in `.gitignore` and should not be committed

#### iOS:
1. Download `GoogleService-Info.plist` from the iOS OAuth client
2. Place it in `ios/Runner/` directory
3. **Important**: This file is already in `.gitignore` and should not be committed

### Step 5: Update Environment Variables

Add to your `.env` file:
```
GOOGLE_CLIENT_ID=your_web_client_id_here.apps.googleusercontent.com
```

Note: Use the **Web** client ID, not Android or iOS client ID.

## Apple Sign-In Setup

### Step 1: Configure App ID

1. Go to [Apple Developer Console](https://developer.apple.com/)
2. Navigate to Certificates, Identifiers & Profiles > Identifiers
3. Select your App ID or create a new one
4. Enable "Sign In with Apple" capability
5. Configure domains and email addresses if needed

### Step 2: Create Service ID

1. Create a new identifier with type "Services IDs"
2. Identifier: `com.stocksignal.pulse.signin`
3. Enable "Sign In with Apple"
4. Configure Web Authentication:
   - Primary App ID: Your app's bundle ID
   - Return URLs: Add your app's custom URL scheme

### Step 3: Create Key for Apple Sign-In

1. Go to Keys section
2. Create a new key
3. Enable "Sign In with Apple"
4. Download the key file (.p8)
5. Note the Key ID and Team ID

### Step 4: Update Environment Variables

Add to your `.env` file:
```
APPLE_SERVICE_ID=com.stocksignal.pulse.signin
APPLE_TEAM_ID=your_team_id_here
APPLE_KEY_ID=your_key_id_here
```

### Step 5: iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.stocksignal.pulse</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.stocksignal.pulse</string>
        </array>
    </dict>
</array>
```

## Testing OAuth Integration

### Development Testing

1. Ensure your `.env` file has the required OAuth configuration
2. Run the app in development mode
3. Test both Google and Apple sign-in flows
4. Verify user profile data is correctly retrieved

### Production Considerations

1. **Security**: Never commit actual API keys to version control
2. **Environment Variables**: Use different keys for development/staging/production
3. **App Store Review**: Apple Sign-In is required if you offer any other third-party authentication
4. **Privacy**: Ensure your privacy policy covers data collection from OAuth providers

## Troubleshooting

### Common Google Sign-In Issues

1. **SHA-1 Certificate Mismatch**: Ensure debug SHA-1 matches what's configured in Google Console
2. **Package Name Mismatch**: Verify `applicationId` in `build.gradle.kts` matches Google Console
3. **google-services.json**: Must be in `android/app/` directory, not subdirectories

### Common Apple Sign-In Issues

1. **Bundle ID Mismatch**: iOS bundle ID must match what's configured in Apple Developer Console
2. **Capability Missing**: Ensure "Sign In with Apple" is enabled in Xcode project capabilities
3. **Service ID Configuration**: Web Authentication must be properly configured with correct return URLs

### Debug Commands

```bash
# Check Android debug certificate
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Verify Flutter dependencies
flutter pub get
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
```

## Security Best Practices

1. **Environment Variables**: 
   - Use different OAuth apps for development and production
   - Rotate keys regularly
   - Monitor usage in OAuth provider consoles

2. **Client Configuration**:
   - Validate OAuth responses on your backend
   - Implement proper session management
   - Use secure token storage

3. **App Store Compliance**:
   - Include Apple Sign-In if offering other OAuth methods
   - Update privacy policy to cover OAuth data collection
   - Implement proper user data deletion flows

## Next Steps

After completing OAuth setup:

1. Test authentication flows thoroughly
2. Implement backend user management
3. Set up Alpaca API integration for real market data
4. Configure production environment variables
5. Prepare for app store submission

For additional support, refer to:
- [Google Sign-In Flutter Documentation](https://pub.dev/packages/google_sign_in)
- [Apple Sign-In Flutter Documentation](https://pub.dev/packages/sign_in_with_apple)
- [Flutter OAuth Best Practices](https://flutter.dev/docs/development/data-and-backend/google-apis)