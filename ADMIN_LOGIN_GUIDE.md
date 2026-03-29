# Admin/SuperAdmin Login Guide

## Changes made

Admin and SuperAdmin roles are now managed exclusively through Firestore. There is no separate admin authentication option in the login screen.

### Files Modified:
1. `lib/main.dart` - Routes admin/superadmin users to Admin Dashboard
2. `lib/screens/auth/auth_screen.dart` - Preserves admin roles during login

## How to Access Admin Dashboard

### Method 1: Set Role in Firestore (Recommended)
1. Create a user account normally (as User or Vendor)
2. Go to Firebase Console → Firestore database
3. Navigate to the `users` collection
4. Find your user document by email or UID
5. Edit the document and change the `role` field to `admin` or `superadmin`
6. Log out of the app and log back in
7. You'll automatically be routed to the Admin dashboard

### Method 2: Manual Database Entry
1. Go to Firebase Console → Firestore Database
2. Create a new document in the `users` collection with:
   ```
   Document ID: [your-firebase-auth-uid]
   Fields:
     - email: "admin@example.com"
     - role: "admin"
     - name: "Admin User"
     - createdAt: [timestamp]
     - updatedAt: [timestamp]
   ```
3. Create the corresponding Firebase Auth account with the same email
4. Log in with those credentials
5. You'll be routed to the Admin Dashboard

## Role Routing Logic

The app supports 4 roles:
- **user** → Customer Landing Page
- **vendor** → Vendor Dashboard
- **admin** → Admin Dashboard
- **superadmin** → Admin Dashboard (same as admin)

## Important Notes

- Admin roles are protected: signing in as User/Vendor won't override an existing admin role
- The auth screen only shows User and Vendor options
- Admin access must be granted manually through Firestore
- This prevents unauthorized users from creating admin accounts

## Troubleshooting

If admin login doesn't work:
1. Verify the `role` field in Firestore is exactly `admin` or `superadmin` (case-sensitive)
2. Log out completely and log back in
3. Check the debug console for role resolution logs (🔍 and ✅ emojis)
4. Ensure the user document exists in Firestore with the correct UID

