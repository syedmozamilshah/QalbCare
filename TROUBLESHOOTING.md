# QalbCare Troubleshooting Guide

This guide helps you resolve common issues with the QalbCare project setup and deployment.

## Table of Contents

1. [Backend Issues](#backend-issues)
2. [Frontend Issues](#frontend-issues)
3. [Android Build Issues](#android-build-issues)
4. [Network Connection Issues](#network-connection-issues)
5. [Firebase Configuration Issues](#firebase-configuration-issues)
6. [Common Error Messages](#common-error-messages)

---

## Backend Issues

### Issue: Backend fails to start
**Error**: `ImportError: No module named 'app.main'`

**Solution**:
1. Ensure you're in the backend directory
2. Activate the virtual environment:
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```
3. Install dependencies:
   ```powershell
   pip install -r requirements.txt
   ```

### Issue: Google API Key not working
**Error**: `EnvironmentError: GOOGLE_API_KEY is missing`

**Solution**:
1. Check your `.env` file in the backend directory
2. Ensure `GOOGLE_API_KEY` is set correctly
3. Get a valid API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

### Issue: ChromaDB initialization errors
**Error**: `chromadb.errors.ChromaError`

**Solution**:
1. Delete the `data/chroma_db` directory
2. Restart the backend server
3. The system will automatically use fallback mode

---

## Frontend Issues

### Issue: Flutter packages not found
**Error**: `pub get failed`

**Solution**:
1. Run `flutter clean`
2. Run `flutter pub get`
3. If still failing, check your Flutter installation:
   ```powershell
   flutter doctor
   ```

### Issue: Environment variables not loading
**Error**: `EnvironmentService.apiBaseUrl returns empty`

**Solution**:
1. Check if `assets/.env` exists
2. Ensure the file contains:
   ```
   API_BASE_URL=http://192.168.2.2:8000
   ```
3. Restart the Flutter app

### Issue: Firebase initialization failed
**Error**: `FirebaseOptions not configured`

**Solution**:
1. Check your Firebase configuration in `assets/.env`
2. Ensure all Firebase fields are populated
3. Verify your Firebase project is active

---

## Android Build Issues

### Issue: SDK version conflicts
**Error**: `Failed to find target with hash string 'android-35'`

**Solution**:
1. Open Android Studio
2. Go to SDK Manager
3. Install Android 15 (API level 35)
4. Run `flutter clean` and rebuild

### Issue: NDK not found
**Error**: `NDK not found`

**Solution**:
1. Install NDK version 27.0.12077973 from Android Studio
2. Set `ANDROID_NDK_HOME` environment variable
3. Restart your terminal

### Issue: Plugin compatibility issues
**Error**: `awesome_notifications requires minSdk 23`

**Solution**:
The build configuration is already fixed to use minSdk 23. If you still see this error:
1. Run `flutter clean`
2. Delete `build` directory
3. Run `flutter build apk`

---

## Network Connection Issues

### Issue: API connection failed
**Error**: `Network connection error`

**Solution**:
1. Check if backend is running on port 8000
2. Test connection:
   ```powershell
   cd frontend
   .\test_api_connection.ps1
   ```
3. Switch network configuration:
   ```powershell
   cd frontend
   .\switch_api_config.ps1 -Target device
   ```

### Issue: CORS errors
**Error**: `Access to XMLHttpRequest has been blocked by CORS policy`

**Solution**:
1. Ensure your frontend URL is in the backend's CORS allowed origins
2. Check `backend/.env` for `ALLOWED_ORIGINS`
3. Restart the backend server

---

## Firebase Configuration Issues

### Issue: Firebase Auth not working
**Error**: `Firebase Auth domain mismatch`

**Solution**:
1. Check your Firebase project settings
2. Ensure `FIREBASE_AUTH_DOMAIN` matches your project
3. Verify your app is registered in Firebase console

### Issue: Firestore permissions denied
**Error**: `Permission denied`

**Solution**:
1. Check your Firestore security rules
2. Ensure authentication is working
3. Verify user is logged in before accessing Firestore

---

## Common Error Messages

### `Exception: Server did not return a valid response`
**Cause**: Backend API is not responding correctly
**Solution**: 
1. Check backend logs
2. Verify API endpoint is correct
3. Test API manually with curl or Postman

### `Exception: Network connection error`
**Cause**: Cannot reach backend server
**Solution**:
1. Check if backend is running
2. Verify IP address configuration
3. Check firewall settings

### `Exception: Failed to send message: 429`
**Cause**: Rate limit exceeded
**Solution**:
1. Wait for rate limit to reset
2. Reduce request frequency
3. Check rate limit settings in backend

### `Exception: Invalid response format`
**Cause**: API returned unexpected data format
**Solution**:
1. Check backend logs for errors
2. Verify API endpoint is correct
3. Update API service if needed

---

## Quick Fix Commands

### Reset entire project:
```powershell
# From project root
.\setup_project.ps1 -Setup full
```

### Reset backend only:
```powershell
cd backend
Remove-Item -Recurse -Force venv
Remove-Item -Recurse -Force data
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Reset frontend only:
```powershell
cd frontend
flutter clean
flutter pub get
```

### Reset Android build:
```powershell
cd frontend
flutter clean
Remove-Item -Recurse -Force build
flutter build apk --debug
```

---

## Getting Help

If you're still experiencing issues:

1. **Check the logs**: Look for error messages in the terminal
2. **Run diagnostics**: Use `flutter doctor` and `python --version`
3. **Test components**: Use the provided test scripts
4. **Check configuration**: Verify all .env files are properly set up

For persistent issues, create a GitHub issue with:
- Error message
- Steps to reproduce
- Your environment (OS, Flutter version, Python version)
- Configuration files (without sensitive data)

---

## Prevention Tips

1. **Regular Updates**: Keep Flutter and Python dependencies updated
2. **Environment Management**: Use virtual environments for Python
3. **Configuration Backup**: Keep backup copies of working .env files
4. **Testing**: Test API connections before full deployment
5. **Version Control**: Commit working configurations to git

Remember: Most issues are configuration-related. Double-check your .env files and network settings first!
