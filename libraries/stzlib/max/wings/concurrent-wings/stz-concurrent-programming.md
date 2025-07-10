# Softanza Concurrent Programming - Design Proposal

## Vision & Philosophy

The Softanza approach to concurrency embraces the library's core principles:

* **Natural Language Programming**: Concurrency expressed in human-readable metaphors
* **Zero Boilerplate**: No async/await syntax pollution or function coloring
* **Practical Simplicity**: Complex concurrency made as simple as sequential code
* **Object-Oriented Elegance**: Seamless integration with existing stzObjects
* **Unified Concurrency Model**: One simple concept instead of confusing parallel vs concurrent distinctions
* **Workshop Vocabulary**: Clear, natural terms that anyone can understand

## Core Design Principles

### 1. The "Workshop" Metaphor

Instead of thinking about threads and processes, Softanza uses the **Workshop** metaphor:

* **Workers** (lightweight threads) perform tasks
* **Workshops** (thread pools) manage workers
* **Tasks** (functions/methods) are the work to be done
* **Results** are collected when work is complete
* **Shared Tools** (data structures) can be used by multiple workers safely
* **Private Tools** (local data) belong to individual workers

### 2. Natural Language Concurrency

```ring
# Sequential (current)
oList = new stzList([ 1, 2, 3, 4, 5 ])
oList.DoubleEach()

# Concurrent (proposed)
oList = new stzList([ 1, 2, 3, 4, 5 ])
oList.DoubleEachConcurrently()
# OR
oList.Concurrently().DoubleEach()
```

**Note**: We use "concurrent" as our unified term. Whether tasks run truly parallel (multiple cores) or interleaved (single core) is handled automatically by the system. The programmer thinks in terms of "concurrent" - multiple things happening at once, however the system can best manage it.

## Technical Architecture

### Core Components

#### 1. stzWorkshop (Main Concurrency Manager)

```ring
oWorkshop = new stzWorkshop()
oWorkshop.SetMaxWorkers(8)
oWorkshop.AddTask("ProcessFile", "file1.txt")
oWorkshop.AddTask("ProcessFile", "file2.txt")
oWorkshop.WaitForAllTasks()
```

#### 2. stzWorker (Lightweight Thread Wrapper)

```ring
oWorker = new stzWorker()
oWorker.Assign("CalculateSum", [1, 2, 3, 4, 5])
oWorker.Start()
result = oWorker.GetResult()
```

#### 3. stzSharedTool (Workshop-Safe Data Structures)

```ring
# Multiple workers can use the same tool safely
oSharedList = new stzSharedList()
oSharedList.Add("item1")  # Worker 1 can add
oSharedList.Add("item2")  # Worker 2 can add simultaneously
```

#### 4. stzEvent & stzEventManager (Event System)

```ring
# Event-driven programming foundation
oEvent = new stzEvent("FileProcessed")
oEvent.SetData(["filename" = "data.txt", "size" = 1024])

oEventManager = new stzEventManager()
oEventManager.WhenEventOccurs("FileProcessed", "DoSomethingWithFile")
oEventManager.SendEvent(oEvent)
```

#### 5. stzPipeline & stzConcurrentPipeline (Advanced Task Processing)

```ring
# Sequential pipeline
oPipeline = new stzPipeline()
oPipeline.AddTask(new stzReadOnlyTask("ReadFile", "input.txt"))
oPipeline.AddTask(new stzCalculationTask("ProcessData"))
oPipeline.AddTask(new stzUpdateTask("WriteResult", "output.txt"))
oPipeline.Run()

# Concurrent pipeline (automatically optimizes based on task types)
oConcurrentPipeline = new stzConcurrentPipeline()
oConcurrentPipeline.AddTask(new stzReadOnlyTask("ReadFile", "input.txt"))
oConcurrentPipeline.AddTask(new stzCalculationTask("ProcessData"))
oConcurrentPipeline.AddTask(new stzUpdateTask("WriteResult", "output.txt"))
oConcurrentPipeline.Run()  # Automatically handles dependencies and concurrency
```

### Integration with Existing stzObjects

#### Enhanced stzString

```ring
# Sequential processing
oStr = new stzString("Hello World Hello Universe")
aWords = oStr.Split(" ")
for word in aWords
    # Process each word
next

# Concurrent processing
oStr = new stzString("Hello World Hello Universe")
oStr.ProcessWordsConcurrently("MyWordProcessor")
# OR
oStr.Concurrently().ProcessEachWord("MyWordProcessor")
```

#### Enhanced stzList

```ring
# Map-Reduce pattern made simple
oList = new stzList(1:1000000)
result = oList.Concurrently().Map("Square").Reduce("Sum")

# Concurrent filtering
oList = new stzList(1:1000000)
oFiltered = oList.Concurrently().Filter("IsEven")
```

#### Enhanced stzTable

```ring
# Concurrent row processing
oTable = new stzTable()
oTable.LoadFromCSV("bigdata.csv")
oTable.ProcessRowsConcurrently("AnalyzeRow")

# Concurrent column operations
oTable.Concurrently().ForEachColumn("NormalizeColumn")
```

## API Design Examples

### 1. Simple Task Execution

```ring
# Fire and forget
RunConcurrently("BackupDatabase", "daily_backup.sql")

# With result
result = RunConcurrently("CalculatePI", 1000000)
? result.Get()  # Blocks until complete
```

### 2. Batch Processing

```ring
aFiles = ["file1.txt", "file2.txt", "file3.txt"]
aResults = ProcessConcurrently(aFiles, "ProcessFile")
for result in aResults
    ? result.Get()
next
```

### 3. Pipeline Processing

```ring
# Basic pipeline
oPipeline = new stzPipeline()
oPipeline.AddTask(new stzReadOnlyTask("ReadFile", "input.txt"))
oPipeline.AddTask(new stzCalculationTask("ProcessData"))
oPipeline.AddTask(new stzUpdateTask("WriteResult", "output.txt"))
oPipeline.Run()

# Concurrent pipeline with automatic optimization
oConcurrentPipeline = new stzConcurrentPipeline()
oConcurrentPipeline.AddTask(new stzReadOnlyTask("ReadFile1", "input1.txt"))
oConcurrentPipeline.AddTask(new stzReadOnlyTask("ReadFile2", "input2.txt"))
oConcurrentPipeline.AddTask(new stzCalculationTask("ProcessData"))  # Waits for both reads
oConcurrentPipeline.AddTask(new stzUpdateTask("WriteResult", "output.txt"))
oConcurrentPipeline.Run()  # Automatically runs ReadFile1 and ReadFile2 concurrently
```

### 4. Event-Driven Concurrency

```ring
oEventManager = new stzEventManager()
oEventManager.WhenFileChanges("ProcessFile")
oEventManager.WhenNetworkRequestComes("HandleRequest")
oEventManager.StartWatching()
```

### 5. Task-Based Concurrency

```ring
# Different task types for optimal concurrency
oReadTask = new stzReadOnlyTask("LoadData", "database.db")
oCalcTask = new stzCalculationTask("AnalyzeData")
oUpdateTask = new stzUpdateTask("SaveResults", "results.txt")

# Pipeline automatically optimizes based on task types
oPipeline = new stzConcurrentPipeline()
oPipeline.AddTask(oReadTask)
oPipeline.AddTask(oCalcTask)    # Can run multiple instances concurrently
oPipeline.AddTask(oUpdateTask)  # Serialized for data consistency
oPipeline.Run()
```

## Performance Optimizations

### 1. Automatic Load Balancing

```ring
# Softanza automatically distributes work
oList = new stzList(1:1000000)
oList.Concurrently().ProcessEach("HeavyComputation")
# Automatically uses optimal number of workers
```

### 2. Memory-Efficient Processing

```ring
# Streaming concurrent processing for large datasets
oFile = new stzFile("huge_data.csv")
oFile.ProcessLinesConcurrently("ProcessLine", :Streaming = TRUE)
```

### 3. Adaptive Concurrency

```ring
# System automatically adjusts based on workload
oWorkshop = new stzWorkshop()
oWorkshop.SetAdaptiveMode(TRUE)  # Automatically scales workers
```

## Error Handling & Resilience

### 1. Smooth Error Handling

```ring
oList = new stzList([1, 2, "invalid", 4, 5])
oResults = oList.Concurrently().TryProcessEach("ConvertToNumber")
for result in oResults
    if result.Succeeded()
        ? result.Get()
    else
        ? "Problem: " + result.GetProblem()
    ok
next
```

### 2. Try-Again Mechanisms

```ring
oWorker = new stzWorker()
oWorker.SetTryAgainCount(3)
oWorker.SetWaitBetweenTries(1000)  # 1 second
oWorker.Assign("UnreliableTask", "data")
```

## Integration with Ring's Extension System

### 1. Libuv Integration

```ring
# Softanza wrapper for Libuv threads
oWorkshop = new stzWorkshop()
oWorkshop.UseLibuv()  # Enables Libuv backend
```

### 2. Qt Integration

```ring
# Softanza wrapper for Qt threads
oWorkshop = new stzWorkshop()
oWorkshop.UseQt()  # Enables Qt backend
```

### 3. Future Extensions

```ring
# Extensible for future backends
oWorkshop = new stzWorkshop()
oWorkshop.UseCustomBackend("MyThreadLibrary")
```

## Real-World Usage Scenarios

### 1. Web Scraping

```ring
aURLs = ["http://site1.com", "http://site2.com", "http://site3.com"]
aResults = ProcessConcurrently(aURLs, "ScrapeWebsite")
for result in aResults
    content = result.Get()
    # Process scraped content
next
```

### 2. Image Processing

```ring
oFolder = new stzFolder("images/")
aImages = oFolder.GetFiles("*.jpg")
ProcessConcurrently(aImages, "ResizeImage")
```

### 3. Data Analysis

```ring
oTable = new stzTable()
oTable.LoadFromCSV("sales_data.csv")
oSummary = oTable.Concurrently().GroupBy("Region").Aggregate("Sales", "Sum")
```

### 4. File Processing

```ring
oFolder = new stzFolder("documents/")
aFiles = oFolder.GetFiles("*.txt")
aResults = ProcessConcurrently(aFiles, "ExtractKeywords")
```

## Benefits of This Approach

### 1. **Simplicity First**

* No new syntax to learn
* Natural language programming maintained
* Existing code easily convertible

### 2. **Performance Without Complexity**

* Automatic optimization
* Efficient resource utilization
* Scalable from single-core to multi-core

### 3. **Practical Integration**

* Works with existing stzObjects
* Backwards compatible
* Incremental adoption possible

### 4. **Developer Experience**

* Familiar metaphors (Workshop, Workers, Tasks)
* Clear error messages
* Comprehensive debugging support

## Implementation Strategy

### Phase 1: Core Framework

* Implement stzWorkshop and stzWorker
* Create stzEvent and stzEventManager
* Build basic task types (stzReadOnlyTask, stzCalculationTask, stzUpdateTask)
* Create basic concurrent collections
* Build Libuv integration

### Phase 2: Pipeline System

* Implement stzPipeline and stzConcurrentPipeline
* Create intelligent task scheduling based on task types
* Add dependency management between tasks

### Phase 3: stzObject Integration

* Add concurrent methods to stzString, stzList, stzTable
* Implement Concurrently() fluent interface
* Create concurrent algorithms

### Phase 4: Advanced Features

* Event-driven concurrency with stzEventManager
* Performance optimizations
* Advanced error handling and try-again mechanisms

### Phase 4: Ecosystem

* Documentation and examples
* Performance benchmarks
* Community feedback integration

## Conclusion

This design maintains Softanza's philosophy of making complex programming concepts accessible through natural language and practical metaphors. The concurrent programming experience becomes as intuitive as sequential programming, while delivering the performance benefits of modern multi-core processors.

The approach ensures that developers can gradually adopt concurrency without rewriting existing code, making it a practical evolution of the Softanza library that honors its commitment to simplicity, efficiency, and programmer happiness.
