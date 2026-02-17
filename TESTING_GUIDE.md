# 🧪 Testing Guide - Wanderly Data Persistence

## Pre-Testing Checklist

```bash
# 1. Ensure dependencies installed
flutter pub get

# 2. Generate Hive adapters if not done
dart run build_runner build

# 3. Check no errors
flutter analyze
```

---

## Test 1: Basic Data Persistence ✅

### Test Scenario: Add Activity & Restart App

**Steps:**
1. Run aplikasi: `flutter run`
2. Navigate to "Wisata Saya" screen
3. Tap "Tambah Wisata" button
4. Fill in the form:
   - Name: "Test Attraction"
   - Location: "Jakarta, Indonesia"
   - Notes: "This is a test"
   - Category: Select "Sightseeing"
   - Date: Pick any date
5. Tap "Simpan" button

**Expected Result:**
- ✅ Activity appears in list immediately
- ✅ No errors in console

**Persistence Test:**
1. Close app completely (swipe from recent)
2. Reopen app
3. Navigate to "Wisata Saya" screen
4. Select category "Sightseeing"

**Expected Result:**
- ✅ "Test Attraction" masih ada di list!
- ✅ Data not lost! 🎉

---

## Test 2: Edit Activity ✅

### Test Scenario: Edit Existing Activity

**Steps:**
1. In "Wisata Saya" screen with activities visible
2. Find an activity and tap "Edit" button
3. Change the name to "Modified Attraction"
4. Change location to "Bandung, Indonesia"
5. Tap "Simpan" button

**Expected Result:**
- ✅ List immediately updates dengan nama baru
- ✅ No errors

**Persistence Check:**
1. Close and reopen app
2. Navigate to same category

**Expected Result:**
- ✅ Activity masih namanya "Modified Attraction"
- ✅ Location masih "Bandung, Indonesia"

---

## Test 3: Delete Activity ✅

### Test Scenario: Delete Activity

**Steps:**
1. In "Wisata Saya" screen
2. Find an activity to delete
3. Tap "Hapus" button
4. Confirm deletion in dialog

**Expected Result:**
- ✅ Activity instantly removed from list
- ✅ No errors

**Persistence Check:**
1. Close and reopen app
2. Navigate to same category

**Expected Result:**
- ✅ Activity is still deleted (not restored!)
- ✅ Deletion was persistent

---

## Test 4: Category Filtering ✅

### Test Scenario: Filter by Category

**Steps:**
1. In "Wisata Saya" screen
2. Dropdown category selector shows: Sightseeing, Restaurant, Nightlife, Hotel, Shopping, Cinema
3. Select each category one by one
4. Check activities display correctly

**Expected Result:**
- ✅ Dropdown shows all 6 categories
- ✅ Selecting category filters list
- ✅ Only activities of selected category show
- ✅ No crashes when category empty

---

## Test 5: Sample Data Loading ✅

### Test Scenario: First App Launch with Sample Data

**Steps:**
1. Uninstall app completely: `flutter clean && flutter pub get`
2. Run app fresh: `flutter run`
3. Navigate to "Wisata Saya"
4. Check categories

**Expected Result:**
- ✅ Sample data loads automatically
- ✅ See various attractions from Japan trip
- ✅ Sightseeing: Golden Pavilion, Fushimi Inari, etc.
- ✅ Restaurant: Ichiran Ramen, Nishiki Warai, etc.
- ✅ Other categories have data too

---

## Test 6: Add Multiple Activities ✅

### Test Scenario: Add 5+ Activities

**Steps:**
1. Add multiple activities across different categories
2. Add at least 2-3 in each category
3. After each add, verify it appears in list

**Expected Result:**
- ✅ All additions work smoothly
- ✅ No lag or freezing
- ✅ Hive handles multiple records well

**Persistence Check:**
1. Close and reopen
2. Check all activities still there

**Expected Result:**
- ✅ All activities persisted correctly
- ✅ No data loss
- ✅ Database scaling works

---

## Test 7: No Crash on Error ✅

### Test Scenario: Database Corruption Handling

**Steps:**
1. Try to trigger edge cases:
   - Add activity with empty name (should show validation)
   - Add activity with very long text (1000+ chars)
   - Rapid-fire add/delete/edit operations
   - Switch between categories rapidly

**Expected Result:**
- ✅ No crashes
- ✅ Validation works for empty name
- ✅ Long text handled gracefully
- ✅ UI remains responsive

---

## Test 8: Data Types Verification ✅

### Test Scenario: Check All Data Fields Persist

**Steps:**
1. Add activity with ALL fields filled:
   ```
   Name: "Complete Test"
   Location: "Multiple Lines Street, Building A, City"
   Notes: "Very long notes with special characters: @#$%^&*()"
   Category: "Restaurant"
   Date: Pick a specific date
   ```
2. Close app
3. Reopen and verify same activity

**Expected Result:**
- ✅ All fields display exactly as entered
- ✅ Special characters work
- ✅ Long text preserved
- ✅ Date formatted correctly

---

## Test 9: Date Picker Works ✅

### Test Scenario: Date Selection & Display

**Steps:**
1. Add new activity with no date first
2. Edit it and add date via date picker
3. Verify date displays as DD/MM/YYYY
4. Edit and change date

**Expected Result:**
- ✅ Date picker opens on tap
- ✅ Selected date updates
- ✅ Format is consistent
- ✅ Persists correctly

---

## Test 10: Performance Test ✅

### Test Scenario: Smooth UI with Multiple Items

**Steps:**
1. Add 20+ activities across categories
2. Scroll through the list smoothly
3. Tap buttons quickly
4. Switch categories rapidly

**Expected Result:**
- ✅ List scrolls smoothly (60 FPS)
- ✅ No lag when scrolling
- ✅ Buttons respond instantly
- ✅ Category switching fast

---

## 🐛 Debugging Tips

### Check Console for Logs
```bash
# In terminal where flutter run is running
# Look for any print statements or errors
```

### Inspect Hive Database
```dart
// In my_itinerary_screen.dart or activity_provider.dart
// The data is stored in Hive box
// Default location: app's documents directory
```

### Reset All Data
```bash
flutter clean
flutter pub get
dart run build_runner build
flutter run
# App will reload with fresh sample data
```

---

## 📊 Test Results Template

```
Date: __________
Tester: ________

Test 1: Basic Persistence
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 2: Edit Activity
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 3: Delete Activity
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 4: Category Filtering
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 5: Sample Data
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 6: Multiple Activities
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 7: Error Handling
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 8: Data Types
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 9: Date Picker
Result: [ ] PASS [ ] FAIL
Notes: _________________

Test 10: Performance
Result: [ ] PASS [ ] FAIL
Notes: _________________

Overall Result: [ ] ALL PASS [ ] SOME FAIL

Issues Found:
1. _________________
2. _________________
3. _________________
```

---

## ✅ Expected Behavior Summary

| Feature | Expected | ✅ |
|---------|----------|-----|
| Add activity | Appears instantly in UI | [ ] |
| Add activity | Persists after restart | [ ] |
| Edit activity | Updates instantly | [ ] |
| Edit activity | Persists after restart | [ ] |
| Delete activity | Removed instantly | [ ] |
| Delete activity | Stays deleted after restart | [ ] |
| Category filter | Shows only selected category | [ ] |
| Sample data | Loads on first launch | [ ] |
| Multiple items | Scroll smooth & fast | [ ] |
| Empty fields | Shows validation | [ ] |
| Special chars | Displayed correctly | [ ] |
| Long text | Wrapped properly | [ ] |
| Date picker | Works & persists | [ ] |

---

## 🎯 Success Criteria

✅ **All 10 Tests PASS** = Implementation is successful!

### Critical Tests (Must Pass)
1. ✅ Basic Data Persistence
2. ✅ Edit & Persistence
3. ✅ Delete & Persistence

### Important Tests (Should Pass)
4. ✅ Category Filtering
5. ✅ Sample Data Loading
6. ✅ Error Handling

---

## 📝 Issue Reporting Template

If you find an issue:

```
**Issue Title**: [Brief description]

**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior**: 
What should happen

**Actual Behavior**: 
What actually happens

**Screenshots**: 
If applicable

**Console Logs**: 
Copy any error messages

**Device/Environment**:
- OS: Android/iOS
- Flutter version: [version]
- Device: [model]
```

---

## 🚀 Go Live Checklist

Before deploying to production:

- [ ] All 10 tests passing
- [ ] No console errors or crashes
- [ ] Data persists correctly
- [ ] Performance is smooth
- [ ] No memory leaks
- [ ] Device storage not bloated
- [ ] Works on Android & iOS (if testing both)
- [ ] Multiple test devices verified
- [ ] User acceptance testing done
- [ ] Ready for app store/play store release

---

**Happy Testing!** 🎉

For any issues, refer to `DATA_PERSISTENCE_GUIDE.md` for implementation details.
