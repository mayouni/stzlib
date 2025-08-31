
load "../stzbase.ring"

/*--- Softanza typical code for programming reactive streams

# First, everything must happen inside a ReactiveSystem object.
# In Softanza, reactive streams (and any other reactive element)
# cannot exist in a vacuum!

# Create a Reactive System instance
Rs = new stzReactiveSystem()
Rs {
    # Inside the reactive system (which is actually built on the
    # Libuv infrastructure), we create a reactive stream object to
    # work with, and begin defining it.

    oPriceStream = CreateStreamXT("my-price-api", OPTIMISED_FOR_NETWORK_SOURCE)
    # The stream is defined with type :NETWORK, telling the libuv engine
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

	# The last step is to define the data the stream will receive.
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

/*--- Basic Stream Operations

# Demonstrates fundamental stream creation, Recieveing, and lifecycle
# Essential concepts: Recieve, OnPassed, Error handling, Completion

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create a manual stream for basic operations
    oBasicStream = CreateStream("basic-example")
    oBasicStream {

        # Each item of data that the stream is fed with
	# is processed using this Rfunction
        OnPassed(func data {
            ? "📊 Data received: " + data
        })

        # Potential erros are captured by the fellowing Rfunction
        OnError(func error {
            ? "❌ Error occurred: " + error
        })

        # When there are no more data items to process,
	# this Rfunction is exuecuted

        OnNoMore(func() {
            ? "✅ Stream processing completed"
        })

        # Recieve individual data points
        Recieve("First message")
        Recieve("Second message")

        # Recieve the stream with multiple items at once
        RecieveMany(["Third", "Fourth", "Fifth"])

        # Check that error handling works (when stream errors don't work)
        CheckErrorHandling("Simulated error")
        # Note: Stream automatically stops after error
    }

    RunLoop()
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
    oTransformStream = CreateStream("transform-pipeline")
    oTransformStream {
        # Chain transformations
        Transform(func price { return price * 1.20 })		# Add 20% tax
        Filter(func price { return price >= 100 })	# Only expensive items

        OnPassed(func finalPrice {
            ? "💰 Final price after tax & filtering: $" + finalPrice
        })

        # Test data with duplicates and various price ranges
        testPrices = [ 80, 90, 100, 120, 150, 200 ]
        RecieveMany(testPrices)

    }

    RunLoop()
    #-->
    # 💰 Final price after tax & filtering: $108
    # 💰 Final price after tax & filtering: $120  
    # 💰 Final price after tax & filtering: $144
    # 💰 Final price after tax & filtering: $180
    # 💰 Final price after tax & filtering: $240
}

pf()
# Executed in 0.93 second(s) in Ring 1.23


/*--- Data Aggregation with Accumulate

# Shows how streams manage accumulated data that must be explicitly concluded
# Essential for analytics, totals, and summary operations

pr()

Rs = new stzReactiveSystem()
Rs {

    # Sales data aggregation stream

    oSalesStream = CreateStream("sales-aggregation")
    oSalesStream {

        Accumulate( func(total, sale) {
            return total + sale["amount"]  # Running total kept internally
        }, 0)  # Starting value: $0.00


        OnPassed( func totalSales {
            ? "💰 Total Sales: $" + totalSales
        })


        OnNoMore( func() {
            ? "✅ Sales calculation completed"
        })

        # Daily sales transactions
        salesData = [
            [ :amount = 150.00, :product = "Laptop" ],
            [ :amount = 89.99, :product = "Mouse" ], 
            [ :amount = 299.99, :product = "Monitor" ],
            [ :amount = 45.50, :product = "Keyboard" ]
        ]

        # Recieve all sales data into the accumulation pipeline
        # Each item gets added to the internal accumulator (150 + 89.99 + 299.99 + 45.50)
 
        RecieveMany(salesData)

    }

    RunLoop()
    #-->
    # 💰 Total Sales: $585.48
    # ✅ Sales calculation completed
}
# Executed in 0.95 second(s) in Ring 1.23


pf()
# Executed in 0.95 second(s) in Ring 1.23

/*--- Analytics Dashboard with Multiple Metrics

# Complex accumulate example calculating multiple statistics
# Shows real-world analytics use case

pr()

Rs = new stzReactiveSystem()
Rs {
    # Website analytics stream

    oAnalyticsStream = CreateStream("web-analytics")
    oAnalyticsStream {

        # Aggregate user session data

        Accumulate(func(stats, session) {
            stats[:totalUsers] += 1
            stats[:totalPageViews] += session[:pageViews]
            stats[:totalSessionTime] += session[:duration]
            
            if session[:converted]
                stats[:conversions] += 1
            ok
            
            return stats

            },
	    [
		:totalUsers = 0,
		:totalPageViews = 0,
		:totalSessionTime = 0,
		:conversions = 0
	    ])

        OnPassed(func analytics {
            avgPageViews = analytics[:totalPageViews] / analytics[:totalUsers]
            avgSessionTime = analytics[:totalSessionTime] / analytics[:totalUsers]
            conversionRate = (analytics[:conversions] * 100.0) / analytics[:totalUsers]
            
            ? "📊 Website Analytics Summary:"
            ? "   Total Users: " + analytics[:totalUsers]
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

        RecieveMany(sessions)

    }
    
    RunReactiveLoop()
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
    oSensorStream = CreateStreamXT("sensor-data", OPTIMISED_FOR_SENSOR_SOURCE)
    oSensorStream {

        # Multi-stage processing pipeline
        Transform(func reading {
            # Convert raw sensor value to temperature
            return (reading - 32) * 5/9  # Fahrenheit to Celsius
        })

        Filter(func temp {
            # Only valid temperature readings
            return temp >= -50 and temp <= 100
        })

        Transform(func temp {
            # Round to 1 decimal place
            return floor(temp * 10) / 10
        })
     
        OnPassed(func temperature {
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
        RecieveMany(rawReadings)

    }
    
    RunLoop()
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

    oChatStream = CreateStream("chat-messages")
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

        Transform(func message {
            timestamp = "12:34"  # In real app, use actual timestamp
            return "[" + timestamp + "] " + message
        })
        
        OnPassed(func formattedMessage {
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
        
        RecieveMany(messages)

    }
    
    RunLoop()
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

    oOrderStream = CreateStream("order-processing")
    oOrderStream {

        # Validate orders

        Filter(func order {
            # Basic validation
            return order["amount"] > 0 and len(order["customer"]) > 0
        })
        
        # Calculate totals with tax and shipping

        Transform(func order {
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
        
        OnPassed(func processedOrder {
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
        
        RecieveMany(orders)

    }
    
    RunLoop()
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

    oTimerStream = CreateStreamXT("system-monitor", OPTIMISED_FOR_TIMER_SOURCE)
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

/*--- File-Based Streams

# File monitoring, log processing, configuration watching
# Essential for: Log analysis, file system events, data ingestion

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log file processing stream
    oFileStream = CreateStreamXT("log-processor", OPTIMISED_FOR_FILE_SOURCE)
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
        logLines = [
            "2024-01-15 10:30:15|INFO|User login successful",
            "2024-01-15 10:31:02|ERROR|Database connection failed",
            "2024-01-15 10:31:05|CRITICAL|System memory exhausted",
            "2024-01-15 10:32:10|INFO|Backup completed successfully",
            "2024-01-15 10:33:22|FATAL|Security breach detected"
        ]
        
        RecieveMany(logLines)

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

/*--- Network-Based Streams

# HTTP requests, WebSocket connections, API polling
# Essential for: Real-time data, API integration, network monitoring

pr()

Rs = new stzReactiveSystem()
Rs {
    # API data processing stream
    oNetworkStream = CreateStreamXT("api-monitor", OPTIMISED_FOR_NETWORK_SOURCE)
    oNetworkStream {
        # Parse API responses
        Transform(func apiResponse {
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
        
        OnPassed(func issue {

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
        
        RecieveMany(responses)

    }
    
    RunLoop()
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
    oSensorStream = CreateStreamXT("environment-monitor", OPTIMISED_FOR_SENSOR_SOURCE)
    oSensorStream {

        # Calibrate sensor readings
        Transform(func rawReading {
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
        
        OnPassed(func alert {
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
        
        RecieveMany(sensorData)

    }
    
    RunLoop()
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

# Low-level system integration using LibUV handles (called Rfunctions in Softanza)
# Essential for: High-performance I/O, system-level operations

pr()

Rs = new stzReactiveSystem()
Rs {
    # System process monitoring via LibUV
    oUVStream = CreateStreamXT("process-monitor", OPTIMISED_FOR_LIBUV_MESSAGES)
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
        systemEvents = [
            [:type = "process_start", :pid = 1234, :resources = 15],
            [:type = "process_crash", :pid = 5678, :resources = 85],
            [:type = "normal_operation", :pid = 9012, :resources = 25],
            [:type = "memory_leak", :pid = 3456, :resources = 95],
            [:type = "high_cpu", :pid = 7890, :resources = 90]
        ]
        
        RecieveMany(systemEvents)

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

/*--- Multi-Source Stream Composition

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

/*--- Immediate Auto-Conclude (Default)
# Best for: Batch processing, complete datasets, sales reports

pr()

Rs = new stzReactiveSystem()
Rs {
    oSalesStream = CreateStream("batch-sales")
    oSalesStream {
        # Default: immediate auto-conclude after RecieveMany()
        SetAutoConclude(true)  # Default behavior
        SetAutoConcludeDelay(0)  # No delay - conclude immediately
        
        Accumulate(func(total, sale) {
            return total + sale["amount"]
        }, 0)
        
        OnPassed(func totalSales {
            ? "💰 Batch Total: $" + totalSales + " (concluded immediately)"
        })
        
        OnNoMore(func() {
            ? "✅ Batch processing completed instantly"
        })
        
        # Complete dataset arrives at once
        salesData = [
            [:amount = 150.00, :product = "Laptop"],
            [:amount = 89.99, :product = "Mouse"], 
            [:amount = 299.99, :product = "Monitor"]
        ]
        
        RecieveMany(salesData)  # Auto-concludes immediately after processing
        # No manual Conclude() needed!
    }
}

pf()

/*--- Debounced Auto-Conclude 
# Best for: Streaming data, network feeds, sensor readings with gaps
*/
pr()

Rs = new stzReactiveSystem()
Rs {
    oSensorStream = CreateStream("temperature-readings")
    oSensorStream {

        # Enable debounced auto-conclude - waits for data gaps
        SetAutoConclude(true)
        SetAutoConcludeDelay(500)  # Wait 500ms after last reading
        
        Accumulate(func(avgTemp, reading) {
            # Simple moving average calculation
            if avgTemp = 0
                return reading["temp"]
            else
                return (avgTemp + reading["temp"]) / 2
            ok
        }, 0)
        
        OnPassed(func finalAvg {
            ? "🌡️  Final Average Temperature: " + finalAvg + "°C"
        })
        
        OnNoMore(func {
            ? "✅ Sensor reading session completed (after 500ms delay)"
        })
        
       # Simulate streaming sensor data with gaps
        ? "📡 Receiving temperature readings..."
        
        # Schedule sensor readings using reactive timers instead of Sleep()
        Rs.SetTimeout(0, func {
            oSensorStream.Recieve([:temp = 22.5, :sensor = "A1"])
            oSensorStream.Recieve([:temp = 23.1, :sensor = "A2"])
        })
        
        Rs.SetTimeout(200, func {
            ? "   (200ms gap - still waiting...)"
            oSensorStream.Recieve([:temp = 21.8, :sensor = "A3"])
            oSensorStream.Recieve([:temp = 24.2, :sensor = "A4"])
        })
        
        Rs.SetTimeout(600, func {
            ? "   (600ms gap - will auto-conclude after 500ms...)"
            # No more data - stream will auto-conclude after 500ms delay
        })

        Rs.SetTimeOut(1200, func {
	  ? "   (System kept alive for auto-conclude)"
        })
        
        # Stream automatically concludes here due to 500ms timeout
        # No manual Conclude() needed!
    }

    RunLoop()
    
    ? ""
    ? "💡 Key Difference:"
    ? "   • Immediate: Perfect for complete datasets (sales batches)"  
    ? "   • Debounced: Handles streaming data with natural gaps (sensors, APIs)"
}

pf()

#---------------------------------------------#
#  Overflow (backpressure) Strategy Examples  #
#---------------------------------------------#

#NOTE

# Overflow occurs when data arrives faster than it can be processed.
# The producer (Recieveing data) overwhelms the consumer (subscriber), so
# the system applies "pressure back" to slow down or block the producer.

/*--- Buffer Strategy - Queue data when subscriber is slow

# The sample shows proper Overflow with OVERFLOW_STRATEGY_BUFFER
# When the buffer is full, new items are blocked/dropped, and only the
# original buffered items get processed when drained.

pr()

Rs = new stzReactiveSystem()
Rs {

    # High-frequency data stream with slow subscriber

    oBufferStream = CreateStream("buffer-example")
    oBufferStream {
        # Set buffer strategy with small buffer for demo
        SetOverflowStrategy(:BUFFER, 3)
        
        # Slow subscriber (simulated)
        OnPassed(func data {
            ? "📊 Processing: " + data + " (slow subscriber)"
            # Simulate slow processing
        })
        
        OnOverflow(func(current, max) {
            ? "🚦 Overflow activated: " + current + "/" + max + " buffer full"
        })
        
        # Rapid data reception

        for i = 1 to 7  # Exceeds buffer size of 3
            ? "Recieveing item " + i
            Recieve("Data-" + i)
        next
        
        ? "Draining buffer..."
        DrainBuffer()

    }
    
    RunLoop()
    #--> (#NOTE I added comments to the output for clarity)
 
    # Phase 1: Filling buffer (capacity: 3)
    # -------------------------------------
    # Recieveing item 1
    # Recieveing item 2
    # Recieveing item 3
    # 
    # Phase 2: Buffer full - Overflow blocks new items
    # ----------------------------------------------------
    # Recieveing item 4
    #🚦 Overflow activated: 3/3 buffer full
    # ⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Recieveing item 5
    #🚦 Overflow activated: 3/3 buffer full
    #⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Recieveing item 6
    #🚦 Overflow activated: 3/3 buffer full
    #⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Recieveing item 7
    #🚦 Overflow activated: 3/3 buffer full
    #⚠️ Overflow: Buffering data (buffer full: 3/3)
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
# in the buffer. Items were temporarily held due to Overflow,
# and draining releases them for processing.

# In our example above:

# Items 1-3 fill the buffer (capacity: 3)
# Items 4-7 are blocked by Overflow (buffer full)
# Draining processes the 3 stored items while blocked items are lost

# It is like a traffic jam: cars (data) back up when the road (processor)
# can't handle the flow, and draining is like clearing the backed-up cars.

pf()
# Executed in 0.95 second(s) in Ring 1.23

/*--- Drop Strategy - Discard data when overwhelmed

# The sample shows OVERFLOW_STRATEGY_DROP behavior
# Buffer fills to capacity (3), then excess sensor readings
# are discarded to prevent system overload - sacrifices data 
# completeness for stability

pr()

Rs = new stzReactiveSystem()
Rs {
    # Real-time sensor stream that can afford to lose some data
    oDropStream = CreateStreamXT("drop-example", :SENSOR)
    oDropStream {
        SetOverflowStrategy(:DROP, 2)
        
        Transform(func reading {
            return "Sensor-" + reading + "°C"
        })
        
        OnPassed(func temperature {
            ? "🌡️ Current temp: " + temperature
        })
        
        OnOverflow(func(current, max) {
            ? "🚨 Sensor overloaded, dropping readings"
        })

        ? "Simulating high-frequency sensor readings..."
        
        # Simulate sensor burst
        sensorReadings = [23.5, 23.7, 24.1, 24.3, 24.5, 24.8, 25.0]
        for i = 1 to len(sensorReadings)
            ? "Reading: " + sensorReadings[i]
            Recieve(sensorReadings[i])
        next
        
        stats = GetOverflowStats()
        ? NL + "Final stats - Dropped: " + stats[:droppedCount] + " readings"

    }
    
    RunLoop()
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
    # ⚠️ Overflow: Dropping data item (dropped so far: 1)
    # 
    # Reading: 24.30
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 2)
    # 
    # Reading: 24.50
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 3)
    # 
    # Reading: 24.80
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 4)
    # 
    # Reading: 25
    # 🚨 Sensor overloaded, dropping readings
    # ⚠️ Overflow: Dropping data item (dropped so far: 5)

    # Result: Only first 3 readings kept, rest dropped
    # ------------------------------------------------
    # Final stats - Dropped: 5 readings

}

pf()
# Executed in 0.92 second(s) in Ring 1.23

/*--- Latest Strategy - Keep most recent data

# The sample shows OVERFLOW_STRATEGY_LATEST behavior
# Buffer maintains fixed size by discarding oldest data when new arrives
# Ensures most current information is preserved for time-sensitive applications

pr()

Rs = new stzReactiveSystem()
Rs {
    # Stock price stream - only latest price matters
    oLatestStream = CreateStreamXT("latest-price", :NETWORK)
    oLatestStream {
        SetOverflowStrategy(:LATEST, 2)
        
        Transform(func price {
            return "AAPL: $" + price
        })
        
        OnPassed(func stockPrice {
            ? "💰 " + stockPrice
        })
        
        OnOverflow(func(current, max) {
            ? "📈 High trading volume - keeping latest prices only"
        })
        
        ? "=== Latest Strategy Demo ==="
        ? "Simulating rapid stock price updates..."
        
        # Rapid price updates
        prices = [150.25, 150.30, 150.15, 150.45, 150.60, 150.55]
        for i = 1 to len(prices)
            ? "Price update: $" + prices[i]
            Recieve(prices[i])
        next
        
        DrainBuffer()

    }
    
    RunLoop()
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
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Price update: $150.60
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Price update: $150.55
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Phase 3: Final buffer contains most recent prices
    # 💰 AAPL: $150.60
    # 💰 AAPL: $150.55
}

pf()
# Executed in 0.93 second(s) in Ring 1.23

/*--- Block Strategy - Simulate producer blocking

# The sample shows OVERFLOW_STRATEGY_BLOCK behavior
# Producer is halted when buffer fills to prevent data loss
# Maintains data integrity by forcing synchronization
# between producer and consumer

pr()

Rs = new stzReactiveSystem()
Rs {
    # Critical system events - cannot lose data
    oBlockStream = CreateStream("critical-events")
    oBlockStream {
        SetOverflowStrategy(:BLOCK, 3)
        
        Filter(func event {
            return event[:severity] = "CRITICAL"
        })
        
        OnPassed(func criticalEvent {
            ? "🚨 CRITICAL: " + criticalEvent[:message]
            # Simulate slow processing of critical events
        })
        
        OnOverflow(func(current, max) {
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
    # Phase 2: Block strategy - producer paused to prevent overflow
    # -------------------------------------------------------------
    # Event: CRITICAL - Security breach
    # ⛔ System overload - would block producer
    # ⚠️ Overflow: Would block producer (simulated)
    # 
    # Event: CRITICAL - Disk full
    # ⛔ System overload - would block producer
    # ⚠️ Overflow: Would block producer (simulated)
    # 
    # Event: CRITICAL - Network down
    # ⛔ System overload - would block producer
    # ⚠️ Overflow: Would block producer (simulated)
    # 
    # ~> No processing shown - events remain queued until
    # consumer catches up
}

pf()
# Executed in 0.92 second(s) in Ring 1.23

/*--- Real-World Example: Log Processing with Adaptive Overflow

# The sample shows adaptive Overflow - system dynamically
# switches strategies, by chaning from buffer to drop mode under
# extreme load to maintain stability

# Processes existing buffer before applying new strategy

pr()

Rs = new stzReactiveSystem()
Rs {
    # Log processing system with smart Overflow
    oLogStream = CreateStreamXT("adaptive-logs", OPTIMISED_FOR_FILE_SOURCE)
    oLogStream {
        # Start with buffer strategy
        SetOverflowStrategy(:BUFFER, 5)
        
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
            ? "🔄 Log processing Overflow: " + current + "/" + max
            
            # Switch to drop strategy under extreme load
            if current >= max
                ? "⚡ Switching to DROP strategy due to extreme load"
                oLogStream.SetOverflowStrategy(OVERFLOW_STRATEGY_DROP, 10)
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
        
        RecieveMany(logEntries)
        
        ? "Processing remaining buffer..."
        DrainBuffer()
        
        stats = GetOverflowStats() 
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
    # 🔄 Log processing Overflow: 5/5
    # ⚡ Switching to DROP strategy due to extreme load
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

#=== #TODO #NARRATION
# # Overflow Strategies Explained

# What is Overflow?

# When data arrives faster than it can be processed, the system
# gets overwhelmed. Overflow is how we handle this mismatch.

# Four Overflow Strategies:

# 1. BUFFER - Store excess data in memory until processing catches up
#  - Methaphor: "Queue up messages like people waiting in line"
#  - Implementation: Currently just logs. In production, would
#    use actual queues with memory limits

# 2. DROP - Discard new data when overwhelmed
#  - Methaphor: "Like dropping phone calls when network is busy" 
#  - Implementation: Already works correctly - increments `droppedCount`

# 3. LATEST - Keep newest data, discard oldest
#  - Metaphor: "Like a news ticker - always show latest updates"
#  - Implementation: Already works correctly - manages buffer rotation

# 4. BLOCK - Pause the data source until ready
#  - Methaphor: "Like telling someone to slow down when they're talking too fast"
#  - Implementation: Currently just logs. In production, would signal the
#    data producer to pause

#TODO Documentation Approach:
# - Lead with simple analogies for educational users
# - Add technical notes for professional use
# - Mark simulation vs. production differences clearly
# - Provide working examples for each strategy

#NOTE
# - Current Status: DROP and LATEST work fully.
# - BUFFER and BLOCK are educational demonstrations that show the concept
#   but don't implement real blocking/queuing mechanisms.
