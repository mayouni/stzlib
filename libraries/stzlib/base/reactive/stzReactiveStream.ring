

# Carries values one by one through steps (transform, filter, accumulate) to the functions that subscribed to it.
#
# Values enter with Recieve (spelt Receive, Feed, Emit or Send as well) and leave through the
# functions given to OnPassed, after the steps added with Transform and Filter, in the order they
# were added. Accumulate replaces the per-value output with one final result, handed to the
# subscribers when the stream concludes: by Conclude, or by itself after a quiet delay once the loop
# runs. SetOverflowStrategy bounds the buffer and decides what is lost when it is full;
# OverflowStats counts what was lost. A stream made with new is inactive and ignores values until
# Start is called, and one made by stzReactive.CreateStream is already started. Known faults:
# OnBufferFull functions are never called, and a stream that concluded at once through RecieveMany
# can conclude a second time when its pending timer fires.
#
#   receiver   oRs = new stzReactive(); o1 = oRs.CreateStream("prices")
#   example    gOut = []
#              o1.Transform(func p { return p * 2 })
#              o1.Filter(func p { return p >= 100 })
#              o1.OnPassed(func v { gOut + v })
#              o1.SetAutoConclude(0)
#              o1.Recieve(30)
#              o1.Recieve(60)
#              o1.Recieve(80)
#              ? @@( gOut )
#              #--> [ 120, 160 ]
#              o2 = oRs.CreateStream("sum")
#              gSum = []
#              o2.Accumulate(func(t, x) { return t + x }, 0)
#              o2.OnPassed(func t { gSum + t })
#              o2.SetAutoConclude(0)
#              o2.Recieve(5)
#              o2.Recieve(7)
#              ? @@( gSum )
#              #--> [ ]
#              o2.Conclude()
#              ? @@( gSum )
#              #--> [ 12 ]
#   see        stzReactive, stzReactiveObject, stzReactiveTask
class stzReactiveStream from stzObject

	@streamId = ""
	@sourceType = STREAM_SOURCE_MANUAL

	@aReactiveFuncs = []
	@errorHandlers = []
	@concludeHandlers = []
	@oEngine = ""
	@isActive = STREAM_STATE_INACTIVE
	@isConcluded = STREAM_STATE_RUNNING

	# Transformation functions to apply
	@transforms = []
	
	# Accumulator for reduce operations
	@accumulator = ""
	@hasReduceTransform = STREAM_STATE_INACTIVE

	# LibUV handle (only for libuv-backed streams)
	@uvHandle = ""

	# Overflow (backpressure) configuration
	@bufferSize = 100
	@overflowStrategy = :BUFFER
	@currentBufferCount = 0
	@buffer = []
	@isOverflowActive = STREAM_STATE_INACTIVE
	@droppedCount = 0
	
	# Overflow (backpressure) callbacks
	@overflowHandlers = []
	@bufferFullHandlers = []

	@hasOverflowConfig = STREAM_STATE_INACTIVE

	@autoConcludeEnabled = STREAM_STATE_ACTIVE
	@pendingDataCount = 0
	@autoConcludeDelay = 100  # milliseconds to wait for more data

	# The id of a pending auto-conclude timer, "" when none. It used to hold a
	# stzRingTimer OBJECT whose callback could not see this object at all --
	# see ScheduleAutoConclude.
	@autoConcludeTimer = ""

	# Builds a stream with an id, a kind of source and the system that serves it; an unknown source kind becomes manual.
	#
	#   id           the stream's name, as text
	#   sourceType   the kind of source: manual, libuv, timer, file, network or sensor
	#   engine       the stzReactive system that created it
	#   returns      nothing; the object is built
	#   note         the kind of source only labels the stream
	#   warning      a stream built with new is inactive and ignores every value until Start is
	#                called; CreateStream of stzReactive starts it for you
	#   see          Start, Recieve
	def Init(id, sourceType, engine)
		@streamId = id
		
		# Validate source type with expressive constants
		if not ( find([
			      STREAM_SOURCE_MANUAL, STREAM_SOURCE_LIBUV, 
		                STREAM_SOURCE_TIMER, STREAM_SOURCE_FILE,
		                STREAM_SOURCE_NETWORK, STREAM_SOURCE_SENSOR], sourceType ) )

			sourceType = STREAM_SOURCE_MANUAL
		ok
		
		@sourceType = sourceType
		@oEngine = engine

	# Adds a step that replaces each value by the result of a function, then returns the stream; steps run in the order they were added.
	#
	#   mapFunction   a function taking one value and returning the new value
	#   returns       the stream itself, so calls chain
	#   note          Map is the same call
	#   see           Filter, Accumulate, OnPassed
	#@ aka  Store map transformation with expressive constant
	def Transform(mapFunction)
		@transforms + [TRANSFORM_MAP, mapFunction]
		return self

		def Map(mapFunction)
			return This.Transform(mapFunction)

	# Adds a step that lets a value go on only when a function answers true for it, then returns the stream.
	#
	#   filterFunction   a function taking one value and returning TRUE to keep it
	#   returns          the stream itself, so calls chain
	#   note             Where is the same call
	#   see              Transform, Accumulate, OnPassed
	#@ aka  Store filter transformation with expressive constant
	def Filter(filterFunction)
		@transforms + [TRANSFORM_FILTER, filterFunction]
		return self

		def Where(filterFunction)
			return This.Filter(filterFunction)

	# Adds a step that folds all the values into one running result, which the subscribers receive only when the stream concludes.
	#
	#   reduceFunction   a function taking the running result and the new value and returning the
	#                    new result
	#   initialValue     the result before the first value
	#   returns          the stream itself, so calls chain
	#   note             Reduce is the same call
	#   warning          with this step the subscribers get nothing per value; they get the final
	#                    result once, at Conclude
	#   see              Conclude, OnNoMore, Transform
	#@ aka  Store reduce transformation with expressive constant
	def Accumulate(reduceFunction, initialValue)
		@transforms + [TRANSFORM_REDUCE, reduceFunction, initialValue]
		@hasReduceTransform = STREAM_STATE_ACTIVE
		@accumulator = initialValue
		return self

		def Reduce(reduceFunction, initialValue)
			return This.Accumulate(reduceFunction, initialValue)

	# Registers a function called with each value that comes out of the steps, then returns the stream.
	#
	#   _Rf_       a function taking one value
	#   returns    the stream itself, so calls chain
	#   note       OnRecieved, OnReceived, Subscribe, OnNext and OnPass are the same call
	#   see        Transform, Filter, Accumulate
	def OnPassed(_Rf_)
		@aReactiveFuncs + _Rf_
		return self

		# Registers a function called with each value that comes out of the steps, then returns the stream.
		#
		#   _Rf_       a function taking one value
		#   returns    the stream itself, so calls chain
		#   note       the same call as OnPassed
		#   see        OnPassed, Subscribe
		def OnRecieved(_Rf_)
			return OnPassed(_Rf_)

		# Registers a function called with each value that comes out of the steps, then returns the stream.
		#
		#   _Rf_       a function taking one value
		#   returns    the stream itself, so calls chain
		#   note       the same call as OnPassed
		#   see        OnPassed, Subscribe
		def OnReceived(_Rf_)
			return OnPassed(_Rf_)

		# Registers a function called with each value that comes out of the steps, then returns the stream.
		#
		#   _Rf_       a function taking one value
		#   returns    the stream itself, so calls chain
		#   note       the same call as OnPassed
		#   see        OnPassed, OnNext
		def Subscribe(_Rf_)
			return OnPassed(_Rf_)

		# Registers a function called with each value that comes out of the steps, then returns the stream.
		#
		#   _Rf_       a function taking one value
		#   returns    the stream itself, so calls chain
		#   note       the same call as OnPassed
		#   see        OnPassed, Subscribe
		def OnNext(_Rf_)
			return OnPassed(_Rf_)

		# Registers a function called with each value that comes out of the steps, then returns the stream.
		#
		#   _Rf_       a function taking one value
		#   returns    the stream itself, so calls chain
		#   note       the same call as OnPassed
		#   see        OnPassed, Subscribe
		def OnPass(_Rf_) # For if we forget it's OnPassed with "ed"
			return OnPassed(_Rf_)

	# Registers a function called with the error text when CheckErrorHandling reports one, then returns the stream.
	#
	#   errorHandler   a function taking the error
	#   returns        the stream itself, so calls chain
	#   warning        an error raised inside a step or a subscriber is not routed here: it reaches
	#                  the caller of Recieve
	#   see            CheckErrorHandling, Stop
	def OnError(errorHandler)
		@errorHandlers + errorHandler
		return self

	# Registers a function called, with no argument, when the stream concludes, then returns the stream.
	#
	#   concludeHandler   a function taking no argument
	#   returns           the stream itself, so calls chain
	#   note              OnComplete is the same call
	#   see               Conclude, Accumulate
	def OnNoMore(concludeHandler)
		@concludeHandlers + concludeHandler
		return self

		def OnComplete(completeHandler)
			return This.OnNoMore(completeHandler)

	# Takes one value into the stream and, when no overflow strategy is set, runs it through the steps and the subscribers at once.
	#
	#   data       the value to take in, of any type
	#   returns    nothing
	#   note       Feed, FeedWith, Emit, Send and Receive are the same call
	#   warning    ignored without any error when the stream is stopped or concluded; with an
	#              overflow strategy set, the value is only buffered until ProcessAnItemFromBuffer
	#              or ProcessAllInBuffer runs
	#   see        OnPassed, Transform, Conclude, SetOverflowStrategy
	def Recieve(data)
		if not @isActive or @isConcluded
			return
		ok
		
		# Increment pending data counter
		@pendingDataCount++
		
		# Check if buffer is at capacity BEFORE adding new data
		if @currentBufferCount >= @bufferSize
		    HandleOverflow(data)
		    return
		ok
		
		# Add to buffer
		@buffer + data
		@currentBufferCount++
	
		# Process immediately if no overflow config
		if not @hasOverflowConfig
		    ProcessAnItemFromBuffer()
		ok
		
		# Schedule auto-completion check if enabled
		if @autoConcludeEnabled
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

		# Recieve has i before e, and so did every way of listening to it.
		# The old spellings stay; these are the ones a caller reaches for.
		def Receive(data)
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
		if @autoConcludeEnabled
			AutoConclude()
		ok

		#< @FunctionAlternativeForms

		def FeedMany(paData)
			return This.RecieveMany(paData)

		def FeedWithMany(paData)
			return This.RecieveMany(paData)

		def SendMany(paData)
			return This.RecieveMany(paData)

		def ReceiveMany(paData)
			return This.RecieveMany(paData)

		def EmitMany(paData)
			return This.RecieveMany(paData)

		#>


	def SetAutoConcludeXT(enable, delay)
		This.SetAutoConclude(enable)
		This.SetAutoConcludeDelay(delay)
		return self

	# Turns automatic conclusion on or off and returns the stream; turning it off cancels a pending timer.
	#
	#   enabled    1 to conclude by itself after a quiet delay, 0 to conclude only by Conclude
	#   returns    the stream itself, so calls chain
	#   note       on by default; SetAutoComplete is the same call
	#   see        SetAutoConcludeDelay, AutoConclude, Conclude
	def SetAutoConclude(enabled)
		@autoConcludeEnabled = enabled
		
		# Cancel any pending timer if disabling.
		#
		# This called @oEngine.TimerManager(), a method that exists nowhere in
		# the library -- the engine holds @timerManager as an ATTRIBUTE, and
		# ScheduleAutoConclude below reached it that way. So turning the feature
		# OFF raised R14 exactly when it had something to turn off, and passed
		# quietly when it had nothing. Cancelling is an id now, no manager.
		if not enabled and @autoConcludeTimer != ""
			StzReaxisStopTimer(@autoConcludeTimer)
			@autoConcludeTimer = ""
		ok
		
		return self

	
		def SetAutoComplete(enabled)
			return This.SetAutoConclude(enabled)

	# Sets the quiet time, in milliseconds, that precedes automatic conclusion, and returns the stream.
	#
	#   pnMilliseconds   the delay, a number not below 0
	#   returns          the stream itself, so calls chain
	#   note             the default is 100
	#   warning          a value that is not a number or is negative is ignored and the old delay
	#                    stays
	#   see              SetAutoConclude, ScheduleAutoConclude
	#@ aka  Set the delay before auto-conclusion triggers.
	def SetAutoConcludeDelay(pnMilliseconds)
		if NOT isNumber(pnMilliseconds)
			return self
		ok
		if pnMilliseconds < 0
			return self
		ok
		@autoConcludeDelay = pnMilliseconds
		return self

	# Starts, or restarts, the timer that concludes the stream when no value is pending after the quiet delay.
	#
	#   returns    nothing
	#   note       Recieve calls it after every value
	#   warning    the timer is run by the reactive loop, so nothing happens until the loop runs; it
	#              acts on a copy of the stream taken now
	#   see        SetAutoConcludeDelay, AutoConclude, Recieve
	#@ aka  Real-world timer implementation for auto-conclusion THE CALLBACK MUST BE HANDED THE OBJECT; it cannot reach for it.
	def ScheduleAutoConclude()
		# Cancel existing timer if running
		if @autoConcludeTimer != ""
			StzReaxisStopTimer(@autoConcludeTimer)
			@autoConcludeTimer = ""
		ok

		@autoConcludeTimer = StzReaxisRunAfterXT(@autoConcludeDelay,
			func(oSelf) {
				oSelf.ClearAutoConcludeTimer()
				if oSelf.PendingDataCount() = 0 and oSelf.AutoConcludeEnabled()
					oSelf.AutoConclude()
				ok
			},
			[ self ])

	# Returns how many values were received and not yet processed.
	#
	#   returns    a number
	#   see        Recieve, ProcessAnItemFromBuffer
	#@ aka  Read by the auto-conclude callback, which is HANDED this object and so must ask it rather than reach into it.
	def PendingDataCount()
		return @pendingDataCount

	# TRUE if the stream concludes by itself after a quiet delay.
	#
	#   returns    1 or 0
	#   see        SetAutoConclude
	def AutoConcludeEnabled()
		return @autoConcludeEnabled

	# Forgets the pending timer's id without cancelling it, and returns the stream.
	#
	#   returns    the stream itself, so calls chain
	#   note       the timer calls it when it fires
	#   see        ScheduleAutoConclude, SetAutoConclude
	def ClearAutoConcludeTimer()
		@autoConcludeTimer = ""
		return This

	
		# Starts, or restarts, the timer that concludes the stream when no value is pending after the quiet delay.
		#
		#   returns    nothing
		#   note       the same call as ScheduleAutoConclude
		#   see        ScheduleAutoConclude
		def ScheduleAutoComplete()
			This.ScheduleAutoConclude()

	# Concludes the stream if it has an accumulating step or a conclude function and is not already concluded; otherwise does nothing.
	#
	#   returns    nothing
	#   note       AutoComplete is the same call
	#   see        Conclude, SetAutoConclude
	def AutoConclude()
		# Only auto-conclude if we have aReactiveFuncs that need final results
		if (@hasReduceTransform or len(@concludeHandlers) > 0) and not @isConcluded
			Conclude()
		ok

		# Concludes the stream if it has an accumulating step or a conclude function and is not already concluded; otherwise does nothing.
		#
		#   returns    nothing
		#   note       the same call as AutoConclude
		#   see        AutoConclude
		def AutoComplete()
			This.AutoConclude()

	# Ends the stream once: hands the final accumulated result to the subscribers, calls the conclude functions and stops the stream.
	#
	#   returns    nothing
	#   note       Complete is the same call
	#   warning    a second call does nothing; the stream accepts no value afterwards until Start is
	#              called
	#   see        Accumulate, OnNoMore, Start
	def Conclude()
		if @isConcluded
			return
		ok
		
		@isConcluded = STREAM_STATE_CONCLUDED
		
		# If we have a reduce transform, emit the final accumulated result
		if @hasReduceTransform
			_nLenSub_ = len(@aReactiveFuncs)
			for i = 1 to _nLenSub_
				_Rf_ = @aReactiveFuncs[i]
				call _Rf_(@accumulator)
			next
		ok
		
		# Call completion handlers
		_nLenHand_ = len(@concludeHandlers)

		for i = 1 to _nLenHand_
			_fConcludeHandler_ = @concludeHandlers[i]
			call _fConcludeHandler_()
		next
		
		Stop()

		def Complete()
			return This.Conclude()

	# Makes the stream accept values, clears its concluded state, and returns it.
	#
	#   returns    the stream itself, so calls chain
	#   note       CreateStream of stzReactive has already called it
	#   see        Stop, Conclude
	def Start()
		@isActive = STREAM_STATE_ACTIVE
		@isConcluded = STREAM_STATE_RUNNING
		return self
		
	# Makes the stream ignore values until Start is called, and returns it.
	#
	#   returns    the stream itself, so calls chain
	#   see        Start, Cleanup
	def Stop()
		@isActive = STREAM_STATE_INACTIVE
		return self
		
	# Stops the stream and releases its libuv handle, if it has one.
	#
	#   returns    nothing
	#   see        Stop
	def Cleanup()
		Stop()
		if @uvHandle != "" and @sourceType = STREAM_SOURCE_LIBUV
			# Clean up LibUV resources
			@uvHandle = ""
		ok

	# Calls every error function with the error and stops the stream; ignored when the stream is stopped or concluded.
	#
	#   error      the error to report, usually a text
	#   returns    nothing
	#   see        OnError, Stop
	def CheckErrorHandling(error)
		if not @isActive or @isConcluded
			return
		ok
		
		# Call error handlers
		_nLenErr_ = len(@errorHandlers)
		for i = 1 to _nLenErr_
			_fErrorHandler_ = @errorHandlers[i]
			call _fErrorHandler_(error)
		next

		# Stop the stream on error
		Stop()

	# Sets what happens to a value that arrives when the buffer is full, and the buffer's size, and returns the stream.
	#
	#   _strategy_      :BUFFER, :DROP, :BLOCK or :LATEST, and :BUFFER for any other word
	#   maxBufferSize   how many values the buffer holds
	#   returns         the stream itself, so calls chain
	#   note            SetBackpressureStrategy is the same call
	#   warning         once set, Recieve only buffers: nothing reaches the subscribers until
	#                   ProcessAnItemFromBuffer or ProcessAllInBuffer runs; :LATEST evicts the
	#                   oldest value, and the three other strategies refuse the new one, and every
	#                   loss is counted as dropped
	#   see             OnOverflow, OverflowStats, ProcessAllInBuffer
	def SetOverflowStrategy(_strategy_, maxBufferSize)
		if not find([:BUFFER, :DROP, :BLOCK, :LATEST], _strategy_)
			_strategy_ = :BUFFER
		ok
		@hasOverflowConfig = STREAM_STATE_ACTIVE
		@overflowStrategy = _strategy_
		@bufferSize = maxBufferSize
		return self

		def SetBackpressureStrategy(_strategy_, maxBufferSize)
			return This.SetOverflowStrategy(_strategy_, maxBufferSize)

	# Registers a function called as f(buffered, size) each time a value arrives while the buffer is full, then returns the stream.
	#
	#   handler    a function taking two arguments, how many values are buffered and the buffer's
	#              size
	#   returns    the stream itself, so calls chain
	#   note       OnBackpressure is the same call
	#   see        SetOverflowStrategy, OverflowStats
	def OnOverflow(handler)
		@overflowHandlers + handler
		return self

		def OnBackpressure(handler)
			return This.OnOverflow(handler)

	# Registers a function meant to be called when the buffer is full, then returns the stream.
	#
	#   handler    a function taking no argument
	#   returns    the stream itself, so calls chain
	#   warning    the function is stored and never called: in the four strategies tested, a full
	#              buffer called OnOverflow handlers and no OnBufferFull handler
	#   see        OnOverflow
	def OnBufferFull(handler)
		@bufferFullHandlers + handler
		return self

	# Calls the overflow functions, then drops the value that met a full buffer or evicts the oldest one, by strategy.
	#
	#   data       the value that did not fit
	#   returns    nothing
	#   note       HandleBackpressure is the same call
	#   warning    calling it directly also counts the value as dropped
	#   see        SetOverflowStrategy, OnOverflow
	def HandleOverflow(data)
		@isOverflowActive = STREAM_STATE_ACTIVE
		
		# Notify overflow handlers
		_nLenBack_ = len(@overflowHandlers)
		for i = 1 to _nLenBack_
			_fHandler_ = @overflowHandlers[i]
			call _fHandler_(@currentBufferCount, @bufferSize)
		next
		
		# WHATEVER IS LOST IS COUNTED. Only :DROP used to increment @droppedCount,
		# so a stream on the DEFAULT :BUFFER strategy discarded every item past
		# capacity while OverflowStats() reported "dropped 0" -- the one number a
		# caller reads to learn whether data was lost said none had been. :LATEST
		# under-reported the same way: it evicts the oldest to make room, and an
		# evicted item is gone whatever the reason for evicting it.
		#
		# The strategies also no longer PRINT. A library has no business writing to
		# the console while data flows, and there is already a seam for saying so:
		# the OnOverflow handlers are called just above, with the count and the
		# ceiling, before this switch runs.
		switch @overflowStrategy
		case :BUFFER
			# The buffer is full and does not grow, so the new item is refused.
			# (BUFFER_EXPAND names an expansion this does not implement -- the
			# item is discarded, and is now counted as discarded.)
			@droppedCount++
		
		case :DROP
			# Drop the new data
			@droppedCount++
		
		case :LATEST
			# Drop oldest, keep latest -- the evicted item is a loss too
			if len(@buffer) > 0
				del(@buffer, 1)  # Remove oldest
				@currentBufferCount--
				@droppedCount++
			ok
			@buffer + data
			@currentBufferCount++
		
		case :BLOCK
			# Nothing here blocks a producer: Ring's face is single-threaded and
			# the item has nowhere to wait, so it is refused -- and counted.
			@droppedCount++
		end

		def HandleBackpressure(data)
			return This.HandleOverflow(data)


	# Takes the oldest buffered value, runs it through the steps and hands it to the subscribers; does nothing when the buffer is empty.
	#
	#   returns    nothing
	#   see        ProcessAllInBuffer, Recieve
	def ProcessAnItemFromBuffer()
		if len(@buffer) = 0
			return
		ok
	
		# Get the next item from buffer
		data = @buffer[1]
		del(@buffer, 1)
		@currentBufferCount--
	
		# Apply transforms (existing logic)
		processedData = [data]
		_nLenTrans_ = len(@transforms)

		for i = 1 to _nLenTrans_
			_transformType_ = @transforms[i][1]

			switch _transformType_
			case TRANSFORM_MAP
				_mapFunc_ = @transforms[i][2]
				processedData = @Map(processedData, _mapFunc_)
	
			case TRANSFORM_FILTER
				_filterFunc_ = @transforms[i][2]
				processedData = @Filter(processedData, _filterFunc_)

			case TRANSFORM_REDUCE
				_fReduceFunc_ = @transforms[i][2]
				_nLenData_ = len(processedData)
				for j = 1 to _nLenData_
					@accumulator = call _fReduceFunc_(@accumulator, processedData[j])
				next
				# Reset overflow if buffer is no longer full
				if @currentBufferCount < @bufferSize and @isOverflowActive
					@isOverflowActive = STREAM_STATE_INACTIVE
				ok

				# Decrement pending counter for reduce transforms
				if @pendingDataCount > 0
					@pendingDataCount--
				ok
				return
			end
		next
		
		# Only emit if we didn't encounter a reduce transform
		if not @hasReduceTransform
			_nLenSub_ = len(@aReactiveFuncs)
			_nLenData_ = len(processedData)
	
			for i = 1 to _nLenSub_
				_Rf_ = @aReactiveFuncs[i]
				for j = 1 to _nLenData_
					call _Rf_(processedData[j])
				next
			next
		ok
		
		# Reset overflow if buffer is no longer full
		if @currentBufferCount < @bufferSize and @isOverflowActive
			@isOverflowActive = STREAM_STATE_INACTIVE
		ok
		
		# Decrement pending counter after successful processing
		if @pendingDataCount > 0
			@pendingDataCount--
		ok


	# Processes every buffered value, oldest first, and returns the stream.
	#
	#   returns    the stream itself, so calls chain
	#   note       DrainBuffer is the same call
	#   see        ProcessAnItemFromBuffer, SetOverflowStrategy
	def ProcessAllInBuffer()
		# Process all buffered items
		while len(@buffer) > 0
			ProcessAnItemFromBuffer()
		end
		return self

		def DrainBuffer()
			return This.ProcessAllInBuffer()

	# Returns the buffer's size, how many values it holds, whether it overflowed, how many values were lost, and the strategy.
	#
	#   returns    a hashlist with the keys bufferSize, currentBuffer, isOverflowActive,
	#              droppedCount and strategy
	#   note       the keys are lower case when listed; reading o1.OverflowStats()[:droppedCount]
	#              works; BackpressureStats is the same call
	#   see        SetOverflowStrategy, HandleOverflow
	def OverflowStats()
		return [
			:bufferSize = @bufferSize,
			:currentBuffer = @currentBufferCount,
			:isOverflowActive = @isOverflowActive,
			:droppedCount = @droppedCount,
			:strategy = @overflowStrategy
		]

		def BackpressureStats()
			return This.OverflowStats()
