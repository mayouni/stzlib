# Reactive Object System for Softanza Library
# Integrates with existing stzReactive system and libuv infrastructure

# This reactive object system provides:
#  1. Full integration with Softanza's libuv-based reactive system
#  2. Seamless use of existing timers, tasks, and streams
#  3. Natural Ring syntax using object access hooks
#  4. Attribute watching, computed attributes, and object binding
#  5. Async Attribute updates using Softanza tasks
#  6. Batch updates for performance
#  7. Debounced attribute changes using Softanza timers
#  8. Attribute change streams using Softanza streams
#  9. Comprehensive error handling and recovery
# 10. Wrapper support for existing objects



# Unified Reactive Object System for Softanza Library
# Single class that handles all reactive object functionality

class stzReactiveObject from stzReactive

	# Core reactive infrastructure
	wrappedObject = OBJECT_STANDALONE       # OBJECT_STANDALONE = standalone, not OBJECT_STANDALONE = wrapper mode
	engine = NULL

	# Attribute watching system
	aAttributeWatchers = []     # [attr, callback] pairs
	aComputedAttributes = []   # [Attribute, computer_func, dependencies]
	aAttributeBindings = []     # [source_attr, target_obj, target_attr]
	aAsyncOperations = []      # Pending async Attribute operations
	
	# State management
	bReactiveMode = DEFAULT_REACTIVE_MODE
	bBatchMode = DEFAULT_BATCH_MODE
	aPendingChanges = []       # Changes accumulated during batch mode
	
	# Change tracking
	aCachedAttributeValues = []       # Cache of current Attribute values for change detection
	
	# Attribute storage - for standalone objects
	aAttributesOfStandaloneObjects = []           # Internal Attribute storage: [name, value] pairs

	def Init(existingObject, reactiveEngine)
	    if existingObject != NULL
	        wrappedObject = existingObject
	    else
	        wrappedObject = OBJECT_STANDALONE
	    ok
	    engine = reactiveEngine

   
	# Initialize attribute cache with wrapped object's current values
	if wrappedObject != OBJECT_STANDALONE
	    _aObjectAttrs_ = AttributesXT(wrappedObject)
	    _nLen_ = len(_aObjectAttrs_)
	
	    for i = 1 to _nLen_
	            SetAttributeInStorage(_aObjectAttrs_[i][1], _aObjectAttrs_[i][2])
	            UpdateAttributeCache(_aObjectAttrs_[i][1], _aObjectAttrs_[i][2])
	    next
	ok

	# Ring's object access hooks - integrate with reactive system
	def BraceStart()
		if bReactiveMode = REACTIVE_ON
			# Notify reactive system of object access start
		ok

	def BraceEnd()
		if bReactiveMode = REACTIVE_ON
			ProcessPendingReactions()
		ok

	def BraceError()
		_cError_ = cCatchError
		
		# Handle errors in async operations
		_nLenOp_ = len(aAsyncOperations)
		for i = 1 to _nLenOp_
			if len(aAsyncOperations[i]) >= 5 and aAsyncOperations[i][5] != ""
				try
					f = aAsyncOperations[i][5]
					call f(_cError_)
				catch
					# Error in error handler - just log it (#tODO)
				done
			ok
		next

	# Universal Attribute setter
	def SetAttribute(_cAttribute_, _newValue_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Get old value
		_cOldValue_ = GetAttributeValue(_cAttribute_)
		
		# Set the new value
		SetAttributeValue(_cAttribute_, _newValue_)
		
		if This.bReactiveMode = REACTIVE_ON and _cOldValue_ != _newValue_
			# Update Attribute cache
			This.UpdateAttributeCache(_cAttribute_, _newValue_)
			
			if this.bBatchMode = BATCH_MODE_ON
				# Accumulate change for batch processing
				this.aPendingChanges + [_cAttribute_, _cOldValue_, _newValue_]
			else
				# Process change immediately
				This.ProcessAttributeChange(_cAttribute_, _cOldValue_, _newValue_)
			ok
		ok

	def @(paAttr)
		This.SetAttribute(paAttr[1], paAttr[2])

	# Universal Attribute getter
	def GetAttribute(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)
		_value_ = GetAttributeValue(_cAttribute_)
		
		if bReactiveMode = REACTIVE_ON
			# Notify reactive system of Attribute access
		ok
		
		return _value_

	# Core Attribute access methods
	def GetAttributeValue(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    
	    # Check cache first
	    _nIndex_ = FindAttributeInCache(_cAttribute_)
	    if _nIndex_ > 0
	        return aCachedAttributeValues[_nIndex_][2]
	    ok
	    
	    if wrappedObject != OBJECT_STANDALONE
	        # Wrapper mode: get from wrapped object
	        if hasattribute(wrappedObject, _cAttribute_)
	            return eval("wrappedObject." + _cAttribute_)
	        else
	            # Try storage if not on wrapped object
	            return GetAttributeFromStorage(_cAttribute_)
	        ok
	    else
	        # Standalone mode: get from internal storage
	        return GetAttributeFromStorage(_cAttribute_)
	    ok
	
	def SetAttributeValue(_cAttribute_, _value_)
		_cAttribute_ = StzLower(_cAttribute_)
		
		if wrappedObject != OBJECT_STANDALONE
			# Wrapper mode: set on wrapped object
			addattribute(wrappedObject, _cAttribute_)
			eval("wrappedObject." + _cAttribute_ + " = value")
		ok
		
		# Always set in internal storage for consistency
		SetAttributeInStorage(_cAttribute_, _value_)
		
		# Also set as object attribute for compatibility
		AddAttribute(this, _cAttribute_)
		eval("this." + _cAttribute_ + " = value")

	#-----------------------#
	#  PUBLIC REACTIVE API  #
	#-----------------------#

	# Watch Attribute changes
	def Watch(_cAttribute_, fCallback)
		_cAttribute_ = StzLower(_cAttribute_)
		aAttributeWatchers + [_cAttribute_, fCallback]
		return self

	# Create computed Attribute that auto-updates
	def Computed(_cAttribute_, _fnComputer_, _aDependencies_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    aComputedAttributes + [_cAttribute_, _fnComputer_, _aDependencies_]
	    
	    # Initial computation
	    ComputeAttribute(_cAttribute_)
	    return self

	# Bind Attribute to another reactive object
	def BindTo(oTargetObject, _cSourceAttribute_, _cTargetAttribute_)
		if _cTargetAttribute_ = NULL
			_cTargetAttribute_ = _cSourceAttribute_
		ok

		_cSourceAttribute_ = StzLower(_cSourceAttribute_)
		_cTargetAttribute_ = StzLower(_cTargetAttribute_)

		aAttributeBindings + [_cSourceAttribute_, oTargetObject, _cTargetAttribute_]
		
		# Initial sync with immediate binding
		_sourceValue_ = GetAttributeValue(_cSourceAttribute_)
		if DEFAULT_SYNC_MODE = BIND_AUTO_SYNC
			oTargetObject.SetAttributeValue(_cTargetAttribute_, _sourceValue_)
		ok

	# Async Attribute update
	def SetAsync(_cAttribute_, _newValue_, fnSuccess, fnError)
		_cAttribute_ = StzLower(_cAttribute_)
		_taskId_ = "attr_" + _cAttribute_ + "_" + string(random(999999))
		
		# Ensure fnError has a value for error handling
		_fnErrorCallback_ = fnError
		if _fnErrorCallback_ = NULL
			_fnErrorCallback_ = func(error) { }
		ok
		
		_task_ = new stzReactiveTask(_taskId_, func {
			return _newValue_
		}, this)
		
		_task_.Then_(func result {
			SetAttribute(_cAttribute_, result)
			if fnSuccess != NULL
				call fnSuccess(result)
			ok
		})
		
		_task_.Catch_(func error {
			call _fnErrorCallback_(error)
		})
		
		aAsyncOperations + [_cAttribute_, _newValue_, fnSuccess, _task_, _fnErrorCallback_]
		_task_.Execute()
		return _task_

	# Batch multiple Attribute updates
	def Batch(fnUpdates)
		bBatchMode = BATCH_MODE_ON
		aPendingChanges = []
		
		try
			call fnUpdates()
		catch
			# Handle batch error with default error handling
		done
		
		bBatchMode = BATCH_MODE_OFF
		
		# Process all accumulated changes at once
		ProcessBatchChanges()
		return self

	# Create reactive stream from Attribute changes
	def StreamAttribute(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)
		
		_streamId_ = StzLower(classname(self)) + "_" + _cAttribute_ + "_" + random(999999)
		_stream_ = this.engine.CreateStream(_streamId_)
		
		Watch(_cAttribute_, func(attr, oldVal, newVal) {
			_aData_ = []
			_aData_ + ["Attribute", attr]
			_aData_ + ["oldValue", oldVal] 
			_aData_ + ["newValue", newVal]
			_aData_ + ["changeType", CHANGE_TYPE_VALUE]
			_stream_.Emit(_aData_)
		})
		
		return _stream_

	# The method waits for the attribute to stop changing (settle) before executing the callback
	def WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)
		_cAttribute_ = StzLower(_cAttribute_)
		
		_currentTimer_ = NULL
		
		Watch(_cAttribute_, func(attr, oldVal, newVal) {
			if _currentTimer_ != NULL
				StopTimer(_currentTimer_)
			ok
			
			_currentTimer_ = RunAfter(func {
				call fCallback(attr, oldVal, newVal)
				_currentTimer_ = NULL
			}, nDelay)
		})
		
		return self

		def DebounceAttribute(_cAttribute_, nDelay, fCallback)
			return This.WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)

	# Factory method for creating reactive objects
	def Reactivate(existingObject)
		return new stzReactiveObject(existingObject, this)

	#-------------------#
	#  UTILITY METHODS  #
	#-------------------#

	def GetAttributeFromStorage(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Find in internal storage
		_nLenAttr_ = len(aAttributesOfStandaloneObjects)

		for i = 1 to _nLenAttr_
			if aAttributesOfStandaloneObjects[i][1] = _cAttribute_
				return aAttributesOfStandaloneObjects[i][2]
			ok
		next
		
		return ""  # Default empty value

	def SetAttributeInStorage(_cAttribute_, _value_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Find existing Attribute
		_nLenAttr_ = len(aAttributesOfStandaloneObjects)
		for i = 1 to _nLenAttr_
			if aAttributesOfStandaloneObjects[i][1] = _cAttribute_
				aAttributesOfStandaloneObjects[i][2] = _value_
				return
			ok
		next
		# Attribute doesn't exist, add it
		aAttributesOfStandaloneObjects + [_cAttribute_, _value_]

	def UpdateAttributeCache(_cAttribute_, _value_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nIndex_ = FindAttributeInCache(_cAttribute_)
	    if _nIndex_ > 0
	        aCachedAttributeValues[_nIndex_][2] = _value_
	    else
	        aCachedAttributeValues + [_cAttribute_, _value_]
	    ok

	def FindAttributeInCache(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenCacheAttr_ = len(aCachedAttributeValues)
	    for i = 1 to _nLenCacheAttr_
	        if aCachedAttributeValues[i][1] = _cAttribute_
	            return i
	        ok
	    next
	    return 0

	def ProcessAttributeChange(_cAttribute_, oldValue, _newValue_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Notify watchers with immediate processing
		if DEFAULT_WATCH_MODE = WATCH_IMMEDIATE
			TriggerAttributeWatchers(_cAttribute_, oldValue, _newValue_)
		ok
		
		# Update computed Attributes
		UpdateDependentComputedAttributes(_cAttribute_)
		
		# Update bound Attributes
		UpdateBoundAttributes(_cAttribute_, _newValue_)

	def ProcessPendingReactions()
		if len(aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	def ProcessBatchChanges()
		_aProcessedAttrs_ = []
		_nLenPend_ = len(aPendingChanges)

		for i = 1 to _nLenPend_
			_cAttribute_ = aPendingChanges[i][1]
			_cOldValue_ = aPendingChanges[i][2] 
			_newValue_ = aPendingChanges[i][3]
			
			if find(_aProcessedAttrs_, _cAttribute_) = 0
				_aProcessedAttrs_ + _cAttribute_
				ProcessAttributeChange(_cAttribute_, _cOldValue_, _newValue_)
			ok
		next
		
		aPendingChanges = []


	def TriggerAttributeWatchers(_cAttribute_, oldValue, _newValue_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenAttr_ = len(aAttributeWatchers)
	
	    for i = 1 to _nLenAttr_
	        if aAttributeWatchers[i][1] = _cAttribute_
	            try
	                f = aAttributeWatchers[i][2]
	                call f(this, _cAttribute_, oldValue, _newValue_)  # Pass 'this' as first parameter
	            catch
	                # Handle watcher error based on error handling mode
	                if DEFAULT_ERROR_HANDLING = ERROR_LOG
	                    # Log the error
	                ok
	            done
	        ok
	    next


	def UpdateDependentComputedAttributes(_cChangedAttribute_)
		_cChangedAttribute_ = StzLower(_cChangedAttribute_)
		_nLenAttr_ = len(aComputedAttributes)

		for i = 1 to _nLenAttr_
			_cAttribute_ = aComputedAttributes[i][1]
			_fnComputer_ = aComputedAttributes[i][2]
			_aDependencies_ = aComputedAttributes[i][3]
			
			if find(_aDependencies_, _cChangedAttribute_) > 0
				ComputeAttribute(_cAttribute_)
			ok
		next

	def UpdateBoundAttributes(_cAttribute_, _newValue_)
		_cAttribute_ = StzLower(_cAttribute_)
		_nLenAttr_ = len(aAttributeBindings)

		for i = 1 to _nLenAttr_
			_cSourceAttr_ = aAttributeBindings[i][1]
			_oTargetObj_ = aAttributeBindings[i][2]
			_cTargetAttr_ = aAttributeBindings[i][3]

			if StzLower(_cSourceAttr_) = StzLower(_cAttribute_)
				try
					if DEFAULT_BINDING_MODE = BIND_ONE_WAY
						_oTargetObj_.SetAttributeValue(_cTargetAttr_, _newValue_)
					ok
				catch
					# Handle binding error based on error handling mode
					if DEFAULT_ERROR_HANDLING = ERROR_LOG
						# Log binding error
					ok
				done
			ok
		next


	def ComputeAttribute(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenAttr_ = len(aComputedAttributes)
	
	    for i = 1 to _nLenAttr_
	        if aComputedAttributes[i][1] = _cAttribute_
	            _fnComputer_ = aComputedAttributes[i][2]
	            try
	                _cOldValue_ = GetAttributeValue(_cAttribute_)
	                _newValue_ = call _fnComputer_(this)  # Pass 'this' as parameter
	
	                # Set the computed value directly without triggering change processing
	                SetAttributeInStorage(_cAttribute_, _newValue_)
	                UpdateAttributeCache(_cAttribute_, _newValue_)
	                
	                # Set as object attribute for compatibility
	                AddAttribute(this, _cAttribute_)
	                eval("this." + _cAttribute_ + " = newValue")
	
	                # Only trigger watchers for computed attributes (no duplicate processing)
	                TriggerAttributeWatchers(_cAttribute_, _cOldValue_, _newValue_)
	
	            catch
	                # Handle computation error based on error handling mode
	                if DEFAULT_ERROR_HANDLING = ERROR_LOG
	                    # Log computation error
	                ok
	            done
	            exit
	        ok
	    next
