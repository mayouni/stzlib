
load "../stzbase.ring"

#=======================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS  #
#=======================================#

# Welcome to Reactive Timers in Softanza library for Ring (StzLib)!
# This tutorial teaches you step-by-step how to work with time-based
# events in a non-blocking way.

#-------------------------#
#  KEY LEARNINGS SUMMARY  #
#-------------------------#

/*--- What you learned with these examples:

1. **RunAfter**: One-time execution after delay
   - RunAfter(function, milliseconds)
   - Perfect for delayed actions

2. **RunEvery**: Repeated execution at intervals  
   - RunEvery(function_name, milliseconds)
   - Perfect for periodic tasks
   - Always remember to StopTimer() to stop it!

3. **Scope Management**: Variables must be accessible to callbacks
   - Use global-level variables, or
   - Use object properties with Method() calls

4. **Timer Coordination**: Multiple timers can work together
   - Each timer runs independently
   - Use RunAfter to stop intervals after a certain time

5. **Reactive Streams + Timers**: Powerful combination
   - Timers generate data
   - Streams distribute data to subscribers
   - Creates real-time data processing pipelines

6. **Always Clean Up**: Prevent infinite loops
   - StopTimer() to stop repeating timers
   - reactive.Stop() to shut down the engine
   - Proper cleanup prevents resource leaks

7. Never use Ring sleep() function inside the Reactive System

Other timer-based applications can be:
- A digital clock display
- A countdown timer
- A simple animation system
- A data polling system for APIs

*/

/*--- Understanding RunAfter - One-time delayed execution

# RunAfter executes a function ONCE after a specified delay
# Think of it like setting an alarm clock that goes off only once

pr()

# Creating a timer that fires once after 2 seconds

Rs = new stzReactiveSystem()
Rs {

    RunAfter( 2000, func() {
        ? "⏰ DING! Timer went off after 2000ms (2 seconds)"
        ? "This message appears exactly once"
    })
    
    ? "Timer set! Now starting the reactive engine..."
    Start()  # This starts the event loop and waits for timers
}
#-->
'
Timer set! Now starting the reactive engine...
⏰ DING! Timer went off after 2000ms (2 seconds)
This message appears exactly once
'

pf()
# Executed in 2.14 second(s) in Ring 1.23

#--> Output:
# Timer set! Now starting the reactive engine...
# ⏰ DING! Timer went off after 2000ms (2 seconds)
# This message appears exactly once


/*--- Understanding RunEvery - Repeating execution

# RunEvery executes a function REPEATEDLY at regular intervals
# Like a metronome that keeps ticking until you stop it

pr()

# Creating a timer that fires every 1 second, 3 times total

# We need these variables at global level so the callback can access them
nCounter = 0
cIntervalID = ""

Rs = new stzReactiveSystem()
Rs {
    # RunEvery(function_name, interval_in_milliseconds)
    cIntervalID = RunEvery(1000, :fCallback)
    
    ? "Repeating timer set! Starting..."
    Start()
}

pf()

# The callback function - defined separately so variables are accessible
func fCallback()
    nCounter++
    ? "🔔 Tick #" + nCounter + " at time " + clock()
    
    # Stop after 3 ticks
    if nCounter >= 3
        ? "Stopping timer after 3 ticks..."
        Rs.StopTimer(cIntervalID)
        Rs.Stop()
    ok

#-->
'
Repeating timer set! Starting...
🔔 Tick #1 at time 3624
🔔 Tick #2 at time 3640
🔔 Tick #3 at time 3656
Stopping timer after 3 ticks...
'

# Executed in 1.06 second(s) in Ring 1.23


/*--- Multiple timers working together

# You can have multiple timers running simultaneously
# Each timer operates independently

pr()

# Running fast timer (every 500ms) and slow timer (every 1500ms)

nFastCount = 0
nSlowCount = 0
cFastId = ""
cSowId = ""

Rs = new stzReactiveSystem()
Rs {
    # Fast timer - every 500ms
    cFastId = RunEvery(500, :fFastTick)
    
    # Slow timer - every 1500ms  
    cSowId = RunEvery(1500, :fSlowTick)
    
    # Stop everything after 4 seconds
    RunAfter(4000, :fStopAllTimers)
    
    ? "Multiple timers started!"

    Start()
}

pf()

func fFastTick()
    nFastCount++
    ? "⚡ Fast tick #" + nFastCount

func fSlowTick()
    nSlowCount++
    ? "🐌 Slow tick #" + nSlowCount
    
func fStopAllTimers()
    ? "⏹️  Stopping all timers..."
    Rs.StopTimer(cFastId)
    Rs.StopTimer(cSowId)
    Rs.Stop()  # This should now properly exit

#--> Output:
# Multiple timers started!
# ⚡ Fast tick #1
# ⚡ Fast tick #2
# ...
# ...
# ⚡ Fast tick #63
# 🐌 Slow tick #1
# ⚡ Fast tick #64
# 🐌 Slow tick #2
# ⚡ Fast tick #65
# ...
# ...
# ...
# ⚡ Fast tick #220
# 🐌 Slow tick #158
# ⏹️  Stopping all timers...

# Executed in 4.02 second(s) in Ring 1.23


/*--- Timer-driven data streams: Using timers to create reactive data streams

# Timers can drive reactive streams, creating time-based data sources
# Perfect for simulating sensRs, stock prices, or any real-time data

pr()

? "Creating a data stream that generates values every 800ms..."

nDtaCounter = 0
cItervalId = ""

Rs = new stzReactiveSystem()
Rs {
    # Create a stream for our time-based data
    oDataStream = CreateStream("sensor-data")
    #TODO // oDataStram is an attribue! think of a better API!

    # Subscribe to the stream - this function receives each data point
    oDataStream.Subscribe(func data {
        ? "📊 Received data: " + data
    })

    # Generate data every 800ms using a timer
    cItervalId = RunEvery(800, :fGenerateData)

    # Stop after 4 data points
    RunAfter(3500, :fStopDataGeneration)

    ? "Data stream started! Generating data every 800ms..."
    Start()
}

pf()

func fGenerateData()
    nDtaCounter++
    # Simulate sensor reading with random-ish data
    temperature = 20 + (nDtaCounter * 2.5)
    dataPoint = "Temperature: " + temperature + "°C (reading #" + nDtaCounter + ")"
    
    # Emit the data to the stream
    Rs.oDataStream.Emit(dataPoint)

func fStopDataGeneration()
    ? "🛑 Stopping data generation..."
    Rs.StopTimer(cItervalId)
    Rs.oDataStream.Complete()  # Properly end the stream
    Rs.Stop()

#--> Output:
# Data stream started! Generating data every 800ms...
# 📊 Received data: Temperature: 22.5°C (reading #1)
# 📊 Received data: Temperature: 25.0°C (reading #2)  
# 📊 Received data: Temperature: 27.5°C (reading #3)
# 📊 Received data: Temperature: 30.0°C (reading #4)
# ...
# ...
# ...
# 📊 Received data: Temperature: 417.50°C (reading #159)
# 📊 Received data: Temperature: 420°C (reading #160)
# 📊 Received data: Temperature: 422.50°C (reading #161)
# 📊 Received data: Temperature: 425°C (reading #162)
# 🛑 Stopping data generation...

# Executed in 3.53 second(s) in Ring 1.23



/*--- Real-world example: Simulating a download progress

# This example shows how timers can simulate real-world async operations
# like file downloads, data processing, or any long-running task

pr()

# Simulating a file download with progress updates...

# Run the download simulation
ds = new DownloadSimulator()
ds.StartDownload()

pf()

func UpdateProgress()
    ds.nProgress += 20
    
    if ds.nProgress <= 100
        cProgressBar = ""
        nFilledBars = floor(ds.nProgress / 10)
        nEmptyBars = 10 - nFilledBars
        
        for i = 1 to nFilledBars
            cProgressBar += "█"
        next

        for i = 1 to nEmptyBars  
            cProgressBar += "░"
        next
        
        ? "Progress: [" + cProgressBar + "] " + ds.nProgress + "%"
    ok

func CompleteDownload()
    ds.oReactive.StopTimer(ds.cProgressId)

    ? NL + "✔ Download completed successfully!"
    ? "File " + ds.cFileName + " is ready to use."

    ds.oReactive.Stop()

class DownloadSimulator
    nProgress = 0
    cDownloadId = ""
    cProgressId = ""
    oReactive = NULL
    cFileName = "large-file.zip"
    
    def Init()
        oReactive = new stzReactive()
        nProgress = 0
        cFileName = "large-file.zip"
        
    def StartDownload()
        ? "🔽 Starting download of " + cFileName + "..." + NL

        ? "Progress: [----------] 0%"
        
        oReactive {
            cProgressId = RunEvery(:UpdateProgress, 500)
            RunAfter(:CompleteDownload, 5000)
            
            Start()
        }

#--> Output:
# 🔽 Starting download of large-file.zip...

# Progress: [----------] 0%
# Progress: [██░░░░░░░░] 20%
# Progress: [████░░░░░░] 40%
# Progress: [██████░░░░] 60%
# Progress: [████████░░] 80%
# Progress: [██████████] 100%

# ✔ Download completed successfully!
# File large-file.zip is ready to use.

# Executed in 5.02 second(s) in Ring 1.23

#=======================================#
#  CRITICAL: NEVER USE Sleep() IN Rs{}  #
#=======================================#

# This example demonstrates why Sleep() blocks reactive systems
# and shows the correct timer-based approach


/*--- This code BLOCKS and prevents auto-conclude from working!

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


/*--- This works perfectly because timers are non-blocking

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


/*--- Understanding the technical reason

🔍 WHY Sleep() BREAKS REACTIVE CODE
The fundamental problem:

1. Sleep() is BLOCKING
   - Pauses the entire thread
   - No other code can execute
   - Timers cannot fire
   - Event loop cannot process

2. RunAfter() is NON-BLOCKING  
   - Schedules execution for later
   - Event loop continues running
   - Other timers can still fire
   - Auto-conclude timers work properly

3. Auto-conclude relies on timers
   - Uses internal timer to detect data gaps
   - Sleep() prevents this timer from running
   - Result: stream never concludes automatically

/*=== STOPPING TIMERS

/*--- Simple countdown timer with StopTimer()

pr()

countdown = 5
timerId = NULL

Rs = new stzReactiveSystem()
Rs {
    # Start countdown timer
    timerId = RunEveryXT(1, :seconds, func {
        ? "Countdown: " + countdown
        countdown--
        
        if countdown <= 0
            ? "Time's up!"
            Rs.StopTimer(timerId)  # Natural stop action
            Rs.Stop()
        ok
    })
    
    Start()
}

#-->
# Countdown: 5
# Countdown: 4  
# Countdown: 3
# Countdown: 2
# Countdown: 1
# Time's up!

pf()
# Executed in 0.19 second(s) in Ring 1.23

/*--- Emergency shutdown with StopAllTimers()
*/

pr()

systemAlert = false
timer1 = NULL
timer2 = NULL  
timer3 = NULL

Rs = new stzReactiveSystem()
Rs {
    # Multiple concurrent timers
    timer1 = RunEveryXT(2, :seconds, func {
        ? "System monitor check"
    })
    
    timer2 = RunEveryXT(3, :seconds, func {
        ? "Data backup running"
    })
    
    timer3 = RunEveryXT(5, :seconds, func {
        ? "Network heartbeat"
        systemAlert = true  # Trigger emergency
    })
    
    # Emergency shutdown timer
    RunEveryXT(1, :second, func {
        if systemAlert
            ? "EMERGENCY: Stopping all operations!"
            Rs.StopAllTimers()  # Single call stops everything
            Rs.Stop()
        ok
    })
    
    RunLoop()
}

#-->
# System monitor check
# Data backup running  
# System monitor check
# Network heartbeat
# EMERGENCY: Stopping all operations!

pf()
# Executed in 0.19 second(s) in Ring 1.23

/*=== Critical guidelines for reactive programming:

✅ DO USE:
- RunAfter() for delays
- RunEvery() for repeated actions  
- Non-blocking operations
- Event-driven patterns

❌ NEVER USE:
- Sleep() - blocks event loop
- Blocking I/O operations
- Busy wait loops (while true)
- Any synchronous delays

💡 REMEMBER:
- Reactive systems are event-driven
- Everything happens through timers and callbacks
- The event loop must stay free to process events
- Use Start() to begin processing, Stop() to end


