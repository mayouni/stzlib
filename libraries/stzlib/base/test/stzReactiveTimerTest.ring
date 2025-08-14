
load "../stzbase.ring"

#=======================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS  #
#=======================================#

# Welcome to Reactive Timers! This tutorial teaches you step-by-step
# how to work with time-based events in a non-blocking way.

#------------------------------#
#  LESSON 1: YOUR FIRST TIMER  #
#------------------------------#

/*--- Understanding setTimeout - One-time delayed execution

# SetTimeout executes a function ONCE after a specified delay
# Think of it like setting an alarm clock that goes off only once

pr()

# Creating a timer that fires once after 2 seconds

oRs = new stzReactive()
oRs {
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

#------------------------------#
#  LESSON 2: REPEATING TIMERS  #
#------------------------------#

/*--- Understanding setInterval - Repeating execution

# SetInterval executes a function REPEATEDLY at regular intervals
# Like a metronome that keeps ticking until you stop it

pr()

# Creating a timer that fires every 1 second, 3 times total

# We need these variables at global level so the callback can access them
lesson2_counter = 0
lesson2_intervalId = ""

oRs2 = new stzReactive()
oRs2 {
    # SetInterval(function_name, interval_in_milliseconds)
    lesson2_intervalId = SetInterval(:Lesson2Callback, 1000)
    
    ? "Repeating timer set! Starting..."
    Start()
}

pf()

# The callback function - defined separately so variables are accessible
func Lesson2Callback()
    lesson2_counter++
    ? "🔔 Tick #" + lesson2_counter + " at time " + clock()
    
    # Stop after 3 ticks
    if lesson2_counter >= 3
        ? "Stopping timer after 3 ticks..."
        oRs2.ClearInterval(lesson2_intervalId)
        oRs2.Stop()
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

#------------------------------#
#  LESSON 3: COMBINING TIMERS  #
#------------------------------#

/*--- Multiple timers working together
*/
# You can have multiple timers running simultaneously
# Each timer operates independently

pr()

# Running fast timer (every 500ms) and slow timer (every 1500ms)

lesson3_fastCount = 0
lesson3_slowCount = 0
lesson3_fastId = ""
lesson3_slowId = ""

oRs3 = new stzReactive()
oRs3 {
    # Fast timer - every 500ms
    lesson3_fastId = SetInterval(:FastTick, 500)
    
    # Slow timer - every 1500ms  
    lesson3_slowId = SetInterval(:SlowTick, 1500)
    
    # Stop everything after 4 seconds
    SetTimeout(:StopAllTimers, 4000)
    
    ? "Multiple timers started!"
    Start()
}

pf()

func FastTick()
    lesson3_fastCount++
    ? "⚡ Fast tick #" + lesson3_fastCount

func SlowTick()
    lesson3_slowCount++
    ? "🐌 Slow tick #" + lesson3_slowCount
    
func StopAllTimers()
    ? "⏹️  Stopping all timers..."
    oRs3.ClearInterval(lesson3_fastId)
    oRs3.ClearInterval(lesson3_slowId)
    oRs3.Stop()

#--> Output:
# Multiple timers started!
# ⚡ Fast tick #1
# ⚡ Fast tick #2  
# 🐌 Slow tick #1
# ⚡ Fast tick #3
# ⚡ Fast tick #4
# 🐌 Slow tick #2
# ⏹️  Stopping all timers...

#========================================#
# LESSON 4: TIMER-DRIVEN DATA STREAMS
#========================================#

/*--- Using timers to create reactive data streams

# Timers can drive reactive streams, creating time-based data sources
# Perfect for simulating sensors, stock prices, or any real-time data

pr()

? "=== LESSON 4: Timer-Driven Data Stream ==="
? "Creating a data stream that generates values every 800ms..."

lesson4_dataCounter = 0
lesson4_intervalId = ""

oRs4 = new stzReactive()
oRs4 {
    # Create a stream for our time-based data
    dataStream = CreateStream("sensor-data", "manual")
    
    # Subscribe to the stream - this function receives each data point
    dataStream.Subscribe(func data {
        ? "📊 Received data: " + data
    })
    
    # Generate data every 800ms using a timer
    lesson4_intervalId = SetInterval("GenerateData", 800)
    
    # Stop after 4 data points
    SetTimeout("StopDataGeneration", 3500)
    
    ? "Data stream started! Generating data every 800ms..."
    Start()
}

pf()

func GenerateData()
    lesson4_dataCounter++
    # Simulate sensor reading with random-ish data
    temperature = 20 + (lesson4_dataCounter * 2.5)
    dataPoint = "Temperature: " + temperature + "°C (reading #" + lesson4_dataCounter + ")"
    
    # Emit the data to the stream
    oRs4.dataStream.Emit(dataPoint)

func StopDataGeneration()
    ? "🛑 Stopping data generation..."
    oRs4.ClearInterval(lesson4_intervalId)
    oRs4.dataStream.Complete()  # Properly end the stream
    oRs4.Stop()

#--> Output:
# Data stream started! Generating data every 800ms...
# 📊 Received data: Temperature: 22.5°C (reading #1)
# 📊 Received data: Temperature: 25.0°C (reading #2)  
# 📊 Received data: Temperature: 27.5°C (reading #3)
# 📊 Received data: Temperature: 30.0°C (reading #4)
# 🛑 Stopping data generation...

#========================================#
# LESSON 5: PRACTICAL EXAMPLE - PROGRESS TRACKER
#========================================#

/*--- Real-world example: Simulating a download progress

# This example shows how timers can simulate real-world async operations
# like file downloads, data processing, or any long-running task

pr()

? "=== LESSON 5: Progress Tracker ==="
? "Simulating a file download with progress updates..."

class DownloadSimulator from ObjectControllerParent
    progress = 0
    downloadId = ""
    progressId = ""
    reactive = NULL
    fileName = "large-file.zip"
    
    def Init()
        reactive = new stzReactive()
        progress = 0
        fileName = "large-file.zip"
        
    def StartDownload()
        ? "🔽 Starting download of " + fileName + "..."
        ? "Progress: [----------] 0%"
        
        reactive {
            # Update progress every 500ms
            progressId = SetInterval(Method(:UpdateProgress), 500)
            
            # Complete download after 5 seconds
            SetTimeout(Method(:CompleteDownload), 5000)
            
            Start()
        }
        
    def UpdateProgress()
        progress += 20  # Increase by 20% each tick
        
        if progress <= 100
            # Create progress bar
            progressBar = ""
            filledBars = floor(progress / 10)
            emptyBars = 10 - filledBars
            
            for i = 1 to filledBars
                progressBar += "█"
            next
            for i = 1 to emptyBars  
                progressBar += "░"
            next
            
            ? "Progress: [" + progressBar + "] " + progress + "%"
        ok
        
    def CompleteDownload()
        reactive.ClearInterval(progressId)
        ? "✅ Download completed successfully!"
        ? "File " + fileName + " is ready to use."
        reactive.Stop()

# Run the download simulation
downloader = new DownloadSimulator()
downloader.Init()
downloader.StartDownload()

pf()

#--> Output:
# 🔽 Starting download of large-file.zip...
# Progress: [----------] 0%
# Progress: [██░░░░░░░░] 20%
# Progress: [████░░░░░░] 40%
# Progress: [██████░░░░] 60%
# Progress: [████████░░] 80%
# Progress: [██████████] 100%
# ✅ Download completed successfully!
# File large-file.zip is ready to use.

#========================================#
# KEY CONCEPTS SUMMARY
#========================================#

/*--- What you learned:

1. **setTimeout**: One-time execution after delay
   - SetTimeout(function, milliseconds)
   - Perfect for delayed actions

2. **setInterval**: Repeated execution at intervals  
   - SetInterval(function_name, milliseconds)
   - Perfect for periodic tasks
   - Always remember to ClearInterval() to stop it!

3. **Scope Management**: Variables must be accessible to callbacks
   - Use module-level variables, or
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

Next steps: Try creating your own timer-based applications like:
- A digital clock display
- A countdown timer
- A simple animation system
- A data polling system for APIs

*/
