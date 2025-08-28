
class stzReactiveStream

	streamId = ""
	sourceType = STREAM_SOURCE_MANUAL

	subscribers = []
	errorHandlers = []
	completeHandlers = []
	engine = NULL
	isActive = STREAM_STATE_INACTIVE
	isCompleted = STREAM_STATE_RUNNING

	# Transformation functions to apply
	transforms = []
	
	# Accumulator for reduce operations
	accumulator = NULL
	hasReduceTransform = STREAM_STATE_INACTIVE

	# LibUV handle (only for libuv-backed streams)
	uvHandle = NULL

	# Backpressure configuration
	bufferSize = 100
	backpressureStrategy = BACKPRESSURE_STRATEGY_BUFFER
	currentBufferCount = 0
	buffer = []
	isBackpressureActive = STREAM_STATE_INACTIVE
	droppedCount = 0
	
	# Backpressure callbacks
	backpressureHandlers = []
	bufferFullHandlers = []

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
		hasReduceTransform = STREAM_STATE_ACTIVE
		accumulator = initialValue
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
	
	# Override Emit to handle backpressure
	def Emit(data)
		if not isActive or isCompleted
			return
		ok
		
		# Check if buffer is at capacity BEFORE adding new data
		if currentBufferCount >= bufferSize
			HandleBackpressure(data)
			return
		ok
		
		# Add to buffer
		buffer + data
		currentBufferCount++
		
		# Process immediately for normal operation
		# Buffer only accumulates when backpressure
		# strategies are actively used
		ProcessBuffer()
	
	def EmitMany(paData)
		if not isList(paData)
			raise("Incorrect param type! paData must be a list.")
		ok

		nLen = len(paData)
		for i = 1 to nLen
			This.Emit(paData[i])
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
		
		# If we have a reduce transform, emit the final accumulated result
		if hasReduceTransform
			nLenSub = len(subscribers)
			for i = 1 to nLenSub
				subscriber = subscribers[i]
				call subscriber(accumulator)
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

	def SetBackpressureStrategy(strategy, maxBufferSize)
		if not find([BACKPRESSURE_STRATEGY_BUFFER, BACKPRESSURE_STRATEGY_DROP, 
		            BACKPRESSURE_STRATEGY_BLOCK, BACKPRESSURE_STRATEGY_LATEST], strategy)
			strategy = BACKPRESSURE_STRATEGY_BUFFER
		ok
		
		backpressureStrategy = strategy
		bufferSize = maxBufferSize
		return self

	def OnBackpressure(handler)
		backpressureHandlers + handler
		return self
		
	def OnBufferFull(handler)
		bufferFullHandlers + handler
		return self

	def HandleBackpressure(data)
		isBackpressureActive = STREAM_STATE_ACTIVE
		
		# Notify backpressure handlers
		nLenBack = len(backpressureHandlers)
		for i = 1 to nLenBack
			handler = backpressureHandlers[i]
			call handler(currentBufferCount, bufferSize)
		next
		
		switch backpressureStrategy
		case BACKPRESSURE_STRATEGY_BUFFER
			# Block until buffer has space (simulate)
			? "⚠️ Backpressure: Buffering data (buffer full: " + currentBufferCount + "/" + bufferSize + ")"
			
		case BACKPRESSURE_STRATEGY_DROP
			# Drop the new data
			droppedCount++
			? "⚠️ Backpressure: Dropping data item (dropped so far: " + droppedCount + ")"
			
		case BACKPRESSURE_STRATEGY_LATEST
			# Drop oldest, keep latest
			if len(buffer) > 0
				del(buffer, 1)  # Remove oldest
				currentBufferCount--
			ok
			buffer + data
			currentBufferCount++
			? "⚠️ Backpressure: Keeping latest, dropped oldest"
			
		case BACKPRESSURE_STRATEGY_BLOCK
			# In real implementation, this would block the producer
			? "⚠️ Backpressure: Would block producer (simulated)"
		end


	def ProcessBuffer()
		if len(buffer) = 0
			return
		ok
		
		# Get the next item from buffer
		data = buffer[1]
		del(buffer, 1)
		currentBufferCount--
		
		# Apply transforms (original Emit logic)
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
	
			case TRANSFORM_REDUCE
				# Handle reduce differently - accumulate but don't emit yet
				reduceFunc = transforms[i][2]
				nLenData = len(processedData)
				for j = 1 to nLenData
					accumulator = call reduceFunc(accumulator, processedData[j])
				next
				# Reset backpressure if buffer is no longer full
				if currentBufferCount < bufferSize and isBackpressureActive
					isBackpressureActive = STREAM_STATE_INACTIVE
				ok
				return
			end
		next
		
		# Only emit if we didn't encounter a reduce transform
		if not hasReduceTransform
			# Emit to local subscribers
			nLenSub = len(subscribers)
			nLenData = len(processedData)
	
			for i = 1 to nLenSub
				subscriber = subscribers[i]
				for j = 1 to nLenData
					call subscriber(processedData[j])
				next
			next
		ok
		
		# Reset backpressure if buffer is no longer full
		if currentBufferCount < bufferSize and isBackpressureActive
			isBackpressureActive = STREAM_STATE_INACTIVE
		ok


	def DrainBuffer()
		# Process all buffered items
		while len(buffer) > 0
			ProcessBuffer()
		end
		return self
		
	def GetBackpressureStats()
		return [
			:bufferSize = bufferSize,
			:currentBuffer = currentBufferCount,
			:isBackpressureActive = isBackpressureActive,
			:droppedCount = droppedCount,
			:strategy = backpressureStrategy
		]
