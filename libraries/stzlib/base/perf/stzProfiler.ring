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

class stzProfiler from stzObject

	pHandle = ""
	bReady = 0
	@nMaxPaths = 256

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

	# -- Frames ---------------------------------------------------

	def Enter(pcFrameName)
		This._Ensure()
		StzEngineProfEnter(pHandle, "" + pcFrameName)
		return This

	def Leave()
		This._Ensure()
		StzEngineProfLeave(pHandle)
		return This

	def Depth()
		This._Ensure()
		return StzEngineProfDepth(pHandle)

	# -- Sampling -------------------------------------------------

	# Start the engine sampler thread: every pnIntervalMs it
	# photographs the active frame path. Constant cost, zero Ring
	# involvement, honest at 1ms+ (the reactor's timeBeginPeriod(1)
	# holds process-wide once any reactor exists; without one,
	# Windows rounds the interval up to ~15.6ms -- fewer samples,
	# same statistics).
	def StartSampling(pnIntervalMs)
		This._Ensure()
		StzEngineProfSampleStart(pHandle, pnIntervalMs)
		return This

	def StopSampling()
		This._Ensure()
		StzEngineProfSampleStop(pHandle)
		return This

	def IsSampling()
		This._Ensure()
		return StzEngineProfIsSampling(pHandle) = 1

	# Sampler wakeups (in-frame or idle) -- SampleCount/Ticks tell
	# the coverage story together.
	def Ticks()
		This._Ensure()
		return StzEngineProfTicks(pHandle)

	# -- The accumulated tree -------------------------------------

	def PathCount()
		This._Ensure()
		return StzEngineProfPathCount(pHandle)

	# All paths: [ [ :path, :calls, :totalMs, :selfMs, :samples ], ... ]
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

	# The top pnHowMany paths by SELF time (instrumented) -- where
	# the time actually lives, children excluded.
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

	# -- Interop: the flame-graph handshake -----------------------

	# Folded-stacks format: one line per path, "a;b;c <weight>".
	# Weight = SAMPLES when sampling ran (the statistical truth),
	# else self-ms rounded up -- either way, flamegraph.pl and
	# speedscope ingest it as-is.
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

	def WriteFoldedTo(pcPath)
		write("" + pcPath, This.Folded())
		return This

	# -- Legibility -----------------------------------------------

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

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	def Reset()
		This._Ensure()
		StzEngineProfReset(pHandle)
		return This

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
