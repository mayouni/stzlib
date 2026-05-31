# Narrative
# --------
# Real-World Example: Log Processing with Adaptive Overflow
#
# Extracted from stzreactivestreamtest.ring, block #21.

load "../../../stzBase.ring"


# The sample shows adaptive overflow - system dynamically
# switches strategies, changing from buffer to drop mode under
# extreme load to maintain stability

# Processes existing buffer before applying new strategy

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log processing system with smart overflow
    oLogStream = CreateFileStream("adaptive-logs")
    oLogStream {
        # Start with BUFFER_EXPAND strategy
        SetOverflowStrategy(BUFFER_EXPAND, 5)
        
        # Parse and enrich log entries
        Transform(func logLine {
            parts = split(logLine, "|")
            return [
                :timestamp = parts[1],
                :level = parts[2],
                :service = parts[3], 
                :message = parts[4],
                :processed_at = clocksPerSecond()
            ]
        })
        
        # Filter for important logs
        Filter(func log {
            importantLevels = ["ERROR", "WARN", "CRITICAL"]
            return find(importantLevels, log[:level])
        })
        
        OnPassed(func importantLog {
            ? "📋 " + importantLog[:level] + " [" + importantLog[:service] + "] " + importantLog[:message]
        })
        
        # Adaptive Overflow Rfunction
        OnOverflow(func(current, max) {
            ? "🔄 Log processing overflow: " + current + "/" + max
            
            # Switch to drop strategy under extreme load
            if current >= max
                ? "⚡ Switching to BUFFER_REJECT_NEWEST strategy due to extreme load"
                oLogStream.SetOverflowStrategy(BUFFER_REJECT_NEWEST, 10)
            ok
        })
        
        ? "Adaptive Log Processing Demo..."
        
        # Simulate log burst
        acLogEntries = [
            "2024-01-15 10:30:15|INFO|AUTH|User login successful",
            "2024-01-15 10:30:16|ERROR|DB|Connection timeout", 
            "2024-01-15 10:30:17|WARN|CACHE|High memory usage",
            "2024-01-15 10:30:18|INFO|API|Request processed",
            "2024-01-15 10:30:19|CRITICAL|SECURITY|Breach detected",
            "2024-01-15 10:30:20|ERROR|PAYMENT|Transaction failed",
            "2024-01-15 10:30:21|WARN|DISK|Low space warning",
            "2024-01-15 10:30:22|ERROR|NETWORK|Connection lost",
            "2024-01-15 10:30:23|CRITICAL|SYSTEM|Out of memory"
        ]
        
        RecieveMany(acLogEntries)
        
        ? "Processing remaining buffer..."
        ProcessAnItemFromBuffer()
        
        stats = OverflowStats() 
        ? "Final processing stats:"
        ? "  • Strategy: " + stats[:strategy]
        ? "  • Items dropped: " + stats[:droppedCount]
        ? "  • Buffer utilization: " + stats[:currentBuffer] + "/" + stats[:bufferSize]

    }
    
    RunLoop()
    #-->  (#NOTE I added some comments to clarify the output)
    # Adaptive Log Processing Demo...
    # 
    # Phase 1: Buffer reaches capacity, triggers strategy change
    # ----------------------------------------------------------
    # 🔄 Log processing overflow: 5/5
    # ⚡ Switching to BUFFER_REJECT_NEWEST strategy due to extreme load
    # ⚠️ Overflow: Dropping data item (dropped so far: 1)
    # 
    # Phase 2: Process buffered logs before strategy switch
    # -----------------------------------------------------
    # Processing remaining buffer...
    # 📋 ERROR [DB] Connection timeout
    # 📋 WARN [CACHE] High memory usage
    # 📋 CRITICAL [SECURITY] Breach detected
    # 📋 WARN [DISK] Low space warning
    # 📋 ERROR [NETWORK] Connection lost
    # 📋 CRITICAL [SYSTEM] Out of memory
    # 
    # Phase 3: Results after adaptive processing
    # ------------------------------------------
    # Final processing stats:
    # - Strategy: drop
    # - Items dropped: 1
    # - Buffer utilization: 0/10
}

pf()
# Executed in 0.95 second(s) in Ring 1.23
