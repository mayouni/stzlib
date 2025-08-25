
load "../stzbase.ring"

#-------------------------#
#  BASIC STREAM EXAMPLES  #
#-------------------------#

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

#-----------------------------------#
#  REAL-WORLD INTEGRATION EXAMPLES  #
#-----------------------------------#

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
