load "libuv.ring"

/*
=============================================================================
SOFTANZA FILE SYSTEM WATCHER API
=============================================================================
A generic file system monitoring library for the Softanza ecosystem.

Usage Example:

=============================================================================
*/

# Global state management
oFSWatcher_Loop = NULL
aFSWatcher_Watchers = []
aFSWatcher_Paths = []
cFSWatcher_GlobalHandler = ""
lFSWatcher_IsRunning = false
oFSWatcher_CurrentEvent = NULL

# Event type constants
FSWATCHER_EVENT_RENAME = 1
FSWATCHER_EVENT_CHANGE = 2
FSWATCHER_EVENT_RENAME_AND_CHANGE = 3

#---------#
# EXAMPLE #
#---------#

    # Initialize the watcher
    FSWatcher_Init()
    
    # Add paths to watch with custom callbacks
    FSWatcher_AddPath("./watch", "OnDocumentChange()")
 //   FSWatcher_AddPath("./config", "OnConfigChange()")
    
    # Set global event handler (optional)
    FSWatcher_SetGlobalHandler("OnAnyFileChange()")
    
    # Start monitoring
    FSWatcher_Start()
    
    # In your callbacks:
    func OnDocumentChange
        oEvent = FSWatcher_GetCurrentEvent()
        ? "Document changed: " + oEvent[:filename]
    end

#----------------------#
#  CORE API FUNCTIONS  #
#----------------------#

func FSWatcher_Init()

    # Initialize the file system watcher.
    # Must be called before using any other FSWatcher functions.

    if oFSWatcher_Loop != NULL
        FSWatcher_Cleanup()
    ok
    
    oFSWatcher_Loop = uv_default_loop()
    aFSWatcher_Watchers = []
    aFSWatcher_Paths = []
    lFSWatcher_IsRunning = false
    
    return true

func FSWatcher_AddPath(cPath, cCallback)

    # Add a path to watch with a specific callback function.
    
    # Parameters:
    #   cPath (string): Path to monitor
    #   cCallback (string): Function name to call on events
    
    # Returns:
    #   boolean: Success status

    if oFSWatcher_Loop = NULL
        ? "Error: FSWatcher not initialized. Call FSWatcher_Init() first."
        return false
    ok
    
    # Create new watcher handle
    oWatcher = new_uv_fs_event_t()
    uv_fs_event_init(oFSWatcher_Loop, oWatcher)
    
    # Start watching
    nResult = uv_fs_event_start(oWatcher, "FSWatcher_InternalCallback()", cPath, UV_FS_EVENT_RECURSIVE)
    
    if nResult != 0
        ? "Error watching path '" + cPath + "': " + uv_strerror(nResult)
        destroy_uv_fs_event_t(oWatcher)
        return false
    ok
    
    # Store watcher info
    aFSWatcher_Watchers + [oWatcher, cPath, cCallback]
    aFSWatcher_Paths + cPath
    
    return true

func FSWatcher_SetGlobalHandler(cCallback)

    # Set a global event handler that receives all file system events.
    
    # Parameters:
    #    cCallback (string): Function name for global event handling

    cFSWatcher_GlobalHandler = cCallback

func FSWatcher_Start()

    # Start the file system watcher event loop.
    # This function blocks until FSWatcher_Stop() is called.
    
    # Returns:
    #    boolean: Success status

    if oFSWatcher_Loop = NULL
        ? "Error: FSWatcher not initialized."
        return false
    ok
    
    if len(aFSWatcher_Watchers) = 0
        ? "Warning: No paths are being watched."
    ok
    
    lFSWatcher_IsRunning = true
    uv_run(oFSWatcher_Loop, UV_RUN_DEFAULT)
    
    return true

func FSWatcher_Stop()

    # Stop the file system watcher event loop.

    lFSWatcher_IsRunning = false
    if oFSWatcher_Loop != NULL
        uv_stop(oFSWatcher_Loop)
    ok

func FSWatcher_RemovePath(cPath)

    # Remove a path from monitoring.
    
    # Parameters:
    #    cPath (string): Path to stop monitoring
    
    # Returns:
    #    boolean: Success status

    for i = 1 to len(aFSWatcher_Watchers)
        aWatcherInfo = aFSWatcher_Watchers[i]
        if aWatcherInfo[2] = cPath  # Compare path
            # Stop and destroy watcher
            uv_fs_event_stop(aWatcherInfo[1])
            destroy_uv_fs_event_t(aWatcherInfo[1])
            
            # Remove from arrays
            del(aFSWatcher_Watchers, i)
            nPathIndex = find(aFSWatcher_Paths, cPath)
            if nPathIndex > 0
                del(aFSWatcher_Paths, nPathIndex)
            ok
            
            return true
        ok
    next
    
    return false

func FSWatcher_Cleanup()

    # Clean up all watchers and resources.
    #  Call this when shutting down your application.

    # Stop all watchers
    for aWatcherInfo in aFSWatcher_Watchers
        uv_fs_event_stop(aWatcherInfo[1])
        destroy_uv_fs_event_t(aWatcherInfo[1])
    next
    
    # Reset state
    aFSWatcher_Watchers = []
    aFSWatcher_Paths = []
    oFSWatcher_Loop = NULL
    lFSWatcher_IsRunning = false
    oFSWatcher_CurrentEvent = NULL


#----------------------------#
#  EVENT HANDLING FUNCTIONS  #
#----------------------------#

func FSWatcher_InternalCallback()

    # Internal callback function that processes file system events
    # and dispatches them to appropriate handlers.

    # Find which watcher triggered this event
    for aWatcherInfo in aFSWatcher_Watchers
        oWatcher = aWatcherInfo[1]
        cPath = aWatcherInfo[2]
        cCallback = aWatcherInfo[3]
        
        # Check if this watcher matches the current event
        aEventParams = uv_Eventpara(oWatcher, :fs_event)
        if len(aEventParams) >= 3
            # Create event object
            oFSWatcher_CurrentEvent = [
                :watcher = oWatcher,
                :path = cPath,
                :filename = aEventParams[2],
                :eventcode = aEventParams[3],
                :fullpath = cPath + "/" + aEventParams[2],
                :timestamp = time(),
                :eventtype = FSWatcher_GetEventTypeName(aEventParams[3])
            ]
            
            # Call specific callback if provided
            if cCallback != ""
                eval(cCallback)
            ok
            
            # Call global handler if set
            if cFSWatcher_GlobalHandler != ""
                eval(cFSWatcher_GlobalHandler)
            ok
            
            exit  # Found the matching watcher
        ok
    next

func FSWatcher_GetCurrentEvent()

    # Get the current event object with all event details.
    
    # Returns:
    #   object: Event details including path, filename, type, timestamp

    return oFSWatcher_CurrentEvent

func FSWatcher_GetEventTypeName(nEventCode)

    # Convert event code to human-readable string.
    
    # Parameters:
    #   nEventCode (number): Event type code
    
    # Returns:
    #   string: Event type name

    switch nEventCode
    case FSWATCHER_EVENT_RENAME
        return "RENAME"
    case FSWATCHER_EVENT_CHANGE
        return "CHANGE"
    case FSWATCHER_EVENT_RENAME_AND_CHANGE
        return "RENAME_AND_CHANGE"
    other
        return "UNKNOWN"
    off


#---------------------#
#  UTILITY FUNCTIONS  #
#---------------------#

func FSWatcher_IsRunning()

    # Check if the file system watcher is currently running.
    
    # Returns:
    #   boolean: Running status

    return lFSWatcher_IsRunning

func FSWatcher_GetWatchedPaths()

    # Get list of all currently watched paths.
    
    # Returns:
    #   List: List of watched paths

    return aFSWatcher_Paths

func FSWatcher_GetWatcherCount()

    # Get the number of active watchers.
    
    # Returns:
    #    number: Count of active watchers

    return len(aFSWatcher_Watchers)

func FSWatcher_PrintStatus()

    # Print current status of the file system watcher.
    # Useful for debugging.

    ? "=== FSWatcher Status ==="
    ? "Running: " + lFSWatcher_IsRunning
    ? "Active Watchers: " + len(aFSWatcher_Watchers)
    ? "Watched Paths:"
    for cPath in aFSWatcher_Paths
        ? "  - " + cPath
    next
    ? "Global Handler: " + cFSWatcher_GlobalHandler
    ? "======================="


#-------------------------#
#  CONVENIENCE FUNCTIONS  #
#-------------------------#


func FSWatcher_QuickStart(cPath, cCallback)

    # Quick start function - initialize, add path, and start watching.
    
    # Parameters:
    #    cPath (string): Path to monitor
    #   cCallback (string): Callback function name
    
    # Returns:
    #    boolean: Success status

    FSWatcher_Init()
    if FSWatcher_AddPath(cPath, cCallback)
        return FSWatcher_Start()
    ok
    return false

func FSWatcher_CreateEventLogger(cLogFile)

    # Create a simple event logger that writes events to a file.
    
    # Parameters:
    #   cLogFile (string): Path to log file
    
    # Returns:
    #    string: Function name for use as callback

    cLoggerFunc = '
    func FSWatcher_LogEvent_' + substr(cLogFile, "/\\", "_") + '()
        oEvent = FSWatcher_GetCurrentEvent()
        cLogEntry = "[" + date() + " " + time() + "] " +
                   oEvent[:eventtype] + ": " + oEvent[:fullpath] + nl
        write("' + cLogFile + '", cLogEntry)
    end'
    
    eval(cLoggerFunc)
    return "FSWatcher_LogEvent_" + substr(cLogFile, "/\\", "_") + "()"


func FSWatcher_InterpretEventType(cEventCode)

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
