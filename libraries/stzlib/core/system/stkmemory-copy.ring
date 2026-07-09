class stkMemory
    @bIsValid = TRUE
    @aAllocatedBuffers = []  # Track allocations

	def init()
		# Does nothing

    def Allocate(nSize)
        if nSize <= 0
            raise("Allocation size must be positive")
        ok
        
        _cBuffer_ = space(nSize)
        @aAllocatedBuffers + _cBuffer_ # Track allocation
        return _cBuffer_

    def Deallocate(pBuffer)
        if IsNull(pBuffer)
            raise("Cannot deallocate a null pointer")
        ok
        
        _nIndex_ = find(@aAllocatedBuffers, pBuffer)
        if _nIndex_ > 0
            del(@aAllocatedBuffers, _nIndex_)
        	# In Ring, memory is automatically managed
        	# This method exists for API compatibility
            return TRUE
        else
            # In Ring, this is just a warning, not an error
            return FALSE
        ok

	def IsAllocated(pBuffer)
	    if IsNull(pBuffer)
	        return FALSE
	    ok
	    
	    _nIndex_ = find(@aAllocatedBuffers, pBuffer)
	    return _nIndex_ > 0

	def Copy(pSrc, pDest, nSize)
	    if IsNull(pSrc)
	        raise("Source is null")
	    ok
	    
	    if nSize <= 0
	        return ""
	    ok
	    
	    if IsString(pSrc)
	        return left(pSrc, nSize)
	    else
	        raise("Unsupported source type for copy")
	    ok
        
        # Ring string-based copy
        if IsString(pSrc)
            _cSrcData_ = left(pSrc, nSize)
            return _cSrcData_
        else
            raise("Unsupported source type for copy")
        ok

	def Fill(pBuffer, nValue, nSize)
	    if nSize <= 0
	        return pBuffer
	    ok
	    
	    _cFillChar_ = char(nValue)
	    _cFilledBuffer_ = @copy(_cFillChar_, nSize)
	    
	    # Update the buffer in our tracking array
	    _nIndex_ = find(@aAllocatedBuffers, pBuffer)
	    if _nIndex_ > 0
	        @aAllocatedBuffers[_nIndex_] = _cFilledBuffer_
	    ok
	    
	    return _cFilledBuffer_

	def Read(pBuffer, nSize)
	    if IsNull(pBuffer)
	        raise("Cannot read from null buffer")
	    ok
	    
	    if nSize <= 0
	        return ""
	    ok
	    
	    return left(pBuffer, nSize)

    def Compare(pBuffer1, pBuffer2, nSize)
        if IsNull(pBuffer1) or IsNull(pBuffer2)
            raise("Cannot compare null buffers")
        ok
        
        if nSize <= 0
            return 0
        ok
        
        _cStr1_ = left(pBuffer1, nSize)
        _cStr2_ = left(pBuffer2, nSize)
        
        if _cStr1_ = _cStr2_
            return 0
        but _cStr1_ < _cStr2_
            return -1
        else
            return 1
        ok

    def Move(pSrc, pDest, nSize)
        # Ring handles overlapping moves automatically
        return This.Copy(pSrc, pDest, nSize)

    def IsValid()
        return @bIsValid

    def Show()
        ? "stkMemory(valid=" + @bIsValid + ")"
