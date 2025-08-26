load "../stzbase.ring"

/*--- Basic File Watching Operations
*/
# Demonstrates fundamental file system monitoring with reactive streams
# Essential concepts: WatchFolder, File events, Reactive subscriptions

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create the test directory structure
    if not isDir("./test_watch")
        system("mkdir test_watch")
        ? "📁 Created test directory: ./test_watch"
    ok

    # Get the file system component
    Fs = FileSystem()
    
    # Create file watch options
    watchOptions = new stzFileWatchOptions()
    watchOptions {
        SetRecursive(FALSE)
        SetFilterType(FS_FILTER_ALL)
        SetIgnoreHidden(TRUE)
    }

    # Create a file watcher using the file system component
    oFileWatcher = Fs.WatchFolder("./test_watch", watchOptions)
    oFileWatcher {
        # Subscribe to all file system events
        OnData(func fsEvent {
            ? "📊 File Event: " + fsEvent.GetFileName()
            ? "   📄 Type: " + fsEvent.GetEventTypeText()
            ? "   📍 Full Path: " + fsEvent.GetFullPath()
            ? "   ⏰ Time: " + fsEvent.GetTimestamp()
            ? ""
        })

        # Handle watcher errors
        OnError(func error {
            ? "❌ File watcher error: " + error
        })

        # Handle watcher completion
        OnComplete(func() {
            ? "✅ File watching completed"
        })
    }

    # Demonstrate file operations that trigger events
    ? "Creating test files to trigger events..."
    write("./test_watch/sample.txt", "Hello World!")
    write("./test_watch/data.log", "Log entry 1")
    
    # Give the watcher time to detect events
    sleep(100)
    
    # Modify existing file
    write("./test_watch/sample.txt", "Hello World! Modified")
    
    sleep(100)

    # Start the reactive system (this will process all pending events)
    Start()
    #-->
    # 📁 Created test directory: ./test_watch
    # Creating test files to trigger events...
    # 📊 File Event: sample.txt
    #    📄 Type: FILE_CREATED
    #    📍 Full Path: ./test_watch/sample.txt
    #    ⏰ Time: 14:23:15 2025-01-15
    # 
    # 📊 File Event: data.log
    #    📄 Type: FILE_CREATED
    #    📍 Full Path: ./test_watch/data.log
    #    ⏰ Time: 14:23:15 2025-01-15
    #
    # 📊 File Event: sample.txt
    #    📄 Type: FILE_MODIFIED
    #    📍 Full Path: ./test_watch/sample.txt
    #    ⏰ Time: 14:23:15 2025-01-15
}

pf()

/*--- Advanced File Watching with Filters

# Shows filtered file watching with custom options
# Key concepts: File filters, Extension filtering, Recursive watching

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create advanced watching options
    oWatchOptions = new stzFileWatchOptions() {
        SetRecursive(TRUE)                    # Watch subdirectories
        SetFilterType(FS_FILTER_TEXT)        # Only text files
        SetIgnoreHidden(TRUE)                # Skip hidden files
    }

    # Create nested directory structure
    if not isDir("./test_advanced")
        system("mkdir test_advanced")
        system("mkdir test_advanced/subdir")
        ? "📁 Created nested test directories"
    ok

    oAdvancedWatcher = CreateFileWatcher("./test_advanced", oWatchOptions)
    oAdvancedWatcher {
        OnData(func fsEvent {
            ? "🔍 Filtered Event: " + fsEvent.GetFileName()
            ? "   📂 Directory: " + fsEvent.watchPath
            ? "   🏷️  Event: " + fsEvent.GetEventTypeText()
        })

        OnError(func error {
            ? "❌ Advanced watcher error: " + error
        })

        Start()
    }

    # Test different file types
    ? "Creating various file types..."
    write("./test_advanced/document.txt", "Text content")      # Will trigger
    write("./test_advanced/image.jpg", "fake image data")      # Will be filtered
    write("./test_advanced/script.ring", "load 'stdlib.ring'") # Will trigger
    write("./test_advanced/subdir/nested.log", "Log data")     # Will trigger (recursive)
    
    sleep(200)

    Start()
    #-->
    # 📁 Created nested test directories
    # Creating various file types...
    # 🔍 Filtered Event: document.txt
    #    📂 Directory: ./test_advanced
    #    🏷️  Event: FILE_CREATED
    # 🔍 Filtered Event: script.ring  
    #    📂 Directory: ./test_advanced
    #    🏷️  Event: FILE_CREATED
    # 🔍 Filtered Event: nested.log
    #    📂 Directory: ./test_advanced
    #    🏷️  Event: FILE_CREATED
}

pf()

/*--- Custom Extension Filtering

# Demonstrates custom file extension filtering
# Key concepts: Custom filters, Multiple extensions, Filter chaining

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create custom filter for specific extensions
    oCustomOptions = new stzFileWatchOptions() {
        SetFilterType(FS_FILTER_CUSTOM)
        AddExtensions([".ring", ".py", ".js", ".rb"])  # Programming files only
    }

    if not isDir("./test_custom")
        system("mkdir test_custom")
    ok

    oCustomWatcher = CreateFileWatcher("./test_custom", oCustomOptions)
    oCustomWatcher {
        OnData(func fsEvent {
            ? "💻 Code File Event: " + fsEvent.GetFileName()
            ? "   🎯 Matched custom filter"
            if fsEvent.IsFileCreated()
                ? "   ➕ New file created"
            but fsEvent.IsFileModified()
                ? "   ✏️  File modified"
            ok
        })

        Start()
    }

    # Test various file extensions
    ? "Testing custom extension filtering..."
    write("./test_custom/app.ring", "# Ring application")    # Matches
    write("./test_custom/script.py", "# Python script")     # Matches  
    write("./test_custom/config.xml", "<config></config>")  # Filtered out
    write("./test_custom/client.js", "// JavaScript")       # Matches
    write("./test_custom/readme.txt", "Documentation")      # Filtered out
    write("./test_custom/tool.rb", "# Ruby script")         # Matches

    sleep(200)

    Start()
    #-->
    # Testing custom extension filtering...
    # 💻 Code File Event: app.ring
    #    🎯 Matched custom filter
    #    ➕ New file created
    # 💻 Code File Event: script.py
    #    🎯 Matched custom filter  
    #    ➕ New file created
    # 💻 Code File Event: client.js
    #    🎯 Matched custom filter
    #    ➕ New file created
    # 💻 Code File Event: tool.rb
    #    🎯 Matched custom filter
    #    ➕ New file created
}

pf()

/*--- Reactive File Content Streaming

# Shows reading and processing file content reactively
# Key concepts: File streams, Content processing, Line-by-line reading

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create test file with sample content
    testContent = "Line 1: Welcome to reactive files" + nl +
                  "Line 2: Processing content streams" + nl + 
                  "Line 3: Real-time file monitoring" + nl +
                  "Line 4: Event-driven programming" + nl +
                  "Line 5: End of sample content"
    
    write("./sample_content.txt", testContent)
    ? "📝 Created sample content file"

    # Create file content stream
    oFileStream = CreateFileStream("./sample_content.txt")
    oFileStream {
        OnData(func content {
            ? "📖 File content received:"
            ? content
            ? ""
        })

        OnError(func error {
            ? "❌ File read error: " + error
        })

        OnComplete(func() {
            ? "✅ File reading completed"
        })

        # Read entire file content
        ReadAll()
    }

    # Create line-by-line stream
    ? "--- Reading file line by line ---"
    oLineStream = CreateFileStream("./sample_content.txt")
    oLineStream {
        OnData(func line {
            ? "📄 Line: " + line
        })

        OnComplete(func() {
            ? "✅ Line processing completed"
        })

        # Process file line by line
        ReadLines()
    }

    Start()
    #-->
    # 📝 Created sample content file
    # 📖 File content received:
    # Line 1: Welcome to reactive files
    # Line 2: Processing content streams
    # Line 3: Real-time file monitoring
    # Line 4: Event-driven programming
    # Line 5: End of sample content
    #
    # ✅ File reading completed
    # --- Reading file line by line ---
    # 📄 Line: Line 1: Welcome to reactive files
    # 📄 Line: Line 2: Processing content streams
    # 📄 Line: Line 3: Real-time file monitoring
    # 📄 Line: Line 4: Event-driven programming
    # 📄 Line: Line 5: End of sample content
    # ✅ Line processing completed
}

pf()

/*--- Reactive File Writing and Monitoring

# Demonstrates reactive file creation and content writing
# Key concepts: Reactive file creation, Write operations, Combined operations

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create a reactive file writer
    oReactiveFile = CreateReactiveFile("./reactive_output.txt", "Initial content")
    oReactiveFile {
        OnData(func fsEvent {
            ? "📝 Reactive File Event: " + fsEvent.GetEventTypeText()
            ? "   📄 File: " + fsEvent.GetFileName()
        })

        OnComplete(func() {
            ? "✅ Reactive file operations completed"
        })
    }

    # Create file content writer
    oWriter = CreateFileStream("./reactive_output.txt")
    oWriter {
        OnData(func result {
            if result = "write_success"
                ? "✏️  Write operation successful"
            ok
        })

        OnError(func error {
            ? "❌ Write error: " + error
        })

        # Write new content
        WriteContent("Updated content through reactive stream!")
    }

    Start()
    #-->
    # 📝 Reactive File Event: FILE_CREATED
    #    📄 File: reactive_output.txt
    # ✏️  Write operation successful
    # 📝 Reactive File Event: FILE_MODIFIED  
    #    📄 File: reactive_output.txt
    # ✅ Reactive file operations completed
}

pf()

/*--- Multi-Directory Monitoring System

# Shows monitoring multiple directories with different configurations
# Key concepts: Multiple watchers, Watcher management, System coordination

pr()

Rs = new stzReactiveSystem()
Rs {
    # Setup multiple directories
    aDirs = ["./logs", "./configs", "./data"]
    
    for dir in aDirs
        if not isDir(dir)
            system("mkdir " + dir)
            ? "📁 Created directory: " + dir
        ok
    next

    # Create specialized watchers for different purposes
    
    # Logs watcher - only log files
    oLogOptions = new stzFileWatchOptions() {
        SetFilterType(FS_FILTER_CUSTOM)
        AddExtensions([".log", ".txt"])
    }
    
    oLogWatcher = CreateFileWatcher("./logs", oLogOptions)
    oLogWatcher {
        OnData(func fsEvent {
            ? "📊 LOG EVENT: " + fsEvent.GetFileName() + " - " + fsEvent.GetEventTypeText()
        })
        Start()
    }

    # Config watcher - configuration files
    oConfigOptions = new stzFileWatchOptions() {
        SetFilterType(FS_FILTER_CUSTOM)
        AddExtensions([".conf", ".ini", ".cfg", ".json"])
    }
    
    oConfigWatcher = CreateFileWatcher("./configs", oConfigOptions)
    oConfigWatcher {
        OnData(func fsEvent {
            ? "⚙️  CONFIG EVENT: " + fsEvent.GetFileName() + " - " + fsEvent.GetEventTypeText()
        })
        Start()
    }

    # Data watcher - all files recursively
    oDataOptions = new stzFileWatchOptions() {
        SetRecursive(TRUE)
        SetFilterType(FS_FILTER_ALL)
    }
    
    oDataWatcher = CreateFileWatcher("./data", oDataOptions)
    oDataWatcher {
        OnData(func fsEvent {
            ? "🗃️  DATA EVENT: " + fsEvent.GetFileName() + " - " + fsEvent.GetEventTypeText()
        })
        Start()
    }

    # Simulate activity across directories
    ? "Simulating multi-directory file activity..."
    write("./logs/application.log", "2025-01-15 14:23:15 - App started")
    write("./configs/database.conf", "host=localhost;port=3306")
    write("./data/users.csv", "id,name,email")
    
    sleep(200)
    
    # Additional activity
    write("./logs/error.log", "2025-01-15 14:23:20 - Error occurred")
    write("./configs/app.json", '{"debug": true, "port": 8080}')
    write("./data/temp.tmp", "temporary data")  # Will be detected by data watcher

    sleep(200)

    Start()
    #-->
    # 📁 Created directory: ./logs
    # 📁 Created directory: ./configs  
    # 📁 Created directory: ./data
    # Simulating multi-directory file activity...
    # 📊 LOG EVENT: application.log - FILE_CREATED
    # ⚙️  CONFIG EVENT: database.conf - FILE_CREATED
    # 🗃️  DATA EVENT: users.csv - FILE_CREATED
    # 📊 LOG EVENT: error.log - FILE_CREATED
    # ⚙️  CONFIG EVENT: app.json - FILE_CREATED
    # 🗃️  DATA EVENT: temp.tmp - FILE_CREATED
}

pf()

/*--- Error Handling and Recovery

# Demonstrates robust error handling in file system operations
# Key concepts: Error handling, Recovery strategies, Graceful degradation

pr()

Rs = new stzReactiveSystem()
Rs {
    # Test error scenarios

    # 1. Watching non-existent directory
    ? "Testing error handling scenarios..."
    
    oErrorWatcher = CreateFileWatcher("./non_existent_directory", NULL)
    oErrorWatcher {
        OnData(func fsEvent {
            ? "📊 Unexpected data: " + fsEvent.ToString()
        })

        OnError(func error {
            ? "❌ Expected error caught: " + error
            ? "   🔄 This is normal error handling behavior"
        })

        Start()
    }

    # 2. Reading non-existent file
    oErrorReader = CreateFileStream("./non_existent_file.txt")
    oErrorReader {
        OnData(func content {
            ? "📖 Unexpected content: " + content
        })

        OnError(func error {
            ? "❌ File read error caught: " + error
            ? "   🔄 Gracefully handling missing file"
        })

        ReadAll()
    }

    # 3. Writing to protected location (simulate)
    oErrorWriter = CreateFileStream("./readonly_test.txt")
    oErrorWriter {
        OnData(func result {
            ? "✏️  Write result: " + result
        })

        OnError(func error {
            ? "❌ Write error caught: " + error
            ? "   🔄 Could handle by retrying or using alternative location"
        })

        # First create the file normally
        WriteContent("Test content")
    }

    Start()
    #-->
    # Testing error handling scenarios...
    # ❌ Expected error caught: Failed to start file watcher: no such file or directory
    #    🔄 This is normal error handling behavior
    # ❌ File read error caught: File not found: ./non_existent_file.txt
    #    🔄 Gracefully handling missing file  
    # ✏️  Write result: write_success
}

pf()

/*--- Real-time File Processing Pipeline

# Shows a complete file processing pipeline with transformations
# Key concepts: Pipeline processing, Data transformation, Event coordination

pr()

Rs = new stzReactiveSystem()
Rs {
    # Create processing pipeline directory
    if not isDir("./pipeline")
        system("mkdir pipeline")
        system("mkdir pipeline/input")
        system("mkdir pipeline/output")
    ok

    # Input watcher - detects new files
    oInputWatcher = CreateFileWatcher("./pipeline/input", NULL)
    oInputWatcher {
        OnData(func fsEvent {
            if fsEvent.IsFileCreated()
                fileName = fsEvent.GetFileName()
                ? "🎬 Pipeline started for: " + fileName
                
                # Process the file
                processFile(fileName)
            ok
        })
        Start()
    }

    # File processor function
    processFile = func fileName {
        inputPath = "./pipeline/input/" + fileName
        outputPath = "./pipeline/output/processed_" + fileName
        
        # Read input file
        oReader = CreateFileStream(inputPath)
        oReader {
            OnData(func content {
                ? "📖 Processing content from: " + fileName
                
                # Transform content (simple example: uppercase)
                transformedContent = upper(content)
                
                # Write to output
                oWriter = CreateFileStream(outputPath)
                oWriter {
                    OnData(func result {
                        if result = "write_success"
                            ? "✅ Processed file saved: processed_" + fileName
                        ok
                    })
                    
                    WriteContent(transformedContent)
                }
            })
            
            ReadAll()
        }
    }

    # Simulate pipeline input
    ? "Starting file processing pipeline..."
    write("./pipeline/input/document1.txt", "hello world from reactive system")
    write("./pipeline/input/document2.txt", "another file to process")
    
    sleep(300)  # Give time for processing

    Start()
    #-->
    # Starting file processing pipeline...
    # 🎬 Pipeline started for: document1.txt
    # 📖 Processing content from: document1.txt
    # ✅ Processed file saved: processed_document1.txt
    # 🎬 Pipeline started for: document2.txt  
    # 📖 Processing content from: document2.txt
    # ✅ Processed file saved: processed_document2.txt
}

pf()

/*--- Watcher Management and Cleanup

# Demonstrates proper watcher lifecycle management
# Key concepts: Resource cleanup, Watcher control, System management

pr()

Rs = new stzReactiveSystem()
Rs {
    ? "Demonstrating watcher management..."
    
    # Create multiple watchers to manage
    aWatchers = []
    
    for i = 1 to 3
        dirName = "./managed_" + i
        if not isDir(dirName)
            system("mkdir " + dirName)
        ok
        
        oWatcher = CreateFileWatcher(dirName, NULL)
        oWatcher {
            OnData(func fsEvent {
                ? "📊 Watcher " + i + ": " + fsEvent.GetFileName()
            })
            Start()
        }
        
        aWatchers + oWatcher
        ? "✅ Started watcher " + i + " for " + dirName
    next

    # Test watchers
    write("./managed_1/test1.txt", "content 1")
    write("./managed_2/test2.txt", "content 2") 
    write("./managed_3/test3.txt", "content 3")
    
    sleep(200)
    
    # Demonstrate watcher control
    ? "--- Stopping watcher 2 ---"
    aWatchers[2].Stop()
    
    # Test after stopping one watcher
    write("./managed_1/test1b.txt", "more content 1")  # Will trigger
    write("./managed_2/test2b.txt", "more content 2")  # Won't trigger  
    write("./managed_3/test3b.txt", "more content 3")  # Will trigger
    
    sleep(200)
    
    # Get active watchers
    ? "--- Active watchers check ---"
    nActive = 0
    for i = 1 to len(aWatchers)
        if aWatchers[i].IsActive()
            nActive++
            ? "✅ Watcher " + i + " is active"
        else
            ? "❌ Watcher " + i + " is stopped"
        ok
    next
    
    ? "Total active watchers: " + nActive

    # Cleanup all watchers
    ? "--- Cleaning up all watchers ---"
    for i = 1 to len(aWatchers)
        aWatchers[i].Stop()
    next
    
    ? "✅ All watchers stopped"

    Start()
    #-->
    # Demonstrating watcher management...
    # ✅ Started watcher 1 for ./managed_1
    # ✅ Started watcher 2 for ./managed_2  
    # ✅ Started watcher 3 for ./managed_3
    # 📊 Watcher 1: test1.txt
    # 📊 Watcher 2: test2.txt
    # 📊 Watcher 3: test3.txt
    # --- Stopping watcher 2 ---
    # 📊 Watcher 1: test1b.txt
    # 📊 Watcher 3: test3b.txt
    # --- Active watchers check ---
    # ✅ Watcher 1 is active
    # ❌ Watcher 2 is stopped
    # ✅ Watcher 3 is active  
    # Total active watchers: 2
    # --- Cleaning up all watchers ---
    # ✅ All watchers stopped
}

pf()

/*===================================================================================

LEARNING SUMMARY - Softanza Reactive File System

===================================================================================

KEY CONCEPTS DEMONSTRATED:

1. **Basic File Watching**
   - Creating file watchers with CreateFileWatcher()
   - Handling file system events (create, modify, rename)
   - Reactive event subscription with OnData()

2. **Advanced Filtering**
   - Using stzFileWatchOptions for configuration
   - Extension-based filtering (text, images, custom)
   - Recursive directory monitoring

3. **File Content Streaming**
   - Reading files reactively with CreateFileStream()
   - Processing content line-by-line
   - Reactive file writing operations

4. **Error Handling**
   - Graceful error handling with OnError()
   - Recovery strategies for failed operations
   - Proper resource cleanup

5. **System Integration**
   - Multi-directory monitoring
   - File processing pipelines
   - Watcher lifecycle management

===================================================================================

PRACTICAL APPLICATIONS:

🔍 **Development Tools**: Monitor source code changes for auto-compilation
📊 **Log Analysis**: Real-time log file processing and alerting  
⚙️  **Configuration**: Automatic config reload when files change
🗃️  **Data Processing**: File-based ETL pipelines
🔄 **Backup Systems**: Incremental backup triggered by file changes
📁 **Asset Management**: Web asset compilation and optimization

===================================================================================

BEST PRACTICES:

✅ Always handle errors gracefully with OnError()
✅ Use appropriate filters to reduce noise
✅ Clean up watchers when done (Stop() method)
✅ Consider recursive watching for nested structures
✅ Test with actual file operations to verify behavior
✅ Use meaningful event handling logic
✅ Combine with other reactive streams for complex workflows

===================================================================================*/
