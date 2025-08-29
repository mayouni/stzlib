# Reactive Stream Programming with Softanza Reaxis System

Reactive programming transforms how we handle asynchronous data flows, making applications more responsive and resilient. The Softanza Reaxis System—part of the comprehensive Softanza library for Ring—delivers a powerful yet accessible framework for reactive stream programming that bridges the gap between high-level abstraction and low-level performance.

Built on the RingLibuv foundation (Ring's C-based binding to libuv), Reaxis combines the performance characteristics of systems programming with the elegance of declarative APIs. This unique architecture makes it suitable for both professional production systems and educational environments where understanding the underlying mechanics matters.

## The Philosophy: Visible Abstractions

Unlike many reactive frameworks that hide complexity behind opaque abstractions, Reaxis follows the principle of "visible abstractions." Every high-level operation maps clearly to well-understood reactive programming patterns, making the system both approachable for newcomers and transparent for experts who need to understand performance characteristics.

The RingLibuv foundation ensures that despite the high-level API, you're working with industrial-strength event loops, efficient memory management, and optimized I/O operations. This means your elegant stream transformations run with the efficiency of carefully crafted C code.

## Understanding Reactive Streams: The Foundation

Reactive streams process asynchronous data sequences, handling the unpredictable nature of real-world data flows. The core concepts become intuitive in Reaxis:

- **Stream**: A temporal sequence of data events
- **Emission**: Publishing data into the stream
- **Subscription**: Reactive callbacks for data, errors, and completion
- **Transformations**: Composable operations like Map, Filter, Reduce
- **Backpressure**: Flow control when producers outpace consumers

Reaxis makes these concepts tangible through its declarative syntax while maintaining visibility into the underlying event-driven mechanics.

## Getting Started: Stream Lifecycle Management

Here's how Reaxis handles the complete reactive lifecycle with transparent error handling:

```ring
load "../stzbase.ring"

Rs = new stzReactiveSystem()
Rs {
    oBasicStream = CreateStream("lifecycle-demo", :MANUAL)
    oBasicStream {
        OnData(func data {
            ? "📊 Processing: " + data
            # The callback runs on the main event loop thread
            # showcasing the underlying libuv integration
        })
        
        OnError(func error {
            ? "❌ Error in stream: " + error
            # Error propagation follows reactive streams specification
        })
        
        OnComplete(func() {
            ? "✅ Stream lifecycle completed"
            # Automatic cleanup of libuv resources
        })
        
        # Demonstrate the emission patterns
        Emit("Synchronous emission")
        EmitMany(["Batch", "emission", "pattern"])
        
        # Error handling is explicit and transparent
        EmitError("Controlled error demonstration")
    }
    
    Start()  # Activates the libuv event loop integration
}
```

**Output:**
```
📊 Processing: Synchronous emission
📊 Processing: Batch
📊 Processing: emission
📊 Processing: pattern
❌ Error in stream: Controlled error demonstration
```

The beauty here is that while you write declarative code, you can see exactly how the reactive streams specification is implemented—errors stop processing, resources are cleaned up automatically, and the event loop efficiently handles the asynchronous operations.

## Composable Transformations: Functional Pipeline Design

Stream transformations in Reaxis demonstrate functional programming principles while maintaining performance through the C-based foundation:

```ring
Rs = new stzReactiveSystem()
Rs {
    oPriceStream = CreateStream("price-pipeline", :MANUAL)
    oPriceStream {
        # Each transformation creates a new stream stage
        # but the underlying libuv handles efficient data passing
        Map(func price { 
            # Business logic transformation
            taxedPrice = price * 1.20
            ? "  Tax calculation: " + price + " -> " + taxedPrice
            return taxedPrice
        })
        
        Filter(func price { 
            # Predicate-based filtering
            passes = (price >= 100)
            ? "  Filter check: $" + price + " -> " + 
              (passes ? "PASS" : "REJECT")
            return passes
        })
        
        Map(func price {
            # Final formatting
            formatted = "Premium item: $" + price
            ? "  Format: " + formatted
            return formatted
        })
        
        Subscribe(func result {
            ? "💰 Final result: " + result
        })
        
        # Test with realistic data
        testPrices = [ 75, 85, 95, 105, 125, 150 ]
        ? "Processing price pipeline..."
        EmitMany(testPrices)
        Complete()
    }
    
    Start()
}
```

**Output:**
```
Processing price pipeline...
  Tax calculation: 75 -> 90
  Filter check: $90 -> REJECT
  Tax calculation: 85 -> 102
  Filter check: $102 -> PASS
  Format: Premium item: $102
💰 Final result: Premium item: $102
  Tax calculation: 95 -> 114
  Filter check: $114 -> PASS
  Format: Premium item: $114
💰 Final result: Premium item: $114
  Tax calculation: 105 -> 126
  Filter check: $126 -> PASS
  Format: Premium item: $126
💰 Final result: Premium item: $126
  Tax calculation: 125 -> 150
  Filter check: $150 -> PASS
  Format: Premium item: $150
💰 Final result: Premium item: $150
  Tax calculation: 150 -> 180
  Filter check: $180 -> PASS
  Format: Premium item: $180
💰 Final result: Premium item: $180
```

This example shows how each transformation stage is clearly visible, making it educational while maintaining the efficiency of compiled operations through RingLibuv.

## Advanced Aggregation: Stateful Stream Operations

Reaxis handles stateful operations like reduce while maintaining the reactive principles:

```ring
Rs = new stzReactiveSystem()
Rs {
    oAnalyticsStream = CreateStream("sales-analytics", :MANUAL)
    oAnalyticsStream {
        # Stateful aggregation with intermediate visibility
        Reduce(func(accumulator, sale) {
            newTotal = accumulator + sale["amount"]
            ? "  Accumulating: $" + accumulator + " + $" + 
              sale["amount"] + " = $" + newTotal + 
              " (" + sale["product"] + ")"
            return newTotal
        }, 0)  # Initial accumulator value
        
        OnData(func totalSales {
            ? "📈 Running total: $" + totalSales
        })
        
        OnComplete(func() {
            ? "✅ Sales analysis completed"
            # The final state is naturally available here
        })
        
        # Complex data structures work seamlessly
        salesData = [
            [:amount = 150.00, :product = "Laptop", :category = "Electronics"],
            [:amount = 89.99, :product = "Mouse", :category = "Accessories"], 
            [:amount = 299.99, :product = "Monitor", :category = "Electronics"],
            [:amount = 45.50, :product = "Keyboard", :category = "Accessories"],
            [:amount = 199.99, :product = "Tablet", :category = "Electronics"]
        ]
        
        ? "Sales Analytics Pipeline..."
        EmitMany(salesData)
        Complete()
    }
    
    Start()
}
```

The reduce operation maintains state efficiently through the libuv event loop, while providing complete visibility into the accumulation process.

## Professional-Grade Backpressure Management

Real-world applications need robust flow control. Reaxis provides multiple backpressure strategies that map directly to industry-standard patterns:

### Buffer Strategy: Resilient Data Preservation

```ring
Rs = new stzReactiveSystem()
Rs {
    oBufferStream = CreateStream("production-buffer", :MANUAL)
    oBufferStream {
        # Production-ready buffering configuration
        SetBackpressureStrategy(:BUFFER, 5)
        
        # Simulate slow consumer (common in real systems)
        Subscribe(func data {
            ? "🔄 Processing: " + data + " [simulated 100ms delay]"
            # In real scenarios, this might be database writes,
            # network requests, or file operations
        })
        
        OnBackpressure(func(current, max) {
            ? "⚠️  Backpressure triggered: Buffer " + current + "/" + max
            # This is where you'd implement monitoring/alerting
            # in production systems
        })
        
        # Simulate high-frequency data arrival
        ? "Simulating burst data arrival..."
        for i = 1 to 8
            ? "Emitting: Batch-" + i
            Emit("Batch-" + i)
        next
        
        ? "Draining buffer (simulating consumer catch-up)..."
        DrainBuffer()  # Process buffered items
        
        # Production monitoring
        stats = GetBackpressureStats()
        ? "Buffer utilization: " + stats[:currentBuffer] + "/" + stats[:bufferSize]
        
        Complete()
    }
    
    Start()
}
```

### Drop Strategy: High-Throughput Data Sampling

For IoT sensors or high-frequency trading scenarios where missing some data is acceptable:

```ring
Rs = new stzReactiveSystem()
Rs {
    oSensorStream = CreateStream("iot-sensor", :SENSOR)
    oSensorStream {
        # Configure for high-throughput sampling
        SetBackpressureStrategy(:DROP, 3)
        
        Map(func reading {
            # Convert raw sensor data to meaningful metrics
            celsius = (reading - 32) * 5/9
            timestamp = clocksPerSecond()
            return [:temp = celsius, :time = timestamp, :raw = reading]
        })
        
        Filter(func data {
            # Only process valid readings
            return data[:temp] >= -50 and data[:temp] <= 100
        })
        
        Subscribe(func sensorData {
            ? "🌡️  " + sensorData[:temp] + "°C [t:" + sensorData[:time] + "]"
        })
        
        OnBackpressure(func(current, max) {
            ? "📡 Sensor overload - dropping readings"
        })
        
        # Simulate high-frequency sensor readings
        sensorReadings = [68.2, 69.1, 70.5, 71.2, 72.8, 73.1, 74.4, 75.0, 76.3]
        ? "High-frequency sensor simulation..."
        
        for reading in sensorReadings
            Emit(reading)
        next
        
        stats = GetBackpressureStats()
        ? "Sensor stats - Processed: " + (len(sensorReadings) - stats[:droppedCount]) + 
          ", Dropped: " + stats[:droppedCount]
        
        Complete()
    }
    
    Start()
}
```

## Complex Real-World Example: Adaptive Log Processing

This example demonstrates how Reaxis handles enterprise-level challenges with adaptive strategies:

```ring
Rs = new stzReactiveSystem()
Rs {
    oLogProcessor = CreateStream("enterprise-logs", :FILE)
    oLogProcessor {
        # Start with buffering for data preservation
        SetBackpressureStrategy(:BUFFER, 10)
        
        # Parse structured logs
        Map(func logLine {
            parts = split(logLine, "|")
            parsed = [
                :timestamp = parts[1],
                :level = parts[2],
                :service = parts[3],
                :message = parts[4],
                :thread = parts[5],
                :processed_at = clocksPerSecond()
            ]
            ? "  Parsed: " + parsed[:level] + " from " + parsed[:service]
            return parsed
        })
        
        # Filter for important events
        Filter(func log {
            criticalLevels = ["ERROR", "WARN", "CRITICAL", "FATAL"]
            isCritical = find(criticalLevels, log[:level]) != 0
            if isCritical
                ? "  ⚡ Critical event detected: " + log[:level]
            ok
            return isCritical
        })
        
        # Enrich with metadata
        Map(func log {
            # Add processing metadata
            log[:alert_priority] = GetPriority(log[:level])
            log[:retention_days] = GetRetention(log[:level])
            return log
        })
        
        Subscribe(func criticalLog {
            ? "🚨 ALERT: " + criticalLog[:level] + " [" + 
              criticalLog[:service] + "] " + criticalLog[:message] +
              " (Priority: " + criticalLog[:alert_priority] + ")"
        })
        
        # Adaptive backpressure management
        OnBackpressure(func(current, max) {
            ? "📊 Log processing pressure: " + current + "/" + max
            
            # Implement adaptive strategy
            if current >= max * 0.8  # 80% threshold
                ? "⚡ High load detected - switching to DROP strategy"
                oLogProcessor.SetBackpressureStrategy(:DROP, 20)
                
                # In production, this would trigger:
                # - Monitoring alerts
                # - Scaling decisions
                # - Circuit breaker patterns
            ok
        })
        
        # Enterprise log simulation
        enterpriseLogs = [
            "2024-01-15 10:30:15|INFO|AUTH-SERVICE|User login successful|thread-1",
            "2024-01-15 10:30:16|ERROR|DATABASE|Connection pool exhausted|thread-3",
            "2024-01-15 10:30:17|WARN|CACHE-SERVICE|Memory usage 85%|thread-2",
            "2024-01-15 10:30:18|INFO|API-GATEWAY|Request processed successfully|thread-4",
            "2024-01-15 10:30:19|CRITICAL|SECURITY|Multiple failed login attempts detected|thread-1",
            "2024-01-15 10:30:20|ERROR|PAYMENT-SERVICE|Transaction processing failed|thread-5",
            "2024-01-15 10:30:21|WARN|STORAGE|Disk space below 15%|thread-2",
            "2024-01-15 10:30:22|FATAL|SYSTEM|Out of memory - application unstable|thread-1",
            "2024-01-15 10:30:23|ERROR|NETWORK|Service mesh connectivity issues|thread-6"
        ]
        
        ? "Enterprise Log Processing Pipeline..."
        EmitMany(enterpriseLogs)
        
        # Process any remaining buffered logs
        ? "Draining processing buffer..."
        DrainBuffer()
        
        # Production metrics
        stats = GetBackpressureStats()
        ? NL + "Processing Summary:"
        ? "  Strategy: " + stats[:strategy]
        ? "  Items processed: " + stats[:processedCount]
        ? "  Items dropped: " + stats[:droppedCount]
        ? "  Final buffer state: " + stats[:currentBuffer] + "/" + stats[:bufferSize]
        
        Complete()
    }
    
    Start()
}

# Helper functions for enterprise features
func GetPriority(level)
    switch level
        on "FATAL"    return "P0-CRITICAL"
        on "CRITICAL" return "P1-HIGH"
        on "ERROR"    return "P2-MEDIUM"
        on "WARN"     return "P3-LOW"
        other         return "P4-INFO"
    off

func GetRetention(level)
    switch level
        on "FATAL"    return 365  # 1 year
        on "CRITICAL" return 180  # 6 months
        on "ERROR"    return 90   # 3 months
        on "WARN"     return 30   # 1 month
        other         return 7    # 1 week
    off
```

## Educational Value: Learning Through Visibility

What makes Reaxis exceptional for educational use is how it reveals the mechanics without overwhelming complexity:

```ring
# Educational example: Understanding stream composition
Rs = new stzReactiveSystem()
Rs {
    oLearningStream = CreateStream("composition-demo", :MANUAL)
    oLearningStream {
        # Each stage shows the transformation clearly
        Map(func x {
            result = x * 2
            ? "Stage 1 - Multiply: " + x + " -> " + result
            return result
        })
        
        Filter(func x {
            passes = (x > 10)
            ? "Stage 2 - Filter: " + x + " -> " + (passes ? "PASS" : "BLOCK")
            return passes
        })
        
        Map(func x {
            result = x + 100
            ? "Stage 3 - Add: " + x + " -> " + result
            return result
        })
        
        Subscribe(func final {
            ? "Final result: " + final
            ? "---"
        })
        
        ? "Understanding Stream Composition:"
        ? "Input -> *2 -> >10? -> +100 -> Output"
        ? ""
        
        testData = [3, 5, 8, 12, 15]
        for num in testData
            ? "Processing: " + num
            Emit(num)
        next
        
        Complete()
    }
    
    Start()
}
```

Students can see exactly how functional composition works, how data flows through transformations, and how the reactive model handles asynchronous processing—all while benefiting from the performance of the underlying C implementation.

## Performance and Scalability: The RingLibuv Advantage

The RingLibuv foundation provides several critical advantages:

1. **Event Loop Efficiency**: Built on libuv's proven event loop architecture
2. **Memory Management**: Efficient allocation and cleanup of stream resources
3. **Non-blocking I/O**: True asynchronous operations for file, network, and timer streams
4. **Cross-platform**: Consistent behavior across Windows, Linux, and macOS
5. **Scalability**: Handles thousands of concurrent streams with minimal overhead

```ring
# Performance monitoring example
Rs = new stzReactiveSystem()
Rs {
    # Create multiple concurrent streams
    for streamId = 1 to 5
        oStream = CreateStream("concurrent-" + streamId, :TIMER)
        oStream {
            SetInterval(100 + (streamId * 50))  # Staggered intervals
            
            Map(func tick {
                return "Stream-" + streamId + ": " + tick
            })
            
            Subscribe(func data {
                ? data + " [" + clocksPerSecond() + "]"
            })
            
            # Run for limited time
            Take(3)  # Only process first 3 emissions
        }
    next
    
    Start()
    
    # The libuv event loop efficiently manages all 5 concurrent streams
    # with minimal CPU usage and no blocking
}
```

## Why Reaxis Excels: Design Philosophy

The Softanza Reaxis system succeeds because it:

1. **Maintains Conceptual Clarity**: Every operation maps to well-understood reactive patterns
2. **Provides Performance Transparency**: You understand the cost of operations
3. **Enables Progressive Learning**: Start simple, add complexity as needed
4. **Supports Production Use**: Enterprise-grade backpressure and error handling
5. **Bridges Abstraction Levels**: High-level APIs backed by efficient C implementation

## Framework Comparison

| Feature | Softanza Reaxis (Ring) | RxJS (JavaScript) | Reactor (Java) |
|---------|------------------------|-------------------|----------------|
| **Learning Curve** | Gentle, visible abstractions | Steep, many operators | Moderate, Spring integration |
| **Performance** | Excellent (C-based libuv) | Good (V8 optimized) | Excellent (JVM optimized) |
| **Memory Management** | Automatic (Ring GC + libuv) | Automatic (V8 GC) | Automatic (JVM GC) |
| **Backpressure** | 4 strategies, adaptive | Complex operator chains | Built-in, sophisticated |
| **Error Handling** | Explicit, transparent | Try/catch operators | Exception propagation |
| **Concurrency Model** | Event loop (libuv) | Event loop (Node.js) | Thread pool + NIO |
| **Educational Value** | High (visible mechanics) | Low (complex abstractions) | Medium (enterprise patterns) |
| **Production Readiness** | High (C foundation) | High (mature ecosystem) | Very High (enterprise grade) |
| **Syntax Clarity** | Excellent (declarative Ring) | Good (functional JS) | Good (fluent Java) |
| **Resource Usage** | Low (efficient C backend) | Medium (JS overhead) | Medium-High (JVM overhead) |
| **Debugging** | Excellent (clear flow) | Difficult (async stack traces) | Good (tooling support) |
| **Platform Support** | Cross-platform (libuv) | Cross-platform (Node.js) | JVM platforms |
| **Stream Types** | 8 built-in types | Many operators | Publishers/Subscribers |
| **Integration** | Ring ecosystem | NPM ecosystem | Spring/Java ecosystem |

## The "Reaxis" Name: Perfect Alignment

The name "Reaxis" brilliantly captures the system's essence:

- **"Re"** suggests the reactive paradigm and repetitive stream processing
- **"axis"** implies the central organizing principle around which data flows
- The combination suggests both the mathematical precision (axis) and the responsive nature (reactive)
- It's memorable, professional, and distinct in the reactive programming space
- The name avoids overloaded terms like "stream" or "flow" while remaining intuitive

Reaxis perfectly represents a system that serves as the foundational axis for reactive programming in the Softanza ecosystem.

## Conclusion

Softanza Reaxis transforms reactive programming from a complex academic concept into an accessible yet powerful tool for both learning and production use. By combining the elegance of Ring's syntax with the performance of RingLibuv's C-based foundation, Reaxis offers a unique approach that neither hides complexity nor overwhelms users with it.

Whether you're building IoT data processing pipelines, enterprise log analysis systems, or teaching students about asynchronous programming patterns, Reaxis provides the perfect balance of abstraction and transparency. The visible abstractions principle ensures that while you write beautiful declarative code, you always understand the efficient mechanisms running underneath.

The reactive future is not about choosing between simplicity and power—with Reaxis, you get both, wrapped in an elegant API that scales from educational examples to enterprise applications.