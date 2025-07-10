class stkBuffer

    @buffer = NULL
    @nSize = 0
    @nCapacity = 0
    @bIsValid = FALSE
	@oMemory = NULL

    def init(pSizeOrData)
		@oMemory = new stkMemory()

        if IsNumber(pSizeOrData)
            This.InitWithSize(pSizeOrData)
        else
            This.InitWithData(pSizeOrData)
        ok


    def InitWithSize(nSize)
        if nSize <= 0
            raise("Buffer size must be positive")
        ok
        
        @nSize = 0
        @nCapacity = nSize
        @buffer = @oMemory.Allocate(nSize)
        @bIsValid = TRUE
        This.Clear()


	def InitWithData(pData)
	    if IsNull(pData)
	        raise("Cannot initialize buffer with null data")
	    ok
	    
	    cData = ""
	    if IsString(pData)
	        cData = pData
	    else
	        cData = string(pData)
	    ok
	    
	    @nSize = len(cData)
	    @nCapacity = @nSize
	    @buffer = cData
	    @bIsValid = TRUE


	def Write(nOffset, pData)
	    This.ValidateBuffer()
	    
	    if nOffset < 0
	        raise("Negative offset not allowed")
	    ok
	    
	    if IsNull(pData)
	        raise("Cannot write null data")
	    ok
	    
	    cData = ""
	    if IsString(pData)
	        cData = pData
	    else
	        cData = string(pData)
	    ok
	    
	    nDataLen = len(cData)
	    nRequiredSize = nOffset + nDataLen
	    
	    if nRequiredSize > @nCapacity
	        This.Resize(nRequiredSize)
	    ok
	    
	    if nRequiredSize > @nSize
	        @nSize = nRequiredSize
	    ok
	    
	    # Update buffer with new data
	    cNewBuffer = ""
	    
	    # Copy existing data up to offset
	    if nOffset > 0
	        cNewBuffer += left(@buffer, nOffset)
	    ok
	    
	    # Add new data
	    cNewBuffer += cData
	    
	    # Copy remaining data if any
	    if len(@buffer) > nOffset + nDataLen
	        cNewBuffer += right(@buffer, len(@buffer) - (nOffset + nDataLen))
	    ok
	    
	    @buffer = cNewBuffer
	    # FIX: Update capacity to match actual buffer size
	    @nCapacity = len(@buffer)


    def Read(nOffset, nLength)
        This.ValidateBuffer()
        
        if nOffset < 0 or nLength < 0
            raise("Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nSize
            raise("Buffer overflow prevented!")
        ok
        
        if nLength = 0
            return ""
        ok
        
       return substr(@buffer, nOffset + 1, nLength)

	
	def Resize(nNewSize)
	    This.ValidateBuffer()
	    
	    if nNewSize <= 0
	        raise("New size must be positive")
	    ok
	    
	    cNewBuffer = ""
	    
	    if nNewSize > len(@buffer)
	        # Extend with null bytes, not spaces
	        cNewBuffer = @buffer + copy(char(0), nNewSize - len(@buffer))
	    but nNewSize < len(@buffer)
	        cNewBuffer = left(@buffer, nNewSize)
	    else
	        cNewBuffer = @buffer
	    ok
	    
	    @buffer = cNewBuffer
	    @nCapacity = nNewSize
	    
	    if @nSize > nNewSize
	        @nSize = nNewSize
	    ok


    def Append(pData)
        if IsNull(pData)
            raise("Cannot append null data")
        ok
        
        This.Write(@nSize, pData)


    def Prepend(pData)
        if IsNull(pData)
            raise("Cannot prepend null data")
        ok
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        @buffer = cData + @buffer
        @nSize += len(cData)
        @nCapacity = len(@buffer)


    def Insert(nOffset, pData)
        if nOffset < 0 or nOffset > @nSize
            raise("Invalid offset for insertion")
        ok
        
        if IsNull(pData)
            raise("Cannot insert null data")
        ok
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        cNewBuffer = left(@buffer, nOffset) + cData + right(@buffer, len(@buffer) - nOffset)
        @buffer = cNewBuffer
        @nSize += len(cData)
        @nCapacity = len(@buffer)


    def Remove(nOffset, nLength)
        if nOffset < 0 or nLength < 0
            raise("Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nSize
            raise("Cannot remove beyond buffer size")
        ok
        
        if nLength = 0
            return
        ok
        
        @buffer = left(@buffer, nOffset) + right(@buffer, len(@buffer) - (nOffset + nLength))
        @nSize -= nLength
        @nCapacity = len(@buffer)


	def IndexOf(pPattern)
		if isList(pPattern) and len(pPattern) = 2
			return This.IndexOfXT(pPattern[1], pPattern[2])
		ok

		return This.IndexOfXT(pPattern, 0)

		def FindFirst(pPattern)
			return This.IndexOf(pPattern)

		def IndexOf0(pPattern)
			return This.IndexOf(pPattern)

		def FindFirst0(pPattern)
			return This.IndexOf(pPattern)

		def IndexOf1(pPattern)
			return This.IndexOf(pPattern) + 1

		def FindFirst1(pPattern)
			return This.IndexOf(pPattern) + 1


    def IndexOfXT(pPattern, nStartOffset)
        if IsNull(nStartOffset)
            nStartOffset = 0
        ok
        
        if nStartOffset < 0 or nStartOffset >= @nSize
            return -1
        ok
        
        if IsNull(pPattern)
            return -1
        ok
        
        cPattern = ""
        if IsString(pPattern)
            cPattern = pPattern
        else
            cPattern = string(pPattern)
        ok
        
        if len(cPattern) = 0
            return nStartOffset
        ok
        
        cSearchBuffer = right(@buffer, len(@buffer) - nStartOffset)
        nPos = substr(cSearchBuffer, cPattern)
        
        if nPos > 0
            return nStartOffset + nPos - 1
        else
            return -1
        ok

		def FindFirstXT(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset)

		def IndexOfXT0(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset)

		def FindFirstXT0(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset)

		def IndexOfXT1(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset) + 1

		def FindFirstXT1(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset) + 1


		def IndexOfN(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset)

		def FindFirstN(pPattern, nStartOffset)
			return This.IndexOfXT(pPattern, nStartOffset)

		def IndexOfN0(pPattern, nStartOffset)
			return This.IndexOfN(pPattern, nStartOffset)

		def FindFirstN0(pPattern, nStartOffset)
			return This.IndexOfN(pPattern, nStartOffset)

		def IndexOfN1(pPattern, nStartOffset)
			return This.IndexOfN(pPattern, nStartOffset) + 1

		def FindFirstN1(pPattern, nStartOffset)
			return This.IndexOfN(pPattern, nStartOffset) + 1


    def Slice(nOffset, nLength)
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nSize - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nSize
            raise("Slice beyond buffer size")
        ok
        
        oNewBuffer = new stkBuffer(nLength)
        oNewBuffer.Write(0, This.Read(nOffset, nLength))
        return oNewBuffer

		
		def Range(nOffset, nLength)
			return This.Slice(nOffset, nLength)

		def Slice0(nOffset, nLength)
			return This.Slice(nOffset, nLength)

		def Range0(nOffset, nLength)
			return This.Slice(nOffset, nLength)

		def Slice1(nOffset, nLength)
			return This.Slice(nOffset-1, nLength)

		def Range1(nOffset, nLength)
			return This.Slice(nOffset-1, nLength)


	def Section(n1, n2)
		return This.Range(n1, n2 - n1 + 1)

		def Section0(n1, n2)
			return This.Section(n1, n2)

		def Section1(n1, n2)
			return This.Section(n1-1, n2-1)

    def Copy()
        oNewBuffer = new stkBuffer(@nSize)
        oNewBuffer.Write(0, This.Read(0, @nSize))
        return oNewBuffer


    def Equals(oOther)
        if IsNull(oOther) or not IsObject(oOther)
            return FALSE
        ok
        
        if ClassName(oOther) != "stkbuffer"
            return FALSE
        ok
        
        if @nSize != oOther.Size()
            return FALSE
        ok
        
        return @buffer = oOther.RawData()


    def Size()
        return @nSize


    def Capacity()
        return @nCapacity


    def RawData()
        return @buffer


	def GetPointer(nOffset)
	    if IsNull(nOffset)
	        nOffset = 0
	    ok
	    
	    if nOffset < 0 or nOffset >= @nSize
	        raise("Invalid offset for pointer")
	    ok

 	   cSliceData = right(@buffer, @nSize - nOffSet)
	   return new stkPointer([cSliceData, "string", len(cSliceData)+1])

    def Memory()
        return @oMemory

    def Clear()
        @buffer = space(@nCapacity)
        @nSize = 0


    def Fill(nValue, nOffset, nLength)

        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nCapacity - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nCapacity
            raise("Fill beyond buffer capacity")
        ok
        
        cFillChar = char(nValue)
        cFillData = @copy(cFillChar, nLength)
        
        This.Write(nOffset, cFillData)


    def Compact()
        if @nSize < @nCapacity and @nSize > 0
            This.Resize(@nSize)
        ok


    def Show()
        ? "stkBuffer(size=" + @nSize + ", capacity=" + @nCapacity + ")"


    def IsValid()
        return @bIsValid


    def Destroy()
        @buffer = NULL
        @nSize = 0
        @nCapacity = 0
        @bIsValid = FALSE


    #--------------------------------#
    #  PRIVATE KITCHEN OF THE CLASS  #
    #--------------------------------#

    PRIVATE


    def ValidateBuffer()
        if not @bIsValid
            raise("Invalid buffer")
        ok
