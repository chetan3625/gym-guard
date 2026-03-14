## Token Refresh Implementation Guide

### What was implemented:

1. **Dependencies Added** (pubspec.yaml):
   - `workmanager: ^0.5.2` - For background task scheduling
   - `http: ^1.1.0` - For HTTP requests

2. **New Services Created**:
   - `token_refresh_service.dart` - Handles token refresh logic
   - `token_refresh_manager.dart` - Manages WorkManager initialization and scheduling

3. **Updated Services**:
   - `session_service.dart` - Now stores and manages refresh tokens
   - `login_services.dart` - Added `refreshToken()` method for API calls

4. **Updated Controllers**:
   - `login_view_controller.dart` - Now saves refresh token on login

5. **Updated Configuration**:
   - `main.dart` - Initializes TokenRefreshManager on app startup
   - `AndroidManifest.xml` - Added required permissions for WorkManager

### How it works:

1. When user logs in, both access token and refresh token are saved
2. WorkManager schedules a background task every 15 minutes
3. The background task calls the `/api/v1/auth/token` endpoint with the refresh token
4. If successful, the new access token is saved
5. User remains logged in without interruption

### Token Refresh Flow:

```
Login → Save tokens → WorkManager starts → Every 15 min → Call /api/v1/auth/token 
→ Get new token → Update SessionService → Continue session
```

### Next Steps:

1. Run `flutter pub get` to install new dependencies
2. Test on Android device/emulator
3. Verify background task is running (check logcat for debug messages)
4. Monitor token refresh in your backend logs

### Notes:

- Frequency is set to 15 minutes (before 20-minute expiry)
- Requires INTERNET and RECEIVE_BOOT_COMPLETED permissions on Android
- Background task runs even when app is closed
- If refresh fails, user will be logged out on next app launch
