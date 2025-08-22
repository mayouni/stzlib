load "../stzbase.ring"

/*
The examples in this file demonstrate Reactive File programming,
part of the Reactive Programming System of Softanza library for Ring.

In particular it shows:

1. Basic file operations with correct callback signatures
2. Directory operations using the filesystem API
3. File watching with proper event structures
4. Chaining operations with realistic error handling
5. Batch processing with completion tracking
6. Configuration management with fallback patterns
7. Custom reactive task creation using the task system
*/

/*
#------------------------------------------#
#  Example usage with expressive constants #
#------------------------------------------#

fs = new stzReactiveFileSystem()
fs.Init(reactiveEngine)

# Create directory with readable permissions
fs.CreateDir("/tmp/myapp", :DEFAULT_DIR,
    func(ok) { ? "Directory created" },
    func(err) { ? "Error: " + err }
)

# Check if file is readable and writable
fs.CheckAccess("/etc/passwd", :READ_WRITE,
    func(ok) { ? "File is readable and writable" },
    func(err) { ? "Access denied" }
)

# Change file to read-only
fs.ChangePermissions("/tmp/test.txt", :READ_ONLY,
    func(ok) { ? "File is now read-only" },
    func(err) { ? "Failed to change permissions" }
)

# Watch file with normal polling interval
fs.PollFile("/var/log/app.log", :NORMAL,
    func(event) { ? "File changed: " + event[:path] }
)

# Create symbolic link (default type)
fs.CreateSymbolicLink("/usr/bin/node", "/usr/local/bin/node", :DEFAULT,
    func(ok) { ? "Symlink created" },
    func(err) { ? "Failed: " + err }
)

# Update file timestamp to now
fs.UpdateFileTime("/tmp/touch.txt", "now", "now",
    func(ok) { ? "Timestamp updated" },
    func(err) { ? "Error: " + err }
)

# High-level convenience methods
fs.EnsureDir("/app/data", :USER_FULL,
    func(ok) { ? "Directory ready" },
    func(err) { ? "Failed: " + err }
)

fs.SafeWriteFile("/config/app.conf", configData,
    func(ok) { ? "Config written safely" },
    func(err) { ? "Write failed: " + err }
)
*/

/*--- Example 1: Basic file operations

pr()
? "=== Basic File Operations ==="

o1 = new stzReactive()

# Read a file
o1.ReadFile("test.txt", 
    func(content) { ? "File content: " + content },
    func(error) { ? "Read error: " + error }
)

# Write a file
o1.WriteFile("output.txt", "Hello World" + nl, 
    func(result) { ? "File written successfully: " + result },
    func(error) { ? "Write error: " + error }
)

# Append to file
o1.fs.AppendFile("output.txt", "Appended line" + nl,
    func(bytes) { ? "Appended " + bytes + " bytes" },
    func(error) { ? "Append error: " + error }
)

# Delete file
o1.fs.DeleteFile("temp.txt",
    func(result) { ? "File deleted: " + result },
    func(error) { ? "Delete error: " + error }
)

pf()

/*--- Example 2: Directory operations

pr()
? "=== Directory Operations ==="

o1 = new stzReactive()

# Create directory
o1.fs.CreateDir("test_dir", 493,
    func(result) { ? "Directory created: " + result },
    func(error) { ? "Create dir error: " + error }
)

# List directory contents
o1.fs.ListDir("./",
    func(result) { ? "Directory listing: " + result },
    func(error) { ? "List dir error: " + error }
)

# Remove directory
o1.fs.RemoveDir("old_dir",
    func(result) { ? "Directory removed: " + result },
    func(error) { ? "Remove dir error: " + error }
)

pf()

/*--- Example 3: File information and operations

pr()
? "=== File Information & Advanced Operations ==="

# Get file statistics
o1.fs.GetStat("test.txt",
    func(result) { ? "File stat retrieved: " + result },
    func(error) { ? "Stat error: " + error }
)

# Copy file
o1.fs.CopyFile("source.txt", "backup.txt",
    func(result) { ? "File copied: " + result },
    func(error) { ? "Copy error: " + error }
)

# Rename/move file
o1.fs.RenameFile("old_name.txt", "new_name.txt",
    func(result) { ? "File renamed: " + result },
    func(error) { ? "Rename error: " + error }
)

pf()

/*--- Example 4: File watching and monitoring

pr()
? "=== File Watching ==="

# Watch file changes (event-driven)
watcher = o1.WatchFile("config.json", func(event) {
    ? "File event detected:"
    ? "  Path: " + event[:path]
    ? "  Event: " + event[:event]
})

# Poll file changes (interval-based)
poller = o1.fs.PollFile("data.log", 2000, func(event) {
    ? "File poll event:"
    ? "  Path: " + event[:path]
    ? "  Event: " + event[:event]
})

# Stop watching after some time
o1.SetTimeout(10000, func() {
    watcher.Stop()
    poller.Stop()
    ? "File monitoring stopped"
})

pf()

/*--- Example 5: Chaining file operations

pr()
? "=== Chaining Operations ==="

# Chain multiple operations with reactive pattern
o1.ReadFile("input.txt",
    func(content) {
        # Process content and write to new file
        processedContent = "PROCESSED: " + content
        o1.WriteFile("processed.txt", processedContent,
            func(result) {
                ? "Write completed: " + result
                # Create backup after successful write
                o1.fs.CopyFile("processed.txt", "backup.txt",
                    func(result) {
                        ? "Complete chain: read → process → write → backup"
                        # Clean up temp file
                        o1.fs.DeleteFile("temp.txt",
                            func(result) { ? "Cleanup completed: " + result },
                            func(error) { ? "Cleanup failed: " + error }
                        )
                    },
                    func(error) { ? "Backup failed: " + error }
                )
            },
            func(error) { ? "Write failed: " + error }
        )
    },
    func(error) { 
        ? "Initial read failed: " + error 
        # Fallback: create default file
        o1.WriteFile("processed.txt", "DEFAULT CONTENT",
            func(result) { ? "Created default file: " + result },
            func(error) { ? "Fallback failed: " + error }
        )
    }
)

pf()

/*--- Example 6: Batch operations with error handling

pr()
? "=== Batch Operations ==="

files = ["file1.txt", "file2.txt", "file3.txt"]
results = []
errorCount = 0
successCount = 0

for fileName in files
    o1.ReadFile(fileName,
        func(content) {
            successCount++
            results + [fileName, "success", len(content)]
            ? fileName + " → " + len(content) + " bytes read"
            
            if successCount + errorCount = len(files)
                ? "Batch complete: " + successCount + " success, " + errorCount + " errors"
            ok
        },
        func(error) {
            errorCount++
            results + [fileName, "error", error]
            ? fileName + " → ERROR: " + error
            
            if successCount + errorCount = len(files)
                ? "Batch complete: " + successCount + " success, " + errorCount + " errors"
            ok
        }
    )
next

pf()

/*--- Example 7: Configuration file management

pr()
? "=== Configuration Management ==="

configPath = "app.config"

# Load configuration with fallback
loadConfig = func() {
    o1.ReadFile(configPath,
        func(content) {
            ? "Config loaded: " + content
            # Parse and apply configuration here
        },
        func(error) {
            ? "Config not found, creating default..."
            defaultConfig = "theme=dark" + nl + "lang=en" + nl + "debug=false" + nl
            o1.WriteFile(configPath, defaultConfig,
                func(result) { 
                    ? "Default config created: " + result
                    call loadConfig() # Reload the new config
                },
                func(error) { ? "Failed to create config: " + error }
            )
        }
    )
}

# Watch for config changes
configWatcher = o1.WatchFile(configPath, func(event) {
    ? "Configuration changed, reloading..."
    call loadConfig()
})

# Initial config load
call loadConfig()

pf()

/*--- Example 8: Error handling patterns

pr()
? "=== Error Handling Patterns ==="

# Try multiple file sources
fileSources = ["primary.txt", "backup.txt", "default.txt"]
currentIndex = 1

tryNextFile = func() {
    if currentIndex <= len(fileSources)
        fileName = fileSources[currentIndex]
        ? "Trying to read: " + fileName
        
        o1.ReadFile(fileName,
            func(content) {
                ? "Successfully read: " + fileName
                ? "Content: " + content
            },
            func(error) {
                ? "Failed to read " + fileName + ": " + error
                currentIndex++
                call tryNextFile()
            }
        )
    else
        ? "All file sources exhausted"
    ok
}

call tryNextFile()

pf()

/*--- Example 9: Reactive task creation

pr()
? "=== Custom Reactive Tasks ==="

# Create custom task using the task system
customTask = o1.CreateTask("custom_file_task", func() {
    # Custom file processing logic
    content = "Custom processed content" + nl
    return content
})

customTask.Then_(func(result) {
    ? "Custom task completed: " + result
    # Write result to file
    o1.WriteFile("custom_output.txt", result,
        func(writeResult) { ? "Custom result saved: " + writeResult },
        func(error) { ? "Save failed: " + error }
    )
}).Catch_(func(error) {
    ? "Custom task failed: " + error
})

customTask.Execute()

pf()

# Start the reactive system
? "Starting reactive system..."
o1.Start()
