/**
 * @file FrogsSprayExample.cpp
 * @brief Example C++ code demonstrating how to use the FROGS_SPRAY message data
 * 
 * This file shows various ways to access and use the FROGS_SPRAY message data
 * in C++ code within QGroundControl.
 */

#include "Vehicle.h"
#include "VehicleFrogsSprayFactGroup.h"
#include <QDebug>
#include <QObject>

class FrogsSprayMonitor : public QObject
{
    Q_OBJECT

public:
    explicit FrogsSprayMonitor(Vehicle* vehicle, QObject* parent = nullptr)
        : QObject(parent)
        , _vehicle(vehicle)
    {
        // Connect to value changes
        connectToSignals();
    }

    /**
     * @brief Get current spray system status
     */
    void printCurrentStatus()
    {
        if (!_vehicle) {
            qWarning() << "No vehicle connected";
            return;
        }

        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        
        // Get raw values
        uint64_t timestamp = spray->timestamp()->rawValue().toULongLong();
        float volWater = spray->volWater()->rawValue().toFloat();
        double flowRate = spray->flowRate()->rawValue().toDouble();
        double cActuator = spray->cActuator()->rawValue().toDouble();
        
        qDebug() << "=== FROGS Spray System Status ===";
        qDebug() << "Timestamp:" << timestamp << "us";
        qDebug() << "Water Volume:" << volWater << "L";
        qDebug() << "Flow Rate:" << flowRate << "L/min";
        qDebug() << "Actuator Control:" << cActuator;
        
        // Check for warnings
        checkWarningConditions();
    }

    /**
     * @brief Check for warning conditions
     */
    void checkWarningConditions()
    {
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        
        float volWater = spray->volWater()->rawValue().toFloat();
        double flowRate = spray->flowRate()->rawValue().toDouble();
        
        // Check for low water
        if (!qIsNaN(volWater) && volWater < 2.0) {
            qWarning() << "⚠️  WARNING: Low water level!" << volWater << "L remaining";
        }
        
        // Check for abnormal flow rate
        if (!qIsNaN(flowRate) && flowRate > 10.0) {
            qWarning() << "⚠️  WARNING: Flow rate exceeds normal range!" << flowRate << "L/min";
        }
    }

    /**
     * @brief Connect to Fact value changes
     */
    void connectToSignals()
    {
        if (!_vehicle) return;
        
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        
        // Monitor water volume changes
        connect(spray->volWater(), &Fact::rawValueChanged, this, [this]() {
            float volume = _vehicle->frogsSpray()->volWater()->rawValue().toFloat();
            qDebug() << "Water volume changed:" << volume << "L";
            
            if (!qIsNaN(volume) && volume < 1.0) {
                emit lowWaterWarning(volume);
            }
        });
        
        // Monitor flow rate changes
        connect(spray->flowRate(), &Fact::rawValueChanged, this, [this]() {
            double rate = _vehicle->frogsSpray()->flowRate()->rawValue().toDouble();
            qDebug() << "Flow rate changed:" << rate << "L/min";
            emit flowRateChanged(rate);
        });
        
        // Monitor actuator changes
        connect(spray->cActuator(), &Fact::rawValueChanged, this, [this]() {
            double actuator = _vehicle->frogsSpray()->cActuator()->rawValue().toDouble();
            qDebug() << "Actuator control changed:" << actuator;
        });
    }

    /**
     * @brief Get formatted string for display
     */
    QString getFormattedStatus()
    {
        if (!_vehicle) return "No vehicle";
        
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        
        QString status = QString("Water: %1 %2 | Flow: %3 %4 | Actuator: %5")
            .arg(spray->volWater()->valueString())
            .arg(spray->volWater()->units())
            .arg(spray->flowRate()->valueString())
            .arg(spray->flowRate()->units())
            .arg(spray->cActuator()->valueString());
        
        return status;
    }

    /**
     * @brief Example: Calculate estimated spray time remaining
     */
    double estimatedTimeRemaining()
    {
        if (!_vehicle) return 0.0;
        
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        
        float volume = spray->volWater()->rawValue().toFloat();
        double flowRate = spray->flowRate()->rawValue().toDouble();
        
        if (qIsNaN(volume) || qIsNaN(flowRate) || flowRate <= 0.0) {
            return 0.0;
        }
        
        // Calculate time remaining in minutes
        double timeRemaining = volume / flowRate;
        return timeRemaining;
    }

    /**
     * @brief Example: Check if spray system is active
     */
    bool isSprayActive()
    {
        if (!_vehicle) return false;
        
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        double flowRate = spray->flowRate()->rawValue().toDouble();
        
        // Consider active if flow rate > 0.1 L/min
        return !qIsNaN(flowRate) && flowRate > 0.1;
    }

signals:
    void lowWaterWarning(float volumeRemaining);
    void flowRateChanged(double newRate);
    void spraySystemActive(bool active);

private:
    Vehicle* _vehicle;
};

// ============================================================================
// Usage Examples
// ============================================================================

/**
 * Example 1: Simple read access
 */
void example1_simpleAccess(Vehicle* vehicle)
{
    VehicleFrogsSprayFactGroup* spray = vehicle->frogsSpray();
    
    // Get values
    float volume = spray->volWater()->rawValue().toFloat();
    double flowRate = spray->flowRate()->rawValue().toDouble();
    
    qDebug() << "Current water volume:" << volume << "L";
    qDebug() << "Current flow rate:" << flowRate << "L/min";
}

/**
 * Example 2: Using formatted strings
 */
void example2_formattedStrings(Vehicle* vehicle)
{
    VehicleFrogsSprayFactGroup* spray = vehicle->frogsSpray();
    
    // Get formatted strings (includes proper decimal places)
    QString volumeStr = spray->volWater()->valueString();
    QString flowRateStr = spray->flowRate()->valueString();
    QString units = spray->flowRate()->units();
    
    qDebug() << "Water:" << volumeStr << "L";
    qDebug() << "Flow:" << flowRateStr << units;
}

/**
 * Example 3: Monitoring value changes
 */
void example3_monitorChanges(Vehicle* vehicle, QObject* context)
{
    VehicleFrogsSprayFactGroup* spray = vehicle->frogsSpray();
    
    // Connect to any value change
    QObject::connect(spray->flowRate(), &Fact::rawValueChanged, context, [vehicle]() {
        double rate = vehicle->frogsSpray()->flowRate()->rawValue().toDouble();
        qDebug() << "Flow rate updated:" << rate;
    });
}

/**
 * Example 4: Using the monitor class
 */
void example4_useMonitorClass(Vehicle* vehicle)
{
    FrogsSprayMonitor* monitor = new FrogsSprayMonitor(vehicle);
    
    // Print current status
    monitor->printCurrentStatus();
    
    // Get formatted status
    QString status = monitor->getFormattedStatus();
    qDebug() << status;
    
    // Calculate time remaining
    double timeLeft = monitor->estimatedTimeRemaining();
    qDebug() << "Estimated time remaining:" << timeLeft << "minutes";
    
    // Connect to warnings
    QObject::connect(monitor, &FrogsSprayMonitor::lowWaterWarning, 
                    [](float volume) {
        qWarning() << "⚠️  Low water alert!" << volume << "L remaining";
    });
}

/**
 * Example 5: Accessing from a QML C++ class
 */
class MyQmlClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sprayStatus READ sprayStatus NOTIFY sprayStatusChanged)

public:
    MyQmlClass(Vehicle* vehicle, QObject* parent = nullptr)
        : QObject(parent), _vehicle(vehicle)
    {
        // Connect to updates
        connect(_vehicle->frogsSpray()->volWater(), &Fact::rawValueChanged,
                this, &MyQmlClass::sprayStatusChanged);
        connect(_vehicle->frogsSpray()->flowRate(), &Fact::rawValueChanged,
                this, &MyQmlClass::sprayStatusChanged);
    }

    QString sprayStatus() const
    {
        if (!_vehicle) return "N/A";
        
        VehicleFrogsSprayFactGroup* spray = _vehicle->frogsSpray();
        return QString("Vol: %1L, Flow: %2L/min")
            .arg(spray->volWater()->valueString())
            .arg(spray->flowRate()->valueString());
    }

signals:
    void sprayStatusChanged();

private:
    Vehicle* _vehicle;
};

// Include the moc file for Qt meta-object compilation
// #include "FrogsSprayExample.moc"

