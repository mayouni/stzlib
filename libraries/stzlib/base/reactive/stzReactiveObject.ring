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

# R54-FIX GLOBAL HELPERS (2026-07-14): Ring's reflection builtins
# (attributes/getattribute/hasattribute/setattribute/addattribute)
# resolve to inherited METHODS inside a class body (the method-vs-
# builtin trap), which raised R20 and crashed ReactivateObject. Doing
# the reflection in GLOBAL funcs -- where the builtins ARE builtins --
# is the standing cure (see stzDeepList's _Dpl* delegation).
func StzReactiveHarvestAttrs(pObj)
	_aOut_ = []
	_acN_ = attributes(pObj)
	_nH_ = len(_acN_)
	for _iH_ = 1 to _nH_
		_aOut_ + [ _acN_[_iH_], getattribute(pObj, _acN_[_iH_]) ]
	next
	return _aOut_

func StzReactiveSetAttr(pObj, pcName, pValue)
	if NOT hasattribute(pObj, pcName)
		addattribute(pObj, pcName)
	ok
	setattribute(pObj, pcName, pValue)

# F5 UNTANGLE (2026-07-14, completes the F3 note): the class now
# COMPOSES the reactive system (`engine`) and inherits only stzObject.
# The two timer calls that used to ride the `from stzReactive`
# inheritance (StopTimer/RunAfter in WaitForAttributetoSettle) route
# through `engine.` explicitly -- one reactive system, reached one way.
class stzReactiveObject from stzObject

	# Core reactive infrastructure
	@wrappedObject = OBJECT_STANDALONE       # OBJECT_STANDALONE = standalone, not OBJECT_STANDALONE = wrapper mode
	@oEngine = ""

	# Attribute watching system
	@aAttributeWatchers = []     # [attr, @callback] pairs
	@aComputedAttributes = []   # [Attribute, computer_func, dependencies]
	@aAttributeBindings = []     # [source_attr, target_obj, target_attr]
	@aAsyncOperations = []      # Pending async Attribute operations
	@aSettleWatchers = []       # [attr, delayMs, @callback, timerId] (F5)
	
	# State management
	@bReactiveMode = DEFAULT_REACTIVE_MODE
	@bBatchMode = DEFAULT_BATCH_MODE
	@aPendingChanges = []       # Changes accumulated during batch mode
	
	# Change tracking
	@aCachedAttributeValues = []       # Cache of current Attribute values for change detection
	
	# Attribute storage - for standalone objects
	@aAttributesOfStandaloneObjects = []           # Internal Attribute storage: [name, value] pairs

	# WHAT WENT WRONG, and where.
	#
	# Five try/catch blocks in this class used to drop the error entirely --
	# three of them a bare comment, two an `if` whose whole body was a comment.
	# The cost was not theoretical: the class's own notes record a watcher bug
	# that "arity-crashed on every trigger and the error was swallowed by
	# TriggerAttributeWatchers' try/catch", and a broken eval in
	# ComputeAttribute sat behind another of them for as long as it existed.
	#
	# The record is BOUNDED and counts what it drops, so a runaway watcher
	# cannot grow it without limit and cannot quietly lose the first failure --
	# which is the one worth reading.
	@aErrors = []               # [ [ cWhere, cMsg ], ... ], newest last
	@nErrorsSeen = 0            # total, including any dropped
	@nErrorsDropped = 0
	@nMaxErrors = 50
	@fOnError = ""            # optional handler: f(cWhere, cMsg)

	#-- THE ERROR RECORD --------------------------------------------------------

	# Hand it a handler and nothing is printed: f(cWhere, cMsg).
	def OnError(fCallback)
		@fOnError = fCallback
		return This

	def Errors()
		return @aErrors

	def LastError()
		if len(@aErrors) = 0
			return ""
		ok
		return @aErrors[len(@aErrors)][2]

	# Which operation failed -- "Batch", "Watcher:name", "Computed:greeting"...
	def LastErrorWhere()
		if len(@aErrors) = 0
			return ""
		ok
		return @aErrors[len(@aErrors)][1]

	# Everything seen, not merely everything KEPT. A bounded record that
	# reported only its own length would under-count exactly when it matters.
	def ErrorCount()
		return @nErrorsSeen

	def ErrorsDropped()
		return @nErrorsDropped

	def HasErrors()
		return @nErrorsSeen > 0

	def ClearErrors()
		@aErrors = []
		@nErrorsSeen = 0
		@nErrorsDropped = 0
		return This

	# The one door every swallowed error now goes through: recorded always,
	# reported to a handler if there is one, otherwise printed unless the mode
	# in force is the one that asks for silence.
	def _RecordError(_cWhere_, _cMsg_)
		@nErrorsSeen++

		if len(@aErrors) < @nMaxErrors
			@aErrors + [ "" + _cWhere_, "" + _cMsg_ ]
		else
			@nErrorsDropped++
		ok

		if @fOnError != ""
			call @fOnError(_cWhere_, _cMsg_)

		but DEFAULT_ERROR_HANDLING != ERROR_IGNORE
			? "[stzReactiveObject." + _cWhere_ + "] " + _cMsg_
		ok

	def Init(existingObject, reactiveEngine)
	    if existingObject != ""
	        @wrappedObject = existingObject
	    else
	        @wrappedObject = OBJECT_STANDALONE
	    ok
	    @oEngine = reactiveEngine

   
	# Initialize attribute cache with wrapped object's current values.
	# R54 FIX (2026-07-14): the old line called AttributesXT(wrappedObject)
	# -- but that name resolves to an inherited 0-ARG method here, so the
	# 1-arg call raised R20 and crashed every ReactivateObject (the second
	# half of the init bug that retired the suite). Use Ring's reflection
	# builtins directly: attributes() gives the NAMES, getattribute() the
	# values. (The bare-name/method-vs-builtin trap -- see the VM-traps.)
	if @wrappedObject != OBJECT_STANDALONE
	    _aObjectAttrs_ = StzReactiveHarvestAttrs(@wrappedObject)
	    _nLen_ = len(_aObjectAttrs_)
	    for i = 1 to _nLen_
	            SetAttributeInStorage(StzLower(_aObjectAttrs_[i][1]), _aObjectAttrs_[i][2])
	            UpdateAttributeCache(StzLower(_aObjectAttrs_[i][1]), _aObjectAttrs_[i][2])
	    next
	ok

	# Ring's object access hooks - integrate with reactive system
	def BraceStart()
		if @bReactiveMode = REACTIVE_ON
			# Notify reactive system of object access start
		ok

	def BraceEnd()
		if @bReactiveMode = REACTIVE_ON
			ProcessPendingReactions()
		ok

	def BraceError()
		_cError_ = cCatchError
		
		# Handle errors in async operations
		_nLenOp_ = len(@aAsyncOperations)
		for i = 1 to _nLenOp_
			if len(@aAsyncOperations[i]) >= 5 and @aAsyncOperations[i][5] != ""
				try
					f = @aAsyncOperations[i][5]
					call f(_cError_)
				catch
					# An error raised BY an error handler. It still gets
					# recorded -- a handler that throws is exactly the case
					# nobody finds out about otherwise.
					This._RecordError("BraceError", CatchError())
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
		
		if This.@bReactiveMode = REACTIVE_ON and _cOldValue_ != _newValue_
			# Update Attribute cache
			This.UpdateAttributeCache(_cAttribute_, _newValue_)
			
			if this.@bBatchMode = BATCH_MODE_ON
				# Accumulate change for batch processing
				this.@aPendingChanges + [_cAttribute_, _cOldValue_, _newValue_]
			else
				# Process change immediately
				This.ProcessAttributeChange(_cAttribute_, _cOldValue_, _newValue_)
			ok
		ok

		# Watch() and Computed() both answer the object; this did not, so a
		# configuration chain broke at the one call most likely to be in it.
		return This

	def @(paAttr)
		This.SetAttribute(paAttr[1], paAttr[2])

	# Universal Attribute getter
	def GetAttribute(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)
		_value_ = GetAttributeValue(_cAttribute_)
		
		if @bReactiveMode = REACTIVE_ON
			# Notify reactive system of Attribute access
		ok
		
		return _value_

	# Core Attribute access methods
	def GetAttributeValue(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    
	    # Check cache first
	    _nIndex_ = FindAttributeInCache(_cAttribute_)
	    if _nIndex_ > 0
	        return @aCachedAttributeValues[_nIndex_][2]
	    ok
	    
	    if @wrappedObject != OBJECT_STANDALONE
	        # Wrapper mode: get from wrapped object
	        if hasattribute(@wrappedObject, _cAttribute_)
	            return eval("@wrappedObject." + _cAttribute_)
	        else
	            # Try storage if not on wrapped object
	            return GetAttributeFromStorage(_cAttribute_)
	        ok
	    else
	        # Standalone mode: get from internal storage
	        return GetAttributeFromStorage(_cAttribute_)
	    ok
	
	def SetAttributeValue(_cAttribute_, _value_)
		# R54 FIX (2026-07-14): the old body called addattribute() on
		# EVERY set -- re-adding an existing attribute REDEFINES it, and
		# that init/redefinition bug retired 8 of 9 reactive-object
		# tests. Guard with hasattribute; and use setattribute() (Ring's
		# reflection setter) instead of eval("... = value") -- the eval
		# strings referenced a bare 'value' that never bound _value_.
		_cAttribute_ = StzLower(_cAttribute_)

		if @wrappedObject != OBJECT_STANDALONE
			# Wrapper mode: set on wrapped object (global helper: the
			# reflection builtins are builtins only outside class scope)
			StzReactiveSetAttr(@wrappedObject, _cAttribute_, _value_)
		ok

		# Always set in internal storage for consistency
		SetAttributeInStorage(_cAttribute_, _value_)

		# Also set as object attribute for compatibility
		StzReactiveSetAttr(this, _cAttribute_, _value_)

	#-----------------------#
	#  PUBLIC REACTIVE API  #
	#-----------------------#

	# Watch Attribute changes
	# A CALLBACK THAT IS NOT ONE IS REFUSED AT REGISTRATION.
	#
	# It used to be stored and only fail when the attribute next changed --
	# recorded now that the catches report, but reported against the WATCHER
	# rather than against the call that registered it. isFunction is the test
	# that works here: a Ring lambda IS a string ("_ring_anonymous_func_NNN"),
	# so isString cannot tell one from "not a function", and isFunction can.
	def Watch(_cAttribute_, fCallback)
		if NOT (isString(fCallback) and isFunction(fCallback))
			This._RecordError("Watch:" + _cAttribute_, WATCH_ERROR_NOT_A_FUNCTION)
			return This
		ok

		_cAttribute_ = StzLower(_cAttribute_)
		@aAttributeWatchers + [_cAttribute_, fCallback]
		return self

	# Create computed Attribute that auto-updates
	# The dependency list is walked by find() on every attribute change, so a
	# non-list is not a problem here -- it is a "Bad parameter type!" raised
	# from UpdateDependentComputedAttributes on some LATER, unrelated set, a
	# long way from the registration that caused it.
	def Computed(_cAttribute_, _fnComputer_, _aDependencies_)
		if NOT (isString(_fnComputer_) and isFunction(_fnComputer_))
			This._RecordError("Computed:" + _cAttribute_, COMPUTED_ERROR_NOT_A_FUNCTION)
			return This
		ok
		if NOT isList(_aDependencies_)
			This._RecordError("Computed:" + _cAttribute_, COMPUTED_ERROR_DEPS_NOT_LIST)
			return This
		ok

	    _cAttribute_ = StzLower(_cAttribute_)
	    @aComputedAttributes + [_cAttribute_, _fnComputer_, _aDependencies_]
	    
	    # Initial computation
	    ComputeAttribute(_cAttribute_)
	    return self

	# Bind Attribute to another reactive object
	# THE TARGET HAS TO BE ABLE TO TAKE THE BINDING. A plain object raised R14
	# "Calling Method without definition: setattributevalue" from inside this
	# setter, so binding to the wrong kind of thing crashed the caller instead
	# of being refused.
	def BindTo(oTargetObject, _cSourceAttribute_, _cTargetAttribute_)
		if NOT isObject(oTargetObject)
			This._RecordError("BindTo:" + _cSourceAttribute_, BIND_ERROR_TARGET_NOT_OBJECT)
			return This
		ok

		if _cTargetAttribute_ = ""
			_cTargetAttribute_ = _cSourceAttribute_
		ok

		_cSourceAttribute_ = StzLower(_cSourceAttribute_)
		_cTargetAttribute_ = StzLower(_cTargetAttribute_)

		@aAttributeBindings + [_cSourceAttribute_, oTargetObject, _cTargetAttribute_]
		
		# Initial sync with immediate binding. A target that cannot take it is
		# recorded rather than raised: the binding is already registered, and
		# UpdateBoundAttributes reports the same way on every later change.
		_sourceValue_ = GetAttributeValue(_cSourceAttribute_)
		if DEFAULT_SYNC_MODE = BIND_AUTO_SYNC
			try
				oTargetObject.SetAttributeValue(_cTargetAttribute_, _sourceValue_)
			catch
				This._RecordError("BindTo:" + _cSourceAttribute_ + "->" + _cTargetAttribute_,
				                  CatchError())
			done
		ok

		return This

	# Async Attribute update
	def SetAsync(_cAttribute_, _newValue_, fnSuccess, fnError)
		_cAttribute_ = StzLower(_cAttribute_)
		_taskId_ = "attr_" + _cAttribute_ + "_" + string(StzEngineRandomInt(0, 999999))
		
		# Ensure fnError has a value for error handling
		_fnErrorCallback_ = fnError
		if _fnErrorCallback_ = ""
			_fnErrorCallback_ = func(error) { }
		ok
		
		# FOUR arguments, not three. stzReactiveTask.init takes
		# (id, f, engine, errorMode) and this passed (id, f, this), so every
		# call raised R19 "Calling function with less number of parameters" on
		# the construction itself, before anything else could run. SetAsync had
		# never worked. The engine is @oEngine, not `this`.
		_task_ = new stzReactiveTask(_taskId_, "", @oEngine, ERROR_CALLBACK)
		
		@aAsyncOperations + [_cAttribute_, _newValue_, fnSuccess, _task_, _fnErrorCallback_]

		# THE SET HAPPENS HERE, in the open.
		#
		# There is nothing to compute -- the value is already in hand -- and the
		# two lambdas this used to lean on could not work. The task function
		# `func { return _newValue_ }` raised R24 reading a caller's local, and
		# the Then_ handler called a bare SetAttribute(...), which inside a
		# lambda's own scope is a global-function lookup rather than this
		# object's method. A Then_ handler receives one argument, so it could
		# not have been handed the object either.
		try
			This.SetAttribute(_cAttribute_, _newValue_)
			_task_.Complete(_newValue_)
			if fnSuccess != ""
				call fnSuccess(_newValue_)
			ok
		catch
			_task_.Fail(CatchError())
			This._RecordError("SetAsync:" + _cAttribute_, _task_.Error())
			call _fnErrorCallback_(_task_.Error())
		done

		return _task_

	# Batch multiple Attribute updates
	def Batch(fnUpdates)
		@bBatchMode = BATCH_MODE_ON
		@aPendingChanges = []
		
		try
			call fnUpdates()
		catch
			This._RecordError("Batch", CatchError())
		done

		@bBatchMode = BATCH_MODE_OFF

		# BATCH IS NOT ATOMIC, and cannot be made so from here. SetAttribute
		# writes the value immediately and queues only the reactive
		# NOTIFICATION, so by the time this catch runs the changes are already
		# in storage. Discarding @aPendingChanges would not undo them -- it
		# would just skip the watchers and bindings, leaving the data changed
		# and everything that reacts to it unaware. Worse than either.
		#
		# So a failed batch still propagates what it managed to change, and now
		# it REPORTS. Making Batch genuinely all-or-nothing means deferring the
		# writes themselves, which is a redesign, not an error-handling fix.
		ProcessBatchChanges()
		return self

	# Create reactive stream from Attribute changes
	def StreamAttribute(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)
		
		_streamId_ = StzLower(ring_classname(self)) + "_" + _cAttribute_ + "_" + StzEngineRandomInt(0, 999999)
		_stream_ = @oEngine.CreateStream(_streamId_)
		
		# Watcher contract is f(oSelf, attr, old, new) -- the old 3-arg
		# lambda arity-crashed on every trigger and the error was
		# swallowed by TriggerAttributeWatchers' try/catch (F5 fix).
		Watch(_cAttribute_, func(oSelf, attr, oldVal, newVal) {
			_aData_ = []
			_aData_ + ["Attribute", attr]
			_aData_ + ["oldValue", oldVal]
			_aData_ + ["newValue", newVal]
			_aData_ + ["changeType", CHANGE_TYPE_VALUE]
			_stream_.Emit(_aData_)
		})
		
		return _stream_

	# The method waits for the attribute to stop changing (settle) before
	# executing the callback.
	#
	# F5 REWRITE (2026-07-14): the old body stored the pending timer in
	# a LOCAL that a lambda "captured" -- but Ring lambdas do NOT capture
	# enclosing locals, so every trigger raised (swallowed silently by
	# TriggerAttributeWatchers' try/catch) and the feature never worked.
	# The settle state now lives ON THE OBJECT (aSettleWatchers records)
	# and the timers go to the GLOBAL detached table, which every
	# RunLoop drives. The lambda uses only its own params (oSelf!) --
	# the reason the watcher contract passes `this` first.
	def WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)
		_cAttribute_ = StzLower(_cAttribute_)
		@aSettleWatchers + [ _cAttribute_, nDelay, fCallback, "" ]
		Watch(_cAttribute_, func(oSelf, attr, oldVal, newVal) {
			oSelf.OnSettleChange(attr, oldVal, newVal)
		})
		return self

		def DebounceAttribute(_cAttribute_, nDelay, fCallback)
			return This.WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)

	# (Internal) a watched-and-settling attribute changed: restart its
	# settle timer. The user callback fires as f(attr, old, new) once
	# the value has been quiet for the configured delay.
	def OnSettleChange(cAttr, oldVal, newVal)
		_nLen_ = len(@aSettleWatchers)
		for _i_ = 1 to _nLen_
			if @aSettleWatchers[_i_][1] = cAttr
				if @aSettleWatchers[_i_][4] != ""
					StzReaxisStopTimer(@aSettleWatchers[_i_][4])
				ok
				@aSettleWatchers[_i_][4] = StzReaxisRunAfterXT(
					@aSettleWatchers[_i_][2],
					@aSettleWatchers[_i_][3],
					[ cAttr, oldVal, newVal ])
			ok
		next

	# Factory method for creating reactive objects
	def Reactivate(existingObject)
		return new stzReactiveObject(existingObject, this)

	#-------------------#
	#  UTILITY METHODS  #
	#-------------------#

	def GetAttributeFromStorage(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Find in internal storage
		_nLenAttr_ = len(@aAttributesOfStandaloneObjects)

		for i = 1 to _nLenAttr_
			if @aAttributesOfStandaloneObjects[i][1] = _cAttribute_
				return @aAttributesOfStandaloneObjects[i][2]
			ok
		next
		
		return ""  # Default empty value

	def SetAttributeInStorage(_cAttribute_, _value_)
		_cAttribute_ = StzLower(_cAttribute_)

		# Find existing Attribute
		_nLenAttr_ = len(@aAttributesOfStandaloneObjects)
		for i = 1 to _nLenAttr_
			if @aAttributesOfStandaloneObjects[i][1] = _cAttribute_
				@aAttributesOfStandaloneObjects[i][2] = _value_
				return
			ok
		next
		# Attribute doesn't exist, add it
		@aAttributesOfStandaloneObjects + [_cAttribute_, _value_]

	def UpdateAttributeCache(_cAttribute_, _value_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nIndex_ = FindAttributeInCache(_cAttribute_)
	    if _nIndex_ > 0
	        @aCachedAttributeValues[_nIndex_][2] = _value_
	    else
	        @aCachedAttributeValues + [_cAttribute_, _value_]
	    ok

	def FindAttributeInCache(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenCacheAttr_ = len(@aCachedAttributeValues)
	    for i = 1 to _nLenCacheAttr_
	        if @aCachedAttributeValues[i][1] = _cAttribute_
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
		if len(@aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	def ProcessBatchChanges()
		_aProcessedAttrs_ = []
		_nLenPend_ = len(@aPendingChanges)

		for i = 1 to _nLenPend_
			_cAttribute_ = @aPendingChanges[i][1]
			_cOldValue_ = @aPendingChanges[i][2] 
			_newValue_ = @aPendingChanges[i][3]
			
			if find(_aProcessedAttrs_, _cAttribute_) = 0
				_aProcessedAttrs_ + _cAttribute_
				ProcessAttributeChange(_cAttribute_, _cOldValue_, _newValue_)
			ok
		next
		
		@aPendingChanges = []


	def TriggerAttributeWatchers(_cAttribute_, oldValue, _newValue_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenAttr_ = len(@aAttributeWatchers)
	
	    for i = 1 to _nLenAttr_
	        if @aAttributeWatchers[i][1] = _cAttribute_
	            try
	                f = @aAttributeWatchers[i][2]
	                call f(this, _cAttribute_, oldValue, _newValue_)  # Pass 'this' as first parameter
	            catch
	                This._RecordError("Watcher:" + _cAttribute_, CatchError())
	            done
	        ok
	    next


	def UpdateDependentComputedAttributes(_cChangedAttribute_)
		_cChangedAttribute_ = StzLower(_cChangedAttribute_)
		_nLenAttr_ = len(@aComputedAttributes)

		for i = 1 to _nLenAttr_
			_cAttribute_ = @aComputedAttributes[i][1]
			_fnComputer_ = @aComputedAttributes[i][2]
			_aDependencies_ = @aComputedAttributes[i][3]
			
			if find(_aDependencies_, _cChangedAttribute_) > 0
				ComputeAttribute(_cAttribute_)
			ok
		next

	def UpdateBoundAttributes(_cAttribute_, _newValue_)
		_cAttribute_ = StzLower(_cAttribute_)
		_nLenAttr_ = len(@aAttributeBindings)

		for i = 1 to _nLenAttr_
			_cSourceAttr_ = @aAttributeBindings[i][1]
			_oTargetObj_ = @aAttributeBindings[i][2]
			_cTargetAttr_ = @aAttributeBindings[i][3]

			if StzLower(_cSourceAttr_) = StzLower(_cAttribute_)
				try
					if DEFAULT_BINDING_MODE = BIND_ONE_WAY
						_oTargetObj_.SetAttributeValue(_cTargetAttr_, _newValue_)
					ok
				catch
					This._RecordError("Binding:" + _cAttribute_ + "->" + _cTargetAttr_, CatchError())
				done
			ok
		next


	def ComputeAttribute(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenAttr_ = len(@aComputedAttributes)
	
	    for i = 1 to _nLenAttr_
	        if @aComputedAttributes[i][1] = _cAttribute_
	            _fnComputer_ = @aComputedAttributes[i][2]
	            try
	                _cOldValue_ = GetAttributeValue(_cAttribute_)
	                _newValue_ = call _fnComputer_(this)  # Pass 'this' as parameter
	
	                # Set the computed value directly without triggering change processing
	                SetAttributeInStorage(_cAttribute_, _newValue_)
	                UpdateAttributeCache(_cAttribute_, _newValue_)
	                
	                # Set as object attribute for compatibility.
	                #
	                # This was AddAttribute(this, attr) followed by an eval, and
	                # it raised on every recompute after the first: adding an
	                # attribute that already exists is R54. The catch below ate
	                # it, so what never ran was invisible -- the eval, and
	                # TriggerAttributeWatchers below it, which is why a watcher
	                # on a COMPUTED attribute never fired at all and the plain
	                # field kept the value from the first computation forever.
	                #
	                # StzReactiveSetAttr is the cure and was already in this
	                # file, written for this exact trap: it adds only when the
	                # attribute is absent, and it does the reflection from
	                # GLOBAL scope, where Ring's builtins are builtins rather
	                # than inherited methods. Using it also retires the eval,
	                # whose string had already survived one rename by naming a
	                # local that no longer existed.
	                StzReactiveSetAttr(this, _cAttribute_, _newValue_)
	
	                # Only trigger watchers for computed attributes (no duplicate processing)
	                TriggerAttributeWatchers(_cAttribute_, _cOldValue_, _newValue_)
	
	            catch
	                This._RecordError("Computed:" + _cAttribute_, CatchError())
	            done
	            exit
	        ok
	    next
