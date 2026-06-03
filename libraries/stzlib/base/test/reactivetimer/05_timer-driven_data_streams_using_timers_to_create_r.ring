# Narrative
# --------
# Timer-driven data streams: Using timers to create reactive data streams
#
# Extracted from stzreactivetimertest.ring, block #5.

load "../../stzBase.ring"


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
