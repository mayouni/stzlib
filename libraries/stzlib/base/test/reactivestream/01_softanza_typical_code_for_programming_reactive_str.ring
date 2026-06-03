# Narrative
# --------
# Softanza typical code for programming reactive streams
#
# Extracted from stzreactivestreamtest.ring, block #1.

load "../../stzBase.ring"

pr()

# First, everything must happen inside a ReactiveSystem object.
# In Softanza, reactive streams (and any other reactive element)
# cannot exist in a vacuum!

# Create a Reactive System instance
Rs = new stzReactiveSystem()
Rs {
    # Inside the reactive system (which is actually built on the
    # Libuv infrastructure), we create a reactive stream object to
    # work with, and begin defining it.

    oPriceStream = CreateNetworkStream("my-price-api")
    # The stream is defined telling the libuv engine
    # to prepare for receiving data from the network (e.g., over HTTP).

    # Declarative code that defines the reactive stream
    # (it will not run until Rs.RunLoop() is reached at the end).

    # When data items arrive in this pipeline called oPriceStream:
    oPriceStream {

        # Transform each incoming item using this action (a business rule).
        Transform(func price { return price * 1.20 })

        # Then filter the transformed values to keep only those
        # that satisfy this condition.
        Filter(func price { return price >= 120 })

        # If the transformed value successfully passes the filter,
        # its journey in the pipeline concludes with this final action.
 
        OnPassed(func item { SaveToDatabase(item) NotifyUsersAbout(item) })

        # Then, take the next item in the pipeline and repeat the same process.
        # Ideally, all items will be transformed, filtered, and concluded properly,
        # until no more data is available (the pipeline runs dry). At that point,
        # we can gracefully say goodbye using this action.

        OnNoMore(func() { CloseConnections() SendSummary() })

        # If, however, an error occurs at any stage,
        # this action ensures the reactive system remains under control.
        # The reactive loop (and data pipeline) is then interrupted
        # responsibly with a clear recovery plan.

        OnError(func error { Log(error) AlertTeamAbout(error) })

	# The last step is to define the data the stream will Recieve.
	# Here we provide test data, with duplicates and varying price ranges.
        # Test data: values below 100 will be filtered out after transformation (< 120)
        # Values 100+ will pass through after transformation (>= 120)

    	anTestPrices = [ 80, 90, 95, 100, 120, 150, 200 ]
	RecieveMany(anTestPrices)

   }

    # Now we leave the static mindset above and fire up the reactive loop.
    # This engages the libuv loop system—the engine and "dark magic"
    # that brings the system to life, accepts data, reacts according to
    # our defined strategy, and produces results through its internal
    # graph of computation.

     RunLoop()
}

pf()

func SaveToDatabase(pItem)
	? "Saving item (" + @@(pItem) + ") to the database..."

func NotifyUsersAbout(pItem)
	? "Notifying users about item (" + @@(pItem) + ")..." + NL

func CloseConnections()
	? "Closing all connections..."

func SendSummary()
	? "Sending summary of the operation..."

func Log(pcError)
	? "Logging error: " + pcError + "."

func AlertTeamAbout(pcError)
	? "Alerting team about error: " + pcError + "."

#-->
# Saving item (120) to the database...
# Notifying users about item (120)...
# 
# Saving item (144) to the database...
# Notifying users about item (144)...
# 
# Saving item (180) to the database...
# Notifying users about item (180)...
# 
# Saving item (240) to the database...
# Notifying users about item (240)...


# Executed in 5.74 second(s) in Ring 1.23
