

class stzReactiveStream from stzObject

	streamId = ""
	sourceType = STREAM_SOURCE_MANUAL

	aReactiveFuncs = []
	errorHandlers = []
	concludeHandlers = []
	engine = NULL
	isActive = STREAM_STATE_INACTIVE
	isConcluded = STREAM_STATE_RUNNING

	# Transformation functions to apply
	transforms = []
	
	# Accumulator for reduce operations
	accumulator = NULL
	hasReduceTransform = STREAM_STATE_INACTIVE

	# LibUV handle (only for libuv-backed streams)
	uvHandle = NULL

	# Overflow (backpressure) configuration
	bufferSize = 100
	overflowStrategy = :BUFFER
	currentBufferCount = 0
	buffer = []
	isOverflowActive = STREAM_STATE_INACTIVE
	droppedCount = 0
	
	# Overflow (backpressure) callbacks
	overflowHandlers = []
	bufferFullHandlers = []

	hasOverflowConfig = STREAM_STATE_INACTIVE

	autoConcludeEnabled = STREAM_STATE_ACTIVE
	pendingDataCount = 0
	autoConcludeDelay = 100  # milliseconds to wait for more data
	autoConcludeTimer = NULL

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
	def Transform(mapFunction)
		transforms + [TRANSFORM_MAP, mapFunction]
		return self

		def Map(mapFunction)
			return This.Transform(mapFunction)

	# Store filter transformation with expressive constant
	def Filter(filterFunction)
		transforms + [TRANSFORM_FILTER, filterFunction]
		return self

		def Where(filterFunction)
			return This.Filter(filterFunction)

	# Store reduce transformation with expressive constant
	def Accumulate(reduceFunction, initialValue)
		transforms + [TRANSFORM_REDUCE, reduceFunction, initialValue]
		hasReduceTransform = STREAM_STATE_ACTIVE
		accumulator = initialValue
		return self

		def Reduce(reduceFunction, initialValue)
			return This.Accumulate(reduceFunction, initialValue)

	def OnPassed(_Rf_)
		aReactiveFuncs + _Rf_
		return self

		def OnRecieved(_Rf_)
			return OnPassed(_Rf_)

		def Subscribe(_Rf_)
			return OnPassed(_Rf_)

		def OnNext(_Rf_)
			return OnPassed(_Rf_)

		def OnPass(_Rf_) # For if we forget it's OnPassed with "ed"
			return OnPassed(_Rf_)

	def OnError(errorHandler)
		errorHandlers + errorHandler
		return self

	def OnNoMore(concludeHandler)
		concludeHandlers + concludeHandler
		return self

		def OnComplete(completeHandler)
			return This.OnNoMore(completeHandler)

	def Recieve(data)
		if not isActive or isConcluded
			return
		ok
		
		# Increment pending data counter
		pendingDataCount++
		
		# Check if buffer is at capacity BEFORE adding new data
		if currentBufferCount >= bufferSize
		    HandleOverflow(data)
		    return
		ok
		
		# Add to buffer
		buffer + data
		currentBufferCount++
	
		# Process immediately if no overflow config
		if not hasOverflowConfig
		    ProcessAnItemFromBuffer()
		ok
		
		# Schedule auto-completion check if enabled
		if autoConcludeEnabled
			ScheduleAutoConclude()
		ok

		#< @FunctionAlternativeForms

		def Feed(data)
			return This.Recieve(data)

		def FeedWith(data)
			return This.Recieve(data)

		def Emit(data)
			return This.Recieve(data)

		def Send(data)
			return This.Recieve(data)

		#>

	def RecieveMany(paData)
		if not isList(paData)
			raise("Incorrect param type! paData must be a list.")
		ok
	
		_nLen_ = len(paData)
		for i = 1 to _nLen_
			This.Emit(paData[i])
		next
	
		# Process buffer after batch emission
		ProcessAnItemFromBuffer()
		
		# Auto-conclude after processing batch if enabled
		if autoConcludeEnabled
			AutoConclude()
		ok

		#< @FunctionAlternativeForms

		def FeedMany(paData)
			return This.RecieveMany(paData)

		def FeedWithMany(paData)
			return This.RecieveMany(paData)

		def SendMany(paData)
			return This.RecieveMany(paData)

		def EmitMany(paData)
			return This.RecieveMany(paData)

		#>


	def SetAutoConcludeXT(enable, delay)
		This.SetAutoConclude(enable)
		This.SetAutoConcludeDelay(delay)
		return self

	def SetAutoConclude(enabled)
		autoConcludeEnabled = enabled
		
		# Cancel any pending timer if disabling
		if not enabled and autoConcludeTimer != NULL
			engine.TimerManager().RemoveTimer(autoConcludeTimer.timerId)
			autoConcludeTimer = NULL
		ok
		
		return self

	
		def SetAutoComplete(enabled)
			return This.SetAutoConclude(enabled)

	# Set the delay before auto-conclusion triggers
	def SetAutoConcludeDelay(pnMilliseconds)
		autoConcludeDelay = pnMilliseconds
		return self

	# Real-world timer implementation for auto-conclusion
	def ScheduleAutoConclude()
		# Cancel existing timer if running
		if autoConcludeTimer != NULL
			engine.timerManager.RemoveTimer(autoConcludeTimer.timerId)
			autoConcludeTimer = NULL
		ok
		
		# Create one-time timer using existing timer system
		_timerId_ = "autoconclude_" + streamId + "_" + random(9999)
		autoConcludeTimer = new stzRingTimer(_timerId_, autoConcludeDelay, func() {
			# Timer callback - check if we should auto-conclude
			if pendingDataCount = 0 and autoConcludeEnabled
				AutoConclude()
			ok
			autoConcludeTimer = NULL  # Clean up timer reference
		}, engine, true, self)  # true = one-time timer
		
		engine.timerManager.AddTimer(autoConcludeTimer)
		autoConcludeTimer.Start()

	
		def ScheduleAutoComplete()
			This.ScheduleAutoConclude()

	def AutoConclude()
		# Only auto-conclude if we have aReactiveFuncs that need final results
		if (hasReduceTransform or len(concludeHandlers) > 0) and not isConcluded
			Conclude()
		ok

		def AutoComplete()
			This.AutoConclude()

	def Conclude()
		if isConcluded
			return
		ok
		
		isConcluded = STREAM_STATE_CONCLUDED
		
		# If we have a reduce transform, emit the final accumulated result
		if hasReduceTransform
			_nLenSub_ = len(aReactiveFuncs)
			for i = 1 to _nLenSub_
				_Rf_ = aReactiveFuncs[i]
				call _Rf_(accumulator)
			next
		ok
		
		# Call completion handlers
		_nLenHand_ = len(concludeHandlers)

		for i = 1 to _nLenHand_
			_fConcludeHandler_ = concludeHandlers[i]
			call _fConcludeHandler_()
		next
		
		Stop()

		def Complete()
			return This.Conclude()

	def Start()
		isActive = STREAM_STATE_ACTIVE
		isConcluded = STREAM_STATE_RUNNING
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

	def CheckErrorHandling(error)
		if not isActive or isConcluded
			return
		ok
		
		# Call error handlers
		_nLenErr_ = len(errorHandlers)
		for i = 1 to _nLenErr_
			_fErrorHandler_ = errorHandlers[i]
			call _fErrorHandler_(error)
		next

		# Stop the stream on error
		Stop()

	def SetOverflowStrategy(_strategy_, maxBufferSize)
		if not find([:BUFFER, :DROP, :BLOCK, :LATEST], _strategy_)
			_strategy_ = :BUFFER
		ok
		hasOverflowConfig = STREAM_STATE_ACTIVE
		overflowStrategy = _strategy_
		bufferSize = maxBufferSize
		return self

		def SetBackpressureStrategy(_strategy_, maxBufferSize)
			return This.SetOverflowStrategy(_strategy_, maxBufferSize)

	def OnOverflow(handler)
		overflowHandlers + handler
		return self

		def OnBackpressure(handler)
			return This.OnOverflow(handler)

	def OnBufferFull(handler)
		bufferFullHandlers + handler
		return self

	def HandleOverflow(data)
		isOverflowActive = STREAM_STATE_ACTIVE
		
		# Notify overflow handlers
		_nLenBack_ = len(overflowHandlers)
		for i = 1 to _nLenBack_
			_fHandler_ = overflowHandlers[i]
			call _fHandler_(currentBufferCount, bufferSize)
		next
		
		switch overflowStrategy
		case :BUFFER
		    # Block until buffer has space (simulate)
		    ? "⚠️ Overflow: Buffering data (buffer full: " + currentBufferCount + "/" + bufferSize + ")"
			
		case :DROP
			# Drop the new data
			droppedCount++
			? "⚠️ Overflow: Dropping data item (dropped so far: " + droppedCount + ")"
			
		case :LATEST
			# Drop oldest, keep latest
			if len(buffer) > 0
				del(buffer, 1)  # Remove oldest
				currentBufferCount--
			ok
			buffer + data
			currentBufferCount++
			? "⚠️ Overflow: Keeping latest, dropped oldest"
			
		case :BLOCK
			# In real implementation, this would block the producer
			? "⚠️ Overflow: Would block producer (simulated)"
		end

		def HandleBackpressure(data)
			return This.HandleOverflow(data)


	def ProcessAnItemFromBuffer()
		if len(buffer) = 0
			return
		ok
	
		# Get the next item from buffer
		data = buffer[1]
		del(buffer, 1)
		currentBufferCount--
	
		# Apply transforms (existing logic)
		processedData = [data]
		_nLenTrans_ = len(transforms)

		for i = 1 to _nLenTrans_
			_transformType_ = transforms[i][1]

			switch _transformType_
			case TRANSFORM_MAP
				_mapFunc_ = transforms[i][2]
				processedData = @Map(processedData, _mapFunc_)
	
			case TRANSFORM_FILTER
				_filterFunc_ = transforms[i][2]
				processedData = @Filter(processedData, _filterFunc_)

			case TRANSFORM_REDUCE
				_fReduceFunc_ = transforms[i][2]
				_nLenData_ = len(processedData)
				for j = 1 to _nLenData_
					accumulator = call _fReduceFunc_(accumulator, processedData[j])
				next
				# Reset overflow if buffer is no longer full
				if currentBufferCount < bufferSize and isOverflowActive
					isOverflowActive = STREAM_STATE_INACTIVE
				ok

				# Decrement pending counter for reduce transforms
				if pendingDataCount > 0
					pendingDataCount--
				ok
				return
			end
		next
		
		# Only emit if we didn't encounter a reduce transform
		if not hasReduceTransform
			_nLenSub_ = len(aReactiveFuncs)
			_nLenData_ = len(processedData)
	
			for i = 1 to _nLenSub_
				_Rf_ = aReactiveFuncs[i]
				for j = 1 to _nLenData_
					call _Rf_(processedData[j])
				next
			next
		ok
		
		# Reset overflow if buffer is no longer full
		if currentBufferCount < bufferSize and isOverflowActive
			isOverflowActive = STREAM_STATE_INACTIVE
		ok
		
		# Decrement pending counter after successful processing
		if pendingDataCount > 0
			pendingDataCount--
		ok


	def ProcessAllInBuffer()
		# Process all buffered items
		while len(buffer) > 0
			ProcessAnItemFromBuffer()
		end
		return self

		def DrainBuffer()
			return This.ProcessAllInBuffer()

	def OverflowStats()
		return [
			:bufferSize = bufferSize,
			:currentBuffer = currentBufferCount,
			:isOverflowActive = isOverflowActive,
			:droppedCount = droppedCount,
			:strategy = overflowStrategy
		]

		def BackpressureStats()
			return This.OverflowStats()
