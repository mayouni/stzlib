#---------------------------------------------------------------------------#
#  STZGPU -- the declarative doorway to the GPU plane (G4 of                #
#  SOFTANZA_GPU_PLAN.md). Describe a computation with stzKernelMaker, hand  #
#  it data, get results -- the engine owns devices, kernels, and buffers.   #
#---------------------------------------------------------------------------#
#
#     oG = new stzGpu
#     ? oG.IsAvailable()
#     ? oG.DeviceName()
#
#     k = StzKernelMakerQ()
#     k.TakesVector(:A)
#     k.TakesVector(:B)
#     k.TakesScalar(:alpha)
#     k.ReturnsVector(:C)
#     k.ForEachElement('{ @C = alpha * @A + @B }')
#
#     aC = oG.Run(k, [ :A = a1, :B = a2, :alpha = 2.5 ])     # data in, data out
#
#     # the resident form -- upload once, chain, download once:
#     b = oG.UploadQ(aBig)
#     b2 = b.ApplyQ(kDouble).ApplyQ(kShift)
#     aOut = b2.Download()
#
# HONESTY ABOUT SPEED (G0's numbers, not hopes): a ONE-SHOT Run() pays
# upload + dispatch + readback, and for elementwise work that transfer is
# ~92% of the cost -- the CPU usually wins one-shots. The GPU pays in the
# RESIDENT form (UploadQ/ApplyQ chains) and in compute-dense ops. Run() is
# the doorway, not the destination.
#
# Device lifetime: lazily initialized on first need (~300 ms once). On a
# machine with no GPU, IsAvailable() answers FALSE and the data paths raise
# a clear error -- kernel AUTHORING (ToWGSL) needs no device at all.

func _FreeIds(paIds)
	_nL_ = len(paIds)
	for _i_ = 1 to _nL_
		if paIds[_i_] > 0
			StzEngineGpuBufferFree(paIds[_i_])
		ok
	next

func StzGpuQ()
	return new stzGpu

class stzGpu from stzObject

	@bTriedInit_ = 0

	def init()

	def IsAvailable()
		This._EnsureInit()
		return StzEngineGpuIsAvailable() = 1

	def DeviceName()
		This._EnsureInit()
		if StzEngineGpuIsAvailable() = 0
			return ""
		ok
		return StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	def AdapterCount()
		This._EnsureInit()
		return StzEngineGpuAdapterCount()

	# ---- the data paths -------------------------------------------------

	# Upload a vector; it lives on the device until Free() (or eviction
	# under VRAM pressure -- bounded, counted, never silent).
	def UploadQ(paNumbers)
		This._RequireDevice()
		if NOT isList(paNumbers) or len(paNumbers) = 0
			StzRaise("UploadQ: give me a non-empty list of numbers.")
		ok
		_nId_ = StzEngineGpuBufferNew(ring_len(paNumbers) * 4)
		if _nId_ = 0
			StzRaise("UploadQ: no device buffer (" + StzEngineGpuLastError() + ")")
		ok
		if StzEngineGpuBufferUploadList(_nId_, paNumbers) != 0
			StzEngineGpuBufferFree(_nId_)
			StzRaise("UploadQ: the upload was refused.")
		ok
		return new stzGpuBuffer([_nId_, ring_len(paNumbers)])

	# One-shot convenience: upload the bound vectors, run the kernel, read
	# the result back, free everything temporary. Data in, DATA out.
	def Run(poKernel, paBindings)
		_oOut_ = This.RunQ(poKernel, paBindings)
		_aOut_ = _oOut_.Download()
		_oOut_.Free()
		return _aOut_

	# The same, but the RESULT stays resident (an stzGpuBuffer) -- feed it
	# to ApplyQ chains without paying the readback.
	def RunQ(poKernel, paBindings)
		This._RequireDevice()
		_aNames_ = poKernel.InputNames()
		_nIn_ = ring_len(_aNames_)
		if _nIn_ = 0
			StzRaise("RunQ: the kernel declares no TakesVector input.")
		ok

		# collect the bound vectors, all the same length
		_aVecs_ = []
		_nElems_ = 0
		for _i_ = 1 to _nIn_
			_v_ = _BindingValue(paBindings, _aNames_[_i_])
			if NOT isList(_v_) or ring_len(_v_) = 0
				StzRaise("RunQ: vector '" + _aNames_[_i_] +
					"' is missing from the bindings (give [ :" +
					_aNames_[_i_] + " = aNumbers ]).")
			ok
			if _nElems_ = 0
				_nElems_ = ring_len(_v_)
			but ring_len(_v_) != _nElems_
				StzRaise("RunQ: vector '" + _aNames_[_i_] + "' has " +
					ring_len(_v_) + " elements, the first had " + _nElems_ +
					" -- elementwise kernels need equal lengths.")
			ok
			_aVecs_ + _v_
		next
		_aScal_ = _OrderedScalars(poKernel, paBindings)

		_cW_ = poKernel.ToWGSL()
		_nK_ = StzEngineGpuKernelCompile(_cW_)
		if _nK_ = 0
			StzRaise("RunQ: the kernel refused to compile: " + StzEngineGpuLastError())
		ok

		# upload inputs (temporaries), make the resident output
		_aIds_ = []
		for _i_ = 1 to _nIn_
			_nId_ = StzEngineGpuBufferNew(_nElems_ * 4)
			_bOk_ = _nId_ > 0
			if _bOk_
				_bOk_ = StzEngineGpuBufferUploadList(_nId_, _aVecs_[_i_]) = 0
			ok
			if NOT _bOk_
				_FreeIds(_aIds_)
				StzRaise("RunQ: input upload refused (" + StzEngineGpuLastError() + ")")
			ok
			_aIds_ + _nId_
		next
		_nOut_ = StzEngineGpuBufferNew(_nElems_ * 4)
		if _nOut_ = 0
			_FreeIds(_aIds_)
			StzRaise("RunQ: no device buffer for the result.")
		ok
		_aIds_ + _nOut_

		_nSt_ = StzEngineGpuDispatchParams(_nK_, _nElems_, _aScal_, _aIds_,
			ceil(_nElems_ / 256.0))
		# the input temporaries go now -- the submitted work holds its own
		# references device-side, so this is safe AND keeps VRAM honest
		for _i_ = 1 to _nIn_
			StzEngineGpuBufferFree(_aIds_[_i_])
		next
		if _nSt_ != 0
			StzEngineGpuBufferFree(_nOut_)
			StzRaise("RunQ: dispatch refused (status " + _nSt_ + ").")
		ok
		return new stzGpuBuffer([_nOut_, _nElems_])

	# Multi-input kernels over ALREADY-RESIDENT buffers: no transfer at all.
	# paBindings binds vector names to stzGpuBuffer objects (plus scalars):
	#     oG.ApplyOnQ(k, [ :A = oBuf1, :B = oBuf2, :alpha = 2 ])
	def ApplyOnQ(poKernel, paBindings)
		This._RequireDevice()
		_aNames_ = poKernel.InputNames()
		_nIn_ = ring_len(_aNames_)
		_aIds_ = []
		_nElems_ = 0
		for _i_ = 1 to _nIn_
			_o_ = _BindingValue(paBindings, _aNames_[_i_])
			if NOT isObject(_o_)
				StzRaise("ApplyOnQ: '" + _aNames_[_i_] +
					"' must be bound to an stzGpuBuffer.")
			ok
			if _nElems_ = 0
				_nElems_ = _o_.Count()
			but _o_.Count() != _nElems_
				StzRaise("ApplyOnQ: buffer lengths disagree (" +
					_o_.Count() + " vs " + _nElems_ + ").")
			ok
			_aIds_ + _o_.Id_()
		next
		_aScal_ = _OrderedScalars(poKernel, paBindings)
		_cW_ = poKernel.ToWGSL()
		_nK_ = StzEngineGpuKernelCompile(_cW_)
		if _nK_ = 0
			StzRaise("ApplyOnQ: the kernel refused to compile: " + StzEngineGpuLastError())
		ok
		_nOut_ = StzEngineGpuBufferNew(_nElems_ * 4)
		if _nOut_ = 0
			StzRaise("ApplyOnQ: no device buffer for the result.")
		ok
		_aIds_ + _nOut_
		_nSt_ = StzEngineGpuDispatchParams(_nK_, _nElems_, _aScal_, _aIds_,
			ceil(_nElems_ / 256.0))
		if _nSt_ != 0
			StzEngineGpuBufferFree(_nOut_)
			StzRaise("ApplyOnQ: dispatch refused (status " + _nSt_ + ").")
		ok
		return new stzGpuBuffer([_nOut_, _nElems_])

	# ---- calibration (G5) -----------------------------------------------

	# Measure where the GPU actually starts winning ON THIS MACHINE, store
	# the crossover in the calibration store, and persist it (the faces
	# auto-load it in later sessions). Warm-min discipline throughout --
	# G0's clock inversion means sustained numbers flatter the GPU.
	# Returns [ nThreshold, [ [nProblemSize, nCpuMs, nGpuMs], ... ] ].
	def Calibrate()
		return This.CalibrateWith([1000, 2000, 4000, 8000, 16000])

	# The same, on a caller-chosen ladder of corpus sizes (d fixed at 64:
	# a representative embedding width; problem size = n*d).
	def CalibrateWith(paRungs)
		This._RequireDevice()
		_nDim_ = 64
		_aReport_ = []
		_nCross_ = 0
		_nRungs_ = ring_len(paRungs)
		for _i_ = 1 to _nRungs_
			_aRes_ = This._CalibRung(paRungs[_i_], _nDim_)
			_aReport_ + [ paRungs[_i_] * _nDim_, _aRes_[1], _aRes_[2] ]
			# crossover = the FIRST rung the GPU wins with a 30% margin;
			# the margin absorbs run-to-run noise (transfer is a band)
			if _nCross_ = 0 and _aRes_[2] * 1.3 <= _aRes_[1]
				_nCross_ = paRungs[_i_] * _nDim_
			ok
		next
		if _nCross_ = 0
			# the GPU never won on this ladder: route everything CPU
			_nCross_ = 999999999999
		ok
		StzEngineGpuCalibSet("pairdist", _nCross_)
		StzGpuSaveCalibration(["pairdist"])
		return [ _nCross_, _aReport_ ]

	# ---- GK0: the checker -----------------------------------------------
	# Verify a CANDIDATE kernel against a REFERENCE one: same inputs, same
	# device, plus a HIDDEN second shape over DIFFERENT data the candidate
	# was never shown; both timed the same way by the ENGINE (never by this
	# face); and a refusal for any time faster than the measured bus. The
	# report is DATA -- the verdict is the engine's, this face only reads it.
	#
	#   aR = oG.Verify(kRef, kCand, [ :a = aData ])
	#   ? aR[:verdict]   # "verified" | "mismatch" | "mismatch-hidden" |
	#                    # "impossible" | "reference-impossible" | "error"
	#
	# pCand may be an stzKernelMaker on the SAME declarations, or raw WGSL
	# on the same binding contract (how a hand-written variant -- or a
	# cheat -- gets checked). Options: [ :reps = 7, :band = 0.000001 ].
	def Verify(poRef, pCand, paBindings)
		return This.VerifyWith(poRef, pCand, paBindings, [])

	def VerifyWith(poRef, pCand, paBindings, paOptions)
		This._RequireDevice()
		_nReps_ = _BindingValue(paOptions, "reps")
		if NOT isNumber(_nReps_) or _nReps_ < 3
			_nReps_ = 7
		ok
		_nBand_ = _BindingValue(paOptions, "band")
		if NOT isNumber(_nBand_)
			_nBand_ = 0.000001
		ok
		_aNames_ = poRef.InputNames()
		_nIn_ = ring_len(_aNames_)
		if _nIn_ = 0
			StzRaise("Verify: the reference kernel declares no TakesVector input.")
		ok
		_aVecs_ = []
		_nA_ = 0
		for _i_ = 1 to _nIn_
			_v_ = _BindingValue(paBindings, _aNames_[_i_])
			if NOT isList(_v_) or ring_len(_v_) = 0
				StzRaise("Verify: vector '" + _aNames_[_i_] +
					"' is missing from the bindings (give [ :" +
					_aNames_[_i_] + " = aNumbers ]).")
			ok
			if _nA_ = 0
				_nA_ = ring_len(_v_)
			but ring_len(_v_) != _nA_
				StzRaise("Verify: vector '" + _aNames_[_i_] + "' has " +
					ring_len(_v_) + " elements, the first had " + _nA_ + ".")
			ok
			_aVecs_ + _v_
		next
		_aScal_ = _OrderedScalars(poRef, paBindings)

		# the candidate: a maker on the SAME declarations, or raw WGSL
		if isString(pCand)
			_cCand_ = pCand
		else
			if ring_len(pCand.InputNames()) != _nIn_ or
			   ring_len(pCand.ScalarNames()) != ring_len(_aScal_)
				StzRaise("Verify: the candidate declares a different " +
					"signature from the reference.")
			ok
			_cCand_ = pCand.ToWGSL()
		ok
		_nKRef_ = StzEngineGpuKernelCompile(poRef.ToWGSL())
		if _nKRef_ = 0
			StzRaise("Verify: the reference refused to compile: " + StzEngineGpuLastError())
		ok
		_nKCand_ = StzEngineGpuKernelCompile(_cCand_)
		if _nKCand_ = 0
			StzRaise("Verify: the candidate refused to compile: " + StzEngineGpuLastError())
		ok

		# THE HIDDEN SET, owned by the checker: a tile-uneven ODD size the
		# candidate was not shown, over DIFFERENT data -- the tail of each
		# vector, reversed. A permutation, so every value stays inside the
		# kernel's domain; and a candidate that hard-coded the visible
		# fixture (out[i] = f(i) instead of f(a[i])) answers wrong here.
		_nB_ = floor(_nA_ * 5 / 7)
		if _nB_ < 1
			_nB_ = 1
		ok
		if _nB_ > 1 and _nB_ % 2 = 0
			_nB_--
		ok
		_aIdsA_ = []
		_aIdsB_ = []
		for _i_ = 1 to _nIn_
			_nId_ = StzEngineGpuBufferNew(_nA_ * 4)
			if _nId_ = 0 or StzEngineGpuBufferUploadList(_nId_, _aVecs_[_i_]) != 0
				_FreeIds(_aIdsA_)
				_FreeIds(_aIdsB_)
				StzRaise("Verify: input upload refused (" + StzEngineGpuLastError() + ")")
			ok
			_aIdsA_ + _nId_
			_aHid_ = []
			for _j_ = _nA_ to (_nA_ - _nB_ + 1) step -1
				_aHid_ + _aVecs_[_i_][_j_]
			next
			_nId_ = StzEngineGpuBufferNew(_nB_ * 4)
			if _nId_ = 0 or StzEngineGpuBufferUploadList(_nId_, _aHid_) != 0
				_FreeIds(_aIdsA_)
				_FreeIds(_aIdsB_)
				StzRaise("Verify: hidden-set upload refused (" + StzEngineGpuLastError() + ")")
			ok
			_aIdsB_ + _nId_
		next
		_nOutA_ = StzEngineGpuBufferNew(_nA_ * 4)
		_nOutB_ = StzEngineGpuBufferNew(_nB_ * 4)
		if _nOutA_ = 0 or _nOutB_ = 0
			_FreeIds(_aIdsA_)
			_FreeIds(_aIdsB_)
			StzRaise("Verify: no device buffer for the outputs.")
		ok
		_aIdsA_ + _nOutA_
		_aIdsB_ + _nOutB_

		_nSt_ = StzEngineGpuVerify(_nKRef_, _nKCand_,
			_nA_, _aScal_, _aIdsA_, ceil(_nA_ / 256.0), ceil(_nA_ / 256.0),
			_nB_, _aIdsB_, ceil(_nB_ / 256.0), ceil(_nB_ / 256.0),
			_nReps_, _nBand_)
		_FreeIds(_aIdsA_)
		_FreeIds(_aIdsB_)
		if _nSt_ != 0
			StzRaise("Verify: the checker refused to run (status " + _nSt_ +
				": " + StzEngineGpuLastError() + ").")
		ok
		_nV_ = StzEngineGpuVerifyResult(0)
		_nBad_ = StzEngineGpuVerifyResult(3)
		if _nBad_ >= 0
			_nBad_++     # engine 0-based -> face 1-based
		else
			_nBad_ = 0
		ok
		return [
			:verdict = This._VerdictName(_nV_),
			:verified = (_nV_ = 0),
			:maxdiff = StzEngineGpuVerifyResult(1),
			:maxdiffhidden = StzEngineGpuVerifyResult(2),
			:firstbad = _nBad_,
			:refms = StzEngineGpuVerifyResult(4),
			:candms = StzEngineGpuVerifyResult(5),
			:refgpums = StzEngineGpuVerifyResult(6),
			:candgpums = StzEngineGpuVerifyResult(7),
			:speedup = StzEngineGpuVerifyResult(8),
			:speedupgpu = StzEngineGpuVerifyResult(9),
			:floorgbs = StzEngineGpuVerifyResult(10),
			:submitfloorms = StzEngineGpuVerifyResult(11),
			:bytes = StzEngineGpuVerifyResult(12),
			:minms = StzEngineGpuVerifyResult(13),
			:clocks = StzEngineGpuVerifyResult(14),
			:reps = StzEngineGpuVerifyResult(15),
			:jitterms = StzEngineGpuVerifyResult(16),
			:hiddensize = _nB_
		]

	# The roofline alone: could a dispatch touching nBytes finish in nMs on
	# this device? Pure judgement over the MEASURED floors -- exposed so a
	# guard can hand it an impossible number and watch it refuse.
	def VerifyJudge(nBytes, nMs)
		This._RequireDevice()
		return This._VerdictName(StzEngineGpuVerifyJudge(nBytes, nMs))

	# The measured floors themselves: [ :floorgbs, :submitfloorms ]
	def VerifyFloors()
		This._RequireDevice()
		StzEngineGpuVerifyJudge(1, 1)
		return [
			:floorgbs = StzEngineGpuVerifyResult(10),
			:submitfloorms = StzEngineGpuVerifyResult(11)
		]

	def _VerdictName(nV)
		switch nV
		on 0
			return "verified"
		on 1
			return "mismatch"
		on 2
			return "mismatch-hidden"
		on 3
			return "impossible"
		on 4
			return "reference-impossible"
		other
			return "error"
		off

	def LoadCalibration()
		StzGpuLoadCalibrationDefault()
		This._EnsureInit()
		StzGpuLoadCalibrationForAdapter()

	# one rung: warm-min per-query ms through the REAL seam, both routes
	def _CalibRung(pnCount, pnDim)
		_aVecs_ = []
		for _i_ = 0 to pnCount-1
			_aRow_ = []
			for _j_ = 0 to pnDim-1
				_aRow_ + ((_i_*7 + _j_*13) % 32)
			next
			_aVecs_ + _aRow_
		next
		_aQry_ = []
		for _j_ = 0 to pnDim-1
			_aQry_ + ((_j_*3 + 11) % 32)
		next
		StzEngineGpuCalibSet("pairdist", 999999999999)
		_oCpu_ = new stzVectorIndex(_aVecs_)
		_oCpu_.SearchExact(_aQry_, 5)
		_nCpu_ = This._MinQueryMs(_oCpu_, _aQry_)
		StzEngineGpuCalibSet("pairdist", 1)
		_oGpu_ = new stzVectorIndex(_aVecs_)
		_oGpu_.SearchExact(_aQry_, 5)
		_nGpu_ = This._MinQueryMs(_oGpu_, _aQry_)
		return [ _nCpu_, _nGpu_ ]

	def _MinQueryMs(poIdx, paQry)
		_nBest_ = 999999999
		for _r_ = 1 to 3
			_nT0_ = StzEngineWatchTimestampNs()
			poIdx.SearchExact(paQry, 5)
			_nMs_ = (StzEngineWatchTimestampNs() - _nT0_) / 1000000
			if _nMs_ < _nBest_
				_nBest_ = _nMs_
			ok
		next
		return _nBest_

	# ---- internals ------------------------------------------------------

	def _EnsureInit()
		if @bTriedInit_
			return
		ok
		@bTriedInit_ = 1
		if StzEngineGpuIsAvailable() = 0
			StzEngineGpuInit($cStzGpuRuntime)
		ok
		if StzEngineGpuIsAvailable() = 1
			StzGpuLoadCalibrationForAdapter()
		ok

	def _RequireDevice()
		This._EnsureInit()
		if StzEngineGpuIsAvailable() = 0
			StzRaise("stzGpu: no GPU device is available on this machine " +
				"(kernel authoring still works -- see stzKernelMaker.ToWGSL()).")
		ok
