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


# Fixed Reactive Object System for Softanza Library

# =============================================================================
# CORE REACTIVE OBJECT BASE CLASS - FIXED VERSION
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
	bBatchMode = False
	aPendingChanges = []       # Changes accumulated during batch mode
	
	# Change tracking
	aPropertyValues = []       # Cache of current property values for change detection
	
	# FIXED: Property storage - use a hash for reliable property storage
	aProperties = []           # Internal property storage: [name, value] pairs

	def Init(reactiveEngine, objectManager)
		engine = reactiveEngine
		this.objectManager = objectManager
		aPropertyWatchers = []
		aComputedProperties = []
		aPropertyBindings = []
		aAsyncOperations = []
		aPendingChanges = []
		aPropertyValues = []
		aProperties = []        # FIXED: Initialize property storage
		bReactiveMode = True
		bBatchMode = False

	# Ring's object access hooks - integrate with reactive system
	def BraceStart()
		if bReactiveMode
			objectManager.NotifyObjectAccess(self, "start", "")
		ok

	def BraceEnd()
		if bReactiveMode
			ProcessPendingReactions()
			objectManager.NotifyObjectAccess(self, "end", "")
		ok

	def BraceError()
		cError = cCatchError
		objectManager.NotifyObjectAccess(self, "error", cError)
		
		for aOperation in aAsyncOperations
			if len(aOperation) >= 5 and aOperation[5] != NULL
				try
					f = aOperation[5]
					call f(cError)
				catch
					# Error in error handler - just log it
				done
			ok
		next

	# FIXED: Universal property setter with reliable property storage
	def SetAttribute(cProperty, newValue)
		cProperty = lower(cProperty)

		# Get old value from internal storage
		cOldValue = GetPropertyFromStorage(cProperty)
		
		# Set in internal storage
		SetPropertyInStorage(cProperty, newValue)
		
		# Also set as object attribute for compatibility
		AddAttribute(this, cProperty)
		eval("this." + cProperty + " = newValue")
		
		if bReactiveMode and cOldValue != newValue

			# Update our property cache
			UpdatePropertyCache(cProperty, newValue)
			
			if bBatchMode
				# Accumulate change for batch processing
				aPendingChanges + [cProperty, cOldValue, newValue]
			else
				# Process change immediately
				ProcessPropertyChange(cProperty, cOldValue, newValue)
			ok
		ok

	def @(paAttr)
		This.SetAttribute(paAttr[1], paAttr[2])

	# FIXED: Get attribute from internal storage first, then object attribute
	def GetAttribute(cProperty)
		cProperty = lower(cProperty)

		# Get from internal storage first
		value = GetPropertyFromStorage(cProperty)
		
		if bReactiveMode
			objectManager.NotifyPropertyAccess(self, cProperty, "read")
		ok
		
		return value

	def GetPropertyValue(cProperty)
		cProperty = lower(cProperty)
		return GetPropertyFromStorage(cProperty)

	#-----------------------#
	#  PUBLIC REACTIVE API  #
	#-----------------------#

	# Watch property changes
	def Watch(cProperty, fnCallback)
		cProperty = lower(cProperty)
		aPropertyWatchers + [cProperty, fnCallback]
		return self

	# Create computed property that auto-updates
	def Computed(cProperty, fnComputer, aDependencies)
		cProperty = lower(cProperty)
		aComputedProperties + [cProperty, fnComputer, aDependencies]
		
		# Initial computation
		ComputeAttribute(cProperty)
		return self

	# Bind property to another reactive object
	def BindTo(oTargetObject, cSourceProperty, cTargetProperty)
		if cTargetProperty = NULL
			cTargetProperty = cSourceProperty
		ok

		cSourceProperty = lower(cSourceProperty)
		cTargetProperty = lower(cTargetProperty)

		aPropertyBindings + [cSourceProperty, oTargetObject, cTargetProperty]
		
		# Initial sync  
		sourceValue = GetPropertyValue(cSourceProperty)
		oTargetObject.SetPropertyInStorage(cTargetProperty, sourceValue)
		AddAttribute(oTargetObject, cTargetProperty)
		eval("oTargetObject." + cTargetProperty + " = sourceValue")

	# Async property update
	def SetAsync(cProperty, newValue, fnSuccess, fnError)
		cProperty = lower(cProperty)
		taskId = "prop_" + cProperty + "_" + string(random(999999))
		
		# Ensure fnError has a value (even if NULL)
		fnErrorCallback = fnError
		if fnErrorCallback = NULL
			fnErrorCallback = func(error) { }  # Empty function
		ok
		
		task = new stzReactiveTask(taskId, func {
			return newValue
		}, engine)
		
		task.Then_(func result {
			SetAttribute(cProperty, result)
			if fnSuccess != NULL
				call fnSuccess(result)
			ok
		})
		
		task.Catch_(func error {
			call fnErrorCallback(error)
		})
		
		aAsyncOperations + [cProperty, newValue, fnSuccess, task, fnErrorCallback]
		task.Execute()
		return task

	# FIXED: Batch multiple property updates
	def Batch(fnUpdates)
		bBatchMode = True
		aPendingChanges = []
		
		try
			call fnUpdates()
		catch
			objectManager.NotifyObjectAccess(self, "batch_error", CatchError())
		done
		
		bBatchMode = False
		
		# Process all accumulated changes at once
		ProcessBatchChanges()
		return self

	# Create reactive stream from property changes
	def StreamAttribute(cProperty)

		cProperty = lower(cProperty)
		
		streamId = lower(classname(self)) + "_" + cProperty + "_" + string(random(999999))
		stream = engine.mainReactive.CreateStream(streamId, "manual")
		
		Watch(cProperty, func(prop, oldVal, newVal) {
			aData = []
			aData + ["property", prop]
			aData + ["oldValue", oldVal] 
			aData + ["newValue", newVal]
			stream.Emit(aData)
		})
		
		return stream

	# Debounce property changes
	def DebounceAttribute(cProperty, nDelay, fnCallback)

		cProperty = lower(cProperty)
		
		currentTimer = NULL
		
		Watch(cProperty, func(prop, oldVal, newVal) {
			if currentTimer != NULL
				engine.mainReactive.ClearInterval(currentTimer)
			ok
			
			currentTimer = engine.mainReactive.SetTimeout(func {
				call fnCallback(prop, oldVal, newVal)
				currentTimer = NULL
			}, nDelay)
		})
		
		return self

	# FIXED: Compute property method
	def ComputeAttribute(cProperty)
		cProperty = lower(cProperty)

		for aComputed in aComputedProperties
			if aComputed[1] = cProperty
				fnComputer = aComputed[2]
				try
					newValue = call c()
					cOldValue = GetPropertyValue(cProperty)
					
					# Set the computed value
					SetPropertyInStorage(cProperty, newValue)
					
					# Set as object attribute too
					AddAttribute(this, cProperty)
					# Process the property change to trigger bindings
					if bReactiveMode and newValue != cOldValue
					    ProcessPropertyChange(cProperty, cOldValue, newValue)
					ok
				catch
					objectManager.NotifyObjectAccess(self, "computed_error", CatchError())
				done
				exit
			ok
		next

	# INTERNAL REACTIVE PROCESSING
	#-----------------------------

	private

	def GetPropertyFromStorage(cProperty)
		cProperty = lower(cProperty)

		for aProp in aProperties
			if aProp[1] = cProperty
				return aProp[2]
			ok
		next
		return ""  # Default empty value

	def SetPropertyInStorage(cProperty, value)
		cProperty = lower(cProperty)

		# Find existing property
		for i = 1 to len(aProperties)
			if aProperties[i][1] = cProperty
				aProperties[i][2] = value
				return
			ok
		next
		# Property doesn't exist, add it
		aProperties + [cProperty, value]

	def UpdatePropertyCache(cProperty, value)
		cProperty = lower(cProperty)
		nIndex = FindPropertyInCache(cProperty)
		if nIndex > 0
			aPropertyValues[nIndex][2] = value
		else
			aPropertyValues + [cProperty, value]
		ok

	def FindPropertyInCache(cProperty)
		cProperty = lower(cProperty)
		for i = 1 to len(aPropertyValues)
			if aPropertyValues[i][1] = cProperty
				return i
			ok
		next
		return 0

	def ProcessPropertyChange(cProperty, oldValue, newValue)
		cProperty = lower(cProperty)

		# Notify watchers
		TriggerPropertyWatchers(cProperty, oldValue, newValue)
		
		# Update computed properties
		UpdateDependentComputedProperties(cProperty)
		
		# Update bound properties
		UpdateBoundProperties(cProperty, newValue)

	def ProcessPendingReactions()
		if len(aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	def ProcessBatchChanges()
		aProcessedProps = []
		
		for aChange in aPendingChanges
			cProperty = aChange[1]
			cOldValue = aChange[2] 
			newValue = aChange[3]
			
			if find(aProcessedProps, cProperty) = 0
				aProcessedProps + cProperty
				ProcessPropertyChange(cProperty, cOldValue, newValue)
			ok
		next
		
		aPendingChanges = []

	def TriggerPropertyWatchers(cProperty, oldValue, newValue)
		cProperty = lower(cProperty)

		for aWatcher in aPropertyWatchers
			if aWatcher[1] = cProperty
				try
					f = aWatcher[2]
					call f(cProperty, oldValue, newValue)
				catch
					objectManager.NotifyObjectAccess(self, "watcher_error", CatchError())
				done
			ok
		next

	def UpdateDependentComputedProperties(cChangedProperty)
		cChangedProperty = lower(cChangedProperty)

		for aComputed in aComputedProperties
			cProperty = aComputed[1]
			fnComputer = aComputed[2]
			aDependencies = aComputed[3]
			
			if find(aDependencies, cChangedProperty) > 0
				ComputeAttribute(cProperty)
			ok
		next

	def UpdateBoundProperties(cProperty, newValue)
		cProperty = lower(cProperty)
		for aBinding in aPropertyBindings
			cSourceProp = aBinding[1]
			oTargetObj = aBinding[2]
			cTargetProp = aBinding[3]

			if lower(cSourceProp) = lower(cProperty)
				try
					oTargetObj.SetProperty(cTargetProp, newValue)
				catch
					objectManager.NotifyObjectAccess(self, "binding_error", CatchError())
				done
			ok
		next

# =============================================================================
# REACTIVE OBJECT MANAGER - FIXED VERSION
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

	# FIXED: Create binding method
	def CreateBinding(oSource, cSourceProp, oTarget, cTargetProp)

		cSourceProp = lower(cSourceProp)
		cTargetProp = lower(cTargetProp)

		# Create binding from source to target
		oSource.BindTo(oTarget, cSourceProp, cTargetProp)
		aGlobalBindings + [oSource, cSourceProp, oTarget, cTargetProp]

	def NotifyObjectAccess(oObject, cAccessType, cData)
		cAccessType = lower(cAccessType)

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
		#TODO// Placeholder for future features

# =============================================================================
# REACTIVE OBJECT WRAPPER - FIXED VERSION
# =============================================================================

class stzReactiveObjectWrapper from stzReactiveObject

	wrappedObject = NULL
	
	def Init(oObject, reactiveEngine, objectManager)
		wrappedObject = oObject
		super.Init(reactiveEngine, objectManager)

	def SetAttribute(cProperty, newValue)
		cProperty = lower(cProperty)

		# Set property on wrapped object
		addattribute(wrappedObject, cProperty)
		eval("wrappedObject." + cProperty + " = newValue")
		
		# Process reactive behavior
		super.setAttribute(cProperty, newValue)

	def GetAttribute(cProperty)
		cProperty = lower(cProperty)

		# Try wrapped object first, then internal storage
		try
			return eval("wrappedObject." + cProperty)
		catch
			return super.getattribute(cProperty)
		done
