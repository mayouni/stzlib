# Narrative
# --------
# Basic Stream Operations
#
# Extracted from stzreactivestreamtest.ring, block #2.

load "../../../stzBase.ring"


# Demonstrates fundamental stream creation, Recieveing, and lifecycle
# Essential concepts: Recieve, OnPassed, Error handling, Completion

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create a manual stream for basic operations
    oBasicStream = CreateStream("basic-example")
    oBasicStream {

        # Each item of data that the stream is fed with
	# is processed using this Rfunction
        OnPassed(func data {
            ? "📊 Data Recieved: " + data
        })

        # Potential erros are captured by the fellowing Rfunction
        OnError(func error {
            ? "❌ Error occurred: " + error
        })

        # When there are no more data items to process,
	# this Rfunction is exuecuted

        OnNoMore(func() {
            ? "✅ Stream processing completed"
        })

        # Recieve individual data points
        Recieve("First message")
        Recieve("Second message")

        # Recieve the stream with multiple items at once
        RecieveMany(["Third", "Fourth", "Fifth"])

        # Check that error handling works (when stream errors don't work)
        CheckErrorHandling("Simulated error")
        # Note: Stream automatically stops after error
    }

    RunLoop()
    #-->
    # 📊 Data Recieved: First message
    # 📊 Data Recieved: Second message  
    # 📊 Data Recieved: Third
    # 📊 Data Recieved: Fourth
    # 📊 Data Recieved: Fifth
    # ❌ Error occurred: Simulated error
}

pf()
# Executed in 0.93 second(s) in Ring 1.23
