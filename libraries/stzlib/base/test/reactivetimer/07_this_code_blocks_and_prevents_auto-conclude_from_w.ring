# Narrative
# --------
# This code BLOCKS and prevents auto-conclude from working!
#
# Extracted from stzreactivetimertest.ring, block #7.

load "../../stzBase.ring"


pr()

? "❌ BROKEN EXAMPLE - Using Sleep() inside Rs{}"
? "This will NOT work because Sleep() blocks the event loop!"
? ""

Rs = new stzReactiveSystem()
Rs {
    oSensorStream = CreateStream("temperature-readings")
    oSensorStream {
        SetAutoConclude(true)
        SetAutoConcludeDelay(500)
        
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
            ? "✅ Stream completed"
        })
        
        ? "📡 Receiving readings..."
        
        # ❌ PROBLEM: Sleep() blocks the entire event loop!
        Recieve([:temp = 22.5, :sensor = "A1"])
        Recieve([:temp = 23.1, :sensor = "A2"])
        
        Sleep(200)  # ❌ BLOCKS! No timers can run during this!
        ? "   (200ms gap - but Sleep() blocked auto-conclude timer!)"
        
        Recieve([:temp = 21.8, :sensor = "A3"])
        Sleep(600)  # ❌ BLOCKS! Auto-conclude timer can't check!
        
        # Stream NEVER auto-concludes because Sleep() blocked the timer!
    }
    
    RunLoop()  # This never gets processed data because Sleep() blocked it
}

#-->
# ❌ BROKEN EXAMPLE - Using Sleep() inside Rs{}
# This will NOT work because Sleep() blocks the event loop!
#
# 📡 Receiving readings...
# !!!BLOCKS HERE!!!

pf()
