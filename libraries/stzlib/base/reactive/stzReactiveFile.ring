# SOFTANZA REACTIVE FILE SYSTEM

# File system event types
FS_EVENT_FILE_CREATED    = 1
FS_EVENT_FILE_MODIFIED   = 2 
FS_EVENT_FILE_RENAMED    = 3
FS_EVENT_UNKNOWN         = 999

# File system watcher states
FS_WATCHER_INACTIVE      = 0
FS_WATCHER_ACTIVE        = 1
FS_WATCHER_ERROR         = 2

# File system filter types
FS_FILTER_ALL            = "all"
FS_FILTER_TEXT           = "text"
FS_FILTER_IMAGES         = "images"
FS_FILTER_CUSTOM         = "custom"

# Global watcher registry for LibUV callbacks
aWatcherRegistry = []  # Will store [handleKey, watcherObject] pairs

# Global callback function for LibUV file system events
func OnGlobalFileSystemEvent()
    oCurrentWatcher = uv_get_current_handle()
    currentKey = ptr2str(oCurrentWatcher, 0, 16)
    
    nLen = len(aWatcherRegistry)
    for i = 1 to nLen
        if aWatcherRegistry[i][1] = currentKey
            oRingWatcher = aWatcherRegistry[i][2]
            oRingWatcher.ProcessFileSystemEvent()
            exit
        ok
    next

class stzReactiveFileSystem

    engine = NULL
    watchers = []
    filters = []

    def init(reactiveEngine)
        engine = reactiveEngine
        watchers = []
        filters = []

    def WatchFolder(path, options)
        if options = NULL
            options = new stzFileWatchOptions()
        ok
        
        watcherId = "fs_watcher_" + random(999999)
        watcher = new stzReactiveFileWatcher(watcherId, path, options, engine)
        
        watchers + watcher
        watcher.Start()
        
        return watcher

    def WatchFile(filePath, options)
        if options = NULL
            options = new stzFileWatchOptions()
        ok
        
        options.SetRecursive(FALSE)
        return WatchFolder(filePath, options)

    def CreateFileStream(filePath)
        streamId = "file_stream_" + random(999999)
        stream = new stzReactiveFileStream(streamId, filePath, engine)
        engine.AddStream(stream)
        return stream

    def CreateReactiveFile(filePath, content)
        if content = NULL
            content = ""
        ok
        
        write(filePath, content)
        return WatchFile(filePath, NULL)

    def RemoveWatcher(watcherId)
        nLen = len(watchers)
        for i = nLen to 1 step -1
            if watchers[i].GetId() = watcherId
                watchers[i].Stop()
                del(watchers, i)
                exit
            ok
        next

    def StopAllWatchers()
        nLen = len(watchers)
        for i = 1 to nLen
            watchers[i].Stop()
        next
        watchers = []

    def GetActiveWatchers()
        activeWatchers = []
        nLen = len(watchers)
        for i = 1 to nLen
            if watchers[i].IsActive()
                activeWatchers + watchers[i]
            ok
        next
        return activeWatchers

class stzReactiveFileWatcher

    # Core properties
    streamId = ""
    watchPath = ""
    watchOptions = NULL
    uvWatcher = NULL
    watcherState = FS_WATCHER_INACTIVE
    engine = NULL
    
    # Reactive stream properties
    subscribers = []
    isCompleted = FALSE
    errorCallback = NULL
    completeCallback = NULL
    
    def init(id, path, options, reactiveEngine)
        streamId = id
        watchPath = path
        watchOptions = options
        engine = reactiveEngine
        uvWatcher = NULL
        watcherState = FS_WATCHER_INACTIVE
        subscribers = []
        isCompleted = FALSE
        errorCallback = NULL
        completeCallback = NULL

    def Start()
        if watcherState = FS_WATCHER_ACTIVE
            return self
        ok

        # Create LibUV file system event handle
        uvWatcher = new_uv_fs_event_t()
        uv_fs_event_init(engine.LibuvLoop(), uvWatcher)

        # Register this watcher in the global registry for callback handling
        handleKey = ptr2str(uvWatcher, 0, 16)
	aWatcherRegistry + [handleKey, self]

        # Determine watch flags
        flags = 0  # Non-recursive by default
        if watchOptions != NULL and watchOptions.IsRecursive()
            flags = 1  # Recursive
        ok

        # Start watching with GLOBAL callback function
        result = uv_fs_event_start(uvWatcher, "OnGlobalFileSystemEvent()", watchPath, flags)

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
 
            # Remove from global registry
            nLen = len(aWatcherRegistry)
	    handleKey = ptr2str(uvWatcher, 0, 16)

	    for i = nLen to 1 step -1
		    if aWatcherRegistry[i][1] = handleKey
		        del(aWatcherRegistry, i)
		        exit
		    ok
	    next

            destroy_uv_fs_event_t(uvWatcher)
            uvWatcher = NULL
        ok

        return self

    def ProcessFileSystemEvent()
        # This method is called by the global callback function
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
            return
        ok
        
        # Emit the event to subscribers
        Emit(fsEvent)

    # Reactive stream methods
    def Subscribe(callback)
        if not find(subscribers, callback)
            subscribers + callback
        ok
        return self

    def OnData(callback)
        return Subscribe(callback)

    def OnError(callback)
        errorCallback = callback
        return self

    def OnComplete(callback)
        completeCallback = callback
        return self

    def Emit(data)
        nLen = len(subscribers)
        for i = 1 to nLen
            f = subscribers[i]
            call f(data)
        next
        return self

    def EmitError(errorMsg)
        if errorCallback != NULL
            call errorCallback(errorMsg)
        else
            see "File Watcher Error: " + errorMsg + nl
        ok
        return self

    def Complete()
        if completeCallback != NULL
            call completeCallback()
        ok
        return self

    # Getters
    def IsActive()
        return watcherState = FS_WATCHER_ACTIVE

    def GetPath()
        return watchPath

    def GetId()
        return streamId

class stzReactiveFileStream

    # Core properties - no inheritance, just composition
    streamId = ""
    filePath = ""
    fileHandle = NULL
    engine = NULL
    subscribers = []
    isCompleted = FALSE
    
    def init(id, path, reactiveEngine)
        streamId = id
        filePath = path
        engine = reactiveEngine
        fileHandle = NULL
        subscribers = []
        isCompleted = FALSE

    def ReadAll()
        if isFile(filePath)
            content = read(filePath)
            Emit(content)
            Complete()
        else
            EmitError("File not found: " + filePath)
        ok
        return self

    def ReadLines()
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
        try
            write(filePath, content)
            Emit("write_success")
            Complete()
        catch cErrorMsg
            EmitError("Write failed: " + cErrorMsg)
        done
        return self

    # Essential reactive methods
    def Subscribe(callback)
        if not find(subscribers, callback)
            subscribers + callback
        ok
        return self

    def Emit(data)
        if isCompleted
            return self
        ok
        
        nLen = len(subscribers)
        for i = 1 to nLen
	    f = subscribers[i]
            call f(data)
        next
        return self

    def EmitMany(dataList)
        nLen = len(dataList)
        for i = 1 to nLen
            Emit(dataList[i])
        next
        return self

    def Complete()
        isCompleted = TRUE
        return self

    def EmitError(errorMsg)
        see "File Stream Error: " + errorMsg + nl
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
        eventTypeText = InterpretEventType(eventCode)

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

    def InterpretEventType(eventCode)
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
                return TRUE
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
