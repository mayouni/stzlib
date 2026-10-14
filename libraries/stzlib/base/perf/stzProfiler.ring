/*
	stzProfiler -- the frame profiler (perf P10).

	(The name has history: the original stzProfiler.ring was a P0
	fossil -- a demo script sketching "a function aware of its own
	execution" -- retired to base/archive/system/. This is that idea
	grown up, on the engine.)

	WHERE does the time go? Mark frames around the work you care
	about; the profiler answers with a CALL TREE -- per path: calls,
	total ms, SELF ms (total minus children) -- and, when sampling,
	a statistical view a background ENGINE THREAD collects by
	photographing the active frame path at a fixed cadence:

		oP = new stzProfiler(256)          # max distinct paths
		oP.Enter("checkout")
			oP.Enter("validate")
				# ...
			oP.Leave()
			oP.Enter("charge")
				# ...
			oP.Leave()
		oP.Leave()
		oP.Show()                          # the tree, self vs total
		? oP.HotSpots(3)                   # top paths by self time

		oP.StartSampling(2)                # a real sampler thread, 2ms
		# ... the workload runs; sampling cost is CONSTANT ...
		oP.StopSampling()
		? oP.Folded()                      # flame-graph food (see below)

	Two accumulations, honestly labeled: INSTRUMENTED numbers
	(calls/total/self) are exact for what you bracketed; SAMPLED
	numbers are statistical -- more samples where more time was
	spent, cost independent of call frequency. Use instrumentation
	for precise per-frame cost, sampling for long runs where
	bracketing every iteration would distort the measurement.

	Interop (the house rule): Folded() emits the FOLDED-STACKS
	format -- "checkout;charge 42" per line -- exactly what
	flamegraph.pl and speedscope.app ingest. Sampled counts when
	sampling ran, else self-ms; one artifact, any flame-graph tool.

	The frame STACK and the path table live engine-side (handle):
	copies share one truth, the sampler thread reads the stack with
	zero Ring involvement, and storage is fixed slabs bounded by
	max_paths (beyond it, paths fold into "_overflow" -- visible,
	never silently dropped). Depth caps at 32 (deeper frames fold
	into their parent). Destroy() stops the sampler and frees.

	Honest limits: frames are COOPERATIVE -- the profiler sees what
	you bracket, not unbracketed Ring code (a VM-level sampler would
	only ever see the interpreter's C internals). Enter/Leave cost
	one engine call each -- see the guard's self-cost scene.
*/

func StzProfiler(pnMaxPaths)
	return new stzProfiler(pnMaxPaths)

# Answers where the time goes by recording the frames you bracket as a call tree with calls, total and self time, and by sampling.
#
# Mark frames around the work you care about with Enter and Leave; the profiler keeps, for each path
# such as checkout;charge, the number of calls, the total time and the self time, which is the total
# minus the children. StartSampling starts an engine thread that photographs the active path at a
# fixed cadence, a statistical view with constant cost. Instrumented numbers are exact for what you
# bracketed; sampled numbers are statistical. Folded writes the folded-stacks format that
# flamegraph.pl and speedscope read. The frame stack lives in the engine, bounded by the maximum
# number of paths, and frames are cooperative: only what you bracket is seen. Times depend on the
# clock, so assert ranges and signs.
#
#   receiver   o1 = StzProfiler(16) o1.Enter("checkout") o1.Enter("validate")
#              StzEngineTimeSleepMs(20) o1.Leave() o1.Enter("charge") StzEngineTimeSleepMs(40)
#              o1.Leave() o1.Leave()
#   example    ? o1.Depth()
#              #--> 0
#              ? o1.PathCount()
#              #--> 3
#              ? o1.Paths()[1][:path]
#              #--> checkout;validate
#              ? o1.Paths()[3][:calls]
#              #--> 1
#              ? o1.HotSpots(1)[1][:path]
#              #--> checkout;charge
#              ? o1.Paths()[3][:totalMs] > o1.Paths()[2][:totalMs]
#              #--> 1
#              ? o1.Paths()[3][:selfMs] < o1.Paths()[3][:totalMs]
#              #--> 1
#              ? o1.IsSampling()
#              #--> 0
#   see        stzStopwatch, stzPerfMonitor, stzPerfSeries
class stzProfiler from stzObject

	pHandle = ""
	bReady = 0
	@nMaxPaths = 256

	# Builds a frame profiler whose frame stack and path table live in the engine, bounded to a number of distinct paths.
	#
	#   pnMaxPaths   the most distinct paths kept, 2 or more, otherwise 256
	#   returns      nothing; the engine handle is made when the object is built
	#   note         StzProfiler builds the same object; beyond the bound, paths fold into an
	#                _overflow path that stays visible, so with a bound of 2 only one path of its
	#                own fits; frames deeper than 32 fold into their parent
	#   see          Enter, Leave
	def init(pnMaxPaths)
		if isNumber(pnMaxPaths) and pnMaxPaths >= 2
			@nMaxPaths = pnMaxPaths
		ok
		# eager, per the copy law
		pHandle = StzEngineProfCreate(@nMaxPaths)
		bReady = 1

	def _Ensure()
		if bReady = 0
			pHandle = StzEngineProfCreate(@nMaxPaths)
			bReady = 1
		ok

	# Opens a frame, a named piece of work whose time is measured until the matching Leave.
	#
	#   pcFrameName   the name of the frame
	#   returns       the profiler itself, so calls chain
	#   note          frames nest, and a frame's path is its name joined to its parents' with
	#                 semicolons; a call costs one engine call; a destroyed profiler is made again
	#                 by it
	#   see           Leave, Depth
	#@ aka  -- Frames ---------------------------------------------------
	def Enter(pcFrameName)
		This._Ensure()
		StzEngineProfEnter(pHandle, "" + pcFrameName)
		return This

	# Closes the innermost open frame and adds its time to its path.
	#
	#   returns    the profiler itself, so calls chain
	#   note       leaving with no frame open does nothing and leaves the depth at 0; a path is
	#              recorded when its frame is left, so a child path is listed before its parent
	#   see        Enter, Depth
	def Leave()
		This._Ensure()
		StzEngineProfLeave(pHandle)
		return This

	# Returns how many frames are open now.
	#
	#   returns    a number
	#   see        Enter, Leave
	def Depth()
		This._Ensure()
		return StzEngineProfDepth(pHandle)

	# Starts the engine's sampler thread, which photographs the active frame path at a fixed interval.
	#
	#   pnIntervalMs   the interval between photographs, in milliseconds
	#   returns        the profiler itself, so calls chain
	#   note           the cost is constant and does not depend on how often frames are entered;
	#                  without a running reactor Windows rounds a short interval up to about 15.6
	#                  ms, so there are fewer samples with the same statistics
	#   see            StopSampling, Ticks
	#@ aka  -- Sampling -------------------------------------------------
	def StartSampling(pnIntervalMs)
		This._Ensure()
		StzEngineProfSampleStart(pHandle, pnIntervalMs)
		return This

	# Stops the sampler thread.
	#
	#   returns    the profiler itself, so calls chain
	#   see        StartSampling, IsSampling
	def StopSampling()
		This._Ensure()
		StzEngineProfSampleStop(pHandle)
		return This

	# TRUE if the sampler thread is running.
	#
	#   returns    TRUE or FALSE
	#   see        StartSampling, StopSampling
	def IsSampling()
		This._Ensure()
		return StzEngineProfIsSampling(pHandle) = 1

	# Returns how many times the sampler woke up, in a frame or idle.
	#
	#   returns    a number; 0 before sampling
	#   note       the samples of the paths add up to no more than the ticks; the count is live, so
	#              assert ranges and signs
	#   see        StartSampling, Paths
	#@ aka  Sampler wakeups (in-frame or idle) -- SampleCount/Ticks tell the coverage story together.
	def Ticks()
		This._Ensure()
		return StzEngineProfTicks(pHandle)

	# Returns how many distinct paths have been recorded.
	#
	#   returns    a number
	#   see        Paths, Reset
	#@ aka  -- The accumulated tree -------------------------------------
	def PathCount()
		This._Ensure()
		return StzEngineProfPathCount(pHandle)

	# Returns every recorded path with its instrumented and sampled numbers.
	#
	#   returns    a list of hash lists with the keys path, calls, totalms, selfms and samples, in
	#              the order the frames were left; times are in milliseconds
	#   note       total includes the children and self does not; instrumented numbers are exact for
	#              what was bracketed and sampled numbers are statistical
	#   see        HotSpots, Folded
	#@ aka  All paths: [ [ :path, :calls, :totalMs, :selfMs, :samples ], ... ]
	def Paths()
		This._Ensure()
		_aOut_ = []
		_nN_ = StzEngineProfPathCount(pHandle)
		for _i_ = 1 to _nN_
			_aOut_ + [
				:path = StzEngineProfPathAt(pHandle, _i_),
				:calls = StzEngineProfCallsAt(pHandle, _i_),
				:totalMs = StzEngineProfTotalNsAt(pHandle, _i_) / 1000000,
				:selfMs = StzEngineProfSelfNsAt(pHandle, _i_) / 1000000,
				:samples = StzEngineProfSamplesAt(pHandle, _i_)
			]
		next
		return _aOut_

	# Returns the paths that spent the most time in themselves, children excluded.
	#
	#   pnHowMany   how many paths to return
	#   returns     a list of the same hash lists as Paths, longest self time first, at most
	#               pnHowMany
	#   note        asking for more than exist returns them all
	#   see         Paths, Folded
	#@ aka  The top pnHowMany paths by SELF time (instrumented) -- where the time actually lives, children excluded.
	def HotSpots(pnHowMany)
		_aAll_ = This.Paths()
		_aOut_ = []
		_nN_ = ring_len(_aAll_)
		for _k_ = 1 to pnHowMany
			_nBest_ = 0
			_nBestV_ = -1
			for _i_ = 1 to _nN_
				if _aAll_[_i_][:selfMs] > _nBestV_ and NOT This._InList(_aOut_, _aAll_[_i_][:path])
					_nBest_ = _i_
					_nBestV_ = _aAll_[_i_][:selfMs]
				ok
			next
			if _nBest_ = 0
				exit
			ok
			_aOut_ + _aAll_[_nBest_]
		next
		return _aOut_

	# Returns the paths in the folded-stacks format that flame-graph tools read, one line per path as the path then a weight.
	#
	#   returns    a text of lines such as checkout;charge 42
	#   note       the weight is the sample count when sampling ran and otherwise the self time in
	#              milliseconds rounded up; a path of weight 0 is left out
	#   see        WriteFoldedTo, HotSpots
	#@ aka  -- Interop: the flame-graph handshake -----------------------
	def Folded()
		_aAll_ = This.Paths()
		_bSampled_ = 0
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if _aAll_[_i_][:samples] > 0
				_bSampled_ = 1
				exit
			ok
		next
		_cOut_ = ""
		for _i_ = 1 to _nN_
			_nW_ = 0
			if _bSampled_
				_nW_ = _aAll_[_i_][:samples]
			else
				_nW_ = ceil(_aAll_[_i_][:selfMs])
			ok
			if _nW_ > 0
				_cOut_ += (_aAll_[_i_][:path] + " " + _nW_ + Char(10))
			ok
		next
		return _cOut_

	# Writes the folded stacks to a file, ready for flamegraph.pl or speedscope.
	#
	#   pcPath     the path of the file to write
	#   returns    the profiler itself, so calls chain
	#   note       an existing file is overwritten
	#   see        Folded
	def WriteFoldedTo(pcPath)
		write("" + pcPath, This.Folded())
		return This

	# Returns the call tree as lines of text: a header, then each path with its calls, total and self time, and its samples if any.
	#
	#   returns    a list of text lines
	#   note       a deeper path is indented, and because children are recorded first they appear
	#              before their parent
	#   see        Show, Paths
	#@ aka  -- Legibility -----------------------------------------------
	def Explain()
		_aL_ = []
		_aAll_ = This.Paths()
		_cS_ = ""
		if This.IsSampling()
			_cS_ = " (sampling live)"
		ok
		_cHead_ = "Profiler -- " + ring_len(_aAll_) + " path(s), depth now "
		_cHead_ += ("" + This.Depth() + _cS_ + ".")
		_aL_ + _cHead_
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			_cIndent_ = ""
			_nSegs_ = ring_len(StzSplit(_aAll_[_i_][:path], ";"))
			for _j_ = 2 to _nSegs_
				_cIndent_ += "  "
			next
			_cLine_ = "  " + _cIndent_ + _aAll_[_i_][:path] + " -- "
			_cLine_ += ("" + _aAll_[_i_][:calls] + " call(s), total ")
			_cLine_ += ("" + _aAll_[_i_][:totalMs] + " ms, self " + _aAll_[_i_][:selfMs] + " ms")
			if _aAll_[_i_][:samples] > 0
				_cLine_ += (", " + _aAll_[_i_][:samples] + " sample(s)")
			ok
			_aL_ + _cLine_
		next
		return _aL_

	# Prints the call tree to the console, one line per line.
	#
	#   returns    nothing
	#   note       it prints with the ? statement
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Clears the recorded paths and the open frames.
	#
	#   returns    the profiler itself, so calls chain
	#   see        Destroy, Paths
	def Reset()
		This._Ensure()
		StzEngineProfReset(pHandle)
		return This

	# Stops the sampler and frees the engine handle.
	#
	#   returns    the profiler itself, so calls chain
	#   note       a later call that needs the engine makes a new handle, so a destroyed profiler
	#              starts again empty
	#   see        Reset, init
	def Destroy()
		if bReady
			StzEngineProfDestroy(pHandle)
			pHandle = ""
			bReady = 0
		ok
		return This

	# -- Internals ------------------------------------------------

	def _InList(paRows, pcPath)
		_nN_ = ring_len(paRows)
		for _i_ = 1 to _nN_
			if paRows[_i_][:path] = pcPath
				return 1
			ok
		next
		return 0
