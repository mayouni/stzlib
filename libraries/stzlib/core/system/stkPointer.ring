class stkPointer
    @cBufferId = ""           # ID of referenced buffer
    @oMemory = NULL          # Reference to containing stkMemory
    @cAccessMode = "read"    # "read" or "write"
    @bIsValid = FALSE        # Validity flag
    @nOffset = 0             # Offset into buffer
    @nLength = 0             # Length of view
    @nPointerId = 0          # Unique pointer ID for tracking
    @pLowLevelPtr = NULL     # Low-level C pointer for direct access
    @nBaseAddress = 0        # Base memory address for calculations

    #-------------------------------#
    #  INITIALIZATION AND CREATION  #
    #-------------------------------#

    def init(oMemory, cBufferId, cAccessMode, nOffset, nLength, nPointerId)
        # Can only be created by stkMemory - no standalone creation
        if IsNull(oMemory) or not IsObject(oMemory)
            raise("ERROR: stkPointer must be created by stkMemory container")
        ok
        
        if ClassName(oMemory) != "stkmemory"
            raise("ERROR: Invalid memory container type")
        ok
        
	    if IsNull(cBufferId) or len(cBufferId) = 0
	        raise("ERROR: Buffer ID cannot be empty")
	    ok
        
        if cAccessMode != "read" and cAccessMode != "write"
            raise("ERROR: Access mode must be 'read' or 'write'")
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Offset and length must be non-negative")
        ok
        
        if nPointerId <= 0
            raise("ERROR: Pointer ID must be positive")
        ok
        
        @oMemory = oMemory
        @cBufferId = cBufferId
        @cAccessMode = cAccessMode
        @nOffset = nOffset
        @nLength = nLength
        @nPointerId = nPointerId
        @bIsValid = TRUE
        
        # Initialize low-level pointer operations
        This.InitializeLowLevelAccess()

    #-----------------------#
    #  READING AND WRITING  #
    #-----------------------#

    def Read(nOffset, nLength)
        This.ValidatePointer()
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nLength - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nLength
            raise("ERROR: Read beyond pointer view bounds")
        ok
        
        # Calculate absolute buffer position
        nAbsoluteOffset = @nOffset + nOffset
        
        # Delegate to memory container
        return @oMemory.ReadFromBuffer(@cBufferId, nAbsoluteOffset, nLength)

    def Read0(nOffset, nLength)
        return This.Read(nOffset, nLength)

    def Read1(nOffset, nLength)
        return This.Read(nOffset-1, nLength)

    def ReadAll()
        return This.Read(0, @nLength)

    def ReadByte(nOffset)
        This.ValidatePointer()
        
        if nOffset < 0 or nOffset >= @nLength
            raise("ERROR: Byte offset out of bounds")
        ok
        
        cData = This.Read(nOffset, 1)
        if len(cData) > 0
            return ascii(cData[1])
        else
            return 0
        ok

    def ReadByte0(nOffset)
        return This.ReadByte(nOffset)

    def ReadByte1(nOffset)
        return This.ReadByte(nOffset-1)

    # Enhanced: Direct memory reading using low-level pointers
    def ReadDirect(nOffset, nLength)
        This.ValidatePointer()
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nLength - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nLength
            raise("ERROR: Read beyond pointer view bounds")
        ok
        
        if @pLowLevelPtr = NULL
            # Fallback to regular read
            return This.Read(nOffset, nLength)
        ok
        
        # Use low-level pointer for direct memory access
        nTargetAddress = @nBaseAddress + @nOffset + nOffset
        pTempPtr = setptr(@pLowLevelPtr, nTargetAddress)
        cResult = ptr2str(pTempPtr, 0, nLength)
        
        return cResult

    def Write(nOffset, pData)
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0
            raise("ERROR: Negative offset not allowed")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot write null data")
        ok
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        if nOffset + len(cData) > @nLength
            raise("ERROR: Write would exceed pointer view bounds")
        ok
        
        # Calculate absolute buffer position
        nAbsoluteOffset = @nOffset + nOffset
        
		# Write directly to buffer to avoid circular call
		oBuffer = @oMemory.GetBufferById(@cBufferId)
		if IsNull(oBuffer)
		    raise("ERROR: Buffer not found")
		ok
		oBuffer.Write(nAbsoluteOffset, cData)

    def Write0(nOffset, pData)
        This.Write(nOffset, pData)

    def Write1(nOffset, pData)
        This.Write(nOffset-1, pData)

    def WriteByte(nOffset, nByte)
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if nOffset < 0 or nOffset >= @nLength
            raise("ERROR: Byte offset out of bounds")
        ok
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        This.Write(nOffset, char(nByte))

    def WriteByte0(nOffset, nByte)
        This.WriteByte(nOffset, nByte)

    def WriteByte1(nOffset, nByte)
        This.WriteByte(nOffset-1, nByte)

    def Fill(nByte, nStart, nLength)
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Fill operation not allowed - pointer is read-only")
        ok
        
        if IsNull(nStart)
            nStart = 0
        ok
        
        if IsNull(nLength)
            nLength = @nLength - nStart
        ok
        
        if nStart < 0 or nLength < 0
            raise("ERROR: Negative start or length not allowed")
        ok
        
        if nStart + nLength > @nLength
            raise("ERROR: Fill would exceed pointer view bounds")
        ok
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        # Create fill data
        cFillData = @copy(char(nByte), nLength)
        This.Write(nStart, cFillData)

    def Fill0(nByte, nStart, nLength)
        This.Fill(nByte, nStart, nLength)

    def Fill1(nByte, nStart, nLength)
        This.Fill(nByte, nStart-1, nLength)

    #--------------------------#
    #  SEARCHING AND INDEXING  #
    #--------------------------#

    def IndexOf(pPattern, nStartPos)
        This.ValidatePointer()
        
        if IsNull(nStartPos)
            nStartPos = 0
        ok
        
        if nStartPos < 0 or nStartPos >= @nLength
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
            return nStartPos
        ok
        
        # Read view data and search within it
        cViewData = This.Read(nStartPos, @nLength - nStartPos)
        nPos = substr(cViewData, cPattern)
        
        if nPos > 0
            return nStartPos + nPos - 1
        else
            return -1
        ok

    def IndexOf0(pPattern, nStartPos)
        return This.IndexOf(pPattern, nStartPos)

    def IndexOf1(pPattern, nStartPos)
        nResult = This.IndexOf(pPattern, nStartPos)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    def Contains(pPattern)
        return This.IndexOf(pPattern) != -1

    #-----------------------#
    #  VIEW MANIPULATION    #
    #-----------------------#

    def CreateSubView(nOffset, nLength)
        This.ValidatePointer()
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nLength
            raise("ERROR: Sub-view exceeds current view bounds")
        ok
        
        # Calculate absolute offset
        nAbsoluteOffset = @nOffset + nOffset
        
        # Create new pointer through memory container
        return @oMemory.CreatePointerView(@cBufferId, @cAccessMode, nAbsoluteOffset, nLength)

    def CreateSubView0(nOffset, nLength)
        return This.CreateSubView(nOffset, nLength)

    def CreateSubView1(nOffset, nLength)
        return This.CreateSubView(nOffset-1, nLength)

    def Slice(nOffset, nLength)
        This.ValidatePointer()
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nLength - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nLength
            raise("ERROR: Slice exceeds view bounds")
        ok
        
        return This.Read(nOffset, nLength)

    def Slice0(nOffset, nLength)
        return This.Slice(nOffset, nLength)

    def Slice1(nOffset, nLength)
        return This.Slice(nOffset-1, nLength)

    #-----------------------#
    #  COPYING AND MOVING   #
    #-----------------------#

    def CopyFrom(oSourcePointer, nSourceOffset, nDestOffset, nLength)
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Copy operation not allowed - pointer is read-only")
        ok
        
        if IsNull(oSourcePointer) or not IsObject(oSourcePointer)
            raise("ERROR: Invalid source pointer")
        ok
        
        if ClassName(oSourcePointer) != "stkpointer"
            raise("ERROR: Source must be stkPointer")
        ok
        
        if not oSourcePointer.IsValid()
            raise("ERROR: Source pointer is invalid")
        ok
        
        if IsNull(nSourceOffset)
            nSourceOffset = 0
        ok
        
        if IsNull(nDestOffset)
            nDestOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = min([oSourcePointer.Length() - nSourceOffset, @nLength - nDestOffset])
        ok
        
        if nSourceOffset < 0 or nDestOffset < 0 or nLength < 0
            raise("ERROR: Negative offsets or length not allowed")
        ok
        
        if nSourceOffset + nLength > oSourcePointer.Length()
            raise("ERROR: Copy would exceed source bounds")
        ok
        
        if nDestOffset + nLength > @nLength
            raise("ERROR: Copy would exceed destination bounds")
        ok
        
        # Read from source and write to destination
        cData = oSourcePointer.Read(nSourceOffset, nLength)
        This.Write(nDestOffset, cData)

    def CopyFrom0(oSourcePointer, nSourceOffset, nDestOffset, nLength)
        This.CopyFrom(oSourcePointer, nSourceOffset, nDestOffset, nLength)

    def CopyFrom1(oSourcePointer, nSourceOffset, nDestOffset, nLength)
        This.CopyFrom(oSourcePointer, nSourceOffset-1, nDestOffset-1, nLength)

    def CopyTo(oDestPointer, nSourceOffset, nDestOffset, nLength)
        This.ValidatePointer()
        
        if IsNull(oDestPointer) or not IsObject(oDestPointer)
            raise("ERROR: Invalid destination pointer")
        ok
        
        if ClassName(oDestPointer) != "stkpointer"
            raise("ERROR: Destination must be stkPointer")
        ok
        
        if not oDestPointer.IsValid()
            raise("ERROR: Destination pointer is invalid")
        ok
        
        # Use destination's CopyFrom method
        oDestPointer.CopyFrom(This, nSourceOffset, nDestOffset, nLength)

    def CopyTo0(oDestPointer, nSourceOffset, nDestOffset, nLength)
        This.CopyTo(oDestPointer, nSourceOffset, nDestOffset, nLength)

    def CopyTo1(oDestPointer, nSourceOffset, nDestOffset, nLength)
        This.CopyTo(oDestPointer, nSourceOffset-1, nDestOffset-1, nLength)

    #----------------------------------#
    #  LOW-LEVEL POINTER OPERATIONS    #
    #----------------------------------#

    def GetRawPointer()
        # Return the low-level C pointer for external use
        This.ValidatePointer()
        return @pLowLevelPtr

    def GetMemoryAddress()
        # Get the actual memory address
        This.ValidatePointer()
        if @pLowLevelPtr = NULL
            return 0
        ok
        return getptr(@pLowLevelPtr)

    def GetViewAddress()
        # Get the memory address of the current view
        This.ValidatePointer()
        if @pLowLevelPtr = NULL
            return 0
        ok
        return @nBaseAddress + @nOffset

    def ComparePointer(oOther)
        # Compare raw pointer addresses
        if IsNull(oOther) or not IsObject(oOther)
            return FALSE
        ok
        
        if ClassName(oOther) != "stkpointer"
            return FALSE
        ok
        
        if @pLowLevelPtr = NULL or oOther.GetRawPointer() = NULL
            return FALSE
        ok
        
        return ptrcmp(@pLowLevelPtr, oOther.GetRawPointer())

    def IsNullPointer()
        # Check if this is a null pointer
        return @pLowLevelPtr = NULL or getptr(@pLowLevelPtr) = 0

    def SetPointerOffset(nNewOffset)
        # Adjust pointer to new offset within current view
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Pointer offset modification not allowed - pointer is read-only")
        ok
        
        if nNewOffset < 0 or nNewOffset >= @nLength
            raise("ERROR: New offset out of view bounds")
        ok
        
        if @pLowLevelPtr != NULL
            nNewAddress = @nBaseAddress + @nOffset + nNewOffset
            setptr(@pLowLevelPtr, nNewAddress)
        ok

    def CreatePointerReference()
        # Create an object reference that can be passed around
        This.ValidatePointer()
        if @pLowLevelPtr = NULL
            return NULL
        ok
        return obj2ptr(This)

    def FromPointerReference(pReference)
        # Restore pointer from reference (static-like method)
        if IsNull(pReference) or not isptr(pReference)
            raise("ERROR: Invalid pointer reference")
        ok
        
        try
            oPointer = ptr2obj(pReference)
            if ClassName(oPointer) != "stkpointer"
                raise("ERROR: Reference does not point to stkPointer")
            ok
            return oPointer
        catch cError
            raise("ERROR: Cannot restore pointer from reference: " + cError)
        done

    def ToBinaryString()
        # Convert pointer view to binary string representation
        This.ValidatePointer()
        
        if @pLowLevelPtr = NULL
            return This.ReadAll()  # Fallback to regular read
        ok
        
        # Use pointer2string for direct memory access
        nViewAddress = This.GetViewAddress()
        pTempPtr = nullptr()
        setptr(pTempPtr, nViewAddress)
        
        try
            return ptr2str(pTempPtr, 0, @nLength)
        catch cError
            # Fallback to regular read if direct access fails
            return This.ReadAll()
        done

    def FromBinaryString(cBinaryData, nOffset)
        # Write binary data directly to pointer location
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0
            raise("ERROR: Negative offset not allowed")
        ok
        
        if nOffset + len(cBinaryData) > @nLength
            raise("ERROR: Binary data would exceed pointer view bounds")
        ok
        
        # Use regular write method for safety
        This.Write(nOffset, cBinaryData)

    #-----------------------------#
    #  INFORMATION AND METADATA   #
    #-----------------------------#

    def BufferId()
        return @cBufferId

    def PointerId()
        return @nPointerId

    def AccessMode()
        return @cAccessMode

    def IsReadOnly()
        return @cAccessMode = "read"

    def IsWritable()
        return @cAccessMode = "write"

    def Offset()
        return @nOffset

    def Length()
        return @nLength

    def Size()
        return @nLength

    def IsValid()
        if not @bIsValid
            return FALSE
        ok
        
        if @oMemory = NULL or not @oMemory.IsValid()
            return FALSE
        ok
        
        return @oMemory.ValidatePointer(@nPointerId)

    def Memory()
        return @oMemory

    def Buffer()
        This.ValidatePointer()
        return @oMemory.GetBuffer(@cBufferId)

    def Info()
        This.ValidatePointer()
        return [
            :pointerId = @nPointerId,
            :bufferId = @cBufferId,
            :accessMode = @cAccessMode,
            :offset = @nOffset,
            :length = @nLength,
            :isValid = This.IsValid(),
            :isReadOnly = This.IsReadOnly(),
            :isWritable = This.IsWritable(),
            :hasLowLevelPtr = (@pLowLevelPtr != NULL),
            :memoryAddress = This.GetMemoryAddress(),
            :viewAddress = This.GetViewAddress(),
            :isNullPointer = This.IsNullPointer()
        ]

    def Content()
        This.ValidatePointer()
        return This.ReadAll()

    def RawData()
        return This.Content()

    def StringValue()
        return This.Content()

    def Equals(oOther)
        if IsNull(oOther) or not IsObject(oOther)
            return FALSE
        ok
        
        if ClassName(oOther) != "stkpointer"
            return FALSE
        ok
        
        if not oOther.IsValid()
            return FALSE
        ok
        
        # Check if they point to the same buffer and have same view
        if @cBufferId != oOther.BufferId()
            return FALSE
        ok
        
        if @nOffset != oOther.Offset()
            return FALSE
        ok
        
        if @nLength != oOther.Length()
            return FALSE
        ok
        
        return TRUE

    def SameBuffer(oOther)
        if IsNull(oOther) or not IsObject(oOther)
            return FALSE
        ok
        
        if ClassName(oOther) != "stkpointer"
            return FALSE
        ok
        
        return @cBufferId = oOther.BufferId()

    def Free()
        if @bIsValid and @oMemory != NULL
            # Clean up low-level pointer if it exists
            if @pLowLevelPtr != NULL
                @pLowLevelPtr = NULL
            ok
            
            # Notify memory container to remove this pointer
            @oMemory.DestroyPointer(@nPointerId)
            @bIsValid = FALSE
        ok

    def Destroy()
        This.Free()

    def Show()
        ? "stkPointer Info:"
        ? "  Pointer ID: " + @nPointerId
        ? "  Buffer ID: " + @cBufferId
        ? "  Access Mode: " + @cAccessMode
        ? "  Offset: " + @nOffset
        ? "  Length: " + @nLength
        ? "  Valid: " + This.IsValid()
        ? "  Has Low-Level Ptr: " + (@pLowLevelPtr != NULL)
        ? "  Memory Address: " + Upper(hex(This.GetMemoryAddress()))
        ? "  View Address: " + Upper(hex(This.GetViewAddress()))
        ? "  Content: '" + This.Content() + "'"

    #--------------------------------#
    #  PRIVATE KITCHEN OF THE CLASS  #
    #--------------------------------#

    PRIVATE

    def InitializeLowLevelAccess()
        # Initialize low-level pointer access if possible
        try
            # Try to get buffer data and create pointer to it
            oBuffer = @oMemory.GetBufferById(@cBufferId)
            if not IsNull(oBuffer)
                cBufferData = oBuffer.Content()
                if len(cBufferData) > 0
                    @pLowLevelPtr = varptr(:cBufferData, :char)
                    @nBaseAddress = getptr(@pLowLevelPtr)
                ok
            ok
        catch cError
            # If low-level access fails, continue without it
            @pLowLevelPtr = NULL
            @nBaseAddress = 0
        done

	def ValidatePointer()

	    if not @bIsValid
	        raise("ERROR: Invalid pointer - pointer was not properly initialized")
	    ok

	    if @oMemory = NULL or not @oMemory.IsValid()
	        raise("ERROR: Pointer has invalid memory container reference")
	    ok

	    oBufferInfo = @oMemory.GetBufferInfo(@cBufferId)

	    if IsNull(oBufferInfo)
	        raise("ERROR: Referenced buffer no longer exists")
	    ok

	    if @nOffset < 0 or @nLength < 0
	        raise("ERROR: Invalid offset or length")
	    ok

	    if @nOffset + @nLength > oBufferInfo[:capacity]
	        raise("ERROR: Pointer view exceeds buffer bounds")
	    ok
