#----------------------------------------------#
#  REACTIVE STREAM - For continuous data flow  #
#----------------------------------------------#

class stzReactiveStream

	streamId = ""
	sourceType = "manual"  # manual, libuv, timer
	dataBuffer = []
	subscribers = []
	errorHandlers = []
	completeHandlers = []
	engine = NULL
	isActive = false
	isCompleted = false

	# Transformation functions to apply
	transforms = []

	# LibUV handle (only for libuv-backed streams)
	uvHandle = NULL

	def Init(id, sourceType, engine)
		streamId = id
		this.sourceType = sourceType
		this.engine = engine
		dataBuffer = []
		subscribers = []
		errorHandlers = []
		completeHandlers = []
		transforms = []
		isActive = true
		isCompleted = false

	# Store map transformation
	def Map(mapFunction)
		transforms + [:map, mapFunction]
		return self
		
	# Store filter transformation
	def Filter(filterFunction)
		transforms + [:filter, filterFunction]
		return self
		
	# Store reduce transformation
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
	    if not isActive or isCompleted
	        return
	    ok
	    
	    dataBuffer + data
	    
	    # Apply transforms
	    processedData = [data]
	    for transform in transforms
	        transformType = transform[1]
	        switch transformType
	        case :map
	            mapFunc = transform[2]
	            processedData = @Map(processedData, mapFunc)
	        case :filter
	            filterFunc = transform[2]
	            processedData = @Filter(processedData, filterFunc)
	        end
	    next
	    
	    # Emit to local subscribers
	    for subscriber in subscribers
	        for item in processedData
	            call subscriber(item)
	        next
	    next


	def EmitError(error)
		if not isActive or isCompleted
			return
		ok
		
		# Call error handlers
		for errorHandler in errorHandlers
			call errorHandler(error)
		next
		
		# Stop the stream on error
		Stop()

	def Complete()
		if isCompleted
			return
		ok
		
		isCompleted = true
		
		# Apply final transformations to all buffered data if needed
		# (This allows for operations like Reduce that need all data)
		processedData = dataBuffer
		hasReduceTransform = false
		
		for transform in transforms
			transformType = transform[1]
			switch transformType
			case :reduce
				reduceFunc = transform[2]
				initialValue = transform[3]
				processedData = [ @Reduce(processedData, reduceFunc, initialValue)]
				hasReduceTransform = true
			end
		next
		
		# Only emit final reduced result if we had a reduce transform
		if hasReduceTransform
			for subscriber in subscribers
				for item in processedData
					call subscriber(item)
				next
			next
		ok
		
		# Call completion handlers
		for completeHandler in completeHandlers
			call completeHandler()
		next
		
		Stop()

		def End_()
			This.Complete()

		def Close()
			This.Complete()

	def Start()
		isActive = true
		isCompleted = false
		return self
		
	def Stop()
		isActive = false
		return self
		
	def Cleanup()
		Stop()
		if uvHandle != NULL and sourceType = "libuv"
			# Clean up LibUV resources
			uvHandle = NULL
		ok
