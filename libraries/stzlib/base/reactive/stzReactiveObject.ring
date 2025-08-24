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
	    aObjectAttrs = AttributesXT(wrappedObject)
	    nLen = len(aObjectAttrs)
	
	    for i = 1 to nLen
	            SetAttributeInStorage(aObjectAttrs[i][1], aObjectAttrs[i][2])
	            UpdateAttributeCache(aObjectAttrs[i][1], aObjectAttrs[i][2])
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
		cError = cCatchError
		
		# Handle errors in async operations
		nLenOp = len(aAsyncOperations)
		for i = 1 to nLenOp
			if len(aAsyncOperations[i]) >= 5 and aAsyncOperations[i][5] != NULL
				try
					f = aAsyncOperations[i][5]
					call f(cError)
				catch
					# Error in error handler - just log it (#tODO)
				done
			ok
		next

	# Universal Attribute setter
	def SetAttribute(cAttribute, newValue)
		cAttribute = lower(cAttribute)

		# Get old value
		cOldValue = GetAttributeValue(cAttribute)
		
		# Set the new value
		SetAttributeValue(cAttribute, newValue)
		
		if This.bReactiveMode = REACTIVE_ON and cOldValue != newValue
			# Update Attribute cache
			This.UpdateAttributeCache(cAttribute, newValue)
			
			if this.bBatchMode = BATCH_MODE_ON
				# Accumulate change for batch processing
				this.aPendingChanges + [cAttribute, cOldValue, newValue]
			else
				# Process change immediately
				This.ProcessAttributeChange(cAttribute, cOldValue, newValue)
			ok
		ok

	def @(paAttr)
		This.SetAttribute(paAttr[1], paAttr[2])

	# Universal Attribute getter
	def GetAttribute(cAttribute)
		cAttribute = lower(cAttribute)
		value = GetAttributeValue(cAttribute)
		
		if bReactiveMode = REACTIVE_ON
			# Notify reactive system of Attribute access
		ok
		
		return value

	# Core Attribute access methods
	def GetAttributeValue(cAttribute)
	    cAttribute = lower(cAttribute)
	    
	    # Check cache first
	    nIndex = FindAttributeInCache(cAttribute)
	    if nIndex > 0
	        return aCachedAttributeValues[nIndex][2]
	    ok
	    
	    if wrappedObject != OBJECT_STANDALONE
	        # Wrapper mode: get from wrapped object
	        if hasattribute(wrappedObject, cAttribute)
	            return eval("wrappedObject." + cAttribute)
	        else
	            # Try storage if not on wrapped object
	            return GetAttributeFromStorage(cAttribute)
	        ok
	    else
	        # Standalone mode: get from internal storage
	        return GetAttributeFromStorage(cAttribute)
	    ok
	
	def SetAttributeValue(cAttribute, value)
		cAttribute = lower(cAttribute)
		
		if wrappedObject != OBJECT_STANDALONE
			# Wrapper mode: set on wrapped object
			addattribute(wrappedObject, cAttribute)
			eval("wrappedObject." + cAttribute + " = value")
		ok
		
		# Always set in internal storage for consistency
		SetAttributeInStorage(cAttribute, value)
		
		# Also set as object attribute for compatibility
		AddAttribute(this, cAttribute)
		eval("this." + cAttribute + " = value")

	#-----------------------#
	#  PUBLIC REACTIVE API  #
	#-----------------------#

	# Watch Attribute changes
	def Watch(cAttribute, fnCallback)
		cAttribute = lower(cAttribute)
		aAttributeWatchers + [cAttribute, fnCallback]
		return self

	# Create computed Attribute that auto-updates
	def Computed(cAttribute, fnComputer, aDependencies)
		cAttribute = lower(cAttribute)
		aComputedAttributes + [cAttribute, fnComputer, aDependencies]
		
		# Initial computation
		ComputeAttribute(cAttribute)
		return self

	# Bind Attribute to another reactive object
	def BindTo(oTargetObject, cSourceAttribute, cTargetAttribute)
		if cTargetAttribute = NULL
			cTargetAttribute = cSourceAttribute
		ok

		cSourceAttribute = lower(cSourceAttribute)
		cTargetAttribute = lower(cTargetAttribute)

		aAttributeBindings + [cSourceAttribute, oTargetObject, cTargetAttribute]
		
		# Initial sync with immediate binding
		sourceValue = GetAttributeValue(cSourceAttribute)
		if DEFAULT_SYNC_MODE = BIND_AUTO_SYNC
			oTargetObject.SetAttributeValue(cTargetAttribute, sourceValue)
		ok

	# Async Attribute update
	def SetAsync(cAttribute, newValue, fnSuccess, fnError)
		cAttribute = lower(cAttribute)
		taskId = "attr_" + cAttribute + "_" + string(random(999999))
		
		# Ensure fnError has a value for error handling
		fnErrorCallback = fnError
		if fnErrorCallback = NULL
			fnErrorCallback = func(error) { }
		ok
		
		task = new stzReactiveTask(taskId, func {
			return newValue
		}, this)
		
		task.Then_(func result {
			SetAttribute(cAttribute, result)
			if fnSuccess != NULL
				call fnSuccess(result)
			ok
		})
		
		task.Catch_(func error {
			call fnErrorCallback(error)
		})
		
		aAsyncOperations + [cAttribute, newValue, fnSuccess, task, fnErrorCallback]
		task.Execute()
		return task

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
	def StreamAttribute(cAttribute)
		cAttribute = lower(cAttribute)
		
		streamId = lower(classname(self)) + "_" + cAttribute + "_" + random(999999)
		stream = this.engine.CreateStream(streamId, "manual")
		
		Watch(cAttribute, func(attr, oldVal, newVal) {
			aData = []
			aData + ["Attribute", attr]
			aData + ["oldValue", oldVal] 
			aData + ["newValue", newVal]
			aData + ["changeType", CHANGE_TYPE_VALUE]
			stream.Emit(aData)
		})
		
		return stream

	# Debounce Attribute changes
	def DebounceAttribute(cAttribute, nDelay, fnCallback)
		cAttribute = lower(cAttribute)
		
		currentTimer = NULL
		
		Watch(cAttribute, func(attr, oldVal, newVal) {
			if currentTimer != NULL
				ClearInterval(currentTimer)
			ok
			
			currentTimer = SetTimeout(func {
				call fnCallback(attr, oldVal, newVal)
				currentTimer = NULL
			}, nDelay)
		})
		
		return self

	# Factory method for creating reactive objects
	def Reactivate(existingObject)
		return new stzReactiveObject(existingObject, this)

	#-------------------#
	#  UTILITY METHODS  #
	#-------------------#

	def GetAttributeFromStorage(cAttribute)
		cAttribute = lower(cAttribute)

		# Find in internal storage
		nLenAttr = len(aAttributesOfStandaloneObjects)

		for i = 1 to nLenAttr
			if aAttributesOfStandaloneObjects[i][1] = cAttribute
				return aAttributesOfStandaloneObjects[i][2]
			ok
		next
		
		return ""  # Default empty value

	def SetAttributeInStorage(cAttribute, value)
		cAttribute = lower(cAttribute)

		# Find existing Attribute
		nLenAttr = len(aAttributesOfStandaloneObjects)
		for i = 1 to nLenAttr
			if aAttributesOfStandaloneObjects[i][1] = cAttribute
				aAttributesOfStandaloneObjects[i][2] = value
				return
			ok
		next
		# Attribute doesn't exist, add it
		aAttributesOfStandaloneObjects + [cAttribute, value]

	def UpdateAttributeCache(cAttribute, value)
	    cAttribute = lower(cAttribute)
	    nIndex = FindAttributeInCache(cAttribute)
	    if nIndex > 0
	        aCachedAttributeValues[nIndex][2] = value
	    else
	        aCachedAttributeValues + [cAttribute, value]
	    ok

	def FindAttributeInCache(cAttribute)
	    cAttribute = lower(cAttribute)
	    nLenCacheAttr = len(aCachedAttributeValues)
	    for i = 1 to nLenCacheAttr
	        if aCachedAttributeValues[i][1] = cAttribute
	            return i
	        ok
	    next
	    return 0

	def ProcessAttributeChange(cAttribute, oldValue, newValue)
		cAttribute = lower(cAttribute)

		# Notify watchers with immediate processing
		if DEFAULT_WATCH_MODE = WATCH_IMMEDIATE
			TriggerAttributeWatchers(cAttribute, oldValue, newValue)
		ok
		
		# Update computed Attributes
		UpdateDependentComputedAttributes(cAttribute)
		
		# Update bound Attributes
		UpdateBoundAttributes(cAttribute, newValue)

	def ProcessPendingReactions()
		if len(aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	def ProcessBatchChanges()
		aProcessedAttrs = []
		nLenPend = len(aPendingChanges)

		for i = 1 to nLenPend
			cAttribute = aPendingChanges[i][1]
			cOldValue = aPendingChanges[i][2] 
			newValue = aPendingChanges[i][3]
			
			if find(aProcessedAttrs, cAttribute) = 0
				aProcessedAttrs + cAttribute
				ProcessAttributeChange(cAttribute, cOldValue, newValue)
			ok
		next
		
		aPendingChanges = []

	def TriggerAttributeWatchers(cAttribute, oldValue, newValue)
		cAttribute = lower(cAttribute)
		nLenAttr = len(aAttributeWatchers)

		for i = 1 to nLenAttr
			if aAttributeWatchers[i][1] = cAttribute
				try
					f = aAttributeWatchers[i][2]
					call f(cAttribute, oldValue, newValue)
				catch
					# Handle watcher error based on error handling mode
					if DEFAULT_ERROR_HANDLING = ERROR_LOG
						# Log the error
					ok
				done
			ok
		next

	def UpdateDependentComputedAttributes(cChangedAttribute)
		cChangedAttribute = lower(cChangedAttribute)
		nLenAttr = len(aComputedAttributes)

		for i = 1 to nLenAttr
			cAttribute = aComputedAttributes[i][1]
			fnComputer = aComputedAttributes[i][2]
			aDependencies = aComputedAttributes[i][3]
			
			if find(aDependencies, cChangedAttribute) > 0
				ComputeAttribute(cAttribute)
			ok
		next

	def UpdateBoundAttributes(cAttribute, newValue)
		cAttribute = lower(cAttribute)
		nLenAttr = len(aAttributeBindings)

		for i = 1 to nLenAttr
			cSourceAttr = aAttributeBindings[i][1]
			oTargetObj = aAttributeBindings[i][2]
			cTargetAttr = aAttributeBindings[i][3]

			if lower(cSourceAttr) = lower(cAttribute)
				try
					if DEFAULT_BINDING_MODE = BIND_ONE_WAY
						oTargetObj.SetAttributeValue(cTargetAttr, newValue)
					ok
				catch
					# Handle binding error based on error handling mode
					if DEFAULT_ERROR_HANDLING = ERROR_LOG
						# Log binding error
					ok
				done
			ok
		next

	def ComputeAttribute(cAttribute)

		cAttribute = lower(cAttribute)
		nLenAttr = len(aComputedAttributes)

		for i = 1 to nLenAttr
			if aComputedAttributes[i][1] = cAttribute

				fnComputer = aComputedAttributes[i][2]
				try
					cOldValue = GetAttributeValue(cAttribute)
					newValue = call fnComputer()

					# Set the computed value
					SetAttributeValue(cAttribute, newValue)

					# Trigger watchers for computed attributes
					TriggerAttributeWatchers(cAttribute, cOldValue, newValue)

					# Process the Attribute change to trigger bindings
					if bReactiveMode = REACTIVE_ON and newValue != cOldValue
						ProcessAttributeChange(cAttribute, cOldValue, newValue)
					ok

				catch
					# Handle computation error based on error handling mode
					if DEFAULT_ERROR_HANDLING = ERROR_LOG
						# Log computation error
					ok
				done
				exit
			ok
		next
