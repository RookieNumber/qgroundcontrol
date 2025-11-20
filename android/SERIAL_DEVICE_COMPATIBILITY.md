# Android Serial Device Compatibility Guide

## Overview

This document explains how QGroundControl handles USB serial devices on Android and how to expand compatibility for new devices like Skydroid and other serial devices.

## Current Implementation

QGroundControl uses the `usb-serial-for-android` library to communicate with USB serial devices. The system supports the following driver types:

1. **FTDI** - FTDI USB-to-serial chips
2. **CDC/ACM** - USB Communication Device Class / Abstract Control Model (generic serial devices)
3. **CP2102** - Silicon Labs CP2102 USB-to-serial chips
4. **Prolific** - Prolific USB-to-serial chips

## Recent Changes for Better Compatibility

### Generic CDC/ACM Support

A new `GENERIC_CDC_ACM_SERIAL` prober has been added to `UsbSerialProber.java` that detects **any** device implementing the CDC/ACM USB class, regardless of vendor ID. This means:

- **Skydroid devices** and other generic CDC/ACM devices will now be automatically detected
- No need to add specific vendor IDs for every CDC/ACM device
- Works with any device that implements the standard CDC/ACM protocol

### How It Works

The generic prober:

1. Checks if the device has a USB interface with class `USB_CLASS_COMM` (CDC/ACM)
2. Verifies the device hasn't already been matched by a vendor-specific prober
3. Creates a `CdcAcmSerialDriver` instance for the device

This allows devices like Skydroid to be detected even if their vendor ID isn't in the supported devices list.

## Adding Support for New Devices

### For CDC/ACM Devices (Recommended)

**Most modern serial devices use CDC/ACM**, so they should work automatically with the new generic prober. No code changes needed!

If you want to add a device to the known vendor list (for better identification), you can:

1. Find the device's Vendor ID and Product ID (use `lsusb` on Linux or check device properties)
2. Add constants to `UsbId.java`:

   ```java
   public static final int VENDOR_SKYDROID = 0xXXXX;  // Replace with actual VID
   public static final int DEVICE_SKYDROID = 0xXXXX;  // Replace with actual PID
   ```

3. Add to `CdcAcmSerialDriver.getSupportedDevices()`:
   ```java
   supportedDevices.put(Integer.valueOf(UsbId.VENDOR_SKYDROID),
           new int[] {
               UsbId.DEVICE_SKYDROID,
           });
   ```

### For Non-CDC/ACM Devices

If a device uses a different protocol (FTDI, CP2102, Prolific, or custom), you may need to:

1. **Check if an existing driver works**: Try the generic CDC/ACM first, then FTDI, CP2102, or Prolific
2. **Create a custom driver**: If none work, you'll need to implement a new driver class extending `CommonUsbSerialDriver`
3. **Add a prober**: Add a new enum value to `UsbSerialProber.java`

## Troubleshooting

### Device Not Detected

1. **Check USB permissions**: Ensure the app has permission to access the USB device
2. **Check device filter**: Verify `android/res/xml/device_filter.xml` allows all USB devices (it currently does with `<usb-device />`)
3. **Check USB class**: Use a USB analyzer or `lsusb -v` to verify the device implements CDC/ACM
4. **Check logs**: Look for messages in logcat with tag "QGC_QGCActivity" or "QGC_UsbSerialProber"

### Device Detected But Won't Connect

1. **Check permissions**: The device may need explicit permission granted
2. **Check driver compatibility**: The device might need a different driver type
3. **Check baud rate**: Ensure the baud rate matches what the device expects
4. **Check USB cable**: Some cables are charge-only and don't support data

## Testing New Devices

To test if a device is detected:

1. Connect the device to your Android device
2. Check logcat for messages like:
   - "Adding new driver [device name]"
   - "Probing device: [device name]"
3. In QGroundControl, check the serial port list - the device should appear
4. Try connecting to the device

## Device Filter Configuration

The `android/res/xml/device_filter.xml` file currently allows all USB devices:

```xml
<usb-device />
```

This is correct for maximum compatibility. If you want to restrict to specific devices, you can add vendor/product ID filters, but this is generally not recommended as it limits compatibility.

## Common Device Types

### Skydroid

- **Type**: CDC/ACM (generic)
- **Status**: Should work automatically with generic CDC/ACM prober
- **Note**: If you know the vendor/product IDs, you can add them to `UsbId.java` for better identification

### Arduino-based Devices

- **Type**: CDC/ACM
- **Status**: Supported via vendor-specific entries in `CdcAcmSerialDriver`

### FTDI-based Devices

- **Type**: FTDI
- **Status**: Supported via `FtdiSerialDriver`

### CP2102-based Devices

- **Type**: CP2102
- **Status**: Supported via `Cp2102SerialDriver`

## Future Improvements

Potential enhancements:

1. Add a device detection test mode that logs all USB device information
2. Add user-configurable vendor/product ID mappings
3. Add support for more driver types (CH340, etc.)
4. Improve error messages when devices fail to connect

## References

- [USB Serial for Android Library (GitHub)](https://github.com/mik3y/usb-serial-for-android)
- [USB Serial for Android Library (Original)](http://code.google.com/p/usb-serial-for-android/) - Deprecated
- [USB CDC/ACM Specification](http://www.usb.org/developers/devclass_docs/usbcdc11.pdf)
- [Android USB Host Documentation](https://developer.android.com/guide/topics/connectivity/usb/host)
- [Updating the USB Serial Library](UPDATING_USB_SERIAL_LIBRARY.md) - Guide for updating the library
