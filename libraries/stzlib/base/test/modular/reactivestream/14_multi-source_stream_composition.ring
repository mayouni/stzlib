# Narrative
# --------
# Multi-Source Stream Composition
#
# Extracted from stzreactivestreamtest.ring, block #14.

load "../../../stzBase.ring"


# Combining different stream sources in complex applications
# Shows real-world architectural patterns

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create multiple specialized streams
    
    # 1. User activity stream (manual)
    oUserStream = CreateStream("user-activity")
    oUserStream {
        Transform(func activity { 
            activity[:source] = "USER"
            return activity
        })
        OnPassed(func event { ? "👤 " + event[:action] + " by " + event[:user] })
    }
    
    # 2. System health stream (timer)
    oHealthStream = CreateStreamXT("system-health", OPTIMISED_FOR_TIMER_SOURCE) 
    oHealthStream {
        Transform(func tick {
            return [:source = "SYSTEM", :status = "healthy", :load = random(100)]
        })
        Filter(func health { return health[:load] > 80 })
        OnPassed(func alert { ? "⚙️  System load high: " + alert[:load] + "%" })
    }
    
    # 3. External API stream (network)
    oApiStream = CreateStreamXT("api-updates", :NETWORK)
    oApiStream {
        Transform(func response {
            response[:source] = "API"  
            return response
        })
        OnPassed(func update { ? "🌐 API: " + update[:message] })
    }
    
    # Simulate multi-source events
    oUserStream.RecieveMany([
        [:action = "Login", :user = "alice"],
        [:action = "Purchase", :user = "bob"]
    ])
    
    # System health checks
    for i = 1 to 3
        oHealthStream.Recieve(i)
    next
    
    # API updates
    oApiStream.RecieveMany([
        [:message = "New feature deployed"],
        [:message = "Maintenance scheduled"]
    ])
    
    RunLoop()
    #-->
    # 👤 Login by alice
    # 👤 Purchase by bob
    # ⚙️  System load high: 94%
    # 🌐 API: New feature deployed
    # 🌐 API: Maintenance scheduled
}

pf()
# Executed in 0.92 second(s) in Ring 1.23

#==== SETTING STREAM AUTOCONCUDE ON AND OFF
