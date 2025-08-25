
load "../stzbase.ring"

#=======================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS  #
#=======================================#

# Welcome to Reactive Timers in Softanza library for Ring (StzLib)!
# This tutorial teaches you step-by-step how to work with time-based
# events in a non-blocking way.

#-------------------------------#
#  EXAMPLE 1: YOUR FIRST TIMER  #
#-------------------------------#

/*--- Understanding setTimeout - One-time delayed execution

# SetTimeout executes a function ONCE after a specified delay
# Think of it like setting an alarm clock that goes off only once

pr()

# Creating a timer that fires once after 2 seconds

Rs = new stzReactiveSystem()
Rs {
    # SetTimeout(function, delay_in_milliseconds)
    SetTimeout( func() {
        ? "⏰ DING! Timer went off after 2000ms (2 seconds)"
        ? "This message appears exactly once"
    }, 2000)
    
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

#-------------------------------#
#  EXAMPLE 2: REPEATING TIMERS  #
#-------------------------------#

/*--- Understanding setInterval - Repeating execution

# SetInterval executes a function REPEATEDLY at regular intervals
# Like a metronome that keeps ticking until you stop it

pr()

# Creating a timer that fires every 1 second, 3 times total

# We need these variables at global level so the callback can access them
nCounter = 0
cIntervalID = ""

Rs = new stzReactiveSystem()
Rs {
    # SetInterval(function_name, interval_in_milliseconds)
    cIntervalID = SetInterval(:fCallback, 1000)
    
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
        Rs.ClearInterval(cIntervalID)
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

#-------------------------------#
#  EXAMPLE 3: COMBINING TIMERS  #
#-------------------------------#

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
    cFastId = SetInterval(:fFastTick, 500)
    
    # Slow timer - every 1500ms  
    cSowId = SetInterval(:fSlowTick, 1500)
    
    # Stop everything after 4 seconds
    SetTimeout(:fStopAllTimers, 4000)
    
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
    Rs.ClearInterval(cFastId)
    Rs.ClearInterval(cSowId)
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

#----------------------------------------#
#  EXAMPLE 4: TIMER-DRIVEN DATA STREAMS  #
#----------------------------------------#

/*--- Using timers to create reactive data streams

# Timers can drive reactive streams, creating time-based data sources
# Perfect for simulating sensRs, stock prices, or any real-time data

pr()

? "Creating a data stream that generates values every 800ms..."

nDtaCounter = 0
cItervalId = ""

Rs = new stzReactiveSystem()
Rs {
    # Create a stream for our time-based data
    oDataStream = CreateStream("sensor-data", "manual")
    #TODO // oDataStram is an attribue! think of a better API!

    # Subscribe to the stream - this function receives each data point
    oDataStream.Subscribe(func data {
        ? "📊 Received data: " + data
    })

    # Generate data every 800ms using a timer
    cItervalId = SetInterval(800, :fGenerateData)

    # Stop after 4 data points
    SetTimeout(3500, :fStopDataGeneration)

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
    Rs.ClearInterval(cItervalId)
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

#---------------------------------------------------#
#  EXAMPLE 5: PRACTICAL EXAMPLE - PROGRESS TRACKER  #
#---------------------------------------------------#

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
    ds.oReactive.ClearInterval(ds.cProgressId)

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
            cProgressId = SetInterval(:UpdateProgress, 500)
            SetTimeout(:CompleteDownload, 5000)
            
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

#------------------------#
#  KEY CONCEPTS SUMMARY  #
#------------------------#

/*--- What you learned with these examples:

1. **setTimeout**: One-time execution after delay
   - SetTimeout(function, milliseconds)
   - Perfect for delayed actions

2. **setInterval**: Repeated execution at intervals  
   - SetInterval(function_name, milliseconds)
   - Perfect for periodic tasks
   - Always remember to ClearInterval() to stop it!

3. **Scope Management**: Variables must be accessible to callbacks
   - Use global-level variables, or
   - Use object properties with Method() calls

4. **Timer Coordination**: Multiple timers can work together
   - Each timer runs independently
   - Use setTimeout to stop intervals after a certain time

5. **Reactive Streams + Timers**: Powerful combination
   - Timers generate data
   - Streams distribute data to subscribers
   - Creates real-time data processing pipelines

6. **Always Clean Up**: Prevent infinite loops
   - ClearInterval() to stop repeating timers
   - reactive.Stop() to shut down the engine
   - Proper cleanup prevents resource leaks

Other timer-based applications can be:
- A digital clock display
- A countdown timer
- A simple animation system
- A data polling system for APIs

*/
