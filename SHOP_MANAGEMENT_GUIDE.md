# Shop Management Guide

## Overview
This guide explains how to add, delete, and manage dummy shops in the Qless application.

## What Was Changed

The **User Dashboard Screen** has been completely redesigned to provide better management of dummy test shops:

### 1. **Converted to StatefulWidget**
- Changed from `StatelessWidget` to `StatefulWidget` to track loading state
- Allows proper state management during add/delete operations

### 2. **New Delete Functionality**
- Added `_deleteMockShops()` method that:
  - Deletes all dummy shops (identified by `mock_` prefix in user IDs)
  - Removes all menu items associated with dummy shops
  - Provides feedback on how many shops and items were deleted

### 3. **Improved UI**
- New **"Manage Dummy Data"** button in the AppBar (storage icon)
- Shows loading spinner during operations
- Clean dialog interface for add/delete operations

### 4. **Better User Feedback**
- Clear snackbar messages for all operations
- Status updates during data processing
- Error handling with descriptive messages

---

## How to Use

### Adding Dummy Shops

1. **Tap the Storage Icon** (in the AppBar) to open "Manage Dummy Data" dialog
2. **Click "Add Dummy Shops"**
3. Wait for confirmation - 5 shops will be created:
   - Spice Garden (Indian Food)
   - Dragon Wok (Chinese Food)
   - Burger Barn (American Burgers)
   - Chai & Snacks (Tea & Snacks)
   - Pizza Planet (Italian Pizza)

Each shop includes:
- Shop name and owner name
- Description
- Menu items (1 signature item per shop)
- Pricing and availability

### Deleting Dummy Shops

1. **Tap the Storage Icon** (in the AppBar)
2. **Click "Delete Dummy Shops"** (red button)
3. All dummy shops and their menu items will be removed
4. Real shops (added by vendors) will NOT be affected

---

## Technical Details

### Dummy Shop Identification
- All dummy shops use IDs starting with `mock_` (e.g., `mock_1234567890_SpiceGarden`)
- This prefix ensures only test data is deleted
- Real vendor accounts are never affected

### Data Deleted
When you delete dummy shops, the following are removed:
- All user documents with `role: 'vendor'` and ID starting with `mock_`
- All menu items where `vendorId` starts with `mock_`

### Collections Affected
- `users` - Vendor/shop profiles
- `menu_items` - Food items and menu data

---

## Troubleshooting

### Shops Not Appearing After Adding

**Solution:** 
1. The app uses real-time streams from Firestore
2. Wait 1-2 seconds for data to sync
3. If still not visible, close and reopen the app
4. Check your Firestore rules allow reading vendors collection

### Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Error seeding: ..." | Firebase connection failed | Check internet connection |
| "Error deleting: ..." | Permission denied | Check Firestore security rules |
| No shops shown | Internet issue or no shops exist | Try adding dummy shops |

### Loading Spinner Stuck

- If the loading spinner gets stuck, restart the app
- Check your internet connection
- Monitor Firestore console for quota issues

---

## Best Practices

1. **Always clean up** - Delete dummy shops before testing with real vendors
2. **Fresh testing** - Clear dummy shops between test cycles
3. **Don't mix data** - Avoid manually creating shops with `mock_` prefix
4. **Check Firestore** - Verify data in Firebase console for debugging

---

## File Changed

**Location:** `lib/screens/customer/user_dashboard_screen.dart`

**Key Classes:**
- `_UserDashboardScreenState` - Main state management
- `_seedMockShops()` - Creates 5 test shops
- `_deleteMockShops()` - Removes all dummy shops
- `_showDummyDataMenu()` - Dialog for managing data

---

## Next Steps

Now you can:
✓ Add dummy shops anytime with one click
✓ Delete dummy shops without affecting real data
✓ Test the full user flow with realistic data
✓ Clean up test data easily between sessions
