

class stzReactiveStream

	streamId = ""
	sourceType = STREAM_SOURCE_MANUAL
	dataBuffer = []
	subscribers = []
	errorHandlers = []
	completeHandlers = []
	engine = NULL
	isActive = STREAM_STATE_INACTIVE
	isCompleted = STREAM_STATE_RUNNING

	# Transformation functions to apply
	transforms = []
	
	# Buffer configuration
	maxBufferSize = BUFFER_STRATEGY_UNLIMITED
	bufferStrategy = BUFFER_STRATEGY_DROP_OLDEST

	# LibUV handle (only for libuv-backed streams)
	uvHandle = NULL

	def Init(id, sourceType, engine)
		streamId = id
		
		# Validate source type with expressive constants
		if not ( find([
				STREAM_SOURCE_MANUAL, STREAM_SOURCE_LIBUV, 
		                STREAM_SOURCE_TIMER, STREAM_SOURCE_FILE,
		                STREAM_SOURCE_NETWORK, STREAM_SOURCE_SENSOR], sourceType ) )

			sourceType = STREAM_SOURCE_MANUAL
		ok
		
		this.sourceType = sourceType
		this.engine = engine
		dataBuffer = []
		subscribers = []
		errorHandlers = []
		completeHandlers = []
		transforms = []
		isActive = STREAM_STATE_ACTIVE
		isCompleted = STREAM_STATE_RUNNING

	# Store map transformation with expressive constant
	def Map(mapFunction)
		transforms + [TRANSFORM_MAP, mapFunction]
		return self
		
	# Store filter transformation with expressive constant
	def Filter(filterFunction)
		transforms + [TRANSFORM_FILTER, filterFunction]
		return self
		
	# Store reduce transformation with expressive constant
	def Reduce(reduceFunction, initialValue)
		transforms + [TRANSFORM_REDUCE, reduceFunction, initialValue]
		return self
		
	# Store debounce transformation
	def Debounce(delayMs)
		transforms + [TRANSFORM_DEBOUNCE, delayMs]
		return self
		
	# Store throttle transformation  
	def Throttle(intervalMs)
		transforms + [TRANSFORM_THROTTLE, intervalMs]
		return self
		
	# Store distinct transformation
	def Distinct()
		transforms + [TRANSFORM_DISTINCT]
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
		
		# Apply buffer strategy if needed
		ManageBuffer(data)
		
		# Apply transforms
		processedData = [data]
		nLenTrans = len(transforms)

		for i = 1 to nLenTrans
			transformType = transforms[i][1]

			switch transformType
			case TRANSFORM_MAP
				mapFunc = transforms[i][2]
				processedData = @Map(processedData, mapFunc)

			case TRANSFORM_FILTER
				filterFunc = transforms[i][2]
				processedData = @Filter(processedData, filterFunc)

			case TRANSFORM_DISTINCT
				processedData = ApplyDistinct(processedData)
			end
		next
		
		# Emit to local subscribers
		nLenSub = len(subscribers)
		nLenData = len(processedData)

		for i = 1 to nLenSub
			subscriber = subscribers[i]
			for j = 1 to nLenData
				call subscriber(processedData[j])
			next
		next

	def EmitError(error)
		if not isActive or isCompleted
			return
		ok
		
		# Call error handlers
		nLenErr = len(errorHandlers)
		for i = 1 to nLenErr
			errorHandler = errorHandlers[i]
			call errorHandler(error)
		next

		# Stop the stream on error
		Stop()

	def Complete()
		if isCompleted
			return
		ok
		
		isCompleted = STREAM_STATE_COMPLETED
		
		# Apply final transformations to all buffered data if needed
		processedData = dataBuffer
		hasReduceTransform = STREAM_STATE_INACTIVE
		nLenTrans = len(transforms)

		for i = 1 to nLenTrans
			transformType = transforms[i][1]

			switch transformType
			case TRANSFORM_REDUCE
				reduceFunc = transforms[i][2]
				initialValue = transforms[i][3]
				processedData = [@Reduce(processedData, reduceFunc, initialValue)]
				hasReduceTransform = STREAM_STATE_ACTIVE
			end
		next
		
		# Only emit final reduced result if we had a reduce transform
		if hasReduceTransform
			nLenSub = len(subscribers)
			nLenData = len(processedData)

			for i = 1 to nLenSub
				subscriber = subscribers[i]

				for j = 1 to nLenData
					call subscriber(processedData[j])
				next
			next
		ok
		
		# Call completion handlers
		nLenHand = len(completeHandlers)

		for i = 1 to nLenHand
			completeHandler = completeHandlers[i]
			call completeHandler()
		next
		
		Stop()

	def End_()
		This.Complete()

	def Close()
		This.Complete()

	def Start()
		isActive = STREAM_STATE_ACTIVE
		isCompleted = STREAM_STATE_RUNNING
		return self
		
	def Stop()
		isActive = STREAM_STATE_INACTIVE
		return self
		
	def Cleanup()
		Stop()
		if uvHandle != NULL and sourceType = STREAM_SOURCE_LIBUV
			# Clean up LibUV resources
			uvHandle = NULL
		ok
		
	# Helper method to manage buffer based on strategy
	def ManageBuffer(data)
		if maxBufferSize = BUFFER_STRATEGY_UNLIMITED
			dataBuffer + data
			return
		ok
		
		if len(dataBuffer) >= maxBufferSize
			switch bufferStrategy
			case BUFFER_STRATEGY_DROP_OLDEST
				del(dataBuffer, 1)
				dataBuffer + data
			case BUFFER_STRATEGY_DROP_NEWEST
				# Don't add new data
			case BUFFER_STRATEGY_BLOCK
				# Could implement blocking behavior here
			end
		else
			dataBuffer + data
		ok
		
	# Helper method for distinct transformation
	def ApplyDistinct(data)
		seen = []
		result = []
		nLenData = len(data)

		for i = 1 to nLenData
			if not (find(seen, data[i]))
				seen + data[i]
				result + data[i]
			ok
		next

		return result
		
	# Configuration methods
	def SetBufferSize(size)
		maxBufferSize = size
		return self
		
	def SetBufferStrategy(strategy)
		if find([
			BUFFER_STRATEGY_DROP_OLDEST,
			BUFFER_STRATEGY_DROP_NEWEST,
			BUFFER_STRATEGY_BLOCK ], strategy)

			bufferStrategy = strategy
		ok
		return self
