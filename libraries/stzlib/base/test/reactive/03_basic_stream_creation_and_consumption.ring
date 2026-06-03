# Narrative
# --------
# Basic stream creation and consumption
#
# Extracted from stzreactivetest.ring, block #3.
#ERR Error (R3) : Calling Function without definition: onrecieve

load "../../stzBase.ring"


# Streams represent continuous data flows that can be processed reactively.
# They support backpressure, filtering, and transformation operations.
# Ideal for handling real-time data, user inputs, or API responses.

pr()

Rs = new stzReactiveSystem()
Rs {

    # Creating a basic reactive stream
    oXStream = CreateStream("data-stream")
    oXStream {
	    # Setting up stream processing pipeline
	    OnRecieve( func cData { # You can also sya OnPassed() instead of OnPass()
	        ? "Received: " + cData
	    })
 
	    OnError( func cError {
	        ? "Stream error: " + cError
	    })
 
	    OnNoMore( func  {
	        ? "Stream completed"
	    })

	    # Start the stream
	    Start()

	    # Recieveting data to the stream
	    Recieve("Hello")
	    Recieve("World")
	    Recieve("Reactive")
	    # Or alternatively:
	    # RecieveMany([ "Hello", "World", "Reactive" ])

	    # Complete the stream
	    Conclude()
    }

    Run()
    #-->
    # Received: Hello
    # Received: World
    # Received: Reactive
    # Stream completed

 }

pf()
# Executed in almost 0.93 second(s) in Ring 1.23
