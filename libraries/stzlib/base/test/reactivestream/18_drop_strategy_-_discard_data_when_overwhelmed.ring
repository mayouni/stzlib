# Narrative
# --------
# Drop Strategy - Discard data when overwhelmed
#
# Extracted from stzreactivestreamtest.ring, block #18.

load "../../stzBase.ring"


# The sample shows BUFFER_REJECT_NEWEST behavior 
# Buffer fills to capacity (3), then excess sensor readings
# are discarded to prevent system overload - sacrifices data 
# completeness for stability

pr()

Rs = new stzReactiveSystem()
Rs {
    # Real-time sensor stream that can afford to lose some data
    oDropStream = CreateSensorStream("drop-example")
    oDropStream {
        SetOverflowStrategy(BUFFER_REJECT_NEWEST, 2)
        
        Transform(func reading {
            return "Sensor-" + reading + "°C"
        })
        
        OnPassed(func temperature {
            ? "🌡️ Current temp: " + temperature
        })
        
        OnOverflow(func(current, max) {
            ? "🚨 Sensor overloaded, discarding readings"
        })

        ? "Simulating high-frequency sensor readings..."
        
        # Simulate sensor burst
        sensorReadings = [23.5, 23.7, 24.1, 24.3, 24.5, 24.8, 25.0]
        _nSensorReadingsLen_ = ring_len(sensorReadings)
        for i = 1 to _nSensorReadingsLen_
            ? "Reading: " + sensorReadings[i]
            Recieve(sensorReadings[i])
        next
        
        stats = OverflowStats()
        ? NL + "Final stats - Dropped: " + stats[:droppedCount] + " readings"

    }
    
    RunLoop()
    #--> (#NOTE I added some comments to clarify the output)
    # Simulating high-frequency sensor readings...
    # 
    # Phase 1: Buffer fills with initial readings (capacity: 2)
    # ---------------------------------------------------------
    # Reading: 23.50
    # Reading: 23.70
    # 
    # Phase 2: Drop strategy - excess readings discarded
    # --------------------------------------------------
    # Reading: 24.10
    # 🚨 Sensor overloaded, discarding readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 1)
    # 
    # Reading: 24.30
    # 🚨 Sensor overloaded, discarding readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 2)
    # 
    # Reading: 24.50
    # 🚨 Sensor overloaded, discarding readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 3)
    # 
    # Reading: 24.80
    # 🚨 Sensor overloaded, discarding readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 4)
    # 
    # Reading: 25
    # 🚨 Sensor overloaded, discarding readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 5)

    # Result: Only first 2 readings kept, rest dropped
    # ------------------------------------------------
    # Final stats - Dropped: 5 readings

}

pf()
# Executed in 0.92 second(s) in Ring 1.23
