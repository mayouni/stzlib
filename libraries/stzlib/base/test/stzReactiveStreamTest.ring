
load "../stzbase.ring"

/*--- Basic Stream Operations

# Demonstrates fundamental stream creation, subscription, and lifecycle
# Essential concepts: Emit, Subscribe, Error handling, Completion

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create a manual stream for basic operations
    oBasicStream = CreateStream("basic-example", :MANUAL)
    oBasicStream {
        # Subscribe to data emissions
        OnData(func data {
            ? "📊 Data received: " + data
        })

        # Handle stream errors gracefully
        OnError(func error {
            ? "❌ Error occurred: " + error
        })

        # Handle stream completion
        OnComplete(func() {
            ? "✅ Stream processing completed"
        })

        # Emit individual data points
        Emit("First message")
        Emit("Second message")

        # Emit multiple items at once
        EmitMany(["Third", "Fourth", "Fifth"])

        # Test error handling
        EmitError("Simulated error")

        # Note: Stream automatically stops after error
    }

    Start()
    #-->
    # 📊 Data received: First message
    # 📊 Data received: Second message  
    # 📊 Data received: Third
    # 📊 Data received: Fourth
    # 📊 Data received: Fifth
    # ❌ Error occurred: Simulated error
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

/*--- Stream Transformations - Map, Filter

# Shows data transformation capabilities with chaining
# Key concepts: Map (transform), Filter (predicate)

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Create stream for data processing pipeline
    oTransformStream = CreateStream("transform-pipeline", :MANUAL)
    oTransformStream {
        # Chain transformations
        Map(func price { return price * 1.20 })		# Add 20% tax
        Filter(func price { return price >= 100 })	# Only expensive items

        Subscribe(func finalPrice {
            ? "💰 Final price after tax & filtering: $" + finalPrice
        })

        # Test data with duplicates and various price ranges
        testPrices = [ 80, 90, 100, 120, 150, 200 ]
        EmitMany(testPrices)

        Complete()
    }

    Start()
    #-->
    # 💰 Final price after tax & filtering: $108
    # 💰 Final price after tax & filtering: $120  
    # 💰 Final price after tax & filtering: $144
    # 💰 Final price after tax & filtering: $180
    # 💰 Final price after tax & filtering: $240
}

pf()
# Executed in 0.93 second(s) in Ring 1.23


/*--- Data Aggregation with Reduce

# Shows reduce functionality for calculating totals, averages, etc.
# Essential for analytics and summary operations

pr()

Rs = new stzReactiveSystem()
Rs {
    # Sales data aggregation
    oSalesStream = CreateStream("sales-aggregation", :MANUAL)
    oSalesStream {
        # Calculate total sales using reduce
        Reduce(func(accumulator, sale) {
            return accumulator + sale["amount"]
        }, 0)  # Start with 0
        
        OnData(func totalSales {
            ? "💰 Total Sales: $" + totalSales
        })
        
        OnComplete(func() {
            ? "✅ Sales calculation completed"
        })
        
        # Daily sales data
        salesData = [
            [:amount = 150.00, :product = "Laptop"],
            [:amount = 89.99, :product = "Mouse"], 
            [:amount = 299.99, :product = "Monitor"],
            [:amount = 45.50, :product = "Keyboard"]
        ]
        
        EmitMany(salesData)
        Complete()
    }
    
    Start()
    #-->
    # 💰 Total Sales: $585.48
    # ✅ Sales calculation completed
}

pf()
# Executed in 0.92 second(s) in Ring 1.23

/*--- Analytics Dashboard with Multiple Metrics

# Complex reduce example calculating multiple statistics
# Shows real-world analytics use case

pr()

Rs = new stzReactiveSystem()
Rs {
    # Website analytics stream
    oAnalyticsStream = CreateStream("web-analytics", :MANUAL)
    oAnalyticsStream {
        # Aggregate user session data
        Reduce(func(stats, session) {
            stats["totalUsers"] += 1
            stats["totalPageViews"] += session["pageViews"]
            stats["totalSessionTime"] += session["duration"]
            
            if session["converted"]
                stats["conversions"] += 1
            ok
            
            return stats
        }, [:totalUsers = 0, :totalPageViews = 0, :totalSessionTime = 0, :conversions = 0])
        
        Subscribe(func analytics {
            avgPageViews = analytics["totalPageViews"] / analytics["totalUsers"]
            avgSessionTime = analytics["totalSessionTime"] / analytics["totalUsers"]
            conversionRate = (analytics["conversions"] * 100.0) / analytics["totalUsers"]
            
            ? "📊 Website Analytics Summary:"
            ? "   Total Users: " + analytics["totalUsers"]
            ? "   Avg Page Views: " + avgPageViews + " pages/user"
            ? "   Avg Session Time: " + avgSessionTime + " minutes"
            ? "   Conversion Rate: " + conversionRate + "%"
        })
        
        # User session data
        sessions = [
            [:pageViews = 5, :duration = 12.5, :converted = true],
            [:pageViews = 3, :duration = 8.2, :converted = false],
            [:pageViews = 7, :duration = 18.7, :converted = true], 
            [:pageViews = 2, :duration = 4.1, :converted = false],
            [:pageViews = 9, :duration = 25.3, :converted = true]
        ]
        
        EmitMany(sessions)
        Complete()
    }
    
    Start()
    #-->
    # 📊 Website Analytics Summary:
    #    Total Users: 5
    #    Avg Page Views: 5.2 pages/user
    #    Avg Session Time: 13.76 minutes
    #    Conversion Rate: 60%
}

pf()

/*--- Complex Transformation Chains

# Shows combining multiple transformation types
# Real-world scenario: Processing sensor data

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Sensor data processing stream
    oSensorStream = CreateStream("sensor-data", :MANUAL)
    oSensorStream {

        # Multi-stage processing pipeline
        Map(func reading {
            # Convert raw sensor value to temperature
            return (reading - 32) * 5/9  # Fahrenheit to Celsius
        })

        Filter(func temp {
            # Only valid temperature readings
            return temp >= -50 and temp <= 100
        })

        Map(func temp {
            # Round to 1 decimal place
            return floor(temp * 10) / 10
        })
     
        Subscribe(func temperature {
            alert = ""
            if temperature > 35
                alert = " 🔥 HIGH"
            but temperature < 0
                alert = " ❄️ FREEZING"
            ok
            ? "🌡️  Temperature: " + temperature + "°C" + alert
        })
        
        # Simulate sensor readings (Fahrenheit)
        rawReadings = [ 68, 75, 32, 100, 212, -40, 150 ]
        EmitMany(rawReadings)
        
        Complete()
    }
    
    Start()
    #-->
    # 🌡️  Temperature: 20°C
    # 🌡️  Temperature: 23.8°C
    # 🌡️  Temperature: 0.0°C ❄️ FREEZING
    # 🌡️  Temperature: 37.7°C 🔥 HIGH
    # 🌡️  Temperature: 100.0°C 🔥 HIGH
    # 🌡️  Temperature: -40.0°C ❄️ FREEZING
    # 🌡️  Temperature: 65.5°C 🔥 HIGH
}

pf()
# Executed in 0.94 second(s) in Ring 1.23

/*--- Chat Message Processing

# Realistic example: Processing chat messages with filtering and
# formatting demonstrates practical stream usage

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Chat message processing pipeline

    oChatStream = CreateStream("chat-messages", :MANUAL)
    oChatStream {

        # Filter out spam and inappropriate content

        Filter(func message {
            spamWords = [ "spam", "advertisement", "buy now" ]
            text = lower(message)
            
            nLenSpam = len(spamWords)
            for i = 1 to nLenSpam
                if substr(text, spamWords[i])
                    return false  # Block spam
                ok
            next
            
            return len(message) > 0 and len(message) <= 280  # Valid length
        })
        
        # Format messages

        Map(func message {
            timestamp = "12:34"  # In real app, use actual timestamp
            return "[" + timestamp + "] " + message
        })
        
        Subscribe(func formattedMessage {
            ? "💬 " + formattedMessage
        })
        
        # Simulate chat messages

        messages = [
            "Hello everyone!",
            "How's everyone doing?", 
            "Check out this spam advertisement",  # Will be filtered
            "",  # Empty message - filtered
            "Great discussion today!",
            "See you later!"
        ]
        
        EmitMany(messages)
        Complete()
    }
    
    Start()
    #-->
    # 💬 [12:34] Hello everyone!
    # 💬 [12:34] How's everyone doing?
    # 💬 [12:34] Great discussion today!
    # 💬 [12:34] See you later!
}

pf()
# Executed in 0.94 second(s) in Ring 1.23

/*--- E-commerce Order Processing

# Complex business logic example with multiple transformations
# Shows stream composition for real business scenarios

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Order processing stream

    oOrderStream = CreateStream("order-processing", :MANUAL)
    oOrderStream {

        # Validate orders

        Filter(func order {
            # Basic validation
            return order["amount"] > 0 and len(order["customer"]) > 0
        })
        
        # Calculate totals with tax and shipping

        Map(func order {
            subtotal = order["amount"]
            tax = subtotal * 0.08  # 8% tax
            shipping = 15.00  # Flat rate shipping
            
            order["tax"] = tax
            order["shipping"] = shipping  
            order["total"] = subtotal + tax + shipping
            
            return order
        })
        
        # Filter high-value orders for special handling

        Filter(func order {
            return order["total"] >= 100  # VIP orders only
        })
        
        Subscribe(func processedOrder {
            ? "🛒 VIP Order processed:"
            ? "   Customer: " + processedOrder["customer"]
            ? "   Subtotal: $" + processedOrder["amount"]
            ? "   Tax: $" + processedOrder["tax"]  
            ? "   Shipping: $" + processedOrder["shipping"]
            ? "   Total: $" + processedOrder["total"]
            ? "   Status: Ready for priority shipping"
            ? ""
        })
        
        # Simulate incoming orders

        orders = [
            [ :customer = "John Doe", :amount = 89.99 ],      # Below threshold
            [ :customer = "Jane Smith", :amount = 150.00 ],   # VIP order
            [ :customer = "", :amount = 200.00 ],             # Invalid customer
            [ :customer = "Bob Wilson", :amount = 299.99 ],   # VIP order
            [ :customer = "Alice Brown", :amount = 0 ]        # Invalid amount
        ]
        
        EmitMany(orders)
        Complete()
    }
    
    Start()
    #-->
    '
	🛒 VIP Order processed:
	   Customer: John Doe
	   Subtotal: $89.99
	   Tax: $7.20
	   Shipping: $15
	   Total: $112.19
	   Status: Ready for priority shipping
	
	🛒 VIP Order processed:
	   Customer: Jane Smith
	   Subtotal: $150
	   Tax: $12
	   Shipping: $15
	   Total: $177
	   Status: Ready for priority shipping
	
	🛒 VIP Order processed:
	   Customer: Bob Wilson
	   Subtotal: $299.99
	   Tax: $24.00
	   Shipping: $15
	   Total: $338.99
	   Status: Ready for priority shipping
    '
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

/*--- Timer-Based Streams

# Periodic data generation for monitoring, logging, scheduled tasks
# Essential for: Heartbeats, polling, periodic updates

pr()

Rs = new stzReactiveSystem()
Rs {

    # System monitoring with timer-based stream

    oTimerStream = CreateStream("system-monitor", :TIMER)
    oTimerStream {

        Map(func tick {
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

        Subscribe(func alert {
            ? "⚠️ SYSTEM ALERT"
	    ? "----------------"
            ? " • CPU    : " + alert[:cpu_usage] + "%"
            ? " • Memory : " + alert[:memory_usage] + "%"
            ? " • Disk   : " + alert[:disk_space] + "%" + NL
        })

        OnComplete(func() {
            ? NL + "✅ Monitoring session ended"
        })
        
        # Simulate 5 timer ticks
        for i = 1 to 5
            Emit(i)  # Timer tick simulation
        next
        
        Complete()
    }
    
    Start()
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

/*--- File-Based Streams

# File monitoring, log processing, configuration watching
# Essential for: Log analysis, file system events, data ingestion

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log file processing stream
    oFileStream = CreateStream("log-processor", :FILE)
    oFileStream {

        # Parse log entries
        Map(func logLine {
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
        
        OnData(func criticalLog {
            ? "🚨 CRITICAL LOG EVENT"
            ? " • Level: " + criticalLog[:level]
            ? " • Message: " + criticalLog[:message] + NL
        })
        
        # Simulate log file content
        logLines = [
            "2024-01-15 10:30:15|INFO|User login successful",
            "2024-01-15 10:31:02|ERROR|Database connection failed",
            "2024-01-15 10:31:05|CRITICAL|System memory exhausted",
            "2024-01-15 10:32:10|INFO|Backup completed successfully",
            "2024-01-15 10:33:22|FATAL|Security breach detected"
        ]
        
        EmitMany(logLines)
        Complete()
    }
    
    Start()
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

/*--- Network-Based Streams

# HTTP requests, WebSocket connections, API polling
# Essential for: Real-time data, API integration, network monitoring

pr()

Rs = new stzReactiveSystem()
Rs {
    # API data processing stream
    oNetworkStream = CreateStream("api-monitor", :NETWORK)
    oNetworkStream {
        # Parse API responses
        Map(func apiResponse {
            # Simulate JSON parsing
            return [
                :endpoint = apiResponse[:url],
                :status_code = apiResponse[:status],
                :response_time = apiResponse[:time],
                :data_size = apiResponse[:size]
            ]
        })
        
        # Monitor performance issues
        Filter(func response {
            return response[:status_code] >= 400 or response[:response_time] > 2000
        })
        
        Subscribe(func issue {

            issueType = ""
            if issue[:status_code] >= 500
                issueType = "🔴 SERVER ERROR"

            but issue[:status_code] >= 400
                issueType = "🟡 CLIENT ERROR"  

            but issue[:response_time] > 2000
                issueType = "🐌 SLOW RESPONSE"
            ok
            
            ? issueType
            ? "• Endpoint: " + issue[:endpoint]
            ? "• Status: " + issue[:status_code]
            ? "• Response Time: " + issue[:response_time] + "ms" + NL
        })
        
        # Simulate API responses
        responses = [
            [:url = "/api/users", :status = 200, :time = 150, :size = 1024],
            [:url = "/api/orders", :status = 404, :time = 89, :size = 256],
            [:url = "/api/products", :status = 500, :time = 3500, :size = 0],
            [:url = "/api/payments", :status = 200, :time = 2500, :size = 512]
        ]
        
        EmitMany(responses)
        Complete()
    }
    
    Start()
    #-->
    '
    🟡 CLIENT ERROR
    • Endpoint: /api/orders
    • Status: 404
    • Response Time: 89ms

    🔴 SERVER ERROR
    • Endpoint: /api/products
    • Status: 500
    • Response Time: 3500ms

    🐌 SLOW RESPONSE
    • Endpoint: /api/payments
    • Status: 200
    • Response Time: 2500ms
    '
}

pf()
# Executed in 0.94 second(s) in Ring 1.23

/*--- Sensor-Based Streams

# IoT devices, environmental monitoring, real-time measurements
# Essential for: IoT applications, monitoring systems, data acquisition

pr()

Rs = new stzReactiveSystem()
Rs {
    # Environmental monitoring stream
    oSensorStream = CreateStream("environment-monitor", :SENSOR)
    oSensorStream {

        # Calibrate sensor readings
        Map(func rawReading {
            # Simulate sensor data processing
            return [
                :sensor_id = rawReading[:id],
                :temperature = rawReading[:temp] * 0.1,  # Convert to Celsius
                :humidity = rawReading[:humidity],
                :air_quality = rawReading[:aqi],
                :timestamp = clocksPerSecond()
            ]
        })
        
        # Environmental alerts
        Filter(func reading {
            return reading[:temperature] > 30 or 
                   reading[:humidity] > 80 or
                   reading[:air_quality] > 150
        })
        
        Subscribe(func alert {
            alertTypes = []

            if alert[:temperature] > 30
                alertTypes + "🌡️ HIGH TEMP"
            ok

            if alert[:humidity] > 80  
                alertTypes + "💧 HIGH HUMIDITY"
            ok

            if alert[:air_quality] > 150
                alertTypes + "🏭 POOR AIR QUALITY"
            ok
            
            ? "⚠️ ENVIRONMENTAL ALERT: " + JoinXT(alertTypes, " + ")
            ? "• Sensor: " + alert[:sensor_id] 
            ? "• Temperature: " + alert[:temperature] + "°C"
            ? "• Humidity: " + alert[:humidity] + "%"
            ? "• Air Quality Index: " + alert[:air_quality] + NL
        })
        
        # Simulate sensor readings
        sensorData = [
            [:id = "TEMP_01", :temp = 250, :humidity = 45, :aqi = 75],   # Normal
            [:id = "TEMP_02", :temp = 320, :humidity = 85, :aqi = 180],  # High temp + humidity + AQI
            [:id = "TEMP_03", :temp = 280, :humidity = 90, :aqi = 120],  # High humidity only
            [:id = "TEMP_04", :temp = 350, :humidity = 60, :aqi = 95]    # High temp only
        ]
        
        EmitMany(sensorData)
        Complete()
    }
    
    Start()
    #-->
    '
    ⚠️ ENVIRONMENTAL ALERT: 🌡️ HIGH TEMP + 💧 HIGH HUMIDITY + 🏭 POOR AIR QUALITY
    • Sensor: TEMP_02
    • Temperature: 32°C
    • Humidity: 85%
    • Air Quality Index: 180

    ⚠️ ENVIRONMENTAL ALERT: 💧 HIGH HUMIDITY
    • Sensor: TEMP_03
    • Temperature: 28°C
    • Humidity: 90%
    • Air Quality Index: 120

    ⚠️ ENVIRONMENTAL ALERT: 🌡️ HIGH TEMP
    • Sensor: TEMP_04
    • Temperature: 35°C
    • Humidity: 60%
    • Air Quality Index: 95
    '
}

pf()
# Executed in 1.06 second(s) in Ring 1.23

/*--- LibUV Integration Example

# Low-level system integration using LibUV handles
# Essential for: High-performance I/O, system-level operations

pr()

Rs = new stzReactiveSystem()
Rs {
    # System process monitoring via LibUV
    oUVStream = CreateStream("process-monitor", :LIBUV)
    oUVStream {
        # Process system events
        Map(func uvEvent {
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
        
        subscribe(func criticalEvent {
            ? "🔥 SYSTEM EVENT DETECTED:"
            ? "• Type: " + criticalEvent[:event_type]
            ? "• Process ID: " + criticalEvent[:process_id] 
            ? "• Resource Impact: " + criticalEvent[:resource_usage] + "%" + NL
        })
        
        OnComplete(func() {
            ? "🛡️ LibUV monitoring stopped - resources cleaned up"
        })
        
        # Simulate LibUV system events
        systemEvents = [
            [:type = "process_start", :pid = 1234, :resources = 15],
            [:type = "process_crash", :pid = 5678, :resources = 85],
            [:type = "normal_operation", :pid = 9012, :resources = 25],
            [:type = "memory_leak", :pid = 3456, :resources = 95],
            [:type = "high_cpu", :pid = 7890, :resources = 90]
        ]
        
        EmitMany(systemEvents)
        Complete()
    }
    
    Start()
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

/*--- Multi-Source Stream Composition

# Combining different stream sources in complex applications
# Shows real-world architectural patterns

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create multiple specialized streams
    
    # 1. User activity stream (manual)
    oUserStream = CreateStream("user-activity", :MANUAL)
    oUserStream {
        Map(func activity { 
            activity[:source] = "USER"
            return activity
        })
        Subscribe(func event { ? "👤 " + event[:action] + " by " + event[:user] })
    }
    
    # 2. System health stream (timer)
    oHealthStream = CreateStream("system-health", STREAM_SOURCE_TIMER) 
    oHealthStream {
        Map(func tick {
            return [:source = "SYSTEM", :status = "healthy", :load = random(100)]
        })
        Filter(func health { return health[:load] > 80 })
        OnData(func alert { ? "⚙️  System load high: " + alert[:load] + "%" })
    }
    
    # 3. External API stream (network)
    oApiStream = CreateStream("api-updates", STREAM_SOURCE_NETWORK)
    oApiStream {
        Map(func response {
            response[:source] = "API"  
            return response
        })
        OnData(func update { ? "🌐 API: " + update[:message] })
    }
    
    # Simulate multi-source events
    oUserStream.EmitMany([
        [:action = "Login", :user = "alice"],
        [:action = "Purchase", :user = "bob"]
    ])
    
    # System health checks
    for i = 1 to 3
        oHealthStream.Emit(i)
    next
    
    # API updates
    oApiStream.EmitMany([
        [:message = "New feature deployed"],
        [:message = "Maintenance scheduled"]
    ])
    
    # Complete all streams
    oUserStream.Complete()
    oHealthStream.Complete() 
    oApiStream.Complete()
    
    Start()
    #-->
    # 👤 Login by alice
    # 👤 Purchase by bob
    # ⚙️  System load high: 94%
    # 🌐 API: New feature deployed
    # 🌐 API: Maintenance scheduled
}

pf()
# Executed in 0.92 second(s) in Ring 1.23

#----------------------------------#
#  Backpressure Strategy Examples  #
#----------------------------------#

#NOTE

# Backpressure occurs when data arrives faster than it can be processed.
# The producer (emitting data) overwhelms the consumer (subscriber), so
# the system applies "pressure back" to slow down or block the producer.

/*--- Buffer Strategy - Queue data when subscriber is slow

# The sample shows proper backpressure with BACKPRESSURE_STRATEGY_BUFFER
# When the buffer is full, new items are blocked/dropped, and only the
# original buffered items get processed when drained.

pr()

Rs = new stzReactiveSystem()
Rs {

    # High-frequency data stream with slow subscriber

    oBufferStream = CreateStream("buffer-example", :MANUAL)
    oBufferStream {
        # Set buffer strategy with small buffer for demo
        SetBackpressureStrategy(:BUFFER, 3)
        
        # Slow subscriber (simulated)
        Subscribe(func data {
            ? "📊 Processing: " + data + " (slow subscriber)"
            # Simulate slow processing
        })
        
        OnBackpressure(func(current, max) {
            ? "🚦 Backpressure activated: " + current + "/" + max + " buffer full"
        })
        
        # Rapid data emission

        for i = 1 to 7  # Exceeds buffer size of 3
            ? "Emitting item " + i
            Emit("Data-" + i)
        next
        
        ? "Draining buffer..."
        DrainBuffer()
        Complete()
    }
    
    Start()
    #--> (#NOTE I added comments to the output for clarity)
 
    # Phase 1: Filling buffer (capacity: 3)
    # -------------------------------------
    # Emitting item 1
    # Emitting item 2
    # Emitting item 3
    # 
    # Phase 2: Buffer full - backpressure blocks new items
    # ----------------------------------------------------
    # Emitting item 4
    #🚦 Backpressure activated: 3/3 buffer full
    # ⚠️ Backpressure: Buffering data (buffer full: 3/3)
    # 
    # Emitting item 5
    #🚦 Backpressure activated: 3/3 buffer full
    #⚠️ Backpressure: Buffering data (buffer full: 3/3)
    # 
    # Emitting item 6
    #🚦 Backpressure activated: 3/3 buffer full
    #⚠️ Backpressure: Buffering data (buffer full: 3/3)
    # 
    # Emitting item 7
    #🚦 Backpressure activated: 3/3 buffer full
    #⚠️ Backpressure: Buffering data (buffer full: 3/3)
    # 
    # Phase 3: Manual drain processes buffered items
    #-----------------------------------------------
    # Draining buffer...
    # 📊 Processing: Data-1 (slow subscriber)
    # 📊 Processing: Data-2 (slow subscriber)
    # 📊 Processing: Data-3 (slow subscriber)

}

#NOTE

# Draining a buffer means processing all queued/stored items
# in the buffer. Items were temporarily held due to backpressure,
# and draining releases them for processing.

# In our example above:

# Items 1-3 fill the buffer (capacity: 3)
# Items 4-7 are blocked by backpressure (buffer full)
# Draining processes the 3 stored items while blocked items are lost

# It is like a traffic jam: cars (data) back up when the road (processor)
# can't handle the flow, and draining is like clearing the backed-up cars.

pf()
# Executed in 0.95 second(s) in Ring 1.23

/*--- Drop Strategy - Discard data when overwhelmed

# The sample shows BACKPRESSURE_STRATEGY_DROP behavior
# Buffer fills to capacity (3), then excess sensor readings
# are discarded to prevent system overload - sacrifices data 
# completeness for stability

pr()

Rs = new stzReactiveSystem()
Rs {
    # Real-time sensor stream that can afford to lose some data
    oDropStream = CreateStream("drop-example", :SENSOR)
    oDropStream {
        SetBackpressureStrategy(:DROP, 2)
        
        Map(func reading {
            return "Sensor-" + reading + "°C"
        })
        
        Subscribe(func temperature {
            ? "🌡️ Current temp: " + temperature
        })
        
        OnBackpressure(func(current, max) {
            ? "🚨 Sensor overloaded, dropping readings"
        })

        ? "Simulating high-frequency sensor readings..."
        
        # Simulate sensor burst
        sensorReadings = [23.5, 23.7, 24.1, 24.3, 24.5, 24.8, 25.0]
        for i = 1 to len(sensorReadings)
            ? "Reading: " + sensorReadings[i]
            Emit(sensorReadings[i])
        next
        
        stats = GetBackpressureStats()
        ? NL + "Final stats - Dropped: " + stats[:droppedCount] + " readings"
        
        Complete()
    }
    
    Start()
    #--> (#NOTE I added some comments to clarify the output)
    # Simulating high-frequency sensor readings...
    # 
    # Phase 1: Buffer fills with initial readings (capacity: 3)
    # ---------------------------------------------------------
    # Reading: 23.50
    # Reading: 23.70
    # Reading: 24.10
    # 
    # Phase 2: Drop strategy - excess readings discarded
    # --------------------------------------------------
    # Reading: 24.30
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Backpressure: Dropping data item (dropped so far: 1)
    # 
    # Reading: 24.50
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Backpressure: Dropping data item (dropped so far: 2)
    # 
    # Reading: 24.80
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Backpressure: Dropping data item (dropped so far: 3)
    # 
    # Reading: 25
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Backpressure: Dropping data item (dropped so far: 4)

    # Result: Only first 3 readings kept, rest dropped
    # ------------------------------------------------
    # Final stats - Dropped: 5 readings

}

pf()
# Executed in 0.92 second(s) in Ring 1.23

/*--- Latest Strategy - Keep most recent data

# The sample shows BACKPRESSURE_STRATEGY_LATEST behavior
# Buffer maintains fixed size by discarding oldest data when new arrives
# Ensures most current information is preserved for time-sensitive applications

pr()

Rs = new stzReactiveSystem()
Rs {
    # Stock price stream - only latest price matters
    oLatestStream = CreateStream("latest-price", :NETWORK)
    oLatestStream {
        SetBackpressureStrategy(:LATEST, 2)
        
        Map(func price {
            return "AAPL: $" + price
        })
        
        Subscribe(func stockPrice {
            ? "💰 " + stockPrice
        })
        
        OnBackpressure(func(current, max) {
            ? "📈 High trading volume - keeping latest prices only"
        })
        
        ? "=== Latest Strategy Demo ==="
        ? "Simulating rapid stock price updates..."
        
        # Rapid price updates
        prices = [150.25, 150.30, 150.15, 150.45, 150.60, 150.55]
        for i = 1 to len(prices)
            ? "Price update: $" + prices[i]
            Emit(prices[i])
        next
        
        DrainBuffer()
        Complete()
    }
    
    Start()
    #--> (#NOTE I added some comments to clarify the output)
    # 
    # Simulating rapid stock price updates...
    # 
    # Phase 1: Buffer fills with initial price updates (capacity: 3)
    # --------------------------------------------------------------
    # Price update: $150.25
    # Price update: $150.30
    # Price update: $150.15
    # 
    # Phase 2: Latest strategy - keeps newest prices, discards oldest
    # ---------------------------------------------------------------
    # Price update: $150.45
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Backpressure: Keeping latest, dropped oldest
    # 
    # Price update: $150.60
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Backpressure: Keeping latest, dropped oldest
    # 
    # Price update: $150.55
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Backpressure: Keeping latest, dropped oldest
    # 
    # Phase 3: Final buffer contains most recent prices
    # 💰 AAPL: $150.60
    # 💰 AAPL: $150.55
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

/*--- Block Strategy - Simulate producer blocking

# The sample shows BACKPRESSURE_STRATEGY_BLOCK behavior
# Producer is halted when buffer fills to prevent data loss
# Maintains data integrity by forcing synchronization
# between producer and consumer

pr()

Rs = new stzReactiveSystem()
Rs {
    # Critical system events - cannot lose data
    oBlockStream = CreateStream("critical-events", :MANUAL)
    oBlockStream {
        SetBackpressureStrategy(:BLOCK, 3)
        
        Filter(func event {
            return event[:severity] = "CRITICAL"
        })
        
        Subscribe(func criticalEvent {
            ? "🚨 CRITICAL: " + criticalEvent[:message]
            # Simulate slow processing of critical events
        })
        
        OnBackpressure(func(current, max) {
            ? "⛔ System overload - would block producer"
        })
        
        ? "Block Strategy Demo..."
        
        events = [
            [:severity = "CRITICAL", :message = "Database failure"],
            [:severity = "CRITICAL", :message = "Memory exhausted"], 
            [:severity = "INFO", :message = "User login"],
            [:severity = "CRITICAL", :message = "Security breach"],
            [:severity = "CRITICAL", :message = "Disk full"],
            [:severity = "CRITICAL", :message = "Network down"]
        ]
        
        for i = 1 to len(events)
            ? "Event: " + events[i][:severity] + " - " + events[i][:message]
            Emit(events[i])
        next
        
        Complete()
    }
    
    Start()
    #--> (#NOTE I added some comments to clarify the output)
    # Block Strategy Demo...
    # 
    # Phase 1: Buffer fills with initial events (capacity: 3)
    # -------------------------------------------------------
    # Event: CRITICAL - Database failure
    # Event: CRITICAL - Memory exhausted
    # Event: INFO - User login
    # 
    # Phase 2: Block strategy - producer paused to prevent overflow
    # -------------------------------------------------------------
    # Event: CRITICAL - Security breach
    # ⛔ System overload - would block producer
    # ⚠️ Backpressure: Would block producer (simulated)
    # 
    # Event: CRITICAL - Disk full
    # ⛔ System overload - would block producer
    # ⚠️ Backpressure: Would block producer (simulated)
    # 
    # Event: CRITICAL - Network down
    # ⛔ System overload - would block producer
    # ⚠️ Backpressure: Would block producer (simulated)
    # 
    # ~> No processing shown - events remain queued until
    # consumer catches up
}

pf()
# Executed in 0.92 second(s) in Ring 1.23

/*--- Real-World Example: Log Processing with Adaptive Backpressure

# The sample shows adaptive backpressure - system dynamically
# switches strategies, by chaning from buffer to drop mode under
# extreme load to maintain stability

# Processes existing buffer before applying new strategy

*/
pr()

Rs = new stzReactiveSystem()
Rs {
    # Log processing system with smart backpressure
    oLogStream = CreateStream("adaptive-logs", :FILE)
    oLogStream {
        # Start with buffer strategy
        SetBackpressureStrategy(:BUFFER, 5)
        
        # Parse and enrich log entries
        Map(func logLine {
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
        
        Subscribe(func importantLog {
            ? "📋 " + importantLog[:level] + " [" + importantLog[:service] + "] " + importantLog[:message]
        })
        
        # Adaptive backpressure handler
        OnBackpressure(func(current, max) {
            ? "🔄 Log processing backpressure: " + current + "/" + max
            
            # Switch to drop strategy under extreme load
            if current >= max
                ? "⚡ Switching to DROP strategy due to extreme load"
                oLogStream.SetBackpressureStrategy(BACKPRESSURE_STRATEGY_DROP, 10)
            ok
        })
        
        ? "Adaptive Log Processing Demo..."
        
        # Simulate log burst
        logEntries = [
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
        
        EmitMany(logEntries)
        
        ? "Processing remaining buffer..."
        DrainBuffer()
        
        stats = GetBackpressureStats() 
        ? "Final processing stats:"
        ? "  • Strategy: " + stats[:strategy]
        ? "  • Items dropped: " + stats[:droppedCount]
        ? "  • Buffer utilization: " + stats[:currentBuffer] + "/" + stats[:bufferSize]
        
        Complete()
    }
    
    Start()
    #-->  (#NOTE I added some comments to clarify the output)
    # Adaptive Log Processing Demo...
    # 
    # Phase 1: Buffer reaches capacity, triggers strategy change
    # ----------------------------------------------------------
    # 🔄 Log processing backpressure: 5/5
    # ⚡ Switching to DROP strategy due to extreme load
    # ⚠️ Backpressure: Dropping data item (dropped so far: 1)
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
