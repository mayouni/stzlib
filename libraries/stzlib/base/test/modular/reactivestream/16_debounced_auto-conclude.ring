# Narrative
# --------
# Debounced Auto-Conclude
#
# Extracted from stzreactivestreamtest.ring, block #16.

load "../../../stzBase.ring"

# Best for: Streaming data, network feeds, sensor readings with gaps

pr()

Rs = new stzReactiveSystem()
Rs {
    oSensorStream = CreateStream("temperature-readings")
    oSensorStream {

        # Enable debounced auto-conclude - waits for data gaps
        # SetAutoConclude(true)
        # SetAutoConcludeDelay(500)  # Wait 500ms after last reading
        SetAutoConcludeXT(true, 500)

        Accumulate( func(avgTemp, reading) {
            # Simple moving average calculation
            if avgTemp = 0
                return reading["temp"]
            else
                return (avgTemp + reading["temp"]) / 2
            ok
        }, 0) # Starting from 0

        OnPassed(func finalAvg {
            ? "🌡️  Final Average Temperature: " + finalAvg + "°C"
        })
 
        OnNoMore(func {
            ? "✅ Sensor reading session completed (after 500ms delay)"
        })

       # Simulate streaming sensor data with gaps
        ? "📡 Receiving temperature readings..."

        # Schedule sensor readings using reactive timers instead of Sleep()
        Rs.SetTimeout(0, func {
            oSensorStream.Recieve([:temp = 22.5, :sensor = "A1"])
            oSensorStream.Recieve([:temp = 23.1, :sensor = "A2"])
        })

        Rs.SetTimeout(200, func {
            ? "   (200ms gap - still waiting...)"
            oSensorStream.Recieve([:temp = 21.8, :sensor = "A3"])
            oSensorStream.Recieve([:temp = 24.2, :sensor = "A4"])
        })

        Rs.SetTimeout(600, func {
            ? "   (600ms gap - will auto-conclude after 500ms...)"
            # No more data - stream will auto-conclude after 500ms delay
        })

        Rs.SetTimeOut(1200, func {
	  ? "   (System kept alive for auto-conclude)"
        })

        # Stream automatically concludes here due to 500ms timeout
        # No manual Conclude() needed!
    }

    RunLoop()

    ? ""
    ? "💡 Key Difference:"
    ? "   • Immediate: Perfect for complete datasets (sales batches)"  
    ? "   • Debounced: Handles streaming data with natural gaps (sensors, APIs)"
}
#-->
# 📡 Receiving temperature readings...
#    (200ms gap - still waiting...)
#    (600ms gap - will auto-conclude after 500ms...)
#    (System kept alive for auto-conclude)
# 
# 💡 Key Difference:
#    • Immediate: Perfect for complete datasets (sales batches)
#    • Debounced: Handles streaming data with natural gaps (sensors, APIs)

pf()
# Executed in 2.08 second(s) in Ring 1.23

#---------------------------------------------#
#  Overflow (backpresuure) Strategy Examples  #
#---------------------------------------------#


#NOTE

# Overflow occurs when data arrives faster than it can be processed.
# The stream Recieves data (from producers) faster than Rfunctions
# (subscribers) can handle it, so the system applies overflow
# strategies to manage the excess flow.
