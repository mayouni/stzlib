# Softanza Reactive Programming System
# A simple, learnable reactive system using Ring's LibUV capabilities

load "libuv.ring"
load "objectslib.ring"

# =============================================================================
# CORE REACTIVE ENGINE
# =============================================================================

class stzReactiveEngine from ObjectControllerParent

    # Core engine state
    myLoop = NULL
    tasks = []
    streams = []
    timers = []
    isRunning = false
    
    def init
        myLoop = uv_default_loop()
        tasks = []
        streams = []
        timers = []
        isRunning = false
        
    def start
        if not isRunning
            isRunning = true
            uv_run(myLoop, UV_RUN_DEFAULT)
            isRunning = false
        ok
        
    def stop
        isRunning = false
        # Clean up all resources
        for task in tasks
            task.cleanup()
        next
        for stream in streams  
            stream.cleanup()
        next
        for timer in timers
            timer.cleanup()
        next
        
    def addTask(task)
        tasks + task
        
    def addStream(stream)
        streams + stream
        
    def addTimer(timer)
        timers + timer

# =============================================================================
# REACTIVE TASK - Core abstraction for async operations
# =============================================================================

class stzReactiveTask from ObjectControllerParent

    # Task properties
    taskId = ""
    taskFunc = NULL
    onComplete = NULL
    onError = NULL
    status = "pending"  # pending, running, completed, error
    result = NULL
    engine = NULL
    
    def init(id, f, engine)
        taskId = id
        taskFunc = f
        this.engine = engine
        status = "pending"
        
    def then_(completeFunc)
        onComplete = completeFunc
        return self
        
    def catch_(errorFunc)
        onError = errorFunc
        return self
        
    def execute
        try
            status = "running"
            if isString(taskFunc)
                result = call taskFunc()
            else
                result = call taskFunc()
            ok
            status = "completed"
            if onComplete != NULL
                call onComplete(result)
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("Task execution failed")
            ok
        done
        
    def cleanup
        # Override in subclasses for specific cleanup

# =============================================================================
# REACTIVE STREAM - For continuous data flow
# =============================================================================

class stzReactiveStream from ObjectControllerParent

    streamId = ""
    sourceFunc = NULL
    dataBuffer = []
    subscribers = []
    errorHandlers = []
    completeHandlers = []
    engine = NULL
    isActive = false
    
    # Transformation functions to apply at completion
    transforms = []
    
    def init(id, source, engine)
        streamId = id
        sourceFunc = source
        this.engine = engine
        dataBuffer = []
        subscribers = []
        errorHandlers = []
        completeHandlers = []
        transforms = []
        isActive = false
        
    # Store map transformation (Ring syntax: Map(list, function))
    def Map(mapFunction)
        transforms + [:map, mapFunction]
        return self
        
    # Store filter transformation (Ring syntax: Filter(list, function))
    def Filter(filterFunction)
        transforms + [:filter, filterFunction]
        return self
        
    # Store reduce transformation (Ring syntax: Reduce(list, function, initial))
    def Reduce(reduceFunction, initialValue)
        transforms + [:reduce, reduceFunction, initialValue]
        return self
        
    def Subscribe(subscriber)
        subscribers + subscriber
        return self
        
    def OnData(subscriber)
        return Subscribe(subscriber)
        
    def OnError(errorHandler)
        errorHandlers + errorHandler
        return self
        
    def OnComplete(completeHandler)
        completeHandlers + completeHandler
        return self
        
    def Emit(data)
        if not isActive
            return
        ok
        dataBuffer + data
        
    def Complete()
        try
            processedData = dataBuffer
            
            # Apply transforms in order using Ring's native functions
            for transform in transforms
                transformType = transform[1]
                switch transformType
                case :map
                    mapFunc = transform[2]
                    processedData = @Map(processedData, mapFunc)  # Ring's Softanzified Map(list, func)
                case :filter
                    filterFunc = transform[2]
                    processedData = @Filter(processedData, filterFunc)  # Ring's Softanzified Filter(list, func)
                case :reduce
                    reduceFunc = transform[2]
                    initialValue = transform[3]
                    processedData = [ @Reduce(processedData, reduceFunc, initialValue)]  # Ring's Softanzified Reduce(list, func, initial)
                end
            next

            # Emit results to subscribers
	  for subscriber in subscribers
	    for item in processedData
	        call subscriber(item)
	    next
	  next
            
        catch
            for errorHandler in errorHandlers
                call errorHandler("Error processing stream")
            next
        done
        
        # Call completion handlers
        for completeHandler in completeHandlers
            call completeHandler()
        next
        
        Stop()
        
    def Start()
        isActive = true
        return self
        
    def Stop()
        isActive = false
        return self

# =============================================================================
# REACTIVE TIMER - For time-based operations
# =============================================================================

class stzReactiveTimer from ObjectControllerParent

    timerId = ""
    interval = 1000  # milliseconds
    callback = NULL
    engine = NULL
    timerHandle = NULL
    isActive = false
    
    def init(id, intervalMs, f, engine)
        timerId = id
        interval = intervalMs
        callback = f
        this.engine = engine
        isActive = false
        
    def start
        if not isActive
            timerHandle = new_uv_timer_t()
            uv_timer_init(engine.myLoop, timerHandle)
            uv_timer_start(timerHandle, Method(:tick), 0, interval)
            isActive = true
        ok
        
    def stop
        if isActive and timerHandle != NULL
            uv_timer_stop(timerHandle)
            isActive = false
        ok
        
    def tick
        if callback != NULL
            call callback()
        ok
        
    def cleanup
        stop()
        if timerHandle != NULL
            destroy_uv_timer_t(timerHandle)
            timerHandle = NULL
        ok

# =============================================================================
# REACTIVE HTTP CLIENT - For web requests
# =============================================================================

class stzReactiveHttp from ObjectControllerParent

    engine = NULL
    
    def init(engine)
        this.engine = engine
        
    def get_(url, onSuccess, onError)
        task = new stzHttpTask("http_get", url, "GET", NULL, engine)
        task.then_(onSuccess)
        task.catch_(onError)
        engine.addTask(task)
        task.execute()
        return task
        
    def post(url, data, onSuccess, onError)
        task = new stzHttpTask("http_post", url, "POST", data, engine)
        task.then_(onSuccess)
        task.catch_(onError)
        engine.addTask(task)
        task.execute()
        return task

class stzHttpTask from stzReactiveTask

    url = ""
    method = "GET"
    data = NULL
    
    def init(id, url, method, data, engine)
        super.init(id, NULL, engine)
        this.url = url
        this.method = method
        this.data = data
        
    def execute
        # Use Ring's built-in HTTP capabilities or curl integration
        try
            status = "running"
            # Simulate HTTP request - in real implementation, use actual HTTP
            if method = "GET"
                result = performHttpGet(url)
            else
                result = performHttpPost(url, data)
            ok
            status = "completed"
            if onComplete != NULL
                call onComplete(result)
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("HTTP request failed")
            ok
        done
        
    # Helper methods for HTTP operations
    def performHttpGet(url)
        # Placeholder - implement with actual HTTP library
        return "GET response from " + url
        
    def performHttpPost(url, data)
        # Placeholder - implement with actual HTTP library  
        return "POST response from " + url

# =============================================================================
# REACTIVE FILE SYSTEM - For file operations
# =============================================================================

class stzReactiveFileSystem from ObjectControllerParent

    engine = NULL
    
    def init(engine)
        this.engine = engine
        
    def readFile(filePath, onSuccess, onError)
        task = new stzFileTask("file_read", filePath, "read", NULL, engine)
        task.then_(onSuccess)
        task.catch_(onError)
        engine.addTask(task)
        task.execute()
        return task
        
    def writeFile(filePath, content, onSuccess, onError)
        task = new stzFileTask("file_write", filePath, "write", content, engine)
        task.then_(onSuccess) 
        task.catch_(onError)
        engine.addTask(task)
        task.execute()
        return task
        
    def watchFile(filePath, onChange)
        watcher = new stzFileWatcher(filePath, onChange, engine)
        engine.addStream(watcher)
        watcher.start()
        return watcher

class stzFileTask from stzReactiveTask

    filePath = ""
    operation = "read"
    content = NULL
    
    def init(id, path, op, data, engine)
        super.init(id, NULL, engine)
        filePath = path
        operation = op
        content = data
        
    def execute
        try
            status = "running"
            if operation = "read"
                result = read(filePath)
            else
                write(filePath, content)
                result = "File written successfully"
            ok
            status = "completed"
            if onComplete != NULL
                call onComplete(result)
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("File operation failed")
            ok
        done

class stzFileWatcher from stzReactiveStream

    filePath = ""
    
    def init(path, changeCallback, engine)
        super.init("file_watch_" + path, NULL, engine)
        filePath = path
        subscribe(changeCallback)
        
    def start
        super.start()
        # In real implementation, use LibUV file system events
        # For now, simulate with timer-based polling
        watcher = new stzReactiveTimer("watcher_" + filePath, 1000, Method(:checkFile), engine)
        engine.addTimer(watcher)
        watcher.start()
        
    def checkFile
        # Simplified file change detection
        # In real implementation, use proper file system events
        emit("File changed: " + filePath)

# =============================================================================
# REACTIVE FUNCTION WRAPPER - Makes any function reactive
# =============================================================================

class stzReactiveFuncWrapper from ObjectControllerParent

    originalFunc = NULL
    engine = NULL
    
    def init(f, engine)
        originalFunc = f
        this.engine = engine
        
    def call_(params)
        task = new stzFunctionTask("func_call", originalFunc, params, engine)
        engine.addTask(task)
        return task
        
    def callAsync(params, onComplete, onError)
        task = new stzFunctionTask("func_call_async", originalFunc, params, engine)
        task.then_(onComplete)
        task.catch_(onError)
        engine.addTask(task)
        task.execute()
        return task

class stzFunctionTask from stzReactiveTask

    @f = NULL
    params = []
    
    def init(id, f, params, engine)
        super.init(id, NULL, engine)
        this.@f = f
        this.params = params
        
    def execute
        try
            status = "running"
            if len(params) = 0
                result = call @f()
            else
                # Handle parameters - Ring requires individual params
                switch len(params)
                case 1
                    result = call @f(params[1])
                case 2
                    result = call @f(params[1], params[2])
                case 3
                    result = call @f(params[1], params[2], params[3])
                # Add more cases as needed
                other
                    result = call @f() # Fallback
                end
            ok
            status = "completed"
            if onComplete != NULL
                call onComplete(result)
            ok
        catch
            status = "error"
            if onError != NULL
                call onError("Function execution failed")
            ok
        done

# =============================================================================
# MAIN REACTIVE API - Simple interface for common patterns
# =============================================================================

class stzReactive from ObjectControllerParent

    engine = NULL
    http = NULL
    fs = NULL
    
    def init
        engine = new stzReactiveEngine()
        engine.init()
        http = new stzReactiveHttp(engine)
        fs = new stzReactiveFileSystem(engine)
        
    def start
        engine.start()
        
    def stop
        engine.stop()
        
    # Make any function reactive
    def makeReactive(f)
        return new stzReactiveFuncWrapper(f, engine)
        
    # Create a reactive stream
    def createStream(id, source)
        stream = new stzReactiveStream(id, source, engine)
        engine.addStream(stream)
        return stream
        
    # Create a timer
    def createTimer(id, interval, callback)
        timer = new stzReactiveTimer(id, interval, callback, engine)
        engine.addTimer(timer)
        return timer
        
    # Create a task
    def createTask(id, f)
        task = new stzReactiveTask(id, f, engine)
        engine.addTask(task)
        return task
        
    # HTTP shortcuts
    def httpGet(url, onSuccess, onError)
        return http.get_(url, onSuccess, onError)
        
    def httpPost(url, data, onSuccess, onError)
        return http.post(url, data, onSuccess, onError)
        
    # File system shortcuts
    def readFile(path, onSuccess, onError)
        return fs.readFile(path, onSuccess, onError)
        
    def writeFile(path, content, onSuccess, onError)
        return fs.writeFile(path, content, onSuccess, onError)
        
    def watchFile(path, onChange)
        return fs.watchFile(path, onChange)
