# Narrative
# --------
# Sensor-Based Streams
#
# Extracted from stzreactivestreamtest.ring, block #12.

load "../../../stzBase.ring"


# IoT devices, environmental monitoring, real-time measurements
# Essential for: IoT applications, monitoring systems, data acquisition

pr()

Rs = new stzReactiveSystem()
Rs {
    # Environmental monitoring stream
    oSensorStream = CreateSensorStream("environment-monitor")
    oSensorStream {

        # Calibrate sensor readings
        Transform(func rawReading {
            # Simulate sensor data processing
            return [
                :sensor_id = rawReading[:id],
                :temperature = rawReading[:temp] * 0.1,  # Convert to Celsius
                :humidity = rawReading[:humidity],
                :air_quality = rawReading[:aqi],
                :timestamp = clocksPerSecond()
            ]
        })
        
        # Environmental alerts
        Filter(func reading {
            return reading[:temperature] > 30 or 
                   reading[:humidity] > 80 or
                   reading[:air_quality] > 150
        })
        
        OnPassed(func alert {
            alertTypes = []

            if alert[:temperature] > 30
                alertTypes + "🌡️ HIGH TEMP"
            ok

            if alert[:humidity] > 80  
                alertTypes + "💧 HIGH HUMIDITY"
            ok

            if alert[:air_quality] > 150
                alertTypes + "🏭 POOR AIR QUALITY"
            ok
            
            ? "⚠️ ENVIRONMENTAL ALERT: " + JoinXT(alertTypes, " + ")
            ? "• Sensor: " + alert[:sensor_id] 
            ? "• Temperature: " + alert[:temperature] + "°C"
            ? "• Humidity: " + alert[:humidity] + "%"
            ? "• Air Quality Index: " + alert[:air_quality] + NL
        })
        
        # Simulate sensor readings
        sensorData = [
            [:id = "TEMP_01", :temp = 250, :humidity = 45, :aqi = 75],   # Normal
            [:id = "TEMP_02", :temp = 320, :humidity = 85, :aqi = 180],  # High temp + humidity + AQI
            [:id = "TEMP_03", :temp = 280, :humidity = 90, :aqi = 120],  # High humidity only
            [:id = "TEMP_04", :temp = 350, :humidity = 60, :aqi = 95]    # High temp only
        ]
        
        RecieveMany(sensorData)

    }
    
    RunLoop()
    #-->
    '
    ⚠️ ENVIRONMENTAL ALERT: 🌡️ HIGH TEMP + 💧 HIGH HUMIDITY + 🏭 POOR AIR QUALITY
    • Sensor: TEMP_02
    • Temperature: 32°C
    • Humidity: 85%
    • Air Quality Index: 180

    ⚠️ ENVIRONMENTAL ALERT: 💧 HIGH HUMIDITY
    • Sensor: TEMP_03
    • Temperature: 28°C
    • Humidity: 90%
    • Air Quality Index: 120

    ⚠️ ENVIRONMENTAL ALERT: 🌡️ HIGH TEMP
    • Sensor: TEMP_04
    • Temperature: 35°C
    • Humidity: 60%
    • Air Quality Index: 95
    '
}

pf()
# Executed in 1.06 second(s) in Ring 1.23
