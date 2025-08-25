
load "../stzbase.ring"

/*--- Basic Stream Operations

# Demonstrates fundamental stream creation, subscription, and lifecycle
# Essential concepts: Emit, Subscribe, Error handling, Completion

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create a manual stream for basic operations
    oBasicStream = CreateStream("basic-example", STREAM_SOURCE_MANUAL)
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

        # Start processing
        Start()

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
*/
# Shows data transformation capabilities with chaining
# Key concepts: Map (transform), Filter (predicate)

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Create stream for data processing pipeline
    oTransformStream = CreateStream("transform-pipeline", STREAM_SOURCE_MANUAL)
    oTransformStream {
        # Chain transformations
        Map(func price { return price * 1.20 })		# Add 20% tax
        Filter(func price { return price >= 100 })	# Only expensive items

        OnData(func finalPrice {
            ? "💰 Final price after tax & filtering: $" + finalPrice
        })

        Start()

        # Test data with duplicates and various price ranges
        testPrices = [80, 90, 100, 120, 150, 200]
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
    oSalesStream = CreateStream("sales-aggregation", STREAM_SOURCE_MANUAL)
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
        
        Start()
        
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
    oAnalyticsStream = CreateStream("web-analytics", STREAM_SOURCE_MANUAL)
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
        
        OnData(func analytics {
            avgPageViews = analytics["totalPageViews"] / analytics["totalUsers"]
            avgSessionTime = analytics["totalSessionTime"] / analytics["totalUsers"]
            conversionRate = (analytics["conversions"] * 100.0) / analytics["totalUsers"]
            
            ? "📊 Website Analytics Summary:"
            ? "   Total Users: " + analytics["totalUsers"]
            ? "   Avg Page Views: " + avgPageViews + " pages/user"
            ? "   Avg Session Time: " + avgSessionTime + " minutes"
            ? "   Conversion Rate: " + conversionRate + "%"
        })
        
        Start()
        
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
    oSensorStream = CreateStream("sensor-data", STREAM_SOURCE_MANUAL)
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
     
        OnData(func temperature {
            alert = ""
            if temperature > 35
                alert = " 🔥 HIGH"
            but temperature < 0
                alert = " ❄️ FREEZING"
            ok
            ? "🌡️  Temperature: " + temperature + "°C" + alert
        })
        
        Start()
        
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

# Realistic example: Processing chat messages with filtering and formatting
# Demonstrates practical stream usage

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Chat message processing pipeline
    oChatStream = CreateStream("chat-messages", STREAM_SOURCE_MANUAL)
    oChatStream {
        # Filter out spam and inappropriate content
        Filter(func message {
            spamWords = ["spam", "advertisement", "buy now"]
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
        
        OnData(func formattedMessage {
            ? "💬 " + formattedMessage
        })
        
        Start()
        
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
# Executed in 0.93 second(s) in Ring 1.23

/*--- E-commerce Order Processing

# Complex business logic example with multiple transformations
# Shows stream composition for real business scenarios

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Order processing stream
    oOrderStream = CreateStream("order-processing", STREAM_SOURCE_MANUAL)
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
        
        OnData(func processedOrder {
            ? "🛒 VIP Order processed:"
            ? "   Customer: " + processedOrder["customer"]
            ? "   Subtotal: $" + processedOrder["amount"]
            ? "   Tax: $" + processedOrder["tax"]  
            ? "   Shipping: $" + processedOrder["shipping"]
            ? "   Total: $" + processedOrder["total"]
            ? "   Status: Ready for priority shipping"
            ? ""
        })
        
        Start()
        
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

*--- Timer-Based Streams

# Periodic data generation for monitoring, logging, scheduled tasks
# Essential for: Heartbeats, polling, periodic updates

pr()

Rs = new stzReactiveSystem()
Rs {
    # System monitoring with timer-based stream
    oTimerStream = CreateStream("system-monitor", STREAM_SOURCE_TIMER)
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

        OnData(func alert {
            ? "⚠️ SYSTEM ALERT"
	    ? "----------------"
            ? " • CPU    : " + alert[:cpu_usage] + "%"
            ? " • Memory : " + alert[:memory_usage] + "%"
            ? " • Disk   : " + alert[:disk_space] + "%"
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
    # ✅ Monitoring session ended
}

pf()
# Executed in 1.04 second(s) in Ring 1.23

/*--- File-Based Streams

# File monitoring, log processing, configuration watching
# Essential for: Log analysis, file system events, data ingestion

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log file processing stream
    oFileStream = CreateStream("log-processor", STREAM_SOURCE_FILE)
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
        
        Start()
        
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
    oNetworkStream = CreateStream("api-monitor", STREAM_SOURCE_NETWORK)
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
        
        OnData(func issue {

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
# Executed in 0.93 second(s) in Ring 1.23

/*--- Sensor-Based Streams

# IoT devices, environmental monitoring, real-time measurements
# Essential for: IoT applications, monitoring systems, data acquisition

pr()

Rs = new stzReactiveSystem()
Rs {
    # Environmental monitoring stream
    oSensorStream = CreateStream("environment-monitor", STREAM_SOURCE_SENSOR)
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
        
        OnData(func alert {
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
    oUVStream = CreateStream("process-monitor", STREAM_SOURCE_LIBUV)
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
        
        OnData(func criticalEvent {
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
    oUserStream = CreateStream("user-activity", STREAM_SOURCE_MANUAL)
    oUserStream {
        Map(func activity { 
            activity[:source] = "USER"
            return activity
        })
        OnData(func event { ? "👤 " + event[:action] + " by " + event[:user] })
        Start()
    }
    
    # 2. System health stream (timer)
    oHealthStream = CreateStream("system-health", STREAM_SOURCE_TIMER) 
    oHealthStream {
        Map(func tick {
            return [:source = "SYSTEM", :status = "healthy", :load = random(100)]
        })
        Filter(func health { return health[:load] > 80 })
        OnData(func alert { ? "⚙️  System load high: " + alert[:load] + "%" })
        Start()
    }
    
    # 3. External API stream (network)
    oApiStream = CreateStream("api-updates", STREAM_SOURCE_NETWORK)
    oApiStream {
        Map(func response {
            response[:source] = "API"  
            return response
        })
        OnData(func update { ? "🌐 API: " + update[:message] })
        Start()
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
# Executed in 0.95 second(s) in Ring 1.23
