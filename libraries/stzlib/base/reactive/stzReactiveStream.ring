

class stzReactiveStream from stzObject

	_streamId_ = ""
	_sourceType_ = STREAM_SOURCE_MANUAL

	_aReactiveFuncs_ = []
	_errorHandlers_ = []
	_concludeHandlers_ = []
	_engine_ = NULL
	_isActive_ = STREAM_STATE_INACTIVE
	_isConcluded_ = STREAM_STATE_RUNNING

	# Transformation functions to apply
	_transforms_ = []
	
	# Accumulator for reduce operations
	_accumulator_ = NULL
	_hasReduceTransform_ = STREAM_STATE_INACTIVE

	# LibUV handle (only for libuv-backed streams)
	_uvHandle_ = NULL

	# Overflow (backpressure) configuration
	_bufferSize_ = 100
	_overflowStrategy_ = :BUFFER
	_currentBufferCount_ = 0
	_buffer_ = []
	_isOverflowActive_ = STREAM_STATE_INACTIVE
	_droppedCount_ = 0
	
	# Overflow (backpressure) callbacks
	_overflowHandlers_ = []
	_bufferFullHandlers_ = []

	_hasOverflowConfig_ = STREAM_STATE_INACTIVE

	_autoConcludeEnabled_ = STREAM_STATE_ACTIVE
	pendingDataCount = 0
	_autoConcludeDelay_ = 100  # milliseconds to wait for more data
	_autoConcludeTimer_ = NULL

	def Init(id, _sourceType_, _engine_)
		_streamId_ = id
		
		# Validate source type with expressive constants
		if not ( find([
			      STREAM_SOURCE_MANUAL, STREAM_SOURCE_LIBUV, 
		                STREAM_SOURCE_TIMER, STREAM_SOURCE_FILE,
		                STREAM_SOURCE_NETWORK, STREAM_SOURCE_SENSOR], _sourceType_ ) )

			_sourceType_ = STREAM_SOURCE_MANUAL
		ok
		
		this.sourceType = _sourceType_
		this.engine = _engine_

	# Store map transformation with expressive constant
	def Transform(mapFunction)
		_transforms_ + [TRANSFORM_MAP, mapFunction]
		return self

		def Map(mapFunction)
			return This.Transform(mapFunction)

	# Store filter transformation with expressive constant
	def Filter(filterFunction)
		_transforms_ + [TRANSFORM_FILTER, filterFunction]
		return self

		def Where(filterFunction)
			return This.Filter(filterFunction)

	# Store reduce transformation with expressive constant
	def Accumulate(reduceFunction, initialValue)
		_transforms_ + [TRANSFORM_REDUCE, reduceFunction, initialValue]
		_hasReduceTransform_ = STREAM_STATE_ACTIVE
		_accumulator_ = initialValue
		return self

		def Reduce(reduceFunction, initialValue)
			return This.Accumulate(reduceFunction, initialValue)

	def OnPassed(_Rf_)
		_aReactiveFuncs_ + _Rf_
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
		_errorHandlers_ + errorHandler
		return self

	def OnNoMore(concludeHandler)
		_concludeHandlers_ + concludeHandler
		return self

		def OnComplete(completeHandler)
			return This.OnNoMore(completeHandler)

	def Recieve(data)
		if not _isActive_ or _isConcluded_
			return
		ok
		
		# Increment pending data counter
		pendingDataCount++
		
		# Check if buffer is at capacity BEFORE adding new data
		if _currentBufferCount_ >= _bufferSize_
		    HandleOverflow(data)
		    return
		ok
		
		# Add to buffer
		_buffer_ + data
		_currentBufferCount_++
	
		# Process immediately if no overflow config
		if not _hasOverflowConfig_
		    ProcessAnItemFromBuffer()
		ok
		
		# Schedule auto-completion check if enabled
		if _autoConcludeEnabled_
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
		if _autoConcludeEnabled_
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
		_autoConcludeEnabled_ = enabled
		
		# Cancel any pending timer if disabling
		if not enabled and _autoConcludeTimer_ != NULL
			_engine_.TimerManager().RemoveTimer(_autoConcludeTimer_.timerId)
			_autoConcludeTimer_ = NULL
		ok
		
		return self

	
		def SetAutoComplete(enabled)
			return This.SetAutoConclude(enabled)

	# Set the delay before auto-conclusion triggers
	def SetAutoConcludeDelay(pnMilliseconds)
		_autoConcludeDelay_ = pnMilliseconds
		return self

	# Real-world timer implementation for auto-conclusion
	def ScheduleAutoConclude()
		# Cancel existing timer if running
		if _autoConcludeTimer_ != NULL
			_engine_.timerManager.RemoveTimer(_autoConcludeTimer_.timerId)
			_autoConcludeTimer_ = NULL
		ok
		
		# Create one-time timer using existing timer system
		_timerId_ = "autoconclude_" + _streamId_ + "_" + random(9999)
		_autoConcludeTimer_ = new stzRingTimer(_timerId_, _autoConcludeDelay_, func() {
			# Timer callback - check if we should auto-conclude
			if pendingDataCount = 0 and _autoConcludeEnabled_
				AutoConclude()
			ok
			_autoConcludeTimer_ = NULL  # Clean up timer reference
		}, _engine_, true, self)  # true = one-time timer
		
		_engine_.timerManager.AddTimer(_autoConcludeTimer_)
		_autoConcludeTimer_.Start()

	
		def ScheduleAutoComplete()
			This.ScheduleAutoConclude()

	def AutoConclude()
		# Only auto-conclude if we have aReactiveFuncs that need final results
		if (_hasReduceTransform_ or len(_concludeHandlers_) > 0) and not _isConcluded_
			Conclude()
		ok

		def AutoComplete()
			This.AutoConclude()

	def Conclude()
		if _isConcluded_
			return
		ok
		
		_isConcluded_ = STREAM_STATE_CONCLUDED
		
		# If we have a reduce transform, emit the final accumulated result
		if _hasReduceTransform_
			_nLenSub_ = len(_aReactiveFuncs_)
			for i = 1 to _nLenSub_
				_Rf_ = _aReactiveFuncs_[i]
				call _Rf_(_accumulator_)
			next
		ok
		
		# Call completion handlers
		_nLenHand_ = len(_concludeHandlers_)

		for i = 1 to _nLenHand_
			_fConcludeHandler_ = _concludeHandlers_[i]
			call _fConcludeHandler_()
		next
		
		Stop()

		def Complete()
			return This.Conclude()

	def Start()
		_isActive_ = STREAM_STATE_ACTIVE
		_isConcluded_ = STREAM_STATE_RUNNING
		return self
		
	def Stop()
		_isActive_ = STREAM_STATE_INACTIVE
		return self
		
	def Cleanup()
		Stop()
		if _uvHandle_ != NULL and _sourceType_ = STREAM_SOURCE_LIBUV
			# Clean up LibUV resources
			_uvHandle_ = NULL
		ok

	def CheckErrorHandling(error)
		if not _isActive_ or _isConcluded_
			return
		ok
		
		# Call error handlers
		_nLenErr_ = len(_errorHandlers_)
		for i = 1 to _nLenErr_
			_fErrorHandler_ = _errorHandlers_[i]
			call _fErrorHandler_(error)
		next

		# Stop the stream on error
		Stop()

	def SetOverflowStrategy(_strategy_, maxBufferSize)
		if not find([:BUFFER, :DROP, :BLOCK, :LATEST], _strategy_)
			_strategy_ = :BUFFER
		ok
		_hasOverflowConfig_ = STREAM_STATE_ACTIVE
		_overflowStrategy_ = _strategy_
		_bufferSize_ = maxBufferSize
		return self

		def SetBackpressureStrategy(_strategy_, maxBufferSize)
			return This.SetOverflowStrategy(_strategy_, maxBufferSize)

	def OnOverflow(handler)
		_overflowHandlers_ + handler
		return self

		def OnBackpressure(handler)
			return This.OnOverflow(handler)

	def OnBufferFull(handler)
		_bufferFullHandlers_ + handler
		return self

	def HandleOverflow(data)
		_isOverflowActive_ = STREAM_STATE_ACTIVE
		
		# Notify overflow handlers
		_nLenBack_ = len(_overflowHandlers_)
		for i = 1 to _nLenBack_
			_fHandler_ = _overflowHandlers_[i]
			call _fHandler_(_currentBufferCount_, _bufferSize_)
		next
		
		switch _overflowStrategy_
		case :BUFFER
		    # Block until buffer has space (simulate)
		    ? "⚠️ Overflow: Buffering data (buffer full: " + _currentBufferCount_ + "/" + _bufferSize_ + ")"
			
		case :DROP
			# Drop the new data
			_droppedCount_++
			? "⚠️ Overflow: Dropping data item (dropped so far: " + _droppedCount_ + ")"
			
		case :LATEST
			# Drop oldest, keep latest
			if len(_buffer_) > 0
				del(_buffer_, 1)  # Remove oldest
				_currentBufferCount_--
			ok
			_buffer_ + data
			_currentBufferCount_++
			? "⚠️ Overflow: Keeping latest, dropped oldest"
			
		case :BLOCK
			# In real implementation, this would block the producer
			? "⚠️ Overflow: Would block producer (simulated)"
		end

		def HandleBackpressure(data)
			return This.HandleOverflow(data)


	def ProcessAnItemFromBuffer()
		if len(_buffer_) = 0
			return
		ok
	
		# Get the next item from buffer
		data = _buffer_[1]
		del(_buffer_, 1)
		_currentBufferCount_--
	
		# Apply transforms (existing logic)
		processedData = [data]
		_nLenTrans_ = len(_transforms_)

		for i = 1 to _nLenTrans_
			_transformType_ = _transforms_[i][1]

			switch _transformType_
			case TRANSFORM_MAP
				_mapFunc_ = _transforms_[i][2]
				processedData = @Map(processedData, _mapFunc_)
	
			case TRANSFORM_FILTER
				_filterFunc_ = _transforms_[i][2]
				processedData = @Filter(processedData, _filterFunc_)

			case TRANSFORM_REDUCE
				_fReduceFunc_ = _transforms_[i][2]
				_nLenData_ = len(processedData)
				for j = 1 to _nLenData_
					_accumulator_ = call _fReduceFunc_(_accumulator_, processedData[j])
				next
				# Reset overflow if buffer is no longer full
				if _currentBufferCount_ < _bufferSize_ and _isOverflowActive_
					_isOverflowActive_ = STREAM_STATE_INACTIVE
				ok

				# Decrement pending counter for reduce transforms
				if pendingDataCount > 0
					pendingDataCount--
				ok
				return
			end
		next
		
		# Only emit if we didn't encounter a reduce transform
		if not _hasReduceTransform_
			_nLenSub_ = len(_aReactiveFuncs_)
			_nLenData_ = len(processedData)
	
			for i = 1 to _nLenSub_
				_Rf_ = _aReactiveFuncs_[i]
				for j = 1 to _nLenData_
					call _Rf_(processedData[j])
				next
			next
		ok
		
		# Reset overflow if buffer is no longer full
		if _currentBufferCount_ < _bufferSize_ and _isOverflowActive_
			_isOverflowActive_ = STREAM_STATE_INACTIVE
		ok
		
		# Decrement pending counter after successful processing
		if pendingDataCount > 0
			pendingDataCount--
		ok


	def ProcessAllInBuffer()
		# Process all buffered items
		while len(_buffer_) > 0
			ProcessAnItemFromBuffer()
		end
		return self

		def DrainBuffer()
			return This.ProcessAllInBuffer()

	def OverflowStats()
		return [
			:bufferSize = _bufferSize_,
			:currentBuffer = _currentBufferCount_,
			:isOverflowActive = _isOverflowActive_,
			:droppedCount = _droppedCount_,
			:strategy = _overflowStrategy_
		]

		def BackpressureStats()
			return This.OverflowStats()
