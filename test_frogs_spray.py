#!/usr/bin/env python3
"""
FROGS_SPRAY Message Test Script

This script sends test FROGS_SPRAY messages to QGroundControl for testing.
It simulates spray system telemetry data.

Usage:
    python test_frogs_spray.py --connect udp:127.0.0.1:14550

Requirements:
    pip install pymavlink
"""

import sys
import time
import argparse
import struct
import random
from pymavlink import mavutil


def create_frogs_spray_message(timestamp, vol_water, flow_rate, c_actuator):
    """
    Create a FROGS_SPRAY message manually.
    
    Message ID: 500
    Fields:
        - uint64 timestamp (8 bytes)
        - float32 vol_water (4 bytes)
        - float64 flow_rate (8 bytes)
        - float64 c_actuator (8 bytes)
    Total: 28 bytes
    """
    # Pack the message payload
    payload = struct.pack('<Qfdd', 
                         timestamp,    # uint64 (Q)
                         vol_water,    # float32 (f)
                         flow_rate,    # float64 (d)
                         c_actuator)   # float64 (d)
    
    return payload


def send_frogs_spray(connection, timestamp, vol_water, flow_rate, c_actuator):
    """Send a FROGS_SPRAY message via MAVLink."""
    
    msg_id = 500  # FROGS_SPRAY message ID
    
    # Create the message payload
    payload = create_frogs_spray_message(timestamp, vol_water, flow_rate, c_actuator)
    
    # Create MAVLink message manually
    # Note: This uses the low-level API since FROGS_SPRAY is a custom message
    connection.mav.send(
        connection.mav.message_factory.encode(
            msg_id,
            payload
        )
    )
    
    print(f"Sent: timestamp={timestamp}, vol_water={vol_water:.2f}L, "
          f"flow_rate={flow_rate:.3f}L/min, c_actuator={c_actuator:.2f}")


def simulate_spray_operation(connection, duration=60, interval=1.0):
    """
    Simulate a spray operation with varying values.
    
    Args:
        connection: MAVLink connection
        duration: Simulation duration in seconds
        interval: Time between messages in seconds
    """
    print(f"\n🚁 Starting FROGS_SPRAY simulation for {duration} seconds...")
    print(f"📡 Sending messages every {interval} second(s)\n")
    
    start_time = time.time()
    initial_volume = 20.0  # Start with 20L
    
    try:
        while time.time() - start_time < duration:
            elapsed = time.time() - start_time
            
            # Simulate changing values
            timestamp = int(time.time() * 1e6)  # microseconds
            
            # Water volume decreases over time
            vol_water = max(0.0, initial_volume - (elapsed * 0.05))
            
            # Flow rate varies (simulation)
            flow_rate = 5.0 + 2.0 * abs(0.5 - (elapsed % 2) / 2)  # 3-7 L/min
            
            # Actuator control varies (0-1 range)
            c_actuator = 0.5 + 0.3 * (0.5 - abs(0.5 - (elapsed % 4) / 4))
            
            # Send the message
            send_frogs_spray(connection, timestamp, vol_water, flow_rate, c_actuator)
            
            time.sleep(interval)
            
    except KeyboardInterrupt:
        print("\n\n⚠️  Simulation stopped by user")


def send_test_messages(connection):
    """Send a few test messages with known values."""
    print("\n📤 Sending test messages...\n")
    
    test_cases = [
        (1000000, 15.5, 5.25, 0.75),    # Normal operation
        (2000000, 10.2, 8.50, 0.90),    # Higher flow rate
        (3000000, 5.0, 3.20, 0.45),     # Low volume warning
        (4000000, 0.5, 1.10, 0.15),     # Critical low volume
    ]
    
    for i, (ts, vol, flow, act) in enumerate(test_cases, 1):
        print(f"Test {i}/4:")
        send_frogs_spray(connection, ts, vol, flow, act)
        time.sleep(0.5)
    
    print("\n✅ Test messages sent successfully!")


def main():
    parser = argparse.ArgumentParser(
        description='Test FROGS_SPRAY message implementation in QGroundControl'
    )
    parser.add_argument(
        '--connect',
        default='udp:127.0.0.1:14550',
        help='MAVLink connection string (default: udp:127.0.0.1:14550)'
    )
    parser.add_argument(
        '--mode',
        choices=['test', 'simulate'],
        default='simulate',
        help='test: send a few test messages, simulate: continuous simulation (default: simulate)'
    )
    parser.add_argument(
        '--duration',
        type=int,
        default=60,
        help='Simulation duration in seconds (default: 60)'
    )
    parser.add_argument(
        '--interval',
        type=float,
        default=1.0,
        help='Time between messages in seconds (default: 1.0)'
    )
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("  FROGS_SPRAY Message Test Tool")
    print("=" * 60)
    
    # Connect to the vehicle
    print(f"\n🔌 Connecting to {args.connect}...")
    
    try:
        connection = mavutil.mavlink_connection(args.connect)
        print("⏳ Waiting for heartbeat...")
        connection.wait_heartbeat()
        print(f"✅ Connected! System ID: {connection.target_system}, "
              f"Component ID: {connection.target_component}")
        
        # Run selected mode
        if args.mode == 'test':
            send_test_messages(connection)
        else:
            simulate_spray_operation(connection, args.duration, args.interval)
        
        print("\n" + "=" * 60)
        print("  Test completed successfully!")
        print("=" * 60 + "\n")
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()

