# FROGS_SPRAY Message Implementation Guide

This document explains how the FROGS_SPRAY message is implemented and how to use it in QGroundControl.

## Message Structure

The FROGS_SPRAY message (MAVLink ID: 500) contains the following fields:

| Field        | Type    | Description                  | Units                 |
| ------------ | ------- | ---------------------------- | --------------------- |
| `timestamp`  | uint64  | Message timestamp            | microseconds (us)     |
| `vol_water`  | float32 | Current water volume in tank | Liters (L)            |
| `flow_rate`  | float64 | Current flow rate            | Liters/minute (L/min) |
| `c_actuator` | float64 | Actuator control value       | -                     |

**Total message payload size:** 28 bytes (8 + 4 + 8 + 8)

## Implementation Architecture

### 1. FactGroup Implementation

The message data is exposed through the `VehicleFrogsSprayFactGroup` class, which inherits from `FactGroup`. This provides automatic data binding to QML.

**Files:**

-   `src/Vehicle/FactGroups/VehicleFrogsSprayFactGroup.h` - Header file with Facts
-   `src/Vehicle/FactGroups/VehicleFrogsSprayFactGroup.cc` - Implementation
-   `src/Vehicle/FactGroups/FrogsSprayFact.json` - Metadata (units, descriptions, formatting)

### 2. Message Handling

The message is received and processed in `VehicleFrogsSprayFactGroup::handleMessage()`:

```cpp
void VehicleFrogsSprayFactGroup::handleMessage(Vehicle *vehicle, const mavlink_message_t &message)
{
    Q_UNUSED(vehicle);

    switch (message.msgid) {
    case 500:  // FROGS_SPRAY message ID
        _handleFrogsSpray(message);
        break;
    default:
        break;
    }
}
```

### 3. Message Decoding

The payload is decoded manually since this is a custom message:

```cpp
void VehicleFrogsSprayFactGroup::_handleFrogsSpray(const mavlink_message_t &message)
{
    // Decode message payload
    uint64_t timestamp_val;
    float vol_water;
    double flow_rate;
    double c_actuator;

    memcpy(&timestamp_val, &message.payload64[0], 8);
    memcpy(&vol_water, &message.payload64[1], 4);
    memcpy(&flow_rate, &message.payload64[1] + 4, 8);
    memcpy(&c_actuator, &message.payload64[3], 8);

    // Update Facts
    timestamp()->setRawValue(timestamp_val);
    volWater()->setRawValue(vol_water);
    flowRate()->setRawValue(flow_rate);
    cActuator()->setRawValue(c_actuator);
}
```

## Usage

### Using in QML

The FROGS_SPRAY data is accessible through the active vehicle:

```qml
import QGroundControl 1.0
import QGroundControl.Vehicle 1.0

Item {
    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Access individual values
    Text {
        text: "Water Volume: " + activeVehicle.frogsSpray.volWater.valueString + " " +
              activeVehicle.frogsSpray.volWater.units
    }

    Text {
        text: "Flow Rate: " + activeVehicle.frogsSpray.flowRate.valueString + " " +
              activeVehicle.frogsSpray.flowRate.units
    }

    Text {
        text: "Actuator: " + activeVehicle.frogsSpray.cActuator.valueString
    }

    // React to changes
    Connections {
        target: activeVehicle ? activeVehicle.frogsSpray.flowRate : null

        function onValueChanged() {
            console.log("Flow rate changed:", activeVehicle.frogsSpray.flowRate.value)
        }
    }
}
```

### Using in C++

Access the FactGroup from the Vehicle object:

```cpp
#include "Vehicle.h"
#include "VehicleFrogsSprayFactGroup.h"

void MyClass::processFrogsSprayData(Vehicle* vehicle)
{
    VehicleFrogsSprayFactGroup* frogsSpray = vehicle->frogsSpray();

    // Get current values
    uint64_t timestamp = frogsSpray->timestamp()->rawValue().toULongLong();
    float volWater = frogsSpray->volWater()->rawValue().toFloat();
    double flowRate = frogsSpray->flowRate()->rawValue().toDouble();
    double cActuator = frogsSpray->cActuator()->rawValue().toDouble();

    qDebug() << "Water Volume:" << volWater << "L";
    qDebug() << "Flow Rate:" << flowRate << "L/min";
}

void MyClass::connectToSignals(Vehicle* vehicle)
{
    // Connect to value changes
    connect(vehicle->frogsSpray()->flowRate(), &Fact::rawValueChanged, this, [this, vehicle]() {
        double rate = vehicle->frogsSpray()->flowRate()->rawValue().toDouble();
        if (rate > 10.0) {
            qWarning() << "Flow rate exceeds threshold!";
        }
    });
}
```

## Fact Properties

Each Fact provides the following properties:

| Property           | Description                                 |
| ------------------ | ------------------------------------------- |
| `value`            | The value in display units                  |
| `rawValue`         | The raw value as received                   |
| `valueString`      | Formatted string with proper decimal places |
| `units`            | Unit string (e.g., "L", "L/min")            |
| `shortDescription` | Human-readable description                  |

## Testing

To test the implementation:

1. **Send test messages** from your autopilot with MAVLink ID 500
2. **Monitor in QGC**: Add the example QML file to display the data
3. **Check telemetry**: Verify `_setTelemetryAvailable(true)` is called
4. **Debug output**: Add debug statements to see decoded values

### Example Test Message (Python/pymavlink)

```python
from pymavlink import mavutil

# Connect to vehicle
vehicle = mavutil.mavlink_connection('udp:127.0.0.1:14550')

# Send FROGS_SPRAY message
vehicle.mav.send(
    vehicle.mav.frogs_spray_encode(
        timestamp=1234567890,  # uint64
        vol_water=15.5,        # float32
        flow_rate=5.25,        # float64
        c_actuator=0.75        # float64
    )
)
```

## Integration Checklist

✅ **FactGroup created** - `VehicleFrogsSprayFactGroup`  
✅ **Header included** - `Vehicle.h` includes the header  
✅ **Property exposed** - `frogsSpray()` property in Vehicle  
✅ **Message ID defined** - Using ID 500  
✅ **Message handling** - `handleMessage()` processes MSG_ID 500  
✅ **Metadata configured** - `FrogsSprayFact.json` with units and formatting  
✅ **QML example** - `FrogsSprayExample.qml` demonstrates usage

## Customization

### Changing Message ID

If you need to use a different MAVLink message ID, update it in:

```cpp
// VehicleFrogsSprayFactGroup.cc
case 500:  // Change this number
    _handleFrogsSpray(message);
    break;
```

### Adding More Fields

1. Add new Fact member in `.h` file
2. Add to constructor in `.cc` file
3. Update `_handleFrogsSpray()` to decode the new field
4. Add metadata to `FrogsSprayFact.json`
5. Update message length check

### Changing Units

Edit `FrogsSprayFact.json`:

```json
{
    "name": "flowRate",
    "units": "ml/s" // Change units here
}
```

## Troubleshooting

### Message not received

1. Check message ID (500) matches your autopilot
2. Verify vehicle connection is active
3. Add debug output in `handleMessage()`
4. Check MAVLink traffic with `mavlink_msg_frogs_spray_decode()`

### Values not updating in UI

1. Ensure `_setTelemetryAvailable(true)` is called
2. Check that Fact signals are connected
3. Verify QML bindings to `activeVehicle.frogsSpray.*`

### Incorrect values

1. Verify byte order (endianness) matches
2. Check message length (should be 28 bytes)
3. Verify payload offsets in `memcpy()` calls
4. Use debugger to inspect raw payload bytes

## MAVLink Message Definition

If you need to define this in a MAVLink XML file:

```xml
<message id="500" name="FROGS_SPRAY">
    <description>FROGS spray system telemetry</description>
    <field type="uint64_t" name="timestamp" units="us">Timestamp in microseconds</field>
    <field type="float" name="vol_water" units="L">Water volume in liters</field>
    <field type="double" name="flow_rate" units="L/min">Flow rate in liters per minute</field>
    <field type="double" name="c_actuator">Actuator control value</field>
</message>
```

Place this in `libs/mavlink/include/mavlink/v2.0/message_definitions/common.xml` or your custom dialect XML.

## Additional Resources

-   QGroundControl Developer Guide: https://dev.qgroundcontrol.com/
-   MAVLink Protocol: https://mavlink.io/
-   Qt QML: https://doc.qt.io/qt-5/qmlapplications.html
-   Example QML: `src/FrogsSprayExample.qml`
