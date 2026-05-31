# Narrative
# --------
# Stream transformation and filtering
#
# Extracted from stzreactivetest.ring, block #4.

load "../../../stzBase.ring"


# Streams can be transformed using operations like Map, Filter, and Reduce.
# This enables powerful data processing pipelines with minimal code.

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create source stream

    oXStream = CreateStream("number-stream")

    # Transform stream and add subscriber in one block

    oXStream {

	# Starting the stream

	Start()	# Optional, for clarity, started automatically when invoqued

	# Defining the stream transformation

        Map( func x { return x * 2 })
        Filter( func x { return x > 10 and x % 2 = 0 })

	# Defining the reactive function to process the item that passes
	# the Map and Filter stels

        OnPassed( func cData {
            ? "Processed number: " + cData
        })

	# Defining the data that will fire the reactive functions above

	RecieveMany(1:10)

	# Cleaning the stream from memory by concluding any pending task (OPTIONAL)

	Conclude()
    }

    RunLoop()
    #-->
    # Processed number: 12
    # Processed number: 14
    # Processed number: 16
    # Processed number: 18
    # Processed number: 20

}

pf()
# Executed in almost 0 second(s) in Ring 1.23
