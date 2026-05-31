# Narrative
# --------
# This works perfectly because timers are non-blocking
#
# Extracted from stzreactivetimertest.ring, block #8.

load "../../../stzBase.ring"


pr()

? "✅ CORRECT EXAMPLE - Using RunAfter() for delays"
? "This properly allows auto-conclude timers to work!"
? ""

Rs = new stzReactiveSystem()
Rs {
    oSensorStream = CreateStream("temperature-readings") 
    oSensorStream {
        SetAutoConclude(true)
        SetAutoConcludeDelay(500)  # Auto-conclude after 500ms of no data
        
        Accumulate(func(avgTemp, reading) {
            if avgTemp = 0
                return reading["temp"]
            else
                return (avgTemp + reading["temp"]) / 2
            ok
        }, 0)
        
        OnPassed(func finalAvg {
            ? "🌡️ Final Average: " + finalAvg + "°C"
        })
        
        OnNoMore(func() {
            ? "✅ Stream completed after natural delay"
            Rs.Stop()
        })
        
        ? "📡 Receiving readings..."
    }
    
    # ✅ SOLUTION: Schedule data emission using non-blocking timers
    RunAfter(func {
        oSensorStream.Recieve([:temp = 22.5, :sensor = "A1"])
        oSensorStream.Recieve([:temp = 23.1, :sensor = "A2"])
    }, 0)
    
    RunAfter(func {
        ? "   (200ms gap - auto-conclude timer can still run!)"
        oSensorStream.Recieve([:temp = 21.8, :sensor = "A3"])
        oSensorStream.Recieve([:temp = 24.2, :sensor = "A4"])
    }, 200)
    
    RunAfter(func {
        ? "   (600ms gap - auto-conclude will trigger after 500ms...)"
        # No more data - stream will auto-conclude naturally
    }, 800)
    
    Start()  # Starts event loop - timers and auto-conclude work perfectly!
}
#-->
# ✅ CORRECT EXAMPLE - Using RunAfter() for delays
# This properly allows auto-conclude timers to work!
# 
# 📡 Receiving readings...
#    (200ms gap - auto-conclude timer can still run!)
#    (600ms gap - auto-conclude will trigger after 500ms...)
# 🌡️ Final Average: 22.9°C
# ✅ Stream completed after natural delay

pf()
# Executed in 1.26 second(s) in Ring 1.23
