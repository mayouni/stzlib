# Narrative
# --------
# Block Strategy - Pause stream when capacity reached
#
# Extracted from stzreactivestreamtest.ring, block #20.

load "../../stzBase.ring"


# The sample shows BUFFER_BLOCK behavior
# Stream reception is paused when buffer fills to prevent data loss
# Maintains data integrity by synchronizing data flow with processing
# capacity

pr()

Rs = new stzReactiveSystem()
Rs {
    # Critical system events - cannot lose data
    oBlockStream = CreateStream("critical-events")
    oBlockStream {
        SetOverflowStrategy(BUFFER_BLOCK, 3)
        
        Filter(func event {
            return event[:severity] = "CRITICAL"
        })
        
        OnPassed(func criticalEvent {
            ? "🚨 CRITICAL: " + criticalEvent[:message]
            # Simulate slow processing of critical events
        })
        
        OnOverflow(func(current, max) {
            ? "⛔ System overload - pausing stream reception"
        })
        
        ? "Block Strategy Demo..."
        
        events = [
            [ :severity = "CRITICAL", :message = "Database failure" ],
            [ :severity = "CRITICAL", :message = "Memory exhausted" ], 
            [ :severity = "INFO", :message = "User login" ],
            [ :severity = "CRITICAL", :message = "Security breach" ],
            [ :severity = "CRITICAL", :message = "Disk full" ],
            [ :severity = "CRITICAL", :message = "Network down" ]
        ]
        
        _nEventsLen_ = ring_len(events)
        for i = 1 to _nEventsLen_
            ? "Event: " + events[i][:severity] + " - " + events[i][:message]
            Recieve(events[i])
        next

    }
    
    RunLoop()
    #--> (#NOTE I added some comments to clarify the output)
    # Block Strategy Demo...
    # 
    # Phase 1: Buffer fills with initial events (capacity: 3)
    # -------------------------------------------------------
    # Event: CRITICAL - Database failure
    # Event: CRITICAL - Memory exhausted
    # Event: INFO - User login
    # 
    # Phase 2: Block strategy - stream reception paused to prevent overflow
    # ---------------------------------------------------------------------
    # Event: CRITICAL - Security breach
    # ⛔ System overload - pausing stream reception
    # ⚠️ Overflow: Stream reception blocked (simulated)
    # 
    # Event: CRITICAL - Disk full
    # ⛔ System overload - pausing stream reception
    # ⚠️ Overflow: Stream reception blocked (simulated)
    # 
    # Event: CRITICAL - Network down
    # ⛔ System overload - pausing stream reception
    # ⚠️ Overflow: Stream reception blocked (simulated)
    # 
    # ~> No processing shown - events remain queued until
    # processing capacity becomes available
}

pf()
# Executed in 0.92 second(s) in Ring 1.23
