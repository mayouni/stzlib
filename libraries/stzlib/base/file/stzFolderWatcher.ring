load "libuv.ring"

? "=== File System oWatcher using RingLibuv ==="
? "This program will monitor a folder for file changes"
? "Try creating, modifying, or deleting files in the watched folder"
? "Press Ctrl+C to stop the program" + NL


# Global variables to hold our handles and loop

oLibuvLoop = NULL
oWatcher = NULL

# Create this subfolder in the same folder as the file holding this code
cWatchPath = "./watch"

func main

    # Step 1: Initialize the event loop
    # The event loop is the heart of asynchronous programming
    # It manages all the events and callbacks

    oLibuvLoop = uv_default_loop()
    ? "Step 1: Event loop initialized"
   
    
    # Step 2: Set up the file system oWatcher
    SetupFileoWatcher()

    # Step 3: Start the event loop
    # This is where the magic happens - the loop runs indefinitely,
    # waiting for file system events and calling our callback when they occur

    ? "Step 4: Starting event loop - watching for file changes..."
    ? "Monitoring folder: " + cWatchPath + NL
    
    uv_run(oLibuvLoop, UV_RUN_DEFAULT)
    
    # Step 4: Cleanup (this runs when the loop exits)
    cleanup()

func SetupFileoWatcher

    # Create a new file system event handle
    # This is like creating a "listener" that can detect file changes

    oWatcher = new_uv_fs_event_t()
    ? "Step 2: File system oWatcher handle created"
    
    # Initialize the oWatcher with our event loop
    # This connects our oWatcher to the main event system

    uv_fs_event_init(oLibuvLoop, oWatcher)
    ? "Step 3: oWatcher initialized with event loop"
    
    # Start watching the specified path
    # UV_FS_EVENT_RECURSIVE means we'll also watch subdirectories
    # The callback function "OnFileChange()" will be called when events occur

    result = uv_fs_event_start(oWatcher, "OnFileChange()", cWatchPath, UV_FS_EVENT_RECURSIVE)
    
    if result != 0
        ? "Error starting file oWatcher: " + uv_strerror(result)
        return false
    ok
    
    return true

func OnFileChange

    # This function is called whenever a file system event occurs
    # Let's extract the event information
    
    # Get event parameters - this contains information about what happened
    aEventParams = uv_Eventpara(oWatcher, :fs_event)
    
    # Extract the filename and event type
    cFileName = aEventParams[2]  # The name of the file that changed
    cEventCode = aEventParams[3]    # The type of event (created, modified, deleted, etc.)
    
    ? "📁 FILE SYSTEM EVENT DETECTED!"
    ? "   Time: " + TimeList()[1] + ":" + TimeList()[2] + ":" + TimeList()[3]
    ? "   File: " + cFileName
    ? "   Event Type Code: " + cEventCode
    
    # Interpret the event type
    # Different numbers represent different types of changes

    InterpretEventType(cEventCode)
    ? "   Full Path: " + cWatchPath + "/" + cFileName
    ? "   " + copy("-", 50)  # Visual separator

func InterpretEventType(cEventCode)

    # File system events are represented by numbers
    # Let's translate them into human-readable descriptions
    
    switch cEventCode
    case 1
        ? "   📄 Event: FILE RENAMED/MOVED"
    case 2  
        ? "   ✏️  Event: FILE CONTENT CHANGED"
    case 3
        ? "   🔄 Event: FILE RENAMED AND CONTENT CHANGED"
    other
        ? "   ❓ Event: UNKNOWN EVENT TYPE (" + cEventCode + ")"
    off
    
    # Additional context about what these events mean:
    # - RENAME events occur when you create, delete, or move files
    # - CHANGE events occur when you modify the contents of existing files
    # - Combined events can happen during certain operations

func Cleanup()
    # Proper cleanup is important in system programming
    # Always clean up resources when you're done with them
    
    ? ""
    ? "Cleaning up resources..."
    
    if oWatcher != NULL
        # Stop the file oWatcher
        uv_fs_event_stop(oWatcher)
        # Destroy the oWatcher handle
        destroy_uv_fs_event_t(oWatcher)
        ? "✅ File oWatcher cleaned up"
    ok
    
    ? "Program ended successfully"

/*
=== HOW TO USE THIS PROGRAM ===

1. Run this program
2. Open Windows Explorer and navigate to the 'test_folder' directory
3. Try these actions to see events:
   - Create a new text file
   - Edit the sample.txt file and save it
   - Rename a file
   - Delete a file
   - Create a new folder

=== UNDERSTANDING THE OUTPUT ===

When you see events, here's what they mean:

Event Type 1 (RENAME): 
- Triggered when files are created, deleted, or renamed
- This includes drag-and-drop operations

Event Type 2 (CHANGE):
- Triggered when file contents are modified
- This happens when you save changes to an existing file

Event Type 3 (RENAME + CHANGE):
- Sometimes both events happen together
- Common during certain file operations

=== LEARNING POINTS ===

1. **Asynchronous Nature**: Notice how the program doesn't freeze while waiting
   for file changes. It responds immediately to events while staying responsive.

2. **Event-Driven Programming**: Your code only runs when something interesting
   happens (a file changes), rather than constantly checking.

3. **Callback Functions**: The onFileChange() function is a "callback" - 
   the system calls it back when events occur.

4. **Resource Management**: Always clean up system resources (handles, oWatchers)
   when you're done with them.

=== COMMON FILE OPERATIONS AND THEIR EVENTS ===

- Creating a file: RENAME event
- Editing and saving a file: CHANGE event  
- Deleting a file: RENAME event
- Moving a file: RENAME event
- Copying a file: RENAME event (for the new copy)

*/
