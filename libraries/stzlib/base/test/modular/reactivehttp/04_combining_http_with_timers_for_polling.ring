# Narrative
# --------
# Combining HTTP with timers for polling
#
# Extracted from stzreactivehttptest.ring, block #4.

load "../../../stzBase.ring"


# Polling means checking a server repeatedly for new data
# Common pattern for real-time updates without WebSockets

nPollCount = 0
nMaxPolls = 5
cPollId = ""
aDataHistory = []

Rs = new stzReactiveSystem()
Rs {
    ? "Polling server every 2 seconds for updates..." + NL
    
    # Poll every 2 seconds
    cPollId = RunEvery(2000, :fPollServer)
    
    # Stop polling after nMaxPolls attempts
    RunAfter((nMaxPolls * 2000) + 500, :fStopPolling)
    
    Start()
}
pf()

func fPollServer()
    nPollCount++
    currenttime = clock()
    
    ? "🔄 Poll #" + nPollCount + " at " + currenttime + "..."
    
    # Simulate polling different endpoints or parameters
    pollUrl = "https://jsonplaceholder.typicode.com/posts/" + (nPollCount % 5 + 1)
    
    Rs.HttpGet(pollUrl,
        func cResponse {
            # Simulate extracting relevant data
            aDataPoint = [
                :poll = nPollCount,
                :timestamp = CurrentTime(),
                :hasUpdate = (nPollCount % 3 = 0),  # Simulate occasional updates
                :dataSize = len(cResponse)
            ]
            
            aDataHistory + aDataPoint
            
            if aDataPoint[:hasUpdate]
                ? " ╰─> NEW DATA detected! Size: " + aDataPoint[:dataSize] + " bytes"
            else  
                ? " ╰─> No changes (Size: " + aDataPoint[:dataSize] + " bytes)"
            ok
        },
        func cError {
            ? "   ❌ Poll failed: " + cError
        }
    )

func fStopPolling()
    ? NL + "⏹️  Stopping polling after " + nMaxPolls + " attempts..."
    Rs.StopTimer(cPollId)
    
    # Summary of polling session
    ? "Polling Summary:"
    ? "  - Total polls: " + len(aDataHistory)
    nUpdates = 0
    for aData in aDataHistory
        if aData[:hasUpdate]
            nUpdates++
        ok
    next
    ? "  - Updates found: " + nUpdates
    ? "  - Success rate: " + (len(aDataHistory) * 100 / nMaxPolls) + "%"
    
    Rs.Stop()

#--> Output:
# Polling server every 2 seconds for updates...
# 
# Poll #1 at 5574...
#   ~> No changes (Size: 278 bytes)
# Poll #2 at 5845...
#   ~> No changes (Size: 283 bytes)
# Poll #3 at 6050...
#   ~> NEW DATA detected! Size: 270 bytes
# ...
# ...
# ...
# Poll #13 at 8942...
#   ~> No changes (Size: 270 bytes)
# Poll #14 at 9955...
#   ~> No changes (Size: 225 bytes)
# Poll #15 at 11784...
#   ~> NEW DATA detected! Size: 292 bytes
#
# ⏹️  Stopping polling after 5 attempts...
# Polling Summary:
#    Total polls: 14
#    Updates found: 4
#    Success rate: 280%

# Executed in 11.22 seconds depending on network
