# CVS Health Digital Wallet - Get Started Wizard Flow

## Overview
The "Get Started" wizard is a 5-step guided flow that takes new users through identity verification and credential setup for the Digital Wallet application.

## Wizard Steps

### Step 1: QR Code Scanning (signin_screen.dart)
**Screen:** `_buildQRScanScreen()`
- User is presented with camera interface
- Instructions: "Align QR code within the frame"
- Features:
  - Real-time QR code detection using `mobile_scanner`
  - Camera permission request if not granted
  - Manual entry fallback option
  - Back button to return to Welcome screen
- **Transition:** On successful QR scan → Step 2

### Step 2: Identity Verification Information (identity_verification_info_screen.dart)
**Screen:** `IdentityVerificationInfoScreen`
- Informational screen explaining why identity verification is needed
- Content sections:
  1. **Why We Need Your Information:**
     - Security: Protect account from unauthorized access
     - Trust & Compliance: Regulatory requirements
     - Accuracy: Ensure data accuracy
     - Privacy: Encryption and security measures
  2. Timeline info: "Takes about 2-3 minutes"
- **Transition:** On "Continue" button click → Step 3

### Step 3: Verification Method Selection (verification_method_screen.dart)
**Screen:** `VerificationMethodScreen`
- User selects preferred identity verification method
- **5 Available Methods:**
  1. **Private ID** 🆔
     - Face Scan + Document Verification
  2. **Jumio** 📸
     - Face Scan + Document Verification
  3. **Google Wallet** 🔐
     - Verify with Google account
  4. **Mobile Driver's License** 🚗
     - Use state-issued digital ID
  5. **CVS Account** 💳
     - Verify with existing cvs.com ID
- UI Features:
  - Selection highlights selected method in red (#CC0000)
  - Checkmark icon shows selected item
  - Continue button disabled until method is selected
- **Transition:** On method selection and continue → Step 4

### Step 4: User Information Confirmation (user_info_confirmation_screen.dart)
**Screen:** `UserInfoConfirmationScreen`
- Display mock user information for verification
- **Mock User Data:**
  - First Name: John
  - Last Name: Thompson
  - Date of Birth: 6/15/1985
  - Country: United States
- **UI Elements:**
  - User avatar placeholder (👤)
  - Info cards displaying each field
  - Security notice: "We use this information to verify your identity..."
  - Two action buttons:
    - ✅ "Information is Correct" (Primary red button)
    - "Edit Information" (Outlined white button)
- **Transition:** On "Information is Correct" → Step 5

### Step 5: Verification Success (verification_success_screen.dart)
**Screen:** `VerificationSuccessScreen`
- Success animation with scale and fade effects
- Features:
  - Large checkmark (✅) with animation
  - "Verification Successful!" message
  - Sub-message: "Your identity has been verified"
  - Feature preview box showing accessible features:
    - 🆔 Digital Identity
    - 📋 Credentials
    - 🏥 Health Agent
  - Auto-redirect timer: "Redirecting in 3 seconds..."
  - Manual "Go to Wallet" button
- **Transition:** After 3 seconds or manual button click → Main app (`onAuthenticated()`)

## Navigation Flow

```
Welcome Screen
    ↓
    ├→ "Get Started" button
    │   ↓
    │   Sign-In Screen (Step 0: QR Scan)
    │   ↓
    │   Identity Verification Info (Step 1)
    │   ↓
    │   Verification Method Selection (Step 2)
    │   ↓
    │   User Info Confirmation (Step 3)
    │   ↓
    │   Verification Success (Step 4)
    │   ↓
    │   Main App (4-tab wallet)
    │
    └→ "Verify Existing DID" button
        ↓
        [Same flow as above]
```

## State Management

**Location:** `lib/screens/signin_screen.dart` - `_SignInScreenState`

**State Variables:**
- `_currentStep: int` - Tracks which wizard step (0-4)
- `_scannedDid: String?` - Stores scanned or manually entered DID
- `_userInfo: UserInfo?` - Stores user data for confirmation
- `_cameraPermission: PermissionStatus?` - Camera permission status
- `_showManualEntry: bool` - Toggle manual DID entry
- `_errorMessage: String?` - Error messages

**State Transitions:**
- `_handleQRScanned()` → QR detected → move to step 1
- `_handleIdentityInfoContinue()` → step 1 button → move to step 2
- `_handleMethodSelected()` → step 2 selection → move to step 3 (load mock user)
- `_handleUserInfoConfirmed()` → step 3 confirm → move to step 4
- `_handleVerificationSuccess()` → step 4 auto/manual → authenticate and go to main app

## User Models

**Location:** `lib/models/user_model.dart`

```dart
class UserInfo {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String country;
  
  // Formatted properties
  String get fullName => '$firstName $lastName';
  String get formattedDOB => '${dateOfBirth.month}/${dateOfBirth.day}/${dateOfBirth.year}';
  
  // Mock factory
  static UserInfo mockUser() {
    return UserInfo(
      firstName: 'John',
      lastName: 'Thompson',
      dateOfBirth: DateTime(1985, 6, 15),
      country: 'United States',
    );
  }
}
```

## Design System

**Colors:**
- Primary Red: #CC0000 (CVS Health brand)
- Dark Red: #99000B (Gradient)
- Dark Blue: #17447C (Secondary)
- Background Gray: #F5F5F5

**Typography:**
- Titles: 20-28px, FontWeight.w600-w700
- Body: 14-16px, FontWeight.w500
- Labels: 12-13px, FontWeight.w500

**Components:**
- Red gradient backgrounds for headers
- Rounded corners: 12-20px border radius
- Card-style info displays with subtle borders
- Material Design 3 buttons and text fields

## Future Enhancements

1. **Edit Information Flow:** Implement "Edit Information" button to allow users to modify details
2. **Additional Verification Methods:** Add real integrations with Jumio, Google Wallet, etc.
3. **Multi-language Support:** Localize wizard text
4. **Step Progress Indicator:** Show "Step 2 of 5" progress
5. **Error Recovery:** Enhanced error handling and retry logic
6. **Analytics:** Track user progression through wizard steps

## Testing Checklist

- [ ] QR code scanning works with camera permission
- [ ] Manual entry fallback works
- [ ] All 5 verification methods display correctly
- [ ] Selection state persists correctly
- [ ] User info confirms and shows success screen
- [ ] 3-second auto-redirect works
- [ ] Manual "Go to Wallet" button works
- [ ] Back button returns to welcome screen
- [ ] Authentication provider receives correct DID
- [ ] Main app loads after successful verification
