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

    def init(oMemory, cBufferId, cAccessMode, _nOffset_, _nLength_, nPointerId)
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
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Offset and length must be non-negative")
        ok
        
        if nPointerId <= 0
            raise("ERROR: Pointer ID must be positive")
        ok
        
        @oMemory = oMemory
        @cBufferId = cBufferId
        @cAccessMode = cAccessMode
        @nOffset = _nOffset_
        @nLength = _nLength_
        @nPointerId = nPointerId
        @bIsValid = TRUE
        
        # Initialize low-level pointer operations
        This.InitializeLowLevelAccess()

    #-----------------------#
    #  READING AND WRITING  #
    #-----------------------#

    def Read(_nOffset_, _nLength_)
        This.ValidatePointer()
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nLength - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nLength
            raise("ERROR: Read beyond pointer view bounds")
        ok
        
        # Calculate absolute buffer position
        _nAbsoluteOffset_ = @nOffset + _nOffset_
        
        # Delegate to memory container
        return @oMemory.ReadFromBuffer(@cBufferId, _nAbsoluteOffset_, _nLength_)

    def Read0(_nOffset_, _nLength_)
        return This.Read(_nOffset_, _nLength_)

    def Read1(_nOffset_, _nLength_)
        return This.Read(_nOffset_-1, _nLength_)

    def ReadAll()
        return This.Read(0, @nLength)

    def ReadByte(_nOffset_)
        This.ValidatePointer()
        
        if _nOffset_ < 0 or _nOffset_ >= @nLength
            raise("ERROR: Byte offset out of bounds")
        ok
        
        _cData_ = This.Read(_nOffset_, 1)
        if len(_cData_) > 0
            return ascii(_cData_[1])
        else
            return 0
        ok

    def ReadByte0(_nOffset_)
        return This.ReadByte(_nOffset_)

    def ReadByte1(_nOffset_)
        return This.ReadByte(_nOffset_-1)

    # Enhanced: Direct memory reading using low-level pointers
    def ReadDirect(_nOffset_, _nLength_)
        This.ValidatePointer()
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nLength - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nLength
            raise("ERROR: Read beyond pointer view bounds")
        ok
        
        if @pLowLevelPtr = NULL
            # Fallback to regular read
            return This.Read(_nOffset_, _nLength_)
        ok
        
        # Use low-level pointer for direct memory access
        _nTargetAddress_ = @nBaseAddress + @nOffset + _nOffset_
        pTempPtr = setptr(@pLowLevelPtr, _nTargetAddress_)
        _cResult_ = ptr2str(pTempPtr, 0, _nLength_)
        
        return _cResult_

    def Write(_nOffset_, pData)
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset not allowed")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot write null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        if _nOffset_ + len(_cData_) > @nLength
            raise("ERROR: Write would exceed pointer view bounds")
        ok
        
        # Calculate absolute buffer position
        _nAbsoluteOffset_ = @nOffset + _nOffset_
        
		# Write directly to buffer to avoid circular call
		_oBuffer_ = @oMemory.GetBufferById(@cBufferId)
		if IsNull(_oBuffer_)
		    raise("ERROR: Buffer not found")
		ok
		_oBuffer_.Write(_nAbsoluteOffset_, _cData_)

    def Write0(_nOffset_, pData)
        This.Write(_nOffset_, pData)

    def Write1(_nOffset_, pData)
        This.Write(_nOffset_-1, pData)

    def WriteByte(_nOffset_, nByte)
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if _nOffset_ < 0 or _nOffset_ >= @nLength
            raise("ERROR: Byte offset out of bounds")
        ok
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        This.Write(_nOffset_, char(nByte))

    def WriteByte0(_nOffset_, nByte)
        This.WriteByte(_nOffset_, nByte)

    def WriteByte1(_nOffset_, nByte)
        This.WriteByte(_nOffset_-1, nByte)

    def Fill(nByte, _nStart_, _nLength_)
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Fill operation not allowed - pointer is read-only")
        ok
        
        if IsNull(_nStart_)
            _nStart_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nLength - _nStart_
        ok
        
        if _nStart_ < 0 or _nLength_ < 0
            raise("ERROR: Negative start or length not allowed")
        ok
        
        if _nStart_ + _nLength_ > @nLength
            raise("ERROR: Fill would exceed pointer view bounds")
        ok
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        # Create fill data
        _cFillData_ = @copy(char(nByte), _nLength_)
        This.Write(_nStart_, _cFillData_)

    def Fill0(nByte, _nStart_, _nLength_)
        This.Fill(nByte, _nStart_, _nLength_)

    def Fill1(nByte, _nStart_, _nLength_)
        This.Fill(nByte, _nStart_-1, _nLength_)

    #--------------------------#
    #  SEARCHING AND INDEXING  #
    #--------------------------#

    def IndexOf(pPattern, _nStartPos_)
        This.ValidatePointer()
        
        if IsNull(_nStartPos_)
            _nStartPos_ = 0
        ok
        
        if _nStartPos_ < 0 or _nStartPos_ >= @nLength
            return -1
        ok
        
        if IsNull(pPattern)
            return -1
        ok
        
        _cPattern_ = ""
        if IsString(pPattern)
            _cPattern_ = pPattern
        else
            _cPattern_ = string(pPattern)
        ok
        
        if len(_cPattern_) = 0
            return _nStartPos_
        ok
        
        # Read view data and search within it
        _cViewData_ = This.Read(_nStartPos_, @nLength - _nStartPos_)
        _nPos_ = substr(_cViewData_, _cPattern_)
        
        if _nPos_ > 0
            return _nStartPos_ + _nPos_ - 1
        else
            return -1
        ok

    def IndexOf0(pPattern, _nStartPos_)
        return This.IndexOf(pPattern, _nStartPos_)

    def IndexOf1(pPattern, _nStartPos_)
        _nResult_ = This.IndexOf(pPattern, _nStartPos_)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    def Contains(pPattern)
        return This.IndexOf(pPattern) != -1

    #-----------------------#
    #  VIEW MANIPULATION    #
    #-----------------------#

    def CreateSubView(_nOffset_, _nLength_)
        This.ValidatePointer()
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nLength
            raise("ERROR: Sub-view exceeds current view bounds")
        ok
        
        # Calculate absolute offset
        _nAbsoluteOffset_ = @nOffset + _nOffset_
        
        # Create new pointer through memory container
        return @oMemory.CreatePointerView(@cBufferId, @cAccessMode, _nAbsoluteOffset_, _nLength_)

    def CreateSubView0(_nOffset_, _nLength_)
        return This.CreateSubView(_nOffset_, _nLength_)

    def CreateSubView1(_nOffset_, _nLength_)
        return This.CreateSubView(_nOffset_-1, _nLength_)

    def Slice(_nOffset_, _nLength_)
        This.ValidatePointer()
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nLength - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nLength
            raise("ERROR: Slice exceeds view bounds")
        ok
        
        return This.Read(_nOffset_, _nLength_)

    def Slice0(_nOffset_, _nLength_)
        return This.Slice(_nOffset_, _nLength_)

    def Slice1(_nOffset_, _nLength_)
        return This.Slice(_nOffset_-1, _nLength_)

    #-----------------------#
    #  COPYING AND MOVING   #
    #-----------------------#

    def CopyFrom(oSourcePointer, _nSourceOffset_, _nDestOffset_, _nLength_)
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
        
        if IsNull(_nSourceOffset_)
            _nSourceOffset_ = 0
        ok
        
        if IsNull(_nDestOffset_)
            _nDestOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = min([oSourcePointer.Length() - _nSourceOffset_, @nLength - _nDestOffset_])
        ok
        
        if _nSourceOffset_ < 0 or _nDestOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offsets or length not allowed")
        ok
        
        if _nSourceOffset_ + _nLength_ > oSourcePointer.Length()
            raise("ERROR: Copy would exceed source bounds")
        ok
        
        if _nDestOffset_ + _nLength_ > @nLength
            raise("ERROR: Copy would exceed destination bounds")
        ok
        
        # Read from source and write to destination
        _cData_ = oSourcePointer.Read(_nSourceOffset_, _nLength_)
        This.Write(_nDestOffset_, _cData_)

    def CopyFrom0(oSourcePointer, _nSourceOffset_, _nDestOffset_, _nLength_)
        This.CopyFrom(oSourcePointer, _nSourceOffset_, _nDestOffset_, _nLength_)

    def CopyFrom1(oSourcePointer, _nSourceOffset_, _nDestOffset_, _nLength_)
        This.CopyFrom(oSourcePointer, _nSourceOffset_-1, _nDestOffset_-1, _nLength_)

    def CopyTo(oDestPointer, _nSourceOffset_, _nDestOffset_, _nLength_)
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
        oDestPointer.CopyFrom(This, _nSourceOffset_, _nDestOffset_, _nLength_)

    def CopyTo0(oDestPointer, _nSourceOffset_, _nDestOffset_, _nLength_)
        This.CopyTo(oDestPointer, _nSourceOffset_, _nDestOffset_, _nLength_)

    def CopyTo1(oDestPointer, _nSourceOffset_, _nDestOffset_, _nLength_)
        This.CopyTo(oDestPointer, _nSourceOffset_-1, _nDestOffset_-1, _nLength_)

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
            _nNewAddress_ = @nBaseAddress + @nOffset + nNewOffset
            setptr(@pLowLevelPtr, _nNewAddress_)
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
            _oPointer_ = ptr2obj(pReference)
            if ClassName(_oPointer_) != "stkpointer"
                raise("ERROR: Reference does not point to stkPointer")
            ok
            return _oPointer_
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
        _nViewAddress_ = This.GetViewAddress()
        pTempPtr = nullptr()
        setptr(pTempPtr, _nViewAddress_)
        
        try
            return ptr2str(pTempPtr, 0, @nLength)
        catch cError
            # Fallback to regular read if direct access fails
            return This.ReadAll()
        done

    def FromBinaryString(cBinaryData, _nOffset_)
        # Write binary data directly to pointer location
        This.ValidatePointer()
        
        if @cAccessMode != "write"
            raise("ERROR: Write operation not allowed - pointer is read-only")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset not allowed")
        ok
        
        if _nOffset_ + len(cBinaryData) > @nLength
            raise("ERROR: Binary data would exceed pointer view bounds")
        ok
        
        # Use regular write method for safety
        This.Write(_nOffset_, cBinaryData)

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
            _oBuffer_ = @oMemory.GetBufferById(@cBufferId)
            if not IsNull(_oBuffer_)
                _cBufferData_ = _oBuffer_.Content()
                if len(_cBufferData_) > 0
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

	    _oBufferInfo_ = @oMemory.GetBufferInfo(@cBufferId)

	    if IsNull(_oBufferInfo_)
	        raise("ERROR: Referenced buffer no longer exists")
	    ok

	    if @nOffset < 0 or @nLength < 0
	        raise("ERROR: Invalid offset or length")
	    ok

	    if @nOffset + @nLength > _oBufferInfo_[:capacity]
	        raise("ERROR: Pointer view exceeds buffer bounds")
	    ok
