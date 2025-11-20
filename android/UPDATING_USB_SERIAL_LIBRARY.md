# Updating the USB Serial for Android Library

## Current Situation

QGroundControl currently has the `usb-serial-for-android` library **embedded directly in the source code** at:

- `android/src/com/hoho/android/usbserial/driver/`

This is **not** a managed dependency - it's source code that was copied into the project.

## Library Information

- **Original Project**: http://code.google.com/p/usb-serial-for-android/ (deprecated)
- **Current GitHub**: https://github.com/mik3y/usb-serial-for-android
- **Author**: Mike Wakerly (mik3y)
- **License**: LGPL 2.1

## Should You Update?

### Pros of Updating:

- **Bug fixes**: Latest version may have fixes for device compatibility issues
- **New drivers**: Support for additional USB-to-serial chips (CH340, etc.)
- **Better Android compatibility**: Updates for newer Android versions
- **Performance improvements**: Optimizations and better error handling

### Cons of Updating:

- **Breaking changes**: The library has been modified in QGroundControl (see note in `UsbSerialProber.java`)
- **Integration work**: Need to re-apply custom modifications
- **Testing required**: Must test with all supported devices

## How to Update

### Option 1: Update Source Files (Recommended for Custom Modifications)

1. **Check current modifications**:

   - `UsbSerialProber.java` has a custom modification (line 22-23):
     ```java
     // IMPORTANT NOTE:
     //  This source has been modified from the original such that testIfSupported only tests for a vendor id
     //  match. If that matches it allows all product ids through. This provides for better match on unknown boards.
     ```

2. **Download latest version**:

   - Go to: https://github.com/mik3y/usb-serial-for-android
   - Download or clone the repository
   - Check the latest release/tag

3. **Compare and merge**:

   - Compare the latest library files with your current files
   - Re-apply your custom modifications
   - **Important**: Keep the `GENERIC_CDC_ACM_SERIAL` prober we just added!

4. **Files to update** (in `android/src/com/hoho/android/usbserial/driver/`):

   - `CdcAcmSerialDriver.java`
   - `CommonUsbSerialDriver.java`
   - `Cp2102SerialDriver.java`
   - `FtdiSerialDriver.java`
   - `ProlificSerialDriver.java`
   - `UsbId.java`
   - `UsbSerialDriver.java`
   - `UsbSerialProber.java` (⚠️ **Keep your custom modifications!**)
   - `UsbSerialRuntimeException.java`

5. **Test thoroughly**:
   - Test with all supported devices
   - Verify the generic CDC/ACM prober still works
   - Check that custom modifications are preserved

### Option 2: Use as Gradle Dependency (Future Consideration)

If you want to switch to using it as a managed dependency:

1. **Add to `build.gradle`** (if using Gradle):

   ```gradle
   dependencies {
       implementation 'com.github.mik3y:usb-serial-for-android:3.7.0'  // Check latest version
   }
   ```

2. **Remove embedded source files**:

   - Delete `android/src/com/hoho/android/usbserial/` directory

3. **Update imports**:

   - Ensure all imports still work
   - May need to adjust package paths

4. **Re-apply custom modifications**:
   - You'll need to extend or modify the library behavior differently
   - Consider creating wrapper classes instead of modifying library source

**Note**: This approach is more complex because you can't directly modify the library source. You'd need to:

- Create custom driver classes that extend the library's drivers
- Override the prober logic with your own implementation
- Or fork the library and publish your own version

## Current Custom Modifications in QGroundControl

### 1. Modified `testIfSupported` behavior

- **Location**: `UsbSerialProber.java`
- **Change**: Only tests vendor ID match, allows all product IDs for that vendor
- **Reason**: Better support for unknown boards with known vendor IDs

### 2. Added Generic CDC/ACM Prober

- **Location**: `UsbSerialProber.java` (new `GENERIC_CDC_ACM_SERIAL` enum)
- **Change**: Detects any CDC/ACM device by USB class, not just vendor IDs
- **Reason**: Support for devices like Skydroid without adding vendor IDs

## Checking for Updates

To check if there's a newer version:

1. **Visit GitHub**: https://github.com/mik3y/usb-serial-for-android
2. **Check releases**: Look for recent releases or tags
3. **Review changelog**: Check what's changed since your version
4. **Check commits**: See if there are important bug fixes

## Recommended Approach

Given that QGroundControl has custom modifications:

1. **Keep embedded source** (current approach) - gives you full control
2. **Update periodically** - check for updates every 6-12 months
3. **Document changes** - keep track of what you've modified
4. **Test thoroughly** - always test with real devices after updates

## What to Look For in Updates

When reviewing updates, check for:

- ✅ New driver support (CH340, etc.)
- ✅ Bug fixes for CDC/ACM devices
- ✅ Android API compatibility updates
- ✅ Performance improvements
- ⚠️ Breaking changes that might affect your modifications
- ⚠️ Changes to the prober logic

## Example: Updating Process

```bash
# 1. Backup current files
cp -r android/src/com/hoho/android/usbserial android/src/com/hoho/android/usbserial.backup

# 2. Download latest from GitHub
git clone https://github.com/mik3y/usb-serial-for-android.git /tmp/usb-serial-update

# 3. Copy new files (excluding UsbSerialProber.java for now)
cp /tmp/usb-serial-update/usbSerialForAndroid/src/main/java/com/hoho/android/usbserial/driver/*.java \
   android/src/com/hoho/android/usbserial/driver/

# 4. Manually merge UsbSerialProber.java
# - Keep your custom testIfSupported modification
# - Keep the GENERIC_CDC_ACM_SERIAL prober
# - Merge any new probers from the update

# 5. Test build
# 6. Test with devices
```

## Conclusion

**Yes, you can update the library**, but since it's embedded source code with custom modifications, you'll need to:

1. Manually merge updates
2. Preserve your custom modifications
3. Test thoroughly

The library is actively maintained, so updates can bring valuable improvements, but the merge process requires care to preserve your customizations.
