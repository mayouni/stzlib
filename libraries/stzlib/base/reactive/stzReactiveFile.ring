# SOFTANZA REACTIVE FILE SYstEM

# File system event types (softanzified names)
FS_EVENT_FILE_CREATED    = 1    # File was created or moved into directory
FS_EVENT_FILE_MODIFIED   = 2    # File content was changed
FS_EVENT_FILE_RENAMED    = 3    # File was renamed and content changed
FS_EVENT_UNKNOWN         = 999  # Unknown or unsupported event

# File system watcher states
FS_WATCHER_INACTIVE      = 0    # Watcher is stopped
FS_WATCHER_ACTIVE        = 1    # Watcher is running
FS_WATCHER_ERROR         = 2    # Watcher encountered error

# File system operation types
FS_OP_CREATE_FILE        = "create_file"
FS_OP_MODIFY_FILE        = "modify_file"
FS_OP_DELETE_FILE        = "delete_file"
FS_OP_RENAME_FILE        = "rename_file"
FS_OP_CREATE_DIRECTORY   = "create_directory"
FS_OP_DELETE_DIRECTORY   = "delete_directory"

# File system watcher options
FS_WATCH_RECURSIVE       = 1    # Watch subdirectories recursively
FS_WATCH_NON_RECURSIVE   = 0    # Watch only the specified directory

# File system filter types
FS_FILTER_ALL            = "all"        # Watch all file types
FS_FILTER_TEXT           = "text"       # Watch only text files
FS_FILTER_IMAGES         = "images"     # Watch only image files
FS_FILTER_CUSTOM         = "custom"     # Use custom extension filter



class stzReactiveFileSystem

    # Core properties
    engine = NULL           # Reference to main reactive engine
    watchers = []          # List of active file watchers
    filters = []           # List of file filters

    def init(reactiveEngine)
        engine = reactiveEngine
        watchers = []
        filters = []

    #--------------------------#
    #  FILE SYSTEM WATCHING    #
    #--------------------------#

    def WatchFolder(path, options)
        # Creates a reactive file watcher for the specified path
        # Returns a file watcher stream that emits file system events
        
        if options = NULL
            options = new stzFileWatchOptions()
        ok
        
        watcherId = "fs_watcher_" + random(999999)
        watcher = new stzReactiveFileWatcher(watcherId, path, options, engine)
        
        watchers + watcher
        watcher.Start()
        
        return watcher

        #< @FunctionAlternativeForms
        def WatchDirectory(path, options)
            return This.WatchFolder(path, options)
            
        def Watch(path, options)
            return This.WatchFolder(path, options)
        #>

    def WatchFile(filePath, options)
        # Creates a reactive watcher for a specific file
        if options = NULL
            options = new stzFileWatchOptions()
        ok
        
        # For single files, disable recursive watching
        options.SetRecursive(FALSE)
        
        return WatchFolder(filePath, options)

    def CreateFileStream(filePath)
        # Creates a reactive stream for reading file content
        streamId = "file_stream_" + random(999999)
        stream = new stzReactiveFileStream(streamId, filePath, engine)
        engine.AddStream(stream)
        return stream

    #--------------------------#
    #  FILE SYSTEM OPERATIONS  #
    #--------------------------#

    def CreateReactiveFile(filePath, content)
        # Creates a file reactively and returns a stream for monitoring it
        if content = NULL
            content = ""
        ok
        
        # Create the file synchronously first
        write(filePath, content)
        
        # Return a watcher stream for the created file
        return WatchFile(filePath, NULL)

    def RemoveWatcher(watcherId)
        # Removes a file watcher by ID
        nLen = len(watchers)
        for i = nLen to 1 step -1
            if watchers[i].GetId() = watcherId
                watchers[i].Stop()
                del(watchers, i)
                exit
            ok
        next

    def StopAllWatchers()
        # Stops all active file watchers
        nLen = len(watchers)
        for i = 1 to nLen
            watchers[i].Stop()
        next
        watchers = []

    def GetActiveWatchers()
        # Returns list of active watchers
        activeWatchers = []
        nLen = len(watchers)
        for i = 1 to nLen
            if watchers[i].IsActive()
                activeWatchers + watchers[i]
            ok
        next
        return activeWatchers



class stzReactiveFileWatcher from stzReactiveStream

    # Watcher-specific properties
    watchPath = ""
    watchOptions = NULL
    uvWatcher = NULL
    watcherState = FS_WATCHER_INACTIVE
    
    def init(id, path, options, engine)
        # Initialize the parent stream
        streamId = id
        sourceType = STREAM_SOURCE_FILE
      
        watchPath = path
        watchOptions = options
        uvWatcher = NULL
        watcherState = FS_WATCHER_INACTIVE

    def Start()
        if watcherState = FS_WATCHER_ACTIVE
            return self
        ok
        
        # Call parent Start() method
        super.Start()
        
        # Create LibUV file system event handle
        uvWatcher = new_uv_fs_event_t()
        uv_fs_event_init(super.engine.LibuvLoop(), uvWatcher)
        
        # Determine watch flags
        flags = FS_WATCH_NON_RECURSIVE
        if watchOptions != NULL and watchOptions.IsRecursive()
            flags = FS_WATCH_RECURSIVE
        ok
        
        # Start watching with callback
        result = uv_fs_event_start(uvWatcher, "OnFileSystemEvent()", watchPath, flags)
        
        if result != 0
            watcherState = FS_WATCHER_ERROR
            EmitError("Failed to start file watcher: " + uv_strerror(result))
            return self
        ok
        
        watcherState = FS_WATCHER_ACTIVE
        return self

    def Stop()
        if watcherState = FS_WATCHER_INACTIVE
            return self
        ok
        
        watcherState = FS_WATCHER_INACTIVE
        
        if uvWatcher != NULL
            uv_fs_event_stop(uvWatcher)
            destroy_uv_fs_event_t(uvWatcher)
            uvWatcher = NULL
        ok
        
        # Call parent Stop() method  
        stzReactiveStream.Stop()
        return self

    def OnFileSystemEvent()
        # Callback function for LibUV file system events
        if watcherState != FS_WATCHER_ACTIVE
            return
        ok
        
        # Extract event information from LibUV
        eventPara = uv_Eventpara(uvWatcher, :fs_event)
        filename = eventPara[2]
        eventType = eventPara[3]
        
        # Create file system event object
        fsEvent = new stzFileSystemEvent(filename, eventType, watchPath)
        
        # Apply file filters if configured
        if watchOptions != NULL and not watchOptions.PassesFilter(filename)
            return  # Skip filtered files
        ok
        
        # Emit the processed event to subscribers
        Emit(fsEvent)

    def IsActive()
        return watcherState = FS_WATCHER_ACTIVE

    def GetPath()
        return watchPath

    def GetId()
        return streamId



class stzReactiveFileStream from stzReactiveStream

    filePath = ""
    fileHandle = NULL
    readBuffer = NULL
    
    def init(id, path, engine)
        # Initialize the parent stream
        streamId = id
        sourceType = STREAM_SOURCE_FILE
        This.Init(id, sourceType, engine)
        
        filePath = path
        fileHandle = NULL
        readBuffer = NULL

    def ReadAll()
        # Reads entire file content and emits it
        if isFile(filePath)
            content = read(filePath)
            Emit(content)
            Complete()
        else
            EmitError("File not found: " + filePath)
        ok
        return self

    def ReadLines()
        # Reads file line by line and emits each line
        if isFile(filePath)
            content = read(filePath)
            lines = str2list(content)
            EmitMany(lines)
            Complete()
        else
            EmitError("File not found: " + filePath)
        ok
        return self

    def WriteContent(content)
        # Writes content to file and emits success/error
        try
            write(filePath, content)
            Emit("write_success")
            Complete()
        catch cErrorMsg
            EmitError("Write failed: " + cErrorMsg)
        done
        return self



class stzFileSystemEvent

    fileName = ""
    eventType = FS_EVENT_UNKNOWN
    eventTypeText = ""
    fullPath = ""
    timestamp = ""
    watchPath = ""

    def init(filename, eventCode, basePath)
        fileName = filename
        eventType = eventCode
        watchPath = basePath
        fullPath = basePath + "/" + filename
        timestamp = Time() + " " + Date()
        eventTypeText = InterpreteventType(eventCode)

    def GetFileName()
        return fileName

    def GetEventType() 
        return eventType

    def GetEventTypeText()
        return eventTypeText

    def GetFullPath()
        return fullPath

    def GetTimestamp()
        return timestamp

    def IsFileCreated()
        return eventType = FS_EVENT_FILE_CREATED

    def IsFileModified()
        return eventType = FS_EVENT_FILE_MODIFIED

    def IsFileRenamed()
        return eventType = FS_EVENT_FILE_RENAMED

    def ToString()
        return "FileSystemEvent{" + 
               "file='" + fileName + "', " +
               "event='" + eventTypeText + "', " +
               "path='" + fullPath + "', " +
               "time='" + timestamp + "'}"

    private

    def InterpreteventType(eventCode)
        # Converts numeric event codes to readable text
        switch eventCode
        case FS_EVENT_FILE_CREATED
            return "FILE_CREATED"
        case FS_EVENT_FILE_MODIFIED  
            return "FILE_MODIFIED"
        case FS_EVENT_FILE_RENAMED
            return "FILE_RENAMED"
        other
            return "UNKNOWN_EVENT"
        end



class stzFileWatchOptions

    recursive = FALSE
    fileExtensions = []
    filterType = FS_FILTER_ALL
    ignoreHidden = TRUE
    
    def init()
        recursive = FALSE
        fileExtensions = []
        filterType = FS_FILTER_ALL
        ignoreHidden = TRUE

    def SetRecursive(isRecursive)
        recursive = isRecursive
        return self

    def IsRecursive()
        return recursive

    def AddExtension(extension)
        if not find(fileExtensions, extension)
            fileExtensions + extension
        ok
        return self

    def AddExtensions(extensions)
        nLen = len(extensions)
        for i = 1 to nLen
            AddExtension(extensions[i])
        next
        return self

    def SetFilterType(type)
        filterType = type
        return self

    def SetIgnoreHidden(ignore)
        ignoreHidden = ignore
        return self

    def PassesFilter(fileName)
        # Check if file passes the configured filters
        
        # Skip hidden files if configured
        if ignoreHidden and left(fileName, 1) = "."
            return FALSE
        ok
        
        # Apply extension filters
        switch filterType
        case FS_FILTER_ALL
            return TRUE
            
        case FS_FILTER_TEXT
            textExtensions = [".txt", ".log", ".md", ".ring", ".py", ".js", ".html", ".css"]
            return PassesExtensionFilter(fileName, textExtensions)
            
        case FS_FILTER_IMAGES
            imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg"]
            return PassesExtensionFilter(fileName, imageExtensions)
            
        case FS_FILTER_CUSTOM
            if len(fileExtensions) = 0
                return TRUE  # No custom extensions specified, allow all
            ok
            return PassesExtensionFilter(fileName, fileExtensions)
            
        other
            return TRUE
        end

    private

    def PassesExtensionFilter(fileName, extensions)
        nLen = len(extensions)
        for i = 1 to nLen
            if right(lower(fileName), len(extensions[i])) = lower(extensions[i])
                return TRUE
            ok
        next
        return FALSE
