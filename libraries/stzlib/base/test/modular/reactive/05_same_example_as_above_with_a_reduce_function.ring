# Narrative
# --------
# Same example as above with a Reduce() function
#
# Extracted from stzreactivetest.ring, block #5.

load "../../../stzBase.ring"


pr()

Rs = new stzReactiveSystem()
Rs {

    # Create source stream

    oXStream = CreateStream("number-stream")

    # Transform stream and add subscriber in one block

    oXStream {

	# Defining the stream transformation

        Map(func x { return x * 2 })
        Filter(func x { return x > 10 and x % 2 = 0 })
	Reduce(func acc, x { return acc + x }, 0)

	# Defining the callback function

        OnPassed(func cData {
            ? "Processed number: " + cData
        })

	# Feeding data to the stream

	RecieveMany(1:10)

    }

    Start()
    #-->
    # Processed number: 80
}

pf()
# Executed in almost 0.94 second(s) in Ring 1.23

#========================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS   #
#========================================#
