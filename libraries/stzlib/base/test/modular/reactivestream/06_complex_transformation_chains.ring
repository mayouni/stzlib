# Narrative
# --------
# Complex Transformation Chains
#
# Extracted from stzreactivestreamtest.ring, block #6.

load "../../../stzBase.ring"


# Shows combining multiple transformation types
# Real-world scenario: Processing sensor data

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Sensor data processing stream
    oSensorStream = CreateSensorStream("sensor-data")
    oSensorStream {

        # Multi-stage processing pipeline
        Transform(func reading {
            # Convert raw sensor value to temperature
            return (reading - 32) * 5/9  # Fahrenheit to Celsius
        })

        Filter(func temp {
            # Only valid temperature readings
            return temp >= -50 and temp <= 100
        })

        Transform(func temp {
            # Round to 1 decimal place
            return floor(temp * 10) / 10
        })
     
        OnPassed(func temperature {
            alert = ""
            if temperature > 35
                alert = " 🔥 HIGH"
            but temperature < 0
                alert = " ❄️ FREEZING"
            ok
            ? "🌡️  Temperature: " + temperature + "°C" + alert
        })
        
        # Simulate sensor readings (Fahrenheit)
        rawReadings = [ 68, 75, 32, 100, 212, -40, 150 ]
        RecieveMany(rawReadings)

    }
    
    RunLoop()
    #-->
    # 🌡️  Temperature: 20°C
    # 🌡️  Temperature: 23.8°C
    # 🌡️  Temperature: 0.0°C ❄️ FREEZING
    # 🌡️  Temperature: 37.7°C 🔥 HIGH
    # 🌡️  Temperature: 100.0°C 🔥 HIGH
    # 🌡️  Temperature: -40.0°C ❄️ FREEZING
    # 🌡️  Temperature: 65.5°C 🔥 HIGH
}

pf()
# Executed in 0.94 second(s) in Ring 1.23
