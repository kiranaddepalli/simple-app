# CVS Health Digital Wallet - Complete Implementation Guide

## Project Overview
A comprehensive Flutter-based digital wallet application designed to store and manage Decentralized Identities (DIDs) and Verifiable Credentials (VCs) with the CVS Health color palette.

## Architecture

### Tech Stack
- **Framework**: Flutter 3.35.7
- **Language**: Dart 3.6.0
- **Java Runtime**: Java 21 LTS
- **State Management**: Provider 6.1.5
- **Build System**: Gradle 8.11.1
- **Android Gradle Plugin**: 8.7.3
- **Kotlin**: 2.1.0

### Project Structure

```
lib/
├── main.dart                          # App entry point with navigation
├── models/
│   ├── did_model.dart                 # Digital Identity model
│   └── credential_model.dart          # Verifiable Credential model
├── providers/
│   └── wallet_provider.dart           # State management (ChangeNotifier)
└── screens/
    ├── qr_scanner_screen.dart         # Initial QR scanning
    ├── verification_screen.dart       # Verification processing
    ├── home_screen.dart               # Main dashboard
    ├── credentials_screen.dart        # Credentials management
    ├── profile_screen.dart            # Digital ID viewing
    └── settings_screen.dart           # App settings
```

## User Flow

### 1. **Startup/Initialization**
- App launches and displays QR Scanner screen
- User scans their Digital ID QR code
- Verification screen shows progress
- Upon successful verification, redirects to home screen

### 2. **Home Screen**
- Welcome header with credential count
- Quick action buttons (Scan QR, Learn More)
- Credential cards display with status (Active/Expired)
- Shows member ID and expiration info

### 3. **Credentials Tab**
- View all credentials with filtering (All, Active, Expired)
- Add new credentials via QR scanning
- Detailed credential information on tap
- Displays issuance date, expiration date, and validity

### 4. **Profile Tab**
- Display Digital ID information
- Shows DID, issuer, contact details
- Validity information and expiration status
- Share Digital ID functionality

### 5. **Settings Tab**
- Security settings (Biometric, PIN)
- Notification preferences
- Appearance/Theme settings
- About and legal information
- Logout option

## Key Features

### Models

#### DigitalIdentity (DID)
```dart
- did: Decentralized identifier
- name: User full name
- email: User email
- phoneNumber: Contact number
- issuedDate: When DID was issued
- expiryDate: When DID expires
- issuer: Issuing authority
- isVerified: Verification status
```

#### VerifiableCredential
```dart
- id: Unique credential ID
- type: Credential type (Insurance, Health Passport, etc.)
- issuer: Issuing organization
- subject: DID reference
- issuanceDate: When issued
- expirationDate: Expiration date
- credentialSubject: Credential details
- isVerified: Verification status
```

### Wallet Provider (State Management)
- Manages DID initialization
- Stores and manages credentials list
- Handles credential addition/removal
- Tracks wallet initialization status
- Provides active/expired credential filtering

### UI Components

#### Bottom Navigation
- 4 tabs: Home, Credentials, Profile, Settings
- CVS Health red selected color (#CC0000)
- Professional material design

#### Credential Cards
- Status indicators (Active/Expired)
- Member ID display
- Days until expiry countdown
- Expandable detailed view

#### Verification Screen
- Animated loading indicator
- Success confirmation animation
- Error handling

## Color Palette
- **Primary Red**: #CC0000 (CVS Health brand)
- **Secondary Blue**: #17447C (Professional accent)
- **Success Green**: #00AA00
- **Error Red**: #FF0000
- **Neutral Gray**: Various shades for text and borders

## Installation & Setup

### Prerequisites
- Flutter 3.35.7+
- Java 21 LTS
- Android SDK with API 36

### Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Build APK**:
   ```bash
   flutter build apk --debug
   ```

3. **Run on device**:
   ```bash
   flutter run -d <device_id>
   ```

## Mock Data Flow

The app uses mock data for demonstration:
- QR codes are simulated with timestamp-based IDs
- Digital IDs are auto-generated from QR input
- Credentials include mock member IDs and coverage details
- Verification delays simulate real processing (2 seconds)

## Future Enhancements

1. **Real QR Integration**: Use actual QR code library
2. **Biometric Authentication**: Fingerprint/Face ID
3. **Blockchain Integration**: Real DID resolution
4. **Credential Verification**: Cryptographic validation
5. **Backup & Recovery**: Secure wallet backup
6. **Multi-language Support**: I18n implementation
7. **Dark Mode**: System-aware theme
8. **Push Notifications**: Credential expiry alerts

## Testing

### UI Testing
- Navigate through all tabs
- Test credential addition
- Verify status transitions
- Check data persistence

### Build Testing
- APK builds successfully
- No compilation errors
- Proper hot reload support

## Notes

- The app demonstrates a professional digital wallet interface
- All UI is responsive and adapts to different screen sizes
- Mock verification provides realistic UX
- CVS Health branding is consistently applied
- Code is well-structured for future enhancements
