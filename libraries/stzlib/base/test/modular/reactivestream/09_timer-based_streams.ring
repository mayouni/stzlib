# Narrative
# --------
# Timer-Based Streams
#
# Extracted from stzreactivestreamtest.ring, block #9.

load "../../../stzBase.ring"


# Periodic data generation for monitoring, logging, scheduled tasks
# Essential for: Heartbeats, polling, periodic updates

pr()

Rs = new stzReactiveSystem()
Rs {

    # System monitoring with timer-based stream

    oTimerStream = CreateTimerStream("system-monitor")
    oTimerStream {

        Transform(func tick {
            # Simulate system metrics collection
            return [
                :timestamp = clocksPerSecond(),
                :cpu_usage = random(100),
                :memory_usage = random(90) + 10,  # 10-100%
                :disk_space = random(50) + 50     # 50-100%
            ]
        })

        Filter(func metrics {
            # Alert on high resource usage
            return metrics[:cpu_usage] > 80 or metrics[:memory_usage] > 85
        })

        OnPassed(func alert {
            ? "⚠️ SYSTEM ALERT"
	    ? "----------------"
            ? " • CPU    : " + alert[:cpu_usage] + "%"
            ? " • Memory : " + alert[:memory_usage] + "%"
            ? " • Disk   : " + alert[:disk_space] + "%" + NL
        })

        OnNoMore(func() {
            ? NL + "✅ Monitoring session ended"
        })

        # Simulate 5 timer ticks
        for i = 1 to 5
            Recieve(i)  # Timer tick simulation
        next

    }
    
    Run()
    #-->
    # ⚠️ SYSTEM ALERT
    # ----------------
    #  • CPU    : 92%
    #  • Memory : 60%
    #  • Disk   : 88%
    # 
    # ⚠️ SYSTEM ALERT
    # ----------------
    #  • CPU    : 94%
    #  • Memory : 19%
    #  • Disk   : 93%
    # 
    # ⚠️ SYSTEM ALERT
    # ----------------
    #  • CPU    : 2%
    #  • Memory : 95%
    #  • Disk   : 100%
    # 
    # ✅ Monitoring session ended
}

#TODO Check why the number of alerts varies if we run the sample
# several times (1, 2, 3 or even nothing)

pf()
# Executed in 0.94 second(s) in Ring 1.23
