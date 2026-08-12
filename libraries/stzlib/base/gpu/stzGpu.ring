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
