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

class stzGpuBuffer from stzObject

	@nId = 0
	@nCount = 0

	# paIdCount = [ nEngineBufferId, nElementCount ]
	def init(paIdCount)
		@nId = paIdCount[1]
		@nCount = paIdCount[2]

	def Id_()
		return @nId

	def Count()
		return @nCount

	def IsAlive()
		return StzEngineGpuBufferSize(@nId) >= 0

	# The vector, back on the CPU. Raises if the buffer was freed or evicted.
	def Download()
		_a_ = StzEngineGpuBufferDownloadList(@nId, @nCount)
		if len(_a_) != @nCount
			StzRaise("stzGpuBuffer: download failed -- the buffer is gone " +
				"(freed, evicted, or the device was lost).")
		ok
		return _a_

	# Run a ONE-INPUT kernel over this buffer; the result is a NEW resident
	# buffer (this one is untouched). No transfer happens -- that is the point.
	def ApplyQ(oKernel)
		return This.ApplyWithQ(oKernel, [])

	# Same, with the kernel's scalar values: [ :alpha = 2.5, ... ]
	def ApplyWithQ(oKernel, paScalars)
		if len(oKernel.InputNames()) != 1
			StzRaise("ApplyQ: the kernel takes " + len(oKernel.InputNames()) +
				" vectors -- ApplyQ() chains single-input kernels; use " +
				"stzGpu.ApplyOnQ() for multi-input ones.")
		ok
		_cW_ = oKernel.ToWGSL()
		_nK_ = StzEngineGpuKernelCompile(_cW_)
		if _nK_ = 0
			StzRaise("ApplyQ: the kernel refused to compile: " + StzEngineGpuLastError())
		ok
		_aScal_ = _OrderedScalars(oKernel, paScalars)
		_nOut_ = StzEngineGpuBufferNew(@nCount * 4)
		if _nOut_ = 0
			StzRaise("ApplyQ: no device buffer for the result (" +
				StzEngineGpuLastError() + ")")
		ok
		_nSt_ = StzEngineGpuDispatchParams(_nK_, @nCount, _aScal_,
			[@nId, _nOut_], ceil(@nCount / 256.0))
		if _nSt_ != 0
			StzEngineGpuBufferFree(_nOut_)
			StzRaise("ApplyQ: dispatch refused (status " + _nSt_ + ").")
		ok
		return new stzGpuBuffer([_nOut_, @nCount])

	def Free()
		if @nId > 0
			StzEngineGpuBufferFree(@nId)
			@nId = 0
		ok
