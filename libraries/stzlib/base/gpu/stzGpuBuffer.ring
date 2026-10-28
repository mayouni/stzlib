#---------------------------------------------------------------------------#
#  STZGPUBUFFER -- a vector RESIDENT on the GPU. The residency object that  #
#  makes chains pay: upload once, Apply kernels with no readback between,   #
#  Download once at the end.                                                #
#---------------------------------------------------------------------------#
#
#     b1 = oG.UploadQ(aBig)
#     b2 = b1.ApplyQ(kDouble).ApplyQ(kShift)     # no transfer between links
#     aOut = b2.Download()
#     b1.Free()  b2.Free()
#
# State is TWO NUMBERS (the generation-keyed engine buffer id + the element
# count), so Ring's copy-on-assign is harmless: copies share the same device
# buffer, and a stale id after Free()/eviction answers by NAME (the engine's
# STALE status), never with someone else's data.
#
# Ring has no destructors: Free() is yours to call. The engine's bounded
# VRAM cache is the backstop -- forgotten buffers get FIFO-evicted under
# pressure and COUNTED, not leaked silently.

# Order a kernel's scalar VALUES per its declaration order -- the params
# uniform is packed positionally, and the declaration is the contract.
# Scans the binding pairs EXPLICITLY: a missing hashlist key reads as 0 in
# Ring (silently!), and a missing scalar must raise by name, not bind 0.0.
# Shared by stzGpuBuffer and stzGpu (main-file func, underscored temps).
func _OrderedScalars(poKernel, paScalars)
	_aNames_ = poKernel.ScalarNames()
	_nS_ = len(_aNames_)
	_aOut_ = []
	for _i_ = 1 to _nS_
		_v_ = _BindingValue(paScalars, _aNames_[_i_])
		if NOT isNumber(_v_)
			StzRaise("kernel scalar '" + _aNames_[_i_] +
				"' is missing from the bindings (give [ :" +
				_aNames_[_i_] + " = value ]).")
		ok
		_aOut_ + _v_
	next
	return _aOut_

# The value bound to cName in a [ :name = value, ... ] list, or NULL if the
# name is absent (NEVER a silent 0).
func _BindingValue(paBindings, pcName)
	_nL_ = len(paBindings)
	for _j_ = 1 to _nL_
		if isList(paBindings[_j_]) and len(paBindings[_j_]) = 2
			if lower("" + paBindings[_j_][1]) = pcName
				return paBindings[_j_][2]
			ok
		ok
	next
	return ""

# A vector that lives on the GPU, so that kernels can be chained on it with no transfer until it is downloaded once.
#
# Obtain one from stzGpu.UploadQ, chain single-input kernels with ApplyQ, read the result with
# Download, and call Free when done. The object holds two numbers, the generation-keyed engine id
# and the element count, so a copy shares the same device buffer and a stale id after Free or
# eviction is reported as stale and never answers with another buffer's data. Every method except
# init, Id_, Count and IsAlive needs the GPU, which sleeps on this machine, so they were read from
# the code and not run.
#
#   receiver   o1 = new stzGpuBuffer([ 0, 5 ])
#   example    ? o1.Count()
#              #--> 5
#              ? o1.IsAlive()
#              #--> 0
#   see        stzGpu, stzKernelMaker
class stzGpuBuffer from stzObject

	@nId = 0
	@nCount = 0

	# Wraps a buffer that lives on the GPU, given as its engine id and its element count.
	#
	#   paIdCount   a list [ nEngineBufferId, nElementCount ], as stzGpu.UploadQ builds it
	#   returns     nothing; the object is built
	#   warning     the object holds only two numbers, so copies of it share the same device buffer
	#   see         Id_, Count
	#@ aka  paIdCount = [ nEngineBufferId, nElementCount ]
	def init(paIdCount)
		@nId = paIdCount[1]
		@nCount = paIdCount[2]
		@bInts = 0
		if len(paIdCount) >= 3
			@bInts = paIdCount[3] # GL0 (atomics): the buffer holds i32 counters
		ok

	# Returns the engine id of the device buffer, 0 once the buffer was freed through this object.
	#
	#   returns    a number
	#   see        Count, Free
	def Id_()
		return @nId

	# Returns how many numbers the buffer holds.
	#
	#   returns    a number
	#   see        Download, Id_
	def Count()
		return @nCount

	# TRUE if the engine still knows the buffer, which is not so after Free or an eviction.
	#
	#   returns    TRUE or FALSE
	#   warning    run only with ids the engine does not know, where it answered FALSE; no buffer
	#              was uploaded
	#   see        Free, Download
	def IsAlive()
		return StzEngineGpuBufferSize(@nId) >= 0

	# Reads the whole vector back from the device into a list of numbers.
	#
	#   returns    a list of numbers
	#   note       not run: it needs a buffer on the GPU, which sleeps on this machine
	#   warning    raises an error when the buffer was freed, evicted or lost with the device
	#   see        Count, ApplyQ
	#@ aka  The vector, back on the CPU. Raises if the buffer was freed or evicted.
	def Download()
		if @bInts
			_a_ = StzEngineGpuBufferDownloadI32List(@nId, @nCount)
		else
			_a_ = StzEngineGpuBufferDownloadList(@nId, @nCount)
		ok
		if len(_a_) != @nCount
			StzRaise("stzGpuBuffer: download failed -- the buffer is gone " +
				"(freed, evicted, or the device was lost).")
		ok
		return _a_

	# Runs a one-input kernel over the buffer on the device and returns the result as a new resident buffer, leaving this one untouched.
	#
	#   oKernel    a stzKernelMaker with exactly one input vector
	#   returns    a new stzGpuBuffer
	#   note       not run: it dispatches on the GPU
	#   warning    a kernel with more than one input raises an error that points to stzGpu.ApplyOnQ;
	#              a kernel that does not compile raises an error with the engine's message
	#   see        ApplyWithQ, Download
	#@ aka  Run a ONE-INPUT kernel over this buffer; the result is a NEW resident buffer (this one is untouched). No transfer happens -- that is the point.
	def ApplyQ(oKernel)
		return This.ApplyWithQ(oKernel, [])

	# Does the same as the call without scalars, binding the kernel's scalars by name.
	#
	#   oKernel     a stzKernelMaker with exactly one input vector
	#   paScalars   a list such as [ :alpha = 2.5 ] that gives each declared scalar a number
	#   returns     a new stzGpuBuffer
	#   note        not run: it dispatches on the GPU
	#   warning     a scalar missing from the list raises an error naming it instead of binding 0
	#   see         ApplyQ
	#@ aka  Same, with the kernel's scalar values: [ :alpha = 2.5, ... ]
	def ApplyWithQ(oKernel, paScalars)
		if len(oKernel.InputNames()) != 1
			StzRaise("ApplyQ: the kernel takes " + len(oKernel.InputNames()) +
				" vectors -- ApplyQ() chains single-input kernels; use " +
				"stzGpu.ApplyOnQ() for multi-input ones.")
		ok
		if @bInts
			StzRaise("ApplyQ: this buffer holds an atomic output's whole-number counters; Download() them before another kernel reads them as floats.")
		ok
		_cW_ = oKernel.ToWGSL()
		_nK_ = StzEngineGpuKernelCompile(_cW_)
		if _nK_ = 0
			StzRaise("ApplyQ: the kernel refused to compile: " + StzEngineGpuLastError())
		ok
		_aScal_ = _OrderedScalars(oKernel, paScalars)
		# GL0 (typed buffers): @nCount counts floats; an element is the input's width of them
		_nE_ = floor(@nCount / oKernel.InputWidth(oKernel.InputNames()[1]))
		_nOutF_ = oKernel.OutputLength(_nE_)
		_nOut_ = StzEngineGpuBufferNew(_nOutF_ * 4)
		_bAtom_ = oKernel.OutputIsAtomic() = 1
		if _bAtom_ and _nOut_ != 0
			StzEngineGpuBufferFillI32(_nOut_, StzEngineGpuSpecOutIdentity(oKernel.Spec()), _nOutF_)
		ok
		if _nOut_ = 0
			StzRaise("ApplyQ: no device buffer for the result (" +
				StzEngineGpuLastError() + ")")
		ok
		_nSt_ = StzEngineGpuDispatchParams(_nK_, _nE_, _aScal_,
			[@nId, _nOut_], ceil(_nE_ / 256.0))
		if _nSt_ != 0
			StzEngineGpuBufferFree(_nOut_)
			StzRaise("ApplyQ: dispatch refused (status " + _nSt_ + ").")
		ok
		return new stzGpuBuffer([_nOut_, _nOutF_, _bAtom_])

	# Frees the device buffer and marks this object empty.
	#
	#   returns    nothing
	#   note       run only on an object with id 0, where it does nothing
	#   warning    Ring has no destructors, so free what you upload; forgotten buffers are evicted
	#              first-in-first-out under VRAM pressure and counted
	#   see        IsAlive, Download
	def Free()
		if @nId > 0
			StzEngineGpuBufferFree(@nId)
			@nId = 0
		ok
