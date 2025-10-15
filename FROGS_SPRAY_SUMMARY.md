# FROGS_SPRAY Implementation Summary

## ✅ What Has Been Implemented

Your `frogs_spray` message with the following fields has been successfully implemented:

```
Message ID: 500
Fields:
  - uint64 timestamp       (microseconds)
  - float32 vol_water      (Liters)
  - float64 flow_rate      (L/min)
  - float64 c_actuator     (control value)
```

## 📁 Files Modified/Created

### Core Implementation

1. **`src/Vehicle/FactGroups/VehicleFrogsSprayFactGroup.h`** - Updated with new fields
2. **`src/Vehicle/FactGroups/VehicleFrogsSprayFactGroup.cc`** - Updated message handling
3. **`src/Vehicle/FactGroups/FrogsSprayFact.json`** - Updated metadata

### Documentation & Examples

4. **`FROGS_SPRAY_IMPLEMENTATION.md`** - Complete implementation guide
5. **`FROGS_SPRAY_SUMMARY.md`** - This summary
6. **`src/FrogsSprayExample.qml`** - QML usage example
7. **`test_frogs_spray.py`** - Python test script

## 🚀 How to Use

### In QML UI

```qml
import QGroundControl 1.0

Text {
    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    text: "Water: " + vehicle.frogsSpray.volWater.valueString + " " +
          vehicle.frogsSpray.volWater.units
}
```

See `src/FrogsSprayExample.qml` for a complete working example.

### In C++ Code

```cpp
Vehicle* vehicle = ...;
double flowRate = vehicle->frogsSpray()->flowRate()->rawValue().toDouble();
float volWater = vehicle->frogsSpray()->volWater()->rawValue().toFloat();
```

## 🧪 Testing

### Option 1: Use the Python Test Script

```bash
# Install pymavlink
pip install pymavlink

# Run simulation (sends messages every second)
python test_frogs_spray.py --connect udp:127.0.0.1:14550 --mode simulate

# Or send just a few test messages
python test_frogs_spray.py --connect udp:127.0.0.1:14550 --mode test
```

### Option 2: Send from Your Autopilot

Make sure your autopilot sends MAVLink messages with:

-   **Message ID:** 500
-   **Payload:** 28 bytes in this order:
    1. uint64 timestamp (8 bytes)
    2. float32 vol_water (4 bytes)
    3. float64 flow_rate (8 bytes)
    4. float64 c_actuator (8 bytes)

## 🔍 Accessing the Data

The data is accessible via the Vehicle object:

| QML Path                       | C++ Method                  | Type   | Description            |
| ------------------------------ | --------------------------- | ------ | ---------------------- |
| `vehicle.frogsSpray.timestamp` | `frogsSpray()->timestamp()` | uint64 | Message timestamp (us) |
| `vehicle.frogsSpray.volWater`  | `frogsSpray()->volWater()`  | float  | Water volume (L)       |
| `vehicle.frogsSpray.flowRate`  | `frogsSpray()->flowRate()`  | double | Flow rate (L/min)      |
| `vehicle.frogsSpray.cActuator` | `frogsSpray()->cActuator()` | double | Actuator control       |

Each Fact provides:

-   `.value` - The current value
-   `.valueString` - Formatted string with decimals
-   `.units` - Unit string (e.g., "L", "L/min")
-   `.rawValue` - Raw value as QVariant

## 📊 Data Flow

```
Autopilot → MAVLink (ID 500) → QGC → VehicleFrogsSprayFactGroup → Facts → QML UI
                                   ↓
                              handleMessage()
                                   ↓
                           _handleFrogsSpray()
                                   ↓
                              Decode Payload
                                   ↓
                              Update Facts
```

## 🔧 Next Steps

1. **Build QGroundControl** with your changes:

    ```bash
    mkdir build && cd build
    cmake ..
    cmake --build .
    ```

2. **Add UI Elements** - Copy and customize `src/FrogsSprayExample.qml` or add the facts to existing UI components

3. **Test the Connection** - Use `test_frogs_spray.py` to verify messages are received

4. **Integrate with Autopilot** - Make sure your autopilot firmware sends the FROGS_SPRAY message (ID 500)

## 📝 Important Notes

-   ✅ The FactGroup is already integrated into the Vehicle class
-   ✅ Message handling is automatic when messages arrive
-   ✅ Values are NaN until first message is received
-   ⚠️ Make sure your autopilot uses the same message ID (500)
-   ⚠️ Verify byte order (little-endian) matches your system

## 🐛 Troubleshooting

**Q: Values show as "N/A" or NaN**

-   Check that your autopilot is sending message ID 500
-   Verify the vehicle is connected
-   Use `test_frogs_spray.py` to test QGC reception

**Q: Values are incorrect**

-   Verify payload byte order and offsets
-   Check message length is exactly 28 bytes
-   Add debug output in `_handleFrogsSpray()`

**Q: QML can't access the values**

-   Make sure `activeVehicle` is not null
-   Check property name capitalization
-   Rebuild QGC after code changes

## 📚 Additional Resources

-   **Full Guide:** `FROGS_SPRAY_IMPLEMENTATION.md`
-   **QML Example:** `src/FrogsSprayExample.qml`
-   **Test Script:** `test_frogs_spray.py`
-   **QGC Dev Guide:** https://dev.qgroundcontrol.com/

## 🎯 Quick Reference

```cpp
// C++ - Get values
Vehicle* v = ...;
uint64_t ts = v->frogsSpray()->timestamp()->rawValue().toULongLong();
float vol = v->frogsSpray()->volWater()->rawValue().toFloat();
double flow = v->frogsSpray()->flowRate()->rawValue().toDouble();
double act = v->frogsSpray()->cActuator()->rawValue().toDouble();

// C++ - Connect to changes
connect(v->frogsSpray()->flowRate(), &Fact::rawValueChanged, this, [v]() {
    qDebug() << "Flow changed:" << v->frogsSpray()->flowRate()->rawValue();
});
```

```qml
// QML - Display values
property var v: QGroundControl.multiVehicleManager.activeVehicle

Text { text: v.frogsSpray.volWater.valueString + " " + v.frogsSpray.volWater.units }
Text { text: v.frogsSpray.flowRate.valueString + " " + v.frogsSpray.flowRate.units }
Text { text: v.frogsSpray.cActuator.valueString }

// QML - React to changes
Connections {
    target: v ? v.frogsSpray.flowRate : null
    function onValueChanged() {
        console.log("Flow rate:", v.frogsSpray.flowRate.value)
    }
}
```

---

✨ **Implementation Complete!** You can now use the FROGS_SPRAY message in QGroundControl.
