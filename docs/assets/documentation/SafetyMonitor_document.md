# APMSprayingComponent Implementation Guide

## Overview

The `APMSprayingComponent` is a QGroundControl vehicle component that provides a user interface for configuring spraying systems on ArduPilot vehicles. This document provides a comprehensive overview of the implementation, from the C++ backend to the QML frontend, including build system integration and resource management.

## Architecture

The APMSprayingComponent follows the standard QGroundControl component architecture:

## File Structure

### Core Implementation Files

1. **Header File**: `src/AutoPilotPlugins/APM/APMSprayingComponent.h`
2. **Implementation File**: `src/AutoPilotPlugins/APM/APMSprayingComponent.cc`
3. **Main QML UI**: `src/AutoPilotPlugins/APM/APMSprayingComponent.qml`
4. **Summary QML**: `src/AutoPilotPlugins/APM/APMSprayingComponentSummary.qml`
5. **Icon**: `src/AutoPilotPlugins/APM/Images/SprayingIcon.svg`

### Integration Files

1. **Plugin Integration**: `src/AutoPilotPlugins/APM/APMAutoPilotPlugin.h/cc`
2. **Build System**: `qgroundcontrol.pro`
3. **Resources**: `src/FirmwarePlugin/APM/APMResources.qrc`
4. **Parameter Metadata**: `src/FirmwarePlugin/APM/APMParameterFactMetaData.*.xml`

## C++ Implementation

### Header File (`APMSprayingComponent.h`)

```cpp
class APMSprayingComponent : public VehicleComponent
{
    Q_OBJECT

public:
    APMSprayingComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent = nullptr);

    // Overrides from VehicleComponent
    QString name(void) const final;
    QString description(void) const final;
    QString iconResource(void) const final;
    bool requiresSetup(void) const final;
    QUrl setupSource(void) const final;
    QUrl summaryQmlSource(void) const final;
    QStringList setupCompleteChangedTriggerList(void) const final;
    bool setupComplete(void) const final;

private:
    const QString _name;
};
```

**Key Points:**
- Inherits from `VehicleComponent` base class
- Uses `Q_OBJECT` macro for Qt meta-object system
- Implements all required virtual methods from base class
- Stores component name as private member

### Implementation File (`APMSprayingComponent.cc`)

#### Constructor
```cpp
APMSprayingComponent::APMSprayingComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent),
    _name(tr("Spraying"))
{
}
```

#### Core Methods

**Component Identity:**
```cpp
QString APMSprayingComponent::name(void) const
{
    return _name;  // Returns "Spraying"
}

QString APMSprayingComponent::description(void) const
{
    return tr("Spraying system configuration for flow rate control and tank level monitoring.");
}

QString APMSprayingComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/SprayingIcon.svg");
}
```

**Setup Configuration:**
```cpp
bool APMSprayingComponent::requiresSetup(void) const
{
    return true;  // Component requires setup
}

QUrl APMSprayingComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSprayingComponent.qml"));
}

QUrl APMSprayingComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSprayingComponentSummary.qml"));
}
```

**Parameter Triggers:**
```cpp
QStringList APMSprayingComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList triggers;
    
    // Trigger when spraying parameters change
    triggers << QStringLiteral("SPRAY_ENABLE");
    triggers << QStringLiteral("SPRAY_TANK_CAPACITY");
    triggers << QStringLiteral("SPRAY_FLOW_RATE");
    triggers << QStringLiteral("SPRAY_FLOW_MONITOR");
    
    return triggers;
}
```

**Setup Completion Logic:**
```cpp
bool APMSprayingComponent::setupComplete(void) const
{
    // Always return true to ensure component is always visible
    // Original implementation checked for parameter existence:
    // - SPRAY_ENABLE
    // - SPRAY_TANK_CAPACITY  
    // - SPRAY_FLOW_RATE
    return true;
}
```

## QML Implementation

### Main UI (`APMSprayingComponent.qml`)

The main QML file provides a comprehensive interface for configuring spraying parameters:

#### Key Features:
- **Spraying System Enable/Disable**: Toggle spraying functionality
- **Tank Configuration**: Set tank capacity and warning levels
- **Flow Rate Settings**: Configure flow rate and monitoring
- **Advanced Settings**: Pin assignments and calibration parameters
- **Real-time Parameter Binding**: Direct connection to APM parameters

#### Parameter Bindings:
```qml
property Fact _sprayEnable:           controller.getParameterFact(-1, "SPRAY_ENABLE")
property Fact _tankCapacity:          controller.getParameterFact(-1, "SPRAY_TANK_CAPACITY", false)
property Fact _flowRate:              controller.getParameterFact(-1, "SPRAY_FLOW_RATE", false)
property Fact _flowMonitor:           controller.getParameterFact(-1, "SPRAY_FLOW_MONITOR", false)
property Fact _flowPin:               controller.getParameterFact(-1, "SPRAY_FLOW_PIN", false)
property Fact _pumpPin:               controller.getParameterFact(-1, "SPRAY_PUMP_PIN", false)
property Fact _flowMult:              controller.getParameterFact(-1, "SPRAY_FLOW_MULT", false)
property Fact _flowOffset:            controller.getParameterFact(-1, "SPRAY_FLOW_OFFSET", false)
property Fact _tankLow:               controller.getParameterFact(-1, "SPRAY_TANK_LOW", false)
property Fact _tankCritical:          controller.getParameterFact(-1, "SPRAY_TANK_CRITICAL", false)
```

#### UI Sections:
1. **Spraying System**: Enable/disable toggle with description
2. **Tank Configuration**: Capacity and warning level settings
3. **Flow Rate Settings**: Flow rate and monitoring configuration
4. **Advanced Settings**: Pin assignments and calibration (collapsible)

### Summary UI (`APMSprayingComponentSummary.qml`)

Provides a compact overview of current spraying configuration:

```qml
VehicleSummaryRow {
    labelText: qsTr("Spraying System:")
    valueText: _sprayEnable.enumStringValue
}

VehicleSummaryRow {
    labelText: qsTr("Tank Capacity:")
    valueText: _sprayEnabled && _tankCapacity ? _tankCapacity.valueString + " " + _tankCapacity.units : ""
    visible:    _sprayEnabled && _tankCapacity
}
```

## APM Parameter Integration

### Supported Parameters

The component integrates with the following ArduPilot spraying parameters:

| Parameter | Description | Type | Range |
|-----------|-------------|------|-------|
| `SPRAY_ENABLE` | Enable/disable spraying system | Enum | 0=Disabled, 1=Enabled |
| `SPRAY_TANK_CAPACITY` | Tank capacity in liters | Float | 0-1000 |
| `SPRAY_FLOW_RATE` | Flow rate in L/min | Float | 0-100 |
| `SPRAY_FLOW_MONITOR` | Enable flow monitoring | Enum | 0=Disabled, 1=Enabled |
| `SPRAY_FLOW_PIN` | Flow sensor pin assignment | Int | 0-54 |
| `SPRAY_PUMP_PIN` | Pump control pin assignment | Int | 0-54 |
| `SPRAY_FLOW_MULT` | Flow sensor multiplier | Float | 0.1-10.0 |
| `SPRAY_FLOW_OFFSET` | Flow sensor offset | Float | -1000-1000 |
| `SPRAY_TANK_LOW` | Low tank warning level | Float | 0-100 |
| `SPRAY_TANK_CRITICAL` | Critical tank level | Float | 0-100 |

### Parameter Metadata

Parameters are defined in the APM parameter metadata files:
- `APMParameterFactMetaData.Copter.4.2.xml`
- `APMParameterFactMetaData.Plane.4.2.xml`
- `APMParameterFactMetaData.Rover.4.2.xml`

Example parameter definition:
```xml
<param humanName="Sprayer enable/disable" name="SPRAY_ENABLE" 
      documentation="Allows you to enable (1) or disable (0) the sprayer" user="Standard">
    <values>
        <value code="0">Disabled</value>
        <value code="1">Enabled</value>
    </values>
</param>
```

## Build System Integration

### QMake Project File (`qgroundcontrol.pro`)

The component must be added to the main project file:

#### Headers Section:
```pro
HEADERS += \
    # ... other headers ...
    src/AutoPilotPlugins/APM/APMSprayingComponent.h \
```

#### Sources Section:
```pro
SOURCES += \
    # ... other sources ...
    src/AutoPilotPlugins/APM/APMSprayingComponent.cc \
```

### Resource Integration (`APMResources.qrc`)

QML files must be included in the resource system:

```xml
<qresource prefix="/qml">
    <!-- ... other QML files ... -->
    <file alias="APMSprayingComponent.qml">../../AutoPilotPlugins/APM/APMSprayingComponent.qml</file>
    <file alias="APMSprayingComponentSummary.qml">../../AutoPilotPlugins/APM/APMSprayingComponentSummary.qml</file>
</qresource>
```

### Icon Integration (`qgcimages.qrc`)

The component icon is included in the main image resources:

```xml
<file alias="SprayingIcon.svg">src/AutoPilotPlugins/APM/Images/SprayingIcon.svg</file>
```

## Plugin Integration

### APMAutoPilotPlugin Integration

The component is integrated into the APM autopilot plugin:

#### Header Declaration (`APMAutoPilotPlugin.h`):
```cpp
class APMSprayingComponent;

class APMAutoPilotPlugin : public AutoPilotPlugin
{
    // ... other members ...
    APMSprayingComponent*       _sprayingComponent;
};
```

#### Implementation (`APMAutoPilotPlugin.cc`):
```cpp
#include "APMSprayingComponent.h"

// In constructor or setup method:
_sprayingComponent = new APMSprayingComponent(_vehicle, this);
_sprayingComponent->setupTriggerSignals();
_components.append(QVariant::fromValue((VehicleComponent*)_sprayingComponent));
```

## Build Process

### Required Steps

1. **Add Source Files**: Include `.h` and `.cc` files in `qgroundcontrol.pro`
2. **Add QML Resources**: Include QML files in `APMResources.qrc`
3. **Plugin Integration**: Add component creation in `APMAutoPilotPlugin.cc`
4. **Clean Build**: Remove build artifacts and regenerate Makefile
5. **Compile**: Build the project with qmake/make

### Build Commands

```bash
# Clean build directory
rm -rf build/*

# Regenerate Makefile
qmake ../qgroundcontrol.pro

# Build project
make
```

## Runtime Behavior

### Component Lifecycle

1. **Initialization**: Component created when APM vehicle connects
2. **Parameter Loading**: APM parameters loaded from vehicle
3. **UI Display**: Component appears in vehicle setup menu
4. **User Interaction**: User configures spraying parameters
5. **Parameter Sync**: Changes sent to vehicle via MAVLink
6. **Summary Display**: Configuration shown in vehicle summary

### Parameter Synchronization

- **Real-time Updates**: Parameter changes immediately reflected in UI
- **Vehicle Sync**: Changes sent to vehicle via MAVLink parameter protocol
- **Validation**: Parameter ranges and types validated by APM firmware
- **Persistence**: Parameters stored in vehicle's EEPROM/flash memory

## Troubleshooting

### Common Issues

1. **Component Not Visible**:
   - Check `setupComplete()` returns `true`
   - Verify QML files in `APMResources.qrc`
   - Ensure source files in `qgroundcontrol.pro`

2. **Build Errors**:
   - Verify all includes are correct
   - Check for missing dependencies
   - Clean and rebuild project

3. **Parameter Issues**:
   - Verify parameter names match APM firmware
   - Check parameter metadata definitions
   - Ensure vehicle supports spraying parameters

### Debug Steps

1. **Check Component Registration**: Verify component appears in `_components` list
2. **Verify QML Loading**: Check for QML loading errors in console
3. **Parameter Validation**: Confirm parameters exist on connected vehicle
4. **Resource Loading**: Verify QML files accessible via `qrc:/` URLs

## Future Enhancements

### Potential Improvements

1. **Advanced Calibration**: Flow sensor calibration wizard
2. **Mission Integration**: Spraying commands in mission planning
3. **Real-time Monitoring**: Live flow rate and tank level display
4. **Preset Management**: Save/load spraying configurations
5. **Multi-tank Support**: Support for multiple spray tanks

### Extension Points

- **Custom Parameters**: Add new spraying-related parameters
- **UI Enhancements**: Improve user experience and workflow
- **Integration**: Connect with mission planning and flight modes
- **Monitoring**: Add real-time status and telemetry display

## Conclusion

The APMSprayingComponent provides a complete solution for configuring spraying systems in QGroundControl. The implementation follows QGroundControl's component architecture and integrates seamlessly with the APM autopilot system. The modular design allows for easy maintenance and future enhancements while providing users with an intuitive interface for spraying system configuration.

