# Narrative
# --------
# File-Based Streams
#
# Extracted from stzreactivestreamtest.ring, block #10.

load "../../stzBase.ring"


# File monitoring, log processing, configuration watching
# Essential for: Log analysis, file system events, data ingestion

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log file processing stream
    oFileStream = CreateFileStream("log-processor")
    oFileStream {

        # Parse log entries
        Transform(func logLine {
            # Simulate log parsing
            parts = split(logLine, "|")
            if len(parts) >= 3
                return [
                    :timestamp = parts[1],
                    :level = parts[2], 
                    :message = parts[3]
                ]
            else
                return [:level = "INFO", :message = logLine]
            ok
        })
        
        # Filter critical events
        Filter(func logEntry {
            criticalLevels = ["ERROR", "CRITICAL", "FATAL"]
            return find(criticalLevels, upper(logEntry[:level]))
        })
        
        OnPassed(func criticalLog {
            ? "🚨 CRITICAL LOG EVENT"
            ? " • Level: " + criticalLog[:level]
            ? " • Message: " + criticalLog[:message] + NL
        })
        
        # Simulate log file content
        acLogLines = [
            "2024-01-15 10:30:15|INFO|User login successful",
            "2024-01-15 10:31:02|ERROR|Database connection failed",
            "2024-01-15 10:31:05|CRITICAL|System memory exhausted",
            "2024-01-15 10:32:10|INFO|Backup completed successfully",
            "2024-01-15 10:33:22|FATAL|Security breach detected"
        ]
        
        RecieveMany(acLogLines)

    }
    
    RunReactiveLoop()
    #-->
    # 🚨 CRITICAL LOG EVENT
    # • Level: ERROR
    # • Message: Database connection failed
    # 
    # 🚨 CRITICAL LOG EVENT
    # • Level: CRITICAL
    # • Message: System memory exhausted
    # 
    # 🚨 CRITICAL LOG EVENT
    # • Level: FATAL
    # • Message: Security breach detected
}

pf()
# Executed in 0.95 second(s) in Ring 1.23
