class stkMemory
    @bIsValid = TRUE

	def init()
		# Does nothing

    def Allocate(nSize)
        if nSize <= 0
            raise("Allocation size must be positive")
        ok
        
        cBuffer = space(nSize)
        return cBuffer

    def Deallocate(pBuffer)
        if IsNull(pBuffer)
            raise("Cannot deallocate a null pointer")
        ok
        
        # In Ring, memory is automatically managed
        # This method exists for API compatibility
        return TRUE

    def Copy(pSrc, pDest, nSize)
        if IsNull(pSrc) or IsNull(pDest)
            raise("Source or destination is null")
        ok
        
        if nSize <= 0
            return
        ok
        
        # Ring string-based copy
        if IsString(pSrc)
            cSrcData = left(pSrc, nSize)
            return cSrcData
        else
            raise("Unsupported source type for copy")
        ok

	def Set(pBuffer, nValue, nSize)
	    if nSize <= 0
	        if IsNull(pBuffer)
	            return ""
	        else
	            return pBuffer
	        ok
	    ok
	    
	    cFillChar = char(nValue)
	    
	    if IsNull(pBuffer)
	        # Create new buffer filled with the character
	        return @copy(cFillChar, nSize)
	    else
	        # This would be for setting existing buffer, but Ring handles strings differently
	        return @copy(cFillChar, nSize)
	    ok

    def Compare(pBuffer1, pBuffer2, nSize)
        if IsNull(pBuffer1) or IsNull(pBuffer2)
            raise("Cannot compare null buffers")
        ok
        
        if nSize <= 0
            return 0
        ok
        
        cStr1 = left(pBuffer1, nSize)
        cStr2 = left(pBuffer2, nSize)
        
        if cStr1 = cStr2
            return 0
        but cStr1 < cStr2
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
