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

# Turns attributes into values that notify: a change runs watchers, recalculates dependent attributes and updates bindings.
#
# A reactive object holds named attributes, made from nothing or wrapped around an existing object.
# SetAttribute stores a value and, when it changed, calls the functions registered with Watch,
# recomputes the attributes declared with Computed from the attributes they depend on, and writes to
# the targets given to BindTo. WaitForAttributetoSettle calls a function once an attribute stops
# changing, and Batch notifies a group of changes together afterwards. An error inside a watcher, a
# calculated attribute or a batch does not stop the caller: it is recorded (Errors, LastError,
# ErrorCount) and passed to the OnError handler, or printed when there is none. Names are not case
# sensitive. Two members do not work as intended today: a binding reaches its target only once, when
# it is made, and StreamAttribute never emits.
#
#   receiver   oRs = new stzReactive(); o1 = oRs.ReactiveObject()
#   example    gLog = []
#              o1.Watch(:name, func(oSelf, attr, oldV, newV) { gLog + [ oldV, newV ] })
#              o1.SetAttribute(:name, "Ann")
#              o1.SetAttribute(:name, "Bob")
#              ? @@( gLog )
#              #--> [ [ "", "Ann" ], [ "Ann", "Bob" ] ]
#              o1.Computed(:greeting, func oSelf { return "Hello " + oSelf.GetAttribute(:name) }, [ :name ])
#              o1.SetAttribute(:name, "Cy")
#              ? o1.GetAttribute(:greeting)
#              #--> Hello Cy
#              o1.OnError(func(w, m) { })
#              o1.Watch(:age, "not a function")
#              ? o1.LastError()
#              #--> Watch callback is not a function
#   see        stzReactive, stzReactiveStream, stzReactiveTask
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

	# Sets the handler that receives each error the object catches instead of printing it, and returns the object.
	#
	#   fCallback   a function taking two arguments, the place that failed and the message
	#   returns     the object itself, so calls chain
	#   note        without a handler the error is printed as [stzReactiveObject.place] message, and
	#               recorded either way
	#   see         Errors, LastError, ErrorCount
	#@ aka  -- THE ERROR RECORD --------------------------------------------------------
	def OnError(fCallback)
		@fOnError = fCallback
		return This

	# Returns the errors recorded so far, as pairs of the place that failed and its message, oldest first.
	#
	#   returns    a list of [ place, message ] pairs; at most 50 are kept
	#   note       the places look like Watch:name, Watcher:name, Computed:name,
	#              Binding:name->target or Batch
	#   see        LastError, ErrorCount, ClearErrors
	def Errors()
		return @aErrors

	# Returns the message of the newest recorded error.
	#
	#   returns    a text; empty when nothing was recorded
	#   see        LastErrorWhere, Errors
	def LastError()
		if len(@aErrors) = 0
			return ""
		ok
		return @aErrors[len(@aErrors)][2]

	# Returns the place of the newest recorded error, such as Watch:age or Batch.
	#
	#   returns    a text; empty when nothing was recorded
	#   see        LastError, Errors
	#@ aka  Which operation failed -- "Batch", "Watcher:name", "Computed:greeting"...
	def LastErrorWhere()
		if len(@aErrors) = 0
			return ""
		ok
		return @aErrors[len(@aErrors)][1]

	# Returns how many errors were seen, including the ones dropped once 50 were kept.
	#
	#   returns    a number
	#   see        ErrorsDropped, HasErrors, Errors
	#@ aka  Everything seen, not merely everything KEPT. A bounded record that reported only its own length would under-count exactly when it matters.
	def ErrorCount()
		return @nErrorsSeen

	# Returns how many errors were counted but not kept, because the record holds 50.
	#
	#   returns    a number
	#   see        ErrorCount, Errors
	def ErrorsDropped()
		return @nErrorsDropped

	# TRUE if at least one error was recorded since the last ClearErrors.
	#
	#   returns    1 or 0
	#   see        ErrorCount, ClearErrors
	def HasErrors()
		return @nErrorsSeen > 0

	# Empties the error record and its counters, then returns the object.
	#
	#   returns    the object itself, so calls chain
	#   see        Errors, HasErrors
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

	# Builds the reactive object around an existing object, or around nothing when given an empty text, and keeps the engine that serves it.
	#
	#   existingObject   the object to wrap, or an empty text for an object made of attributes only
	#   reactiveEngine   the stzReactive system that serves timers and streams
	#   returns          nothing; the object is built
	#   note             the attributes of a wrapped object are read into the storage and the cache
	#                    when it is built
	#   warning          the wrapped object is stored as a copy: changing the original afterwards
	#                    does not reach the reactive object, and setting through the reactive object
	#                    does not change the original
	#   see              Reactivate, SetAttribute
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

	# Runs when Ring opens a brace block on the object, and does nothing today.
	#
	#   returns    nothing
	#   see        BraceEnd, BraceError
	#@ aka  Ring's object access hooks - integrate with reactive system
	def BraceStart()
		if @bReactiveMode = REACTIVE_ON
			# Notify reactive system of object access start
		ok

	# Runs when Ring closes a brace block on the object, and notifies the changes queued during the block.
	#
	#   returns    nothing
	#   see        BraceStart, ProcessPendingReactions
	def BraceEnd()
		if @bReactiveMode = REACTIVE_ON
			ProcessPendingReactions()
		ok

	# Runs when a call in a brace block fails, and hands the error text to the failure function of every SetAsync made so far.
	#
	#   returns    nothing
	#   warning    the SetAsync records are never removed, so a later failed brace call reaches the
	#              failure handlers of earlier, finished SetAsync calls as well
	#   see        SetAsync, OnError
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

	# Sets an attribute, creating it when new, and on a real change runs its watchers, dependent attributes and bindings.
	#
	#   _cAttribute_   the attribute's name, which is lowercased
	#   _newValue_     the value to store
	#   returns        the object itself, so calls chain
	#   note           the name is lowercased, so :Name and :name are one attribute
	#   warning        inside Batch the notifications are queued and the value is stored at once; an
	#                  equal value triggers nothing
	#   see            GetAttribute, Watch, Computed, Batch
	#@ aka  Universal Attribute setter
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

	# Sets an attribute from a pair of its name and its value, so that a set reads like an assignment.
	#
	#   paAttr     a list of two items, the attribute's name and its value
	#   returns    nothing
	#   note       it calls SetAttribute and, unlike it, does not return the object
	#   see        SetAttribute
	def @(paAttr)
		This.SetAttribute(paAttr[1], paAttr[2])

	# Returns the current value of an attribute, matched without regard to case.
	#
	#   _cAttribute_   the attribute's name
	#   returns        the value; an empty text when the attribute is unknown
	#   see            SetAttribute, GetAttributeValue
	#@ aka  Universal Attribute getter
	def GetAttribute(_cAttribute_)
		_cAttribute_ = StzLower(_cAttribute_)
		_value_ = GetAttributeValue(_cAttribute_)
		
		if @bReactiveMode = REACTIVE_ON
			# Notify reactive system of Attribute access
		ok
		
		return _value_

	# Returns the value of an attribute, reading the cache first, then the wrapped object, then the storage.
	#
	#   _cAttribute_   the attribute's name
	#   returns        the value; an empty text when the attribute is unknown
	#   warning        a value written with SetAttributeValue is not read back while the cache holds
	#                  an older one
	#   see            GetAttribute, SetAttributeValue, UpdateAttributeCache
	#@ aka  Core Attribute access methods
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
	
	# Writes a value into the storage, the wrapped object and the object's own attribute, without any notification and without touching the cache.
	#
	#   _cAttribute_   the attribute's name
	#   _value_        the value to write
	#   returns        nothing
	#   note           it is the call a binding makes on its target
	#   warning        GetAttribute keeps answering the older value for an attribute already in the
	#                  cache; use SetAttribute to set and notify
	#   see            SetAttribute, UpdateAttributeCache
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

	# Registers a function called as f(object, name, oldValue, newValue) each time the attribute changes, and returns the object.
	#
	#   _cAttribute_   the attribute to watch
	#   fCallback      a function taking four arguments: the reactive object, the attribute's name,
	#                  the old value and the new value
	#   returns        the object itself, so calls chain
	#   note           the function runs on every real change, in order of registration; an error
	#                  inside it is recorded as Watcher:name
	#   warning        a value that is not a function is refused: nothing is stored and the error
	#                  Watch callback is not a function is recorded
	#   see            Computed, WaitForAttributetoSettle, OnError
	#@ aka  Watch Attribute changes A CALLBACK THAT IS NOT ONE IS REFUSED AT REGISTRATION.
	def Watch(_cAttribute_, fCallback)
		if NOT (isString(fCallback) and isFunction(fCallback))
			This._RecordError("Watch:" + _cAttribute_, WATCH_ERROR_NOT_A_FUNCTION)
			return This
		ok

		_cAttribute_ = StzLower(_cAttribute_)
		@aAttributeWatchers + [_cAttribute_, fCallback]
		return self

	# Creates an attribute whose value is calculated by a function from other attributes, now and again each time one of them changes.
	#
	#   _cAttribute_      the name of the calculated attribute
	#   _fnComputer_      a function taking the reactive object and returning the value
	#   _aDependencies_   the names of the attributes it depends on, as a list
	#   returns           the object itself, so calls chain
	#   note              a watcher on the calculated attribute also fires when it is recomputed
	#   warning           a function that is not one, or dependencies that are not a list, are
	#                     refused and recorded, and nothing is created
	#   see               Watch, SetAttribute, ComputeAttribute
	#@ aka  Create computed Attribute that auto-updates The dependency list is walked by find() on every attribute change, so a non-list is not a problem here -- it is a "Bad parameter type!" raised from UpdateDependentComputedAttributes on some LATER, unrelated set, a long way from the registration that caused it.
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

	# Binds an attribute to an attribute of another reactive object, copying its current value to the target at once.
	#
	#   oTargetObject        the reactive object that receives the value
	#   _cSourceAttribute_   the attribute of this object to follow
	#   _cTargetAttribute_   the attribute to write in the target, or an empty text for the same
	#                        name
	#   returns              the object itself, so calls chain
	#   note                 the starting value is written to the object you passed
	#   warning              a later change of the source does not reach the target object you
	#                        passed, because the binding keeps a copy of the target: the target
	#                        holds the value of the moment of binding; a target that is not an
	#                        object is refused and recorded
	#   see                  UpdateBoundAttributes, Watch
	#@ aka  Bind Attribute to another reactive object THE TARGET HAS TO BE ABLE TO TAKE THE BINDING. A plain object raised R14 "Calling Method without definition: setattributevalue" from inside this setter, so binding to the wrong kind of thing crashed the caller instead of being refused.
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

	# Sets an attribute at once, completes a task with the value, calls the success function, and returns the task.
	#
	#   _cAttribute_   the attribute's name
	#   _newValue_     the value to set
	#   fnSuccess      a function taking the value, or an empty text
	#   fnError        a function taking the error text, or an empty text
	#   returns        a stzReactiveTask, already completed or failed
	#   note           the error is also recorded as SetAsync:name
	#   warning        the name suggests a deferred update, but nothing waits: the value is set
	#                  before the call returns
	#   see            SetAttribute, BraceError
	#@ aka  Async Attribute update
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

	# Runs a function in which attribute changes are stored at once but notified together afterwards, then returns the object.
	#
	#   fnUpdates   the function with no argument that makes the changes
	#   returns     the object itself, so calls chain
	#   note        each changed attribute is notified once
	#   warning     the watcher receives the first change of an attribute, with its old value and
	#               the value it had then, not the last: after sets of 1, 2 and 3 on an attribute
	#               that held 10 it is told 10 and 1 while the attribute holds 3; an error in the
	#               function is recorded as Batch and the changes already made stay
	#   see         SetAttribute, ProcessBatchChanges
	#@ aka  Batch multiple Attribute updates
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

	# Returns a stream that never emits, because the watcher behind it fails at every change; the failure is recorded, not raised.
	#
	#   _cAttribute_   the attribute to follow
	#   returns        a stream object; it stays empty
	#   warning        the watcher raises error R24 Using uninitialized variable: _stream_, because
	#                  the function it registers reads a local of the method; the error is recorded
	#                  as Watcher:name and nothing reaches the stream
	#   see            Watch, SetAttribute
	#@ aka  Create reactive stream from Attribute changes
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

	# Calls a function once an attribute has stopped changing for the given delay, with the last change, and returns the object.
	#
	#   _cAttribute_   the attribute to watch
	#   nDelay         the quiet time in milliseconds
	#   fCallback      a function taking three arguments: the name, the old value and the new value
	#   returns        the object itself, so calls chain
	#   note           after three quick sets, the function ran once, with the second value as old
	#                  and the last as new; DebounceAttribute is the same call
	#   warning        the timer is run by the reactive loop, so nothing fires until the loop runs
	#   see            OnSettleChange, Watch
	#@ aka  The method waits for the attribute to stop changing (settle) before executing the callback.
	def WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)
		# F5 REWRITE (2026-07-14): the old body stored the pending timer in
		# a LOCAL that a lambda "captured" -- but Ring lambdas do NOT capture
		# enclosing locals, so every trigger raised (swallowed silently by
		# TriggerAttributeWatchers' try/catch) and the feature never worked.
		# The settle state now lives ON THE OBJECT (aSettleWatchers records)
		# and the timers go to the GLOBAL detached table, which every
		# RunLoop drives. The lambda uses only its own params (oSelf!) --
		# the reason the watcher contract passes `this` first.
		_cAttribute_ = StzLower(_cAttribute_)
		@aSettleWatchers + [ _cAttribute_, nDelay, fCallback, "" ]
		Watch(_cAttribute_, func(oSelf, attr, oldVal, newVal) {
			oSelf.OnSettleChange(attr, oldVal, newVal)
		})
		return self

		def DebounceAttribute(_cAttribute_, nDelay, fCallback)
			return This.WaitForAttributetoSettle(_cAttribute_, nDelay, fCallback)

	# Restarts the settle timer of an attribute each time it changes, so that the function fires only when the changes stop.
	#
	#   cAttr      the attribute that changed
	#   oldVal     its old value
	#   newVal     its new value
	#   returns    nothing
	#   warning    internal: the object registers it for you
	#   see        WaitForAttributetoSettle
	#@ aka  (Internal) a watched-and-settling attribute changed: restart its settle timer. The user callback fires as f(attr, old, new) once the value has been quiet for the configured delay.
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

	# Returns a new reactive object wrapping an object, which is copied.
	#
	#   existingObject   the object to wrap, or an empty text
	#   returns          a new stzReactiveObject
	#   warning          the new object is given this reactive object as its engine, not the
	#                    stzReactive system, so StreamAttribute on it raises error R14 Calling
	#                    Method without definition: createstream
	#   see              Init
	#@ aka  Factory method for creating reactive objects
	def Reactivate(existingObject)
		return new stzReactiveObject(existingObject, this)

	#-------------------#
	#  UTILITY METHODS  #
	#-------------------#

	# Returns the value of an attribute from the storage only, ignoring the cache and the wrapped object.
	#
	#   _cAttribute_   the attribute's name
	#   returns        the value; an empty text when absent
	#   see            SetAttributeInStorage, GetAttributeValue
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

	# Writes a value into the storage only, adding the attribute when absent.
	#
	#   _cAttribute_   the attribute's name
	#   _value_        the value to store
	#   returns        nothing
	#   see            GetAttributeFromStorage, UpdateAttributeCache
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

	# Writes a value into the cache that GetAttribute reads first, adding the attribute when absent.
	#
	#   _cAttribute_   the attribute's name
	#   _value_        the value to cache
	#   returns        nothing
	#   see            FindAttributeInCache, SetAttributeInStorage
	def UpdateAttributeCache(_cAttribute_, _value_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nIndex_ = FindAttributeInCache(_cAttribute_)
	    if _nIndex_ > 0
	        @aCachedAttributeValues[_nIndex_][2] = _value_
	    else
	        @aCachedAttributeValues + [_cAttribute_, _value_]
	    ok

	# Returns the position of an attribute in the cache, or 0 when it is not cached.
	#
	#   _cAttribute_   the attribute's name
	#   returns        a number
	#   see            UpdateAttributeCache
	def FindAttributeInCache(_cAttribute_)
	    _cAttribute_ = StzLower(_cAttribute_)
	    _nLenCacheAttr_ = len(@aCachedAttributeValues)
	    for i = 1 to _nLenCacheAttr_
	        if @aCachedAttributeValues[i][1] = _cAttribute_
	            return i
	        ok
	    next
	    return 0

	# Notifies one change: runs the watchers, recomputes the calculated attributes that depend on it, and updates the bound targets.
	#
	#   _cAttribute_   the attribute that changed
	#   oldValue       its previous value
	#   _newValue_     its new value
	#   returns        nothing
	#   warning        calling it directly notifies without changing any value
	#   see            TriggerAttributeWatchers, UpdateDependentComputedAttributes,
	#                  UpdateBoundAttributes
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

	# Notifies the changes queued by Batch, if any.
	#
	#   returns    nothing
	#   see        ProcessBatchChanges, BraceEnd
	def ProcessPendingReactions()
		if len(@aPendingChanges) > 0
			ProcessBatchChanges()
		ok

	# Notifies each attribute queued by Batch once, using its first queued change, then empties the queue.
	#
	#   returns    nothing
	#   see        Batch, ProcessAttributeChange
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


	# Calls every watcher of an attribute as f(object, name, oldValue, newValue); an error in one is recorded and the others still run.
	#
	#   _cAttribute_   the attribute whose watchers to call
	#   oldValue       the old value to pass
	#   _newValue_     the new value to pass
	#   returns        nothing
	#   see            Watch, ProcessAttributeChange
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


	# Recomputes each calculated attribute that lists the changed attribute among its dependencies.
	#
	#   _cChangedAttribute_   the attribute that changed
	#   returns               nothing
	#   see                   Computed, ComputeAttribute
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

	# Writes a new value to the target of each binding that follows the attribute.
	#
	#   _cAttribute_   the source attribute
	#   _newValue_     the value to write
	#   returns        nothing
	#   warning        the targets written are the copies kept by BindTo, so the object you passed
	#                  to BindTo does not see the value
	#   see            BindTo
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


	# Recomputes one calculated attribute with its function, stores the result and runs the watchers of the attribute.
	#
	#   _cAttribute_   the name of a calculated attribute
	#   returns        nothing
	#   warning        an error in the function is recorded as Computed:name and the old value stays
	#   see            Computed, UpdateDependentComputedAttributes
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
