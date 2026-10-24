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

# A deterministic, distinct unit vector per index -- the synthetic corpus
# the knn_resident calibration walks (no model needed). A main-file func,
# ABOVE the class: in Ring a func after a class becomes its method.
func _StzUnitVector(pnI, pnD)
	_v_ = []
	_ss_ = 0
	for _j_ = 1 to pnD
		_x_ = sin(pnI * 0.37 + _j_ * 1.13) + 0.5 * cos(pnI * _j_ * 0.071)
		_v_ + _x_
		_ss_ += _x_ * _x_
	next
	_n_ = sqrt(_ss_)
	for _j_ = 1 to pnD
		_v_[_j_] = _v_[_j_] / _n_
	next
	return _v_

func StzGpuQ()
	return new stzGpu

# The doorway to the GPU plane: describe a computation with stzKernelMaker, hand it data, get data back, and calibrate where the GPU pays.
#
# Run is data in, data out; UploadQ and ApplyOnQ keep vectors resident to chain kernels without
# transfers. A one-shot Run pays upload, dispatch and readback, and for elementwise work the CPU
# usually wins: the GPU pays in the resident form and in compute-dense work. The device opens lazily
# on the first call that needs it; on a machine with no GPU IsAvailable answers FALSE and the data
# paths raise a clear error, while kernel authoring needs no device. Calibrate, CalibrateShaped, the
# Foundry methods and Verify measure the machine and persist their findings in the calibration file
# that later sessions load. Wake lifts an idle laptop GPU out of its power state before a timing.
# Only FirstError, LastError and ClearErrors were run for this documentation: the GPU sleeps on this
# machine and was left alone, so every other method was read from the code.
#
#   receiver   o1 = new stzGpu
#   example    o1.ClearErrors()
#              ? len(o1.FirstError())
#              #--> 0
#   see        stzKernelMaker, stzGpuBuffer
class stzGpu from stzObject

	@bTriedInit_ = 0

	# Creates a handle on the GPU plane; the device itself is opened lazily by the first call that needs it.
	#
	#   returns    nothing; the object is built
	#   note       nothing touches the device here
	#   see        IsAvailable
	def init()

	# TRUE if a GPU device was found and initialised, which the first call pays for once.
	#
	#   returns    TRUE or FALSE
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    initialises the device on its first use, which can wake a sleeping GPU
	#   see        DeviceName, AdapterCount
	def IsAvailable()
		This._EnsureInit()
		return StzEngineGpuIsAvailable() = 1

	# Returns the name of the selected GPU adapter, or an empty text when there is none.
	#
	#   returns    a text
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    initialises the device on its first use
	#   see        IsAvailable, AdapterCount
	def DeviceName()
		This._EnsureInit()
		if StzEngineGpuIsAvailable() = 0
			return ""
		ok
		return StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	# Returns how many GPU adapters the engine found.
	#
	#   returns    a number
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    initialises the device on its first use
	#   see        DeviceName
	def AdapterCount()
		This._EnsureInit()
		return StzEngineGpuAdapterCount()

	# Uploads a list of numbers to the device as one resident buffer and returns the buffer.
	#
	#   paNumbers   a non-empty list of numbers, stored as f32
	#   returns     a stzGpuBuffer
	#   note        not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#               from the code
	#   warning     a buffer lives on the device until Free is called, or until the engine evicts it
	#               under pressure; raises an error when no GPU device is available on the machine;
	#               an empty or non-list argument raises an error
	#   see         Run, ApplyOnQ
	# ---- the data paths -------------------------------------------------
	#@ aka  Upload a vector; it lives on the device until Free() (or eviction under VRAM pressure -- bounded, counted, never silent).
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

	# Runs an elementwise kernel over bound vectors and returns the result as a list of numbers, freeing every temporary.
	#
	#   poKernel     the stzKernelMaker that describes the computation
	#   paBindings   a list such as [ :A = aNumbers, :alpha = 2.5 ] that binds each declared vector
	#                to a list and each scalar to a number
	#   returns      a list of numbers
	#   note         not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#                from the code
	#   warning      a one-shot run pays upload, dispatch and readback, so for elementwise work the
	#                CPU usually wins; a missing binding or vectors of unequal lengths raise an
	#                error naming them; raises an error when no GPU device is available on the
	#                machine
	#   see          ApplyOnQ, UploadQ
	#@ aka  One-shot convenience: upload the bound vectors, run the kernel, read the result back, free everything temporary. Data in, DATA out.
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
			StzRaise("RunQ: the kernel refused to compile: " + StzEngineGpuFirstError())
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

	# Runs a multi-input kernel over buffers that are already resident, with no transfer, and returns the result as a new resident buffer.
	#
	#   poKernel     the stzKernelMaker that describes the computation
	#   paBindings   a list such as [ :A = oBuf1, :B = oBuf2, :alpha = 2 ] that binds each vector to
	#                a stzGpuBuffer and each scalar to a number
	#   returns      a stzGpuBuffer
	#   note         not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#                from the code
	#   warning      buffers of different lengths, or a vector not bound to a buffer, raise an
	#                error; raises an error when no GPU device is available on the machine
	#   see          Run, UploadQ
	#@ aka  Multi-input kernels over ALREADY-RESIDENT buffers: no transfer at all. paBindings binds vector names to stzGpuBuffer objects (plus scalars): oG.ApplyOnQ(k, [ :A = oBuf1, :B = oBuf2, :alpha = 2 ])
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
			StzRaise("ApplyOnQ: the kernel refused to compile: " + StzEngineGpuFirstError())
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

	# Measures where the GPU starts to beat the CPU on this machine for pairwise distances, stores the crossover and saves it.
	#
	#   returns    a list [ nThreshold, report ], the report holding [ size, cpuMs, gpuMs ] per rung
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the calibration file, which later sessions load; wakes the device with
	#              heavy work; takes seconds
	#   see        CalibrateWith, CalibrateShaped
	# ---- calibration (G5) -----------------------------------------------
	#@ aka  Measure where the GPU actually starts winning ON THIS MACHINE, store the crossover in the calibration store, and persist it (the faces auto-load it in later sessions). Warm-min discipline throughout -- G0's clock inversion means sustained numbers flatter the GPU. Returns [ nThreshold, [ [nProblemSize, nCpuMs, nGpuMs], ... ] ].
	def Calibrate()
		return This.CalibrateWith([1000, 2000, 4000, 8000, 16000])

	# Does the same as the call without arguments, on a ladder of corpus sizes chosen by the caller, the dimension being fixed at 64.
	#
	#   paRungs    the corpus sizes to measure, as a list of numbers, from small to large
	#   returns    a list [ nThreshold, report ]
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    the crossover is the first rung where the GPU wins by 30 percent; if it never
	#              wins, everything routes to the CPU; writes the calibration file
	#   see        Calibrate
	#@ aka  The same, on a caller-chosen ladder of corpus sizes (d fixed at 64: a representative embedding width; problem size = n*d).
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

	# Checks a candidate kernel against a reference kernel on the same inputs and on a hidden second shape, and returns a report.
	#
	#   poRef        the reference stzKernelMaker
	#   pCand        the candidate, a stzKernelMaker on the same declarations or raw WGSL on the
	#                same binding contract
	#   paBindings   a list that binds the vectors and scalars, as for Run
	#   returns      a hashlist with :verdict among verified, mismatch, mismatch-hidden, impossible,
	#                reference-impossible and error
	#   note         not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#                from the code
	#   warning      timing is taken by the engine, never by this face, and a time faster than the
	#                measured bus is refused as impossible; raises an error when no GPU device is
	#                available on the machine
	#   see          VerifyWith, VerifyJudge
	# ---- GK0: the checker -----------------------------------------------
	#@ aka  Verify a CANDIDATE kernel against a REFERENCE one: same inputs, same device, plus a HIDDEN second shape over DIFFERENT data the candidate was never shown; both timed the same way by the ENGINE (never by this face); and a refusal for any time faster than the measured bus. The report is DATA -- the verdict is the engine's, this face only reads it.
	def Verify(poRef, pCand, paBindings)
		return This.VerifyWith(poRef, pCand, paBindings, [])

	# Does the same as the call without options, with the repetitions and the numeric band chosen by the caller.
	#
	#   poRef        the reference stzKernelMaker
	#   pCand        the candidate, a stzKernelMaker or raw WGSL
	#   paBindings   a list that binds the vectors and scalars
	#   paOptions    a list such as [ :reps = 7, :band = 0.000001 ]
	#   returns      a hashlist with :verdict and the measurements
	#   note         not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#                from the code
	#   warning      reps below 3 become 7; raises an error when no GPU device is available on the
	#                machine
	#   see          Verify
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
			:peakgflops = StzEngineGpuVerifyResult(17),
			:flops = StzEngineGpuVerifyResult(18),
			:minmscompute = StzEngineGpuVerifyResult(19),
			:hiddensize = _nB_
		]

	# Judges whether a dispatch touching nBytes could finish in nMs on this device, against the measured floors.
	#
	#   nBytes     the bytes the dispatch touches
	#   nMs        the time it claims, in milliseconds
	#   returns    a text among verified, mismatch, mismatch-hidden, impossible, reference-
	#              impossible and error
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    pure judgement over floors measured on the device, exposed so that a guard can
	#              hand it an impossible number and watch it refuse; raises an error when no GPU
	#              device is available on the machine
	#   see        VerifyFloors, Verify
	#@ aka  The roofline alone: could a dispatch touching nBytes finish in nMs on this device? Pure judgement over the MEASURED floors -- exposed so a guard can hand it an impossible number and watch it refuse.
	def VerifyJudge(nBytes, nMs)
		This._RequireDevice()
		return This._VerdictName(StzEngineGpuVerifyJudge(nBytes, nMs))

	# Returns the device's measured floors: the copy speed in GB per second and the fixed cost of a submit in milliseconds.
	#
	#   returns    a hashlist [ :floorgbs, :submitfloorms ]
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    runs a tiny judgement to refresh the floors; raises an error when no GPU device
	#              is available on the machine
	#   see        VerifyJudge
	#@ aka  The measured floors themselves: [ :floorgbs, :submitfloorms ]
	def VerifyFloors()
		This._RequireDevice()
		StzEngineGpuVerifyJudge(1, 1)
		# the RECORD: the measured floors go into the adapter's calibration file under
		# peak_gflops and copy_gbs the next time any foundry verb saves (or RecordFloors()
		# saves now). The engine never reads them back -- see gpu_verify.zig, GK3.
		StzEngineGpuCalibSet("peak_gflops", StzEngineGpuVerifyPeakMeasuredGflops())
		StzEngineGpuCalibSet("copy_gbs", StzEngineGpuVerifyResult(10))
		return [
			:floorgbs = StzEngineGpuVerifyResult(10),
			:submitfloorms = StzEngineGpuVerifyResult(11),
			:peakgflops = StzEngineGpuVerifyResult(17),
			:peakmeasuredgflops = StzEngineGpuVerifyPeakMeasuredGflops(),
			:peakwarm = StzEngineGpuVerifyResult(20)
		]

	# Measures the floors and writes them into this adapter's calibration file at once, so the plan's tables can cite a dated number per adapter.
	#
	#   returns    the floors hashlist VerifyFloors returns
	#   see        VerifyFloors
	def RecordFloors()
		_aF_ = This.VerifyFloors()
		StzGpuSaveCalibration(This._AllCalibOps())
		return _aF_

	# Pins the compute peak the judge reads against, in GFLOP/s, for this process; 0 removes the pin.
	#
	#   nGflops    the peak to judge against; 0 = back to the measured one
	#   returns    the object itself
	#   note       a guard's tool: a peak pinned LOW refuses a time the measured peak accepted,
	#              which is how the compute ceiling's refusal is shown to work
	#   see        PeakGFlops, VerifyJudgeFlops
	def PinPeakGFlops(nGflops)
		StzEngineGpuVerifyPeakSet(nGflops)
		return This

	# Judges whether a dispatch touching nBytes and doing nFlops could finish in nMs on this device, against the measured floors AND the measured compute peak.
	#
	#   nBytes     the bytes the dispatch touches
	#   nFlops     the floating-point operations it does (2 per fused multiply-add)
	#   nMs        the time it claims, in milliseconds
	#   returns    a text among verified and impossible (error without a device)
	#   note       GK3: the compute ceiling is the burst peak the engine measured on this adapter
	#              (VerifyFloors()[:peakgflops]) times an allowance of 1.15; a claim above it is
	#              impossible by name, whatever the bytes
	#   warning    raises an error when no GPU device is available on the machine
	#   see        VerifyJudge, VerifyFloors
	def VerifyJudgeFlops(nBytes, nFlops, nMs)
		This._RequireDevice()
		return This._VerdictName(StzEngineGpuVerifyJudgeFlops(nBytes, nFlops, nMs))

	# Returns the compute peak of the current adapter in GFLOP/s, measured once per device by a dense fused-multiply-add kernel (or pinned explicitly in this process, or read from the adapter's calibration file).
	#
	#   returns    a number, GFLOP/s; 0 without a device
	#   note       GK3 (2026-10-24): RTX 3050 6GB Laptop 8,364 burst; Intel Graphics (Core 5 210H) 972
	#   see        VerifyFloors, VerifyJudgeFlops
	def PeakGFlops()
		return StzEngineGpuVerifyPeakGflops()

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

	# Loads the calibration store, the default one and the one of the selected adapter, so that the faces route by measured thresholds.
	#
	#   returns    nothing
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    initialises the device to learn the adapter
	#   see        Calibrate
	def LoadCalibration()
		StzGpuLoadCalibrationDefault()
		This._EnsureInit()
		StzGpuLoadCalibrationForAdapter()

	# Returns the first GPU error since the last clear, the cause where LastError is the symptom that followed it.
	#
	#   returns    a text; empty when there is none
	#   note       run: it answered an empty text on a fresh process, with no device opened
	#   warning    reads the engine's error buffer and does not touch the device
	#   see        LastError, ClearErrors
	# ---- the device's power state -----------------------------------------
	#@ aka  one rung: warm-min per-query ms through the REAL seam, both routes Measured 2026-09-09 on this laptop's RTX 3050: after ~10 s idle, every submit pays a fixed ~2 ms and the copy floor reads 13 GB/s instead of 85 -- and hundreds of tiny queries never lift it, while ~150 ms of heavy work does. Wake() is that work, ADAPTIVE: it copies until a copy runs at full speed, settles, and stops -- the budget i
	def FirstError()
		return StzEngineGpuFirstError()

	# Returns the latest GPU error since the last clear, which is the symptom of the first one.
	#
	#   returns    a text; empty when there is none
	#   note       run: it answered an empty text on a fresh process, with no device opened
	#   warning    reads the engine's error buffer and does not touch the device
	#   see        FirstError, ClearErrors
	def LastError()
		return StzEngineGpuLastError()

	# Forgets the recorded GPU errors, the first and the last.
	#
	#   returns    the object itself, so calls chain
	#   note       run: it touches only the engine's error buffer
	#   warning    a kernel compile clears both by itself
	#   see        FirstError, LastError
	def ClearErrors()
		StzEngineGpuErrorClear()
		return This

	# Wakes a sleeping device with copy work until a copy runs at full speed, and returns how many copies it took.
	#
	#   nBudgetMs   the most time to spend, in milliseconds, a cap and not a target
	#   returns     a number; about 20 on a device that was already awake
	#   note        not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#               from the code
	#   warning     an idle laptop GPU runs at a fraction of its speed, so every timing must call it
	#               first; raises an error when no GPU device is available on the machine
	#   see         Calibrate
	def Wake(nBudgetMs)
		This._RequireDevice()
		return StzEngineGpuWake(nBudgetMs)

	# Measures where the resident nearest-neighbour search wins on the GPU, on synthetic vectors of 384 dimensions, and saves the result.
	#
	#   returns    a hashlist of cells, the flat line and the reason
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the calibration file; the result is not stored when the control rung
	#              moved; takes minutes
	#   see        CalibrateKnnResidentWith, CalibrateShaped
	# ---- GS4: calibrating the semantic index's seam -------------------------
	#@ aka  The semantic index (stzSemanticIndex) routes its resident corpus to the GPU under the key "knn_resident" -- ITS OWN line, because a line is a comparison against a CPU alternative and this face's alternative is the multicore SIMD top-k (cluster.topK), not the vector index's scan the "pairdist" line was measured against. This pass walks corpus sizes at one dimension through the REAL face on syntheti
	def CalibrateKnnResident()
		# Measured 2026-09-09 on the RTX 3050 laptop at 384 dims: the GPU loses
		# at 1,000 (0.39x) and 4,000 (0.98x) and wins at 16,000 (1.42x); the
		# multicore top-k switches on at n*d >= 8M and the window may close
		# again above it -- which is why the rung above that gate is measured
		# too, and why the store is SHAPED: a class that wins carries its win,
		# and the flat line stays beyond the ladder where a class lost.
		return This.CalibrateKnnResidentWith([1000, 4000, 16000, 32000], 384)

	# Does the same as the call without arguments, for corpus sizes and a dimension chosen by the caller.
	#
	#   paCounts   the corpus sizes to measure, as a list of numbers
	#   nDim       the vector width of the synthetic corpus
	#   returns    a hashlist with :cells, :flat and :flatwhy
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    the first rung is measured again at the end as a control; writes the calibration
	#              file
	#   see        CalibrateKnnResident
	def CalibrateKnnResidentWith(paCounts, nDim)
		This._RequireDevice()
		_cKey_ = "knn_resident"
		_aCells_ = []
		_nFlat_ = 0
		_bBeyond_ = FALSE
		_nMaxNd_ = 0
		_nRungs_ = ring_len(paCounts)
		for _i_ = 1 to _nRungs_
			_n_ = paCounts[_i_]
			_aR_ = This._KnnRung(_n_, nDim)
			_nRatio_ = 0
			if _aR_[2] > 0
				_nRatio_ = _aR_[1] / _aR_[2]
			ok
			StzGpuCalibSetShaped(_cKey_, _n_, nDim, _nRatio_)
			StzGpuCalibAddLadderRow(_cKey_, _n_, nDim, _aR_[1], _aR_[2])
			_aCells_ + [ nDim, _n_, _aR_[1], _aR_[2], _nRatio_ ]
			if _n_ * nDim > _nMaxNd_
				_nMaxNd_ = _n_ * nDim
			ok
			if _nRatio_ >= 1.3
				if _nFlat_ = 0
					_nFlat_ = _n_ * nDim
				ok
			else
				# a rung that LOSES above a rung that won: the window closed,
				# so the flat line cannot be a simple "from here on" -- the
				# shaped classes carry the wins; the flat line goes beyond
				if _nFlat_ > 0
					_bBeyond_ = TRUE
				ok
			ok
		next
		_cWhy_ = "crossover"
		if _nFlat_ = 0 or _bBeyond_
			_nFlat_ = _nMaxNd_ + 1
			_cWhy_ = "beyond-ladder"
		ok
		# the control: the first rung again, last
		_bConf_ = FALSE
		_aCtrl_ = []
		if ring_len(_aCells_) > 0
			_c1_ = _aCells_[1]
			_aAgain_ = This._KnnRung(_c1_[2], _c1_[1])
			_nG_ = 0
			if _c1_[4] > 0
				_nG_ = _aAgain_[2] / _c1_[4]
			ok
			_nC_ = 0
			if _c1_[3] > 0
				_nC_ = _aAgain_[1] / _c1_[3]
			ok
			_aCtrl_ = [ _c1_[1], _c1_[2], _c1_[3], _c1_[4], _aAgain_[1], _aAgain_[2], _nC_, _nG_ ]
			if _nG_ > 2 or _nG_ < 0.5 or _nC_ > 2 or _nC_ < 0.5
				_bConf_ = TRUE
			ok
		ok
		if _bConf_
			_nS_ = ring_len(_aCells_)
			for _i_ = 1 to _nS_
				StzEngineGpuCalibSetShaped(_cKey_, _aCells_[_i_][2], _aCells_[_i_][1], 0)
			next
			return [ :cells = _aCells_, :flat = 0, :flatwhy = "confounded",
			         :confounded = TRUE, :control = _aCtrl_, :adapter = This.DeviceName() ]
		ok
		StzEngineGpuCalibSet(_cKey_, _nFlat_)
		StzGpuSaveCalibration([_cKey_])
		return [ :cells = _aCells_, :flat = _nFlat_, :flatwhy = _cWhy_,
		         :confounded = FALSE, :control = _aCtrl_, :adapter = This.DeviceName() ]

	# one rung: both routes through the real face, [ cpuMs, gpuMs ]
	def _KnnRung(pnN, pnDim)
		_aVecs_ = []
		for _i_ = 1 to pnN
			_aVecs_ + _StzUnitVector(_i_, pnDim)
		next
		_nOldT_ = StzEngineGpuCalibGet("knn_resident")
		_nOldR_ = StzEngineGpuCalibGetShaped("knn_resident", pnN, pnDim)
		StzEngineGpuCalibSet("knn_resident", 999999999999)
		StzEngineGpuCalibSetShaped("knn_resident", pnN, pnDim, 0.01)
		_oC_ = new stzSemanticIndex([])
		for _i_ = 1 to pnN
			_oC_.AddEmbedded("t" + _i_, _aVecs_[_i_])
		next
		_oC_.SearchByVectorXT(_aVecs_[7], 5)
		_nCpu_ = This._MinVectorSearchMs(_oC_, _aVecs_[7])
		_oC_.Close()
		StzEngineGpuCalibSet("knn_resident", 1)
		StzEngineGpuCalibSetShaped("knn_resident", pnN, pnDim, 1000)
		_oG_ = new stzSemanticIndex([])
		for _i_ = 1 to pnN
			_oG_.AddEmbedded("t" + _i_, _aVecs_[_i_])
		next
		_oG_.SearchByVectorXT(_aVecs_[7], 5)
		StzEngineGpuWake(400)
		_nGpu_ = This._MinVectorSearchMs(_oG_, _aVecs_[7])
		_oG_.Close()
		StzEngineGpuCalibSetShaped("knn_resident", pnN, pnDim, _nOldR_)
		if _nOldT_ > 0
			StzEngineGpuCalibSet("knn_resident", _nOldT_)
		else
			StzEngineGpuCalibSet("knn_resident", 0)
		ok
		return [ _nCpu_, _nGpu_ ]

	def _MinVectorSearchMs(poIdx, paQ)
		_nBest_ = 999999999
		for _r_ = 1 to 5
			_nT0_ = StzEngineWatchTimestampNs()
			poIdx.SearchByVectorXT(paQ, 5)
			_nMs_ = (StzEngineWatchTimestampNs() - _nT0_) / 1000000
			if _nMs_ < _nBest_
				_nBest_ = _nMs_
			ok
		next
		return _nBest_

	# Convolves two real signals on the device in one batched FFT pass and returns the linear convolution as a list of numbers.
	#
	#   paA        the first signal, a non-empty list of numbers
	#   paB        the second signal, a non-empty list of numbers
	#   returns    a list of numbers of length len(A) + len(B) - 1
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    one-shot: it uploads, runs and downloads; empty or non-list signals raise an
	#              error; raises an error when no GPU device is available on the machine
	#   see        UploadQ
	# ---- GS1: FFT convolution on the GPU -----------------------------------
	#@ aka  The linear convolution of two real signals -- convolution reverb's arithmetic -- as ONE batched pass on the device: both operands packed and transformed (Stockham radix-2, twiddles from a table computed in f64), multiplied pointwise, transformed back, the real part scaled. SN0 measured it at 19-23x over fft.zig for 60 s of audio on the 3050.
	def ConvolveReal(paA, paB)
		This._RequireDevice()
		if NOT isList(paA) or NOT isList(paB) or ring_len(paA) = 0 or ring_len(paB) = 0
			StzRaise("ConvolveReal: give me two non-empty lists of numbers.")
		ok
		_nA_ = ring_len(paA)
		_nB_ = ring_len(paB)
		_nOut_ = _nA_ + _nB_ - 1
		_hA_ = StzEngineGpuBufferNew(_nA_ * 4)
		_hB_ = StzEngineGpuBufferNew(_nB_ * 4)
		_hO_ = StzEngineGpuBufferNew(_nOut_ * 4)
		if _hA_ = 0 or _hB_ = 0 or _hO_ = 0
			_FreeIds([_hA_, _hB_, _hO_])
			StzRaise("ConvolveReal: no device buffer (" + StzEngineGpuLastError() + ")")
		ok
		if StzEngineGpuBufferUploadList(_hA_, paA) != 0 or StzEngineGpuBufferUploadList(_hB_, paB) != 0
			_FreeIds([_hA_, _hB_, _hO_])
			StzRaise("ConvolveReal: upload refused (" + StzEngineGpuLastError() + ")")
		ok
		_nSt_ = StzEngineGpuOpConvolveReal(_hA_, _nA_, _hB_, _nB_, _hO_)
		if _nSt_ != 0
			_FreeIds([_hA_, _hB_, _hO_])
			StzRaise("ConvolveReal: the op refused (status " + _nSt_ + ").")
		ok
		_aOut_ = StzEngineGpuBufferDownloadList(_hO_, _nOut_)
		_FreeIds([_hA_, _hB_, _hO_])
		return _aOut_

	# Lets the engine try the variants of the pairwise-distance kernel at a shape and record the winner if it beats the generic one by 1.3 times.
	#
	#   m          the number of queries, from 1 to 16
	#   n          the corpus size
	#   d          the vector width
	#   returns    a hashlist report: :m, :n, :d, :variants, :winner, :ratio, :stored
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the variant table to the calibration file; the foundry refuses m above 16
	#              with an error
	#   see        FoundryPairdistWith, FoundryPairdistGrid
	# ---- GK2: the foundry -- op variants by enumeration ------------------
	#@ aka  The op library carries VARIANTS of pairdist (a straight row kernel, a vec4 one, one with the query staged in workgroup memory) beside the generic 16x16 tile. This pass lets the ENGINE enumerate them under GK0's checker: each is verified against the generic on the same device buffers at the visible shape AND a hidden one (different size, different data), timed on the GPU clock with the device awake
	def FoundryPairdist(m, n, d)
		return This.FoundryPairdistWith(m, n, d, 7)

	# Does the same as the call without repetitions, with the number of timed repetitions chosen by the caller.
	#
	#   m          the number of queries, from 1 to 16
	#   n          the corpus size
	#   d          the vector width
	#   nReps      how many repetitions to time
	#   returns    a hashlist report as FoundryPairdist returns
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    an invalid shape raises an error quoting the engine status
	#   see        FoundryPairdist
	def FoundryPairdistWith(m, n, d, nReps)
		This._RequireDevice()
		_nSt_ = StzEngineGpuFoundryPairdist(m, n, d, nReps, 0)
		if _nSt_ != 0
			StzRaise("FoundryPairdist: the foundry refused to run (status " + _nSt_ +
				": " + StzEngineGpuLastError() + "). m must be 1..16.")
		ok
		return This._FoundryReport(m, n, d, TRUE)

	def _FoundryReport(m, n, d, bStore)
		_nCount_ = StzEngineGpuFoundryResult(0)
		_aV_ = []
		for _v_ = 1 to _nCount_
			_nB_ = 10 + _v_ * 5
			_aV_ + [ StzEngineGpuVariantName(_v_), StzEngineGpuFoundryResult(_nB_),
			         StzEngineGpuFoundryResult(_nB_ + 1), StzEngineGpuFoundryResult(_nB_ + 2),
			         StzEngineGpuFoundryResult(_nB_ + 3), StzEngineGpuFoundryResult(_nB_ + 4) ]
		next
		_nW_ = StzEngineGpuFoundryResult(3)
		_bStored_ = FALSE
		if bStore and _nW_ > 0
			_bStored_ = StzGpuVariantSet("pairdist", m, n, d, _nW_)
			StzGpuSaveCalibration(["pairdist"])
		ok
		return [
			:m = m, :n = n, :d = d,
			:hiddenn = StzEngineGpuFoundryResult(6),
			:clocks = StzEngineGpuFoundryResult(5),
			:refgpums = StzEngineGpuFoundryResult(1),
			:refwallms = StzEngineGpuFoundryResult(2),
			:flops = StzEngineGpuFoundryResult(7),
			:bytes = StzEngineGpuFoundryResult(8),
			:peakgflops = StzEngineGpuFoundryResult(9),
			:fractions = This._FoundryFractions(_aV_, StzEngineGpuFoundryResult(1), StzEngineGpuFoundryResult(2),
				StzEngineGpuFoundryResult(7), StzEngineGpuFoundryResult(8), StzEngineGpuFoundryResult(9)),
			:variants = _aV_,
			:winner = StzEngineGpuVariantName(_nW_),
			:ratio = StzEngineGpuFoundryResult(4),
			:stored = _bStored_
		]

	# Lets the engine try three workgroup widths of the fused attention kernel at a shape and record the winner.
	#
	#   nTok       the tokens, from 2 to 256
	#   nEmbd      the model width, a multiple of the head count
	#   nHeads     the number of attention heads
	#   returns    a hashlist report with the winner and its ratio
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the variant table to the calibration file and pushes it into the neural
	#              engine; a refused shape raises an error
	#   see        FoundryAttentionWith, FoundryMatmul
	#@ aka  THE ATTENTION FOUNDRY (GK2c). The backbone's fused attention -- one workgroup per (head, query row) -- against three reduction-form variants at workgroup widths 64, 128 and 256, under the checker on the neural DLL's device; the winner recorded for the (tokens, width, head_dim) class under the op name "attention", persisted, and pushed into the neural DLL's table so the next forward dispatches it.
	def FoundryAttention(nTok, nEmbd, nHeads)
		return This.FoundryAttentionWith(nTok, nEmbd, nHeads, 7)

	# Does the same as the call without repetitions, with the number of timed repetitions chosen by the caller.
	#
	#   nTok       the tokens, from 2 to 256
	#   nEmbd      the model width, a multiple of the head count
	#   nHeads     the number of attention heads
	#   nReps      how many repetitions to time
	#   returns    a hashlist report as FoundryAttention returns
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    a refused shape raises an error
	#   see        FoundryAttention
	def FoundryAttentionWith(nTok, nEmbd, nHeads, nReps)
		_nSt_ = StzEngineNeuralAttentionFoundry(nTok, nEmbd, nHeads, nReps, 0)
		if _nSt_ != 0
			StzRaise("FoundryAttention: the foundry refused to run (status " + _nSt_ +
				"). Tokens must be 2..256 and the width a multiple of the head count.")
		ok
		_nCount_ = StzEngineNeuralAttentionFoundryResult(0)
		_aV_ = []
		for _v_ = 1 to _nCount_
			_nB_ = 8 + _v_ * 5
			_aV_ + [ StzEngineNeuralAttentionVariantName(_v_), StzEngineNeuralAttentionFoundryResult(_nB_),
			         StzEngineNeuralAttentionFoundryResult(_nB_ + 1), StzEngineNeuralAttentionFoundryResult(_nB_ + 2),
			         StzEngineNeuralAttentionFoundryResult(_nB_ + 3), StzEngineNeuralAttentionFoundryResult(_nB_ + 4) ]
		next
		_nW_ = StzEngineNeuralAttentionFoundryResult(3)
		_nHd_ = floor(nEmbd / nHeads)
		_bStored_ = FALSE
		if _nW_ > 0
			StzEngineNeuralVariantSet("attention", nTok, nEmbd, _nHd_, _nW_)
			_bStored_ = StzGpuVariantSet("attention", nTok, nEmbd, _nHd_, _nW_)
			StzGpuSaveCalibration(This._AllCalibOps())
		ok
		return [
			:tokens = nTok, :width = nEmbd, :heads = nHeads,
			:hiddenn = StzEngineNeuralAttentionFoundryResult(6),
			:clocks = StzEngineNeuralAttentionFoundryResult(5),
			:refgpums = StzEngineNeuralAttentionFoundryResult(1),
			:refwallms = StzEngineNeuralAttentionFoundryResult(2),
			:variants = _aV_,
			:winner = StzEngineNeuralAttentionVariantName(_nW_),
			:ratio = StzEngineNeuralAttentionFoundryResult(4),
			:stored = _bStored_
		]

	# Lets the engine try the matrix-multiply variants tile16, tile8, reg2 and reg4 at a shape and record the winner.
	#
	#   m          the rows of A
	#   k          the columns of A and the rows of B
	#   n          the columns of B
	#   returns    a hashlist report with the winner and its ratio
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the variant table to the calibration file; a refused shape raises an error
	#   see        FoundryMatmulWith, FoundryAttention
	#@ aka  THE MATMUL FOUNDRY (GK2b's matmul leg). C(m x n) = A(m x k) B(k x n): tile16 (the generic), tile8, reg2, reg4 under the checker at the asked shape and a hidden one; the winner recorded for the (m, n, k) class under the op name "matmul" and persisted. The backbone compiles the table's winner for its own shapes with the bias fused.
	def FoundryMatmul(m, k, n)
		return This.FoundryMatmulWith(m, k, n, 7)

	# Does the same as the call without repetitions, with the number of timed repetitions chosen by the caller.
	#
	#   m          the rows of A
	#   k          the columns of A and the rows of B
	#   n          the columns of B
	#   nReps      how many repetitions to time
	#   returns    a hashlist report as FoundryMatmul returns
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    a refused shape raises an error
	#   see        FoundryMatmul
	def FoundryMatmulWith(m, k, n, nReps)
		This._RequireDevice()
		_nSt_ = StzEngineGpuFoundryMatmul(m, k, n, nReps, 0)
		if _nSt_ != 0
			StzRaise("FoundryMatmul: the foundry refused to run (status " + _nSt_ +
				": " + StzEngineGpuFirstError() + ").")
		ok
		_nCount_ = StzEngineGpuFoundryResult(0)
		_aV_ = []
		for _v_ = 1 to _nCount_
			_nB_ = 10 + _v_ * 5
			_aV_ + [ StzEngineGpuMmVariantName(_v_), StzEngineGpuFoundryResult(_nB_),
			         StzEngineGpuFoundryResult(_nB_ + 1), StzEngineGpuFoundryResult(_nB_ + 2),
			         StzEngineGpuFoundryResult(_nB_ + 3), StzEngineGpuFoundryResult(_nB_ + 4) ]
		next
		_nW_ = StzEngineGpuFoundryResult(3)
		_bStored_ = FALSE
		if _nW_ > 0
			_bStored_ = StzGpuVariantSet("matmul", m, n, k, _nW_)
			StzGpuSaveCalibration(This._AllCalibOps())
		ok
		return [
			:m = m, :k = k, :n = n,
			:hiddenn = StzEngineGpuFoundryResult(6),
			:clocks = StzEngineGpuFoundryResult(5),
			:refgpums = StzEngineGpuFoundryResult(1),
			:refwallms = StzEngineGpuFoundryResult(2),
			:flops = StzEngineGpuFoundryResult(7),
			:bytes = StzEngineGpuFoundryResult(8),
			:peakgflops = StzEngineGpuFoundryResult(9),
			:fractions = This._FoundryFractions(_aV_, StzEngineGpuFoundryResult(1), StzEngineGpuFoundryResult(2),
				StzEngineGpuFoundryResult(7), StzEngineGpuFoundryResult(8), StzEngineGpuFoundryResult(9)),
			:variants = _aV_,
			:winner = StzEngineGpuMmVariantName(_nW_),
			:ratio = StzEngineGpuFoundryResult(4),
			:stored = _bStored_
		]

	# Lets the engine try the variants of the UMAP nearest-neighbour kernel at a shape and record the winner for the next session.
	#
	#   n          the number of points
	#   d          the vector width
	#   k          the neighbours, from 1 to 64 and below n
	#   returns    a hashlist report with the winner and its ratio
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the variant table to the calibration file under umap_knn; a refused shape
	#              raises an error
	#   see        FoundryUmapKnnWith, FoundryPairdist
	#@ aka  THE k-NN FOUNDRY (GS6e). The UMAP k-NN kernel lives in the stats DLL on its own device, so its enumeration runs there; the verdict is recorded in that DLL's variant table AND persisted here under the op name "umap_knn", beside pairdist's rows, so the next session finds it. The stats DLL reads the persisted rows back through StzUmapKnnVariantsSync() at its first fit.
	def FoundryUmapKnn(n, d, k)
		return This.FoundryUmapKnnWith(n, d, k, 7)

	# Does the same as the call without repetitions, with the number of timed repetitions chosen by the caller.
	#
	#   n          the number of points
	#   d          the vector width
	#   k          the neighbours, from 1 to 64 and below n
	#   nReps      how many repetitions to time
	#   returns    a hashlist report as FoundryUmapKnn returns
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    a refused shape raises an error
	#   see        FoundryUmapKnn
	def FoundryUmapKnnWith(n, d, k, nReps)
		This._RequireDevice()
		_nSt_ = StzEngineUmapKnnFoundry(n, d, k, nReps, 0)
		if _nSt_ != 0
			StzRaise("FoundryUmapKnn: the foundry refused to run (status " + _nSt_ +
				": " + StzEngineStatsGpuFirstError() + "). k must be 1..64 and below n.")
		ok
		_nCount_ = StzEngineUmapKnnFoundryResult(0)
		_aV_ = []
		for _v_ = 1 to _nCount_
			_nB_ = 8 + _v_ * 5
			_aV_ + [ StzEngineUmapKnnVariantName(_v_), StzEngineUmapKnnFoundryResult(_nB_),
			         StzEngineUmapKnnFoundryResult(_nB_ + 1), StzEngineUmapKnnFoundryResult(_nB_ + 2),
			         StzEngineUmapKnnFoundryResult(_nB_ + 3), StzEngineUmapKnnFoundryResult(_nB_ + 4) ]
		next
		_nW_ = StzEngineUmapKnnFoundryResult(3)
		_bStored_ = FALSE
		if _nW_ > 0
			StzEngineUmapKnnVariantSet(n, d, k, _nW_)
			_bStored_ = StzGpuVariantSet("umap_knn", k, n, d, _nW_)
			StzGpuSaveCalibration(This._AllCalibOps())
		ok
		return [
			:n = n, :d = d, :k = k,
			:hiddenn = StzEngineUmapKnnFoundryResult(6),
			:clocks = StzEngineUmapKnnFoundryResult(5),
			:refgpums = StzEngineUmapKnnFoundryResult(1),
			:refwallms = StzEngineUmapKnnFoundryResult(2),
			:variants = _aV_,
			:winner = StzEngineUmapKnnVariantName(_nW_),
			:ratio = StzEngineUmapKnnFoundryResult(4),
			:stored = _bStored_
		]

	# every op the calibration file currently knows, so a save from one foundry
	# never drops another's rows (the writer keeps only the ops it is given)
	# GK3: for the generic and every verified variant, the fraction of the measured compute peak and of the measured copy bandwidth its time reached (GPU clock where there is one, wall otherwise). A row is [ name, gpu_ms, fraction_of_peak, fraction_of_bandwidth ].
	def _FoundryFractions(paVariants, nRefGpuMs, nRefWallMs, nFlops, nBytes, nPeakGflops)
		_aRows_ = []
		_nCopyGbs_ = StzEngineGpuVerifyResult(10)
		_nRef_ = nRefGpuMs
		if _nRef_ <= 0
			_nRef_ = nRefWallMs
		ok
		_aRows_ + This._FractionRow("generic", _nRef_, nFlops, nBytes, nPeakGflops, _nCopyGbs_)
		_n_ = len(paVariants)
		for _i_ = 1 to _n_
			_v_ = paVariants[_i_]
			if _v_[2] = 1
				_nMs_ = _v_[3]
				if _nMs_ <= 0
					_nMs_ = _v_[4]
				ok
				_aRows_ + This._FractionRow(_v_[1], _nMs_, nFlops, nBytes, nPeakGflops, _nCopyGbs_)
			ok
		next
		return _aRows_

	def _FractionRow(cName, nMs, nFlops, nBytes, nPeakGflops, nCopyGbs)
		_nPeak_ = 0
		_nBw_ = 0
		if nMs > 0 and nPeakGflops > 0
			_nPeak_ = (nFlops / (nMs / 1000)) / (nPeakGflops * 1000000000)
		ok
		if nMs > 0 and nCopyGbs > 0
			_nBw_ = (nBytes / (nMs / 1000)) / (nCopyGbs * 1000000000)
		ok
		return [ cName, nMs, _nPeak_, _nBw_ ]

	def _AllCalibOps()
		_aOps_ = [ "pairdist", "peak_gflops", "copy_gbs" ]
		_aAll_ = StzGpuVariants()
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if find(_aOps_, _aAll_[_i_][1]) = 0
				_aOps_ + _aAll_[_i_][1]
			ok
		next
		_aAll_ = StzGpuCalibrationLadder()
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if find(_aOps_, _aAll_[_i_][1]) = 0
				_aOps_ + _aAll_[_i_][1]
			ok
		next
		if find(_aOps_, "knn_resident") = 0
			_aOps_ + "knn_resident"
		ok
		return _aOps_

	# Runs the pairwise-distance foundry over a grid of corpus sizes and widths and says whether any shape found a variant worth the margin.
	#
	#   paCounts   the corpus sizes to try, as a list of numbers
	#   paDims     the vector widths to try, as a list of numbers
	#   returns    a hashlist [ :cells, :anywin, :adapter ]
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    one single-query run per cell, so the cost grows with the grid; writes the
	#              calibration file
	#   see        FoundryPairdist
	#@ aka  The kill line, per adapter: a grid of single-query shapes; TRUE if any class found a variant worth the margin.
	def FoundryPairdistGrid(paCounts, paDims)
		This._RequireDevice()
		_aCells_ = []
		_bAny_ = FALSE
		_nC_ = ring_len(paCounts)
		_nD_ = ring_len(paDims)
		for _i_ = 1 to _nC_
			for _j_ = 1 to _nD_
				_aR_ = This.FoundryPairdist(1, paCounts[_i_], paDims[_j_])
				_aCells_ + _aR_
				if _aR_[:ratio] >= 1.3
					_bAny_ = TRUE
				ok
			next
		next
		return [ :cells = _aCells_, :anywin = _bAny_, :adapter = This.DeviceName() ]

	# Times CPU and GPU over a grid of widths and corpus sizes, records the ratio per shape class, and checks itself on two unmeasured shapes.
	#
	#   returns    a hashlist report: :cells, :flat, :flatwhy, :hidden, :adapter
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    writes the calibration file unless the control cell moved, in which case the grid
	#              is reported as confounded and not saved; takes minutes
	#   see        CalibrateShapedWith, Calibrate
	# ---- GK1: the SHAPED calibration --------------------------------------
	#@ aka  The flat pass above walks one dimension (d = 64) and stores one number. GK1's probe (gk1_shape_probe.ring, 2026-09-09) measured that the number on disk routed half the grid WRONG, and that on the Intel iGPU the crossover moves 4x with the dimension. So this pass walks a GRID of dimensions x corpus sizes through the real seam, both routes forced, records the measured cpu/gpu RATIO per shape class (
	def CalibrateShaped()
		return This.CalibrateShapedWith([16, 64, 256, 1024], [1000, 4000, 16000])

	# Does the same as the call without arguments, on a grid of widths and corpus sizes chosen by the caller.
	#
	#   paDims     the vector widths to measure, as a list of numbers
	#   paCounts   the corpus sizes to measure, as a list of numbers
	#   returns    a hashlist report as CalibrateShaped returns
	#   note       not run: it uses the GPU, which sleeps on this machine and was left alone; read
	#              from the code
	#   warning    a width whose ladder never crossed sends unknown shapes to the CPU; writes the
	#              calibration file unless confounded
	#   see        CalibrateShaped
	def CalibrateShapedWith(paDims, paCounts)
		This._RequireDevice()
		_nBudget_ = 4200000
		_aCells_ = []
		_nMaxNd_ = 0
		_nFlat_ = 0
		_bBeyond_ = FALSE
		_nDims_ = ring_len(paDims)
		_nCounts_ = ring_len(paCounts)
		for _di_ = 1 to _nDims_
			_d_ = paDims[_di_]
			_nCrossD_ = 0
			_nLastNd_ = 0
			for _ni_ = 1 to _nCounts_
				_n_ = paCounts[_ni_]
				if _n_ * _d_ > _nBudget_
					loop
				ok
				_aR_ = This._CalibRung(_n_, _d_)
				_nRatio_ = 0
				if _aR_[2] > 0
					_nRatio_ = _aR_[1] / _aR_[2]
				ok
				StzGpuCalibSetShaped("pairdist", _n_, _d_, _nRatio_)
				StzGpuCalibAddLadderRow("pairdist", _n_, _d_, _aR_[1], _aR_[2])
				_aCells_ + [ _d_, _n_, _aR_[1], _aR_[2], _nRatio_ ]
				_nLastNd_ = _n_ * _d_
				if _nLastNd_ > _nMaxNd_
					_nMaxNd_ = _nLastNd_
				ok
				if _nCrossD_ = 0 and _nRatio_ >= 1.3
					_nCrossD_ = _n_ * _d_
				ok
			next
			if _nCrossD_ = 0
				# this dimension never crossed on the ladder: unknown
				# territory lies BEYOND it, and unknown routes CPU
				_bBeyond_ = TRUE
			but _nCrossD_ > _nFlat_
				_nFlat_ = _nCrossD_
			ok
		next
		_cWhy_ = "crossover"
		if _bBeyond_ or _nFlat_ = 0
			_nFlat_ = _nMaxNd_ + 1
			_cWhy_ = "beyond-ladder"
		ok

		# THE CONTROL: the first cell, measured again at the END of the grid.
		# A control that moves means the grid was confounded -- and on this
		# machine it can be (GK1 found a device state where every query
		# pays a fixed ~2 ms, appearing mid-run, persisting for the process).
		# A confounded grid is REPORTED and NOT persisted: a wrong number on
		# disk routes every later process wrong.
		_bConf_ = FALSE
		_aCtrl_ = []
		if ring_len(_aCells_) > 0
			_c1_ = _aCells_[1]
			_aAgain_ = This._CalibRung(_c1_[2], _c1_[1])
			_nGpuMove_ = 0
			if _c1_[4] > 0
				_nGpuMove_ = _aAgain_[2] / _c1_[4]
			ok
			_nCpuMove_ = 0
			if _c1_[3] > 0
				_nCpuMove_ = _aAgain_[1] / _c1_[3]
			ok
			_aCtrl_ = [ _c1_[1], _c1_[2], _c1_[3], _c1_[4], _aAgain_[1], _aAgain_[2], _nCpuMove_, _nGpuMove_ ]
			if _nGpuMove_ > 2 or _nGpuMove_ < 0.5 or _nCpuMove_ > 2 or _nCpuMove_ < 0.5
				_bConf_ = TRUE
			ok
		ok
		if _bConf_
			# leave the store as it was before this pass: nothing measured
			# under a moving control is trusted
			_nS_ = ring_len(_aCells_)
			for _i_ = 1 to _nS_
				StzEngineGpuCalibSetShaped("pairdist", _aCells_[_i_][2], _aCells_[_i_][1], 0)
			next
			return [
				:cells = _aCells_,
				:flat = 0,
				:flatwhy = "confounded",
				:confounded = TRUE,
				:control = _aCtrl_,
				:hidden = [],
				:adapter = This.DeviceName()
			]
		ok
		StzEngineGpuCalibSet("pairdist", _nFlat_)

		# THE HIDDEN CHECK: shapes the grid did not hold
		_aHidden_ = []
		if _nDims_ >= 2 and _nCounts_ >= 2
			# (a) inside a measured class, off the grid point: 3/4 of a cell
			_d1_ = paDims[_nDims_ - 1]
			_n1_ = paCounts[2]
			_aHidden_ + This._HiddenCheck(floor(_n1_ * 3 / 4), floor(_d1_ * 3 / 4) + 1)
			# (b) in a class the grid never measured: between two dims
			_dm_ = floor(sqrt(paDims[1] * paDims[2]))
			_nm_ = floor(sqrt(paCounts[1] * paCounts[2]))
			_aHidden_ + This._HiddenCheck(_nm_, _dm_)
		ok

		StzGpuSaveCalibration(["pairdist"])
		return [
			:cells = _aCells_,
			:flat = _nFlat_,
			:flatwhy = _cWhy_,
			:confounded = FALSE,
			:control = _aCtrl_,
			:hidden = _aHidden_,
			:adapter = This.DeviceName()
		]

	# what the store PREDICTS for (n, d) vs what the seam MEASURES there
	def _HiddenCheck(pnN, pnD)
		_nPred_ = StzEngineGpuCalibRouteShaped("pairdist", pnN, pnD)
		_aR_ = This._CalibRung(pnN, pnD)
		_nMeas_ = 0
		_nRatio_ = 0
		if _aR_[2] > 0
			_nRatio_ = _aR_[1] / _aR_[2]
			if _nRatio_ >= 1.3
				_nMeas_ = 1
			ok
		ok
		# a shape near the line (ratio inside [1, 1.69], the margin either
		# side) is MARGINAL: its verdict can flip run to run, and it is not
		# evidence against the store. :decisive says whether it counts.
		_bDecisive_ = (_nRatio_ < 1 or _nRatio_ >= 1.69)
		return [ pnD, pnN, _aR_[1], _aR_[2], _nPred_, _nMeas_, (_nPred_ = _nMeas_), _nRatio_, _bDecisive_ ]

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
		# force each route through BOTH knobs: the flat line, and the
		# shape class this corpus falls in (a measured class outranks the
		# flat line -- GK1 -- so a ladder cannot be forced by the line alone)
		_nOldR_ = StzEngineGpuCalibGetShaped("pairdist", pnCount, pnDim)
		_nOldT_ = StzEngineGpuCalibGet("pairdist")
		StzEngineGpuCalibSet("pairdist", 999999999999)
		StzEngineGpuCalibSetShaped("pairdist", pnCount, pnDim, 0.01)
		_oCpu_ = new stzVectorIndex(_aVecs_)
		_oCpu_.SearchExact(_aQry_, 5)
		_nCpu_ = This._MinQueryMs(_oCpu_, _aQry_)
		StzEngineGpuCalibSet("pairdist", 1)
		StzEngineGpuCalibSetShaped("pairdist", pnCount, pnDim, 1000)
		# the corpus was just built in Ring (seconds, GPU idle): WAKE the
		# device, or the GPU number measures its power state (see Wake).
		# 400 ms is a CAP -- the burst stops once copies run at full speed
		# (measured: an asleep 3050 needs ~250 ms of work to flip; awake,
		# the burst costs ~10 ms)
		StzEngineGpuWake(400)
		_oGpu_ = new stzVectorIndex(_aVecs_)
		_oGpu_.SearchExact(_aQry_, 5)
		_nGpu_ = This._MinQueryMs(_oGpu_, _aQry_)
		_oGpu_._DropGpu()     # the rung must not leak its resident corpus
		# restore BOTH knobs: a rung that left the flat line at its forcing
		# value made the next hidden check read a line of 1 -- and agree by
		# coincidence once before disagreeing (caught 2026-09-09)
		StzEngineGpuCalibSetShaped("pairdist", pnCount, pnDim, _nOldR_)
		if _nOldT_ > 0
			StzEngineGpuCalibSet("pairdist", _nOldT_)
		ok
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
