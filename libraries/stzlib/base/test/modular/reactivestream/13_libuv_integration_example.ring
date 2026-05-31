# Narrative
# --------
# LibUV Integration Example
#
# Extracted from stzreactivestreamtest.ring, block #13.

load "../../../stzBase.ring"


# Low-level system integration using LibUV handles
# Essential for: High-performance I/O, system-level operations

pr()

Rs = new stzReactiveSystem()
Rs {
    # System process monitoring via LibUV
    oUVStream = CreateLibuvStream("process-monitor")
    oUVStream {

        # Process system events
        Transform(func uvEvent {
            # Simulate LibUV event processing
            return [
                :event_type = uvEvent[:type],
                :process_id = uvEvent[:pid],
                :resource_usage = uvEvent[:resources],
                :event_time = clocksPerSecond()
            ]
        })
        
        # Filter high-impact events
        Filter(func processEvent {
            highImpactEvents = ["process_crash", "memory_leak", "high_cpu"]
            return find(highImpactEvents, processEvent[:event_type])
        })
        
        OnPassed(func criticalEvent {
            ? "🔥 SYSTEM EVENT DETECTED:"
            ? "• Type: " + criticalEvent[:event_type]
            ? "• Process ID: " + criticalEvent[:process_id] 
            ? "• Resource Impact: " + criticalEvent[:resource_usage] + "%" + NL
        })
        
        OnNoMore(func() {
            ? "🛡️ LibUV monitoring stopped - resources cleaned up"
        })
        
        # Simulate LibUV system events
        aSystemEvents = [
            [ :type = "process_start", :pid = 1234, :resources = 15 ],
            [ :type = "process_crash", :pid = 5678, :resources = 85 ],
            [ :type = "normal_operation", :pid = 9012, :resources = 25 ],
            [ :type = "memory_leak", :pid = 3456, :resources = 95 ],
            [ :type = "high_cpu", :pid = 7890, :resources = 90 ]
        ]
        
        RecieveMany(aSystemEvents)

    }
    
    RunLoop()
    #-->
    '
    🔥 SYSTEM EVENT DETECTED:
    • Type: process_crash
    • Process ID: 5678
    • Resource Impact: 85%

    🔥 SYSTEM EVENT DETECTED:
    • Type: memory_leak
    • Process ID: 3456
    • Resource Impact: 95%

    🔥 SYSTEM EVENT DETECTED:
    • Type: high_cpu
    • Process ID: 7890
    • Resource Impact: 90%

    🛡️ LibUV monitoring stopped - resources cleaned up
    '
}

pf()
# Executed in 0.93 second(s) in Ring 1.23
