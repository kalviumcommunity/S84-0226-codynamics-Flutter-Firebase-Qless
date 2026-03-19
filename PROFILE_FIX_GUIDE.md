# Profile Fix Guide

## Problem
Shop name and owner name showing as "Unknown Shop" or "Shop Name Not Set" even after signing up.

## Solutions Implemented

### 1. Enhanced Sign-Up Process
- Added debug logging to track data being saved
- Added verification step after saving to Firestore
- Included default empty strings for optional fields (phone, address, description)

### 2. Profile Screen Improvements
- Shows "Shop Name Not Set" instead of "Unknown Shop" for clarity
- Orange warning banner appears when critical info is missing
- Debug button (🐛) to view raw Firestore data
- Better empty state handling

### 3. Quick Fix Screen
A dedicated screen to quickly update missing profile information:
- Access via "Fix Now" button in the warning banner
- Simple form with just shop name and owner name
- Validates and saves data with merge option
- Shows success/error feedback

### 4. Debug Tools
- **Firestore Debug Screen**: View all raw data from your profile document
- **Console Logging**: Check terminal for detailed sign-up and data loading logs

## How to Fix Your Profile

### Option 1: Use the Fix Screen (Easiest)
1. Open Vendor Profile
2. If you see the orange warning banner, tap "Fix Now"
3. Enter your shop name and owner name
4. Tap "Update Profile"
5. Profile will refresh automatically

### Option 2: Use the Edit Screen
1. Open Vendor Profile
2. Tap the edit icon (pencil) in the top right
3. Fill in shop name and owner name
4. Tap the checkmark or "Save Changes"

### Option 3: Debug and Investigate
1. Open Vendor Profile
2. Tap the bug icon (🐛) in the top right
3. Check what data exists in Firestore
4. Use the copy buttons to copy field values
5. Verify if fields are empty or missing

## What Was Fixed

1. **Sign-up validation**: Now logs exactly what data is being saved
2. **Empty string handling**: Shows "Not set" instead of "—" or "Unknown"
3. **Warning system**: Visual indicator when profile is incomplete
4. **Quick fix tool**: Fast way to add missing information
5. **Debug tools**: Easy way to see what's actually in the database

## For New Sign-Ups

The enhanced sign-up process now:
- Logs all data being saved (check console)
- Verifies data was saved successfully
- Includes all required fields with proper defaults
- Shows clear error messages if something fails

## Console Logs to Watch For

When signing up:
```
📝 Signing up with role: vendor
📝 Vendor data - Shop: "Your Shop", Owner: "Your Name"
💾 Saving to Firestore: {email: ..., role: vendor, shopName: ..., ownerName: ...}
✅ User data saved to Firestore successfully
✅ Verification: Document exists with data: {...}
```

When viewing profile:
```
📊 Firestore data for user [uid]:
{shopName: Your Shop, ownerName: Your Name, ...}
🏪 Shop Name: "Your Shop"
👤 Owner Name: "Your Name"
```

## Files Modified

1. `lib/screens/auth/auth_screen.dart` - Enhanced sign-up with logging
2. `lib/screens/admin/vendor_profile_screen.dart` - Added warning banner and fix button
3. `lib/screens/admin/edit_vendor_profile_screen.dart` - Added debug logging
4. `lib/screens/admin/fix_profile_screen.dart` - NEW: Quick fix tool
5. `lib/screens/admin/firestore_debug_screen.dart` - NEW: Debug viewer
