# Reactive Object System for Softanza Library
# Integrates with existing stzReactive system and libuv infrastructure

# This reactive object system provides:
#  1. Full integration with Softanza's libuv-based reactive system
#  2. Seamless use of existing timers, tasks, and streams
#  3. Natural Ring syntax using object access hooks
#  4. Property watching, computed properties, and object binding
#  5. Async property updates using Softanza tasks
#  6. Batch updates for performance
#  7. Debounced property changes using Softanza timers
#  8. Property change streams using Softanza streams
#  9. Comprehensive error handling and recovery
# 10. Wrapper support for existing objects

# =============================================================================
# CORE REACTIVE OBJECT BASE CLASS
# =============================================================================

class stzReactiveObject

	# Core reactive infrastructure
	engine = NULL
	objectManager = NULL
	
	# Property watching system
	aPropertyWatchers = []     # [property, callback] pairs
	aComputedProperties = []   # [property, computer_func, dependencies]
	aPropertyBindings = []     # [source_prop, target_obj, target_prop]
	aAsyncOperations = []      # Pending async property operations
	
	# State management
	bReactiveMode = True
	lBatchMode = False
	aPendingChanges = []       # Changes accumulated during batch mode
	
	# Change tracking
	aPropertyValues = []       # Cache of current property values for change detection
	
	def Init(reactiveEngine, objectManager)
		engine = reactiveEngine
		this.objectManager = objectManager
		aPropertyWatchers = []
		aComputedProperties = []
		aPropertyBindings = []
		aAsyncOperations = []
		aPendingChanges = []
		aPropertyValues = []
		bReactiveMode = True
		lBatchMode = False

	# Ring's object access hooks - integrate with reactive system
	def BraceStart()
		if bReactiveMode
			# Object access started - could trigger lazy loading, validation, etc.
			objectManager.NotifyObjectAccess(self, "start", "")
		ok

	def BraceEnd()
		if bReactiveMode
			# Object update completed - process all accumulated reactions
			ProcessPendingReactions()
			objectManager.NotifyObjectAccess(self, "end", "")
		ok

	def BraceError()
		# Handle reactive errors gracefully
		cError = cCatchError
		objectManager.NotifyObjectAccess(self, "error", cError)
		
		# Try to recover or log the error
		for aOperation in aAsyncOperations
			if len(aOperation) >= 5 and aOperation[5] != NULL  # Error handler exists
				try
					f = aOperation[5]
					call f(cError)
				catch
					# Error in error handler - just log it
				done
			ok
		next

	# Universal property setter with full reactive capabilities
	def SetAttribute(cProperty, newValue)
		AddAttribute(this, cProperty)
		
		# Check cache first, then current value
		nIndex = FindPropertyInCache(cProperty)
		if nIndex > 0
			cOldValue = aPropertyValues[nIndex][2]
		else
			cOldValue = GetPropertyValue(cProperty)
		ok
		
		# Set the actual property value
		eval("this." + cProperty + " = newValue")
		
		if bReactiveMode and cOldValue != newValue
			# Update our property cache
			UpdatePropertyCache(cProperty, newValue)
			
			if lBatchMode
				# Accumulate change for batch processing
				aPendingChanges + [cProperty, cOldValue, newValue]
			else
				# Process change immediately
				ProcessPropertyChange(cProperty, cOldValue, newValue)
			ok
		ok

	def GetAttribute(cProperty)
		value = GetPropertyValue(cProperty)
		
		if bReactiveMode
			# Could implement access logging, lazy loading, etc.
			objectManager.NotifyPropertyAccess(self, cProperty, "read")
		ok
		
		return value

	#-----------------------#
	#  PUBLIC REACTIVE API  #
	#-----------------------#

	# Watch property changes (integrates with Softanza timer system)
	def Watch(cProperty, fnCallback)
		aPropertyWatchers + [cProperty, fnCallback]
		return self

	# Create computed property that auto-updates
	def Computed(cProperty, fnComputer, aDependencies)
		aComputedProperties + [cProperty, fnComputer, aDependencies]
		
		# Initial computation
		ComputeProperty(cProperty)
		return self

	# Bind property to another reactive object
	def BindTo(oTargetObject, cSourceProperty, cTargetProperty)
		if cTargetProperty = NULL
			cTargetProperty = cSourceProperty
		ok
		
		# Ensure target property exists
		addattribute(oTargetObject, cTargetProperty)
		
		aPropertyBindings + [cSourceProperty, oTargetObject, cTargetProperty]
		
		# Initial sync
		sourceValue = GetPropertyValue(cSourceProperty)
		eval("oTargetObject." + cTargetProperty + " = sourceValue")
		return self

	# Async property update (uses Softanza task system)
	def SetAsync(cProperty, newValue, fnSuccess, fnError)
		taskId = "prop_" + cProperty + "_" + string(random(999999))
		
		# Create task using Softanza engine
		task = new stzReactiveTask(taskId, func {
			# Simulate async operation - could be validation, network call, etc.
			return newValue
		}, engine)
		
		task.Then_(func result {
			# Success - update property
			eval("this." + cProperty + " = result")
			if fnSuccess != NULL
				call fnSuccess(result)
			ok
		})
		
		task.Catch_(func error {
			# Error - call error handler
			if error != NULL
				call fnError(error)
			ok
		})
		
		# Store operation reference
		aAsyncOperations + [cProperty, newValue, fnSuccess, fnError, task]
		
		# Execute task
		task.Execute()
		return task

	# Batch multiple property updates (more efficient)
	def Batch(fnUpdates)
		lBatchMode = True
		aPendingChanges = []
		
		try
			call fnUpdates()
		catch
			objectManager.NotifyObjectAccess(self, "batch_error", CatchError())
		done
		
		lBatchMode = False
		
		# Process all accumulated changes at once
		ProcessBatchChanges()
		return self

	# Create reactive stream from property changes
	def StreamProperty(cProperty)
		streamId = lower(classname(self)) + "_" + cProperty + "_" + string(random(999999))
		stream = engine.mainReactive.CreateStream(streamId, "manual")
		
		# Watch property and emit to stream
		Watch(cProperty, func(prop, oldVal, newVal) {
			aData = []
			aData + ["property", prop]
			aData + ["oldValue", oldVal] 
			aData + ["newValue", newVal]
			stream.Emit(aData)
		})
		
		return stream

	# Debounce property changes (uses Softanza timers)
	def DebounceProperty(cProperty, nDelay, fnCallback)
		currentTimer = NULL
		
		Watch(cProperty, func(prop, oldVal, newVal) {
			# Clear existing timer
			if currentTimer != NULL
				engine.mainReactive.ClearInterval(currentTimer)
			ok
			
			# Set new timer
			currentTimer = engine.mainReactive.SetTimeout(func {
				call fnCallback(prop, oldVal, newVal)
				currentTimer = NULL
			}, nDelay)
		})
		
		return self

	# INTERNAL REACTIVE PROCESSING
	#-----------------------------

	private

	def GetPropertyValue(cProperty)
		try
			return eval("this." + cProperty)
		catch
			return NULL
		done

	def UpdatePropertyCache(cProperty, value)
		# Update our cached property values for change detection
		nIndex = FindPropertyInCache(cProperty)
		if nIndex > 0
			aPropertyValues[nIndex][2] = value
		else
			aPropertyValues + [cProperty, value]
		ok

	def FindPropertyInCache(cProperty)
		for i = 1 to len(aPropertyValues)
			if aPropertyValues[i][1] = cProperty
				return i
			ok
		next
		return 0

	def ProcessPropertyChange(cProperty, cOldValue, newValue)
		# Notify watchers
		TriggerPropertyWatchers(cProperty, cOldValue, newValue)
		
		# Update computed properties
		UpdateDependentComputedProperties(cProperty)
		
		# Update bound properties
		UpdateBoundProperties(cProperty, newValue)

	def ProcessPendingReactions()
		# Process any accumulated reactions from this update cycle
		if len(aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	def ProcessBatchChanges()
		# Group changes by property for efficient processing
		aProcessedProps = []
		
		for aChange in aPendingChanges
			cProperty = aChange[1]
			cOldValue = aChange[2] 
			newValue = aChange[3]
			
			# Only process each property once (use latest value)
			if find(aProcessedProps, cProperty) = 0
				aProcessedProps + cProperty
				ProcessPropertyChange(cProperty, cOldValue, newValue)
			ok
		next
		
		aPendingChanges = []

	def TriggerPropertyWatchers(cProperty, cOldValue, newValue)
		for aWatcher in aPropertyWatchers
			if aWatcher[1] = cProperty
				try
					f = aWatcher[2]
					call f(cProperty, cOldValue, newValue)
				catch
					objectManager.NotifyObjectAccess(self, "watcher_error", CatchError())
				done
			ok
		next

	def UpdateDependentComputedProperties(cChangedProperty)
		for aComputed in aComputedProperties
			cProperty = aComputed[1]
			fnComputer = aComputed[2]
			aDependencies = aComputed[3]
			
			# Check if this computed property depends on the changed property
			if find(aDependencies, cChangedProperty) > 0
				ComputeProperty(cProperty)
			ok
		next

	def ComputeProperty(cProperty)
		for aComputed in aComputedProperties
			if aComputed[1] = cProperty
				fnComputer = aComputed[2]
				try
					newValue = call fnComputer()
					cOldValue = GetPropertyValue(cProperty)
					eval("this." + cProperty + " = newValue")
					
					# Trigger reactions for computed property change
					if newValue != cOldValue
						UpdatePropertyCache(cProperty, newValue)
						TriggerPropertyWatchers(cProperty, cOldValue, newValue)
					ok
				catch
					objectManager.NotifyObjectAccess(self, "computed_error", CatchError())
				done
				exit
			ok
		next

	def UpdateBoundProperties(cProperty, newValue)
		for aBinding in aPropertyBindings
			cSourceProp = aBinding[1]
			oTargetObj = aBinding[2]
			cTargetProp = aBinding[3]
			
			if cSourceProp = cProperty
				try
					eval("oTargetObj." + cTargetProp + " = newValue")
				catch
					objectManager.NotifyObjectAccess(self, "binding_error", CatchError())
				done
			ok
		next

# =============================================================================
# REACTIVE OBJECT MANAGER (integrates with Softanza engine)
# =============================================================================

class stzReactiveObjectManager

	engine = NULL
	aRegisteredObjects = []
	aGlobalBindings = []
	
	def Init(reactiveEngine)
		engine = reactiveEngine
		aRegisteredObjects = []
		aGlobalBindings = []

	def RegisterObject(oReactiveObject)
		aRegisteredObjects + oReactiveObject

	def CreateBinding(oSource, cSourceProp, oTarget, cTargetProp)
		# Ensure target property exists
//		addattribute(oTarget, cTargetProp)
		
		# Create binding from source to target
		oSource.BindTo(oTarget, cSourceProp, cTargetProp)
		aGlobalBindings + [oSource, cSourceProp, oTarget, cTargetProp]

	def NotifyObjectAccess(oObject, cAccessType, cData)
		# Could be used for debugging, logging, performance monitoring
		switch cAccessType
		case "start"
			# Object access started
		case "end" 
			# Object access completed
		case "error"
			# Error occurred
		case "watcher_error"
			# Error in property watcher
		case "computed_error"
			# Error in computed property
		case "binding_error"
			# Error in property binding
		end

	def NotifyPropertyAccess(oObject, cProperty, cAccessType)
		# Could implement access logging, caching, etc.
		# For now, just a placeholder for future features

# =============================================================================
# REACTIVE OBJECT WRAPPER (for existing objects)
# =============================================================================

class stzReactiveObjectWrapper from stzReactiveObject

	wrappedObject = NULL
	
	def Init(oObject, reactiveEngine, objectManager)
		wrappedObject = oObject
		super.Init(reactiveEngine, objectManager)

	def SetAttribute(cProperty, newValue)
		# Set property on wrapped object
		addattribute(wrappedObject, cProperty)
		eval("wrappedObject." + cProperty + " = newValue")
		
		# Process reactive behavior
		super.setattribute(cProperty, newValue)

	def GetAttribute(cProperty)
		# Get from wrapped object
		return eval("wrappedObject." + cProperty)
