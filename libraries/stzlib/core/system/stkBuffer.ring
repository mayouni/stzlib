#Note : The pointer system still needs buffer IDs internally,
# but user-facing API should work with buffer objects directly.


class stkBuffer
    @cId = ""                # Unique identifier assigned by stkMemory
    @oMemory = NULL          # Reference to containing stkMemory
    @buffer = ""             # Actual data storage
    @nSize = 0               # Current size in bytes
    @nCapacity = 0           # Maximum capacity
    @bIsValid = FALSE        # Validity flag
    @bHasWritePointer = FALSE # Write access control

    #-------------------------------#
    #  INITIALIZATION AND CREATION  #
    #-------------------------------#

	def init(oMemory, cId, nSize)
	    # Can only be created by stkMemory - no standalone creation
	    if IsNull(oMemory) or not IsObject(oMemory)
	        raise("ERROR: stkBuffer must be created by stkMemory container")
	    ok
	    
	    if ClassName(oMemory) != "stkmemory"
	        raise("ERROR: Invalid memory container type")
	    ok
	    
	    if IsNull(cId) or not IsString(cId) or len(cId) = 0
	        raise("ERROR: Buffer ID must be a non-empty string")
	    ok
	    
	    if nSize <= 0
	        raise("ERROR: Buffer size must be positive")
	    ok
	    
	    @oMemory = oMemory
	    @cId = cId
	    @nSize = 0
	    @nCapacity = nSize
	    @buffer = ""  # Start empty, not filled with spaces
	    @bIsValid = TRUE
	    @bHasWritePointer = FALSE

	def id()
		return @cID

    def InitWithData(pData)
        # Helper method for stkMemory to initialize with data
        This.ValidateBuffer()
        
        if IsNull(pData)
            raise("ERROR: Cannot initialize buffer with null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        @buffer = _cData_
        @nSize = len(_cData_)
        @nCapacity = max([@nCapacity, @nSize])

    #------------------------#
    #  WRITING AND UPDATING  #
    #------------------------#

	def Write(_nOffset_, pData)
	    if _nOffset_ < 0
	        raise("ERROR: Negative offset not allowed")
	    ok
	    _cData_ = ""
	    if IsString(pData)
	        _cData_ = pData
	    else
	        _cData_ = string(pData)
	    ok
	    _nLenData_ = len(_cData_)
//	    ? "DEBUG: nLenData = " + nLenData
	    if _nLenData_ = 0
//	        ? "WARNING: Writing empty data - no changes made"
	        return
	    ok
//	    ? "DEBUG: About to write data, current buffer size: " + @nSize
	    _nRequiredSize_ = _nOffset_ + _nLenData_
//	    ? "DEBUG: nRequiredSize = " + nRequiredSize + ", capacity = " + @nCapacity
	    if _nRequiredSize_ > @nCapacity
	        @nCapacity = _nRequiredSize_
	    ok
	    _cNewBuffer_ = ""
	    _nLenBuffer_ = len(@buffer)
//	    ? "DEBUG: nLenBuffer = " + nLenBuffer + ", nOffset = " + nOffset
	    if _nOffset_ >= _nLenBuffer_
//	        ? "DEBUG: Taking first branch (nOffset >= nLenBuffer)"
	        _cNewBuffer_ = @buffer
	        if _nOffset_ > _nLenBuffer_
//	            ? "DEBUG: Adding padding of " + (nOffset - nLenBuffer) + " bytes"
	            _cNewBuffer_ += @copy(char(0), _nOffset_ - _nLenBuffer_)
	        ok
	        _cNewBuffer_ += _cData_
//	        ? "DEBUG: After adding data, cNewBuffer length = " + len(cNewBuffer)
	    else
//	        ? "DEBUG: Taking second branch (nOffset < nLenBuffer)"
	        _cNewBuffer_ = left(@buffer, _nOffset_) + _cData_
	        _nEndPos_ = _nOffset_ + _nLenData_
	        if _nEndPos_ < _nLenBuffer_
	            _cNewBuffer_ += right(@buffer, _nLenBuffer_ - _nEndPos_)
	        ok
//	        ? "DEBUG: After building, cNewBuffer length = " + len(cNewBuffer)
	    ok
	    @buffer = _cNewBuffer_
	    @nSize = len(@buffer)
//	    ? "DEBUG: Final buffer size: " + @nSize + ", buffer content: '" + @buffer + "'"
	

    def Write0(_nOffset_, pData)
        This.Write(_nOffset_, pData)

    def Write1(_nOffset_, pData)
        This.Write(_nOffset_-1, pData)

    def UpdateRange(nStart, _nLength_, pData)
        This.ValidateBuffer()
        
        if nStart < 0 or _nLength_ < 0
            raise("ERROR: Negative start position or length not allowed")
        ok
        
        if nStart >= @nSize
            raise("ERROR: Start position beyond buffer size")
        ok
        
        if nStart + _nLength_ > @nSize
            raise("ERROR: Range exceeds buffer size")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot update with null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        # Replace the range with new data
        _cNewBuffer_ = left(@buffer, nStart) + _cData_ + right(@buffer, @nSize - (nStart + _nLength_))
        @buffer = _cNewBuffer_
        @nSize = len(@buffer)
        @nCapacity = max([@nCapacity, @nSize])

    def UpdateRange0(nStart, _nLength_, pData)
        This.UpdateRange(nStart, _nLength_, pData)

    def UpdateRange1(nStart, _nLength_, pData)
        This.UpdateRange(nStart-1, _nLength_, pData)

    def UpdateSection(nStart, nEnd, pData)
        This.ValidateBuffer()
        
        if nStart < 0 or nEnd < 0
            raise("ERROR: Negative start or end position not allowed")
        ok
        
        if nStart > nEnd
            raise("ERROR: Start position cannot be greater than end position")
        ok
        
        if nEnd >= @nSize
            raise("ERROR: End position beyond buffer size")
        ok
        
        _nLength_ = nEnd - nStart + 1
        This.UpdateRange(nStart, _nLength_, pData)

    def UpdateSection0(nStart, nEnd, pData)
        This.UpdateSection(nStart, nEnd, pData)

    def UpdateSection1(nStart, nEnd, pData)
        This.UpdateSection(nStart-1, nEnd-1, pData)

    #-----------------------#
    #  READING AND SLICING  #
    #-----------------------#

    def Read(_nOffset_, _nLength_)
        This.ValidateBuffer()
 ? "DEBUG Read: @nSize = " + @nSize + ", nOffset = " + _nOffset_ + ", nLength = " + _nLength_

        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") or length (" + _nLength_ + ") not allowed")
        ok
        
        if @nSize = 0
       ? "DEBUG: Buffer is empty, @buffer = '" + @buffer + "'"
            raise("ERROR: Cannot read from empty buffer (size=0)")
        ok
        
        if _nOffset_ >= @nSize
            raise("ERROR: Offset (" + _nOffset_ + ") beyond buffer size (" + @nSize + ")")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("ERROR: Read request (offset:" + _nOffset_ + " + length:" + _nLength_ + 
                  ") exceeds buffer size (" + @nSize + ")")
        ok
        
        if _nLength_ = 0
            ? "WARNING: Reading zero bytes - returning empty string"
            return ""
        ok
        
        # Buffer integrity check
        if len(@buffer) != @nSize
            raise("CRITICAL ERROR: Buffer corruption detected - internal size mismatch")
        ok
        
        if _nOffset_ = 0
            return left(@buffer, _nLength_)
        else
            _cTemp_ = right(@buffer, @nSize - _nOffset_)
            return left(_cTemp_, _nLength_)
        ok

    def Read1(_nOffset_, _nLength_)
        return This.Read(_nOffset_-1, _nLength_)

    def Slice(_nOffset_, _nLength_)
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nSize - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("ERROR: Slice beyond buffer size")
        ok
        
        return This.Read(_nOffset_, _nLength_)

    def Range(_nOffset_, _nLength_)
        return This.Slice(_nOffset_, _nLength_)

    def Slice0(_nOffset_, _nLength_)
        return This.Slice(_nOffset_, _nLength_)

    def Range0(_nOffset_, _nLength_)
        return This.Slice(_nOffset_, _nLength_)

    def Slice1(_nOffset_, _nLength_)
        return This.Slice(_nOffset_-1, _nLength_)

    def Range1(_nOffset_, _nLength_)
        return This.Slice(_nOffset_-1, _nLength_)

    def Section(n1, n2)
        return This.Range(n1, n2 - n1 + 1)

    def Section0(n1, n2)
        return This.Section(n1, n2)

    def Section1(n1, n2)
        return This.Section(n1-1, n2-1)

    #----------------------------------#
    #  INSERTING, APPENDING, REMOVING  #
    #----------------------------------#

    def Append(pData)
        if IsNull(pData)
            raise("ERROR: Cannot append null data")
        ok
        
        This.Write(@nSize, pData)

    def Prepend(pData)
        if IsNull(pData)
            raise("ERROR: Cannot prepend null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        @buffer = _cData_ + @buffer
        @nSize += len(_cData_)
        @nCapacity = max([@nCapacity, @nSize])

    def Insert(_nOffset_, pData)
        if _nOffset_ < 0 or _nOffset_ > @nSize
            raise("ERROR: Invalid offset for insertion")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot insert null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        _cNewBuffer_ = left(@buffer, _nOffset_) + _cData_ + right(@buffer, len(@buffer) - _nOffset_)
        @buffer = _cNewBuffer_
        @nSize += len(_cData_)
        @nCapacity = max([@nCapacity, @nSize])

    def Insert0(_nOffset_, pData)
        This.Insert(_nOffset_, pData)

    def Insert1(_nOffset_, pData)
        This.Insert(_nOffset_-1, pData)

    def Remove(_nOffset_, _nLength_)
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("ERROR: Cannot remove beyond buffer size")
        ok
        
        if _nLength_ = 0
            return
        ok
        
        @buffer = left(@buffer, _nOffset_) + right(@buffer, len(@buffer) - (_nOffset_ + _nLength_))
        @nSize -= _nLength_
        @nCapacity = max([@nCapacity, @nSize])

    def Remove0(_nOffset_, _nLength_)
        This.Remove(_nOffset_, _nLength_)

    def Remove1(_nOffset_, _nLength_)
        This.Remove(_nOffset_-1, _nLength_)

    def RemoveSection(nStart, nEnd)
        This.ValidateBuffer()
        
        if nStart < 0 or nEnd < 0
            raise("ERROR: Negative start or end position not allowed")
        ok
        
        if nStart > nEnd
            raise("ERROR: Start position cannot be greater than end position")
        ok
        
        if nEnd >= @nSize
            raise("ERROR: End position beyond buffer size")
        ok
        
        _nLength_ = nEnd - nStart + 1
        This.Remove(nStart, _nLength_)

    def RemoveSection0(nStart, nEnd)
        This.RemoveSection(nStart, nEnd)

    def RemoveSection1(nStart, nEnd)
        This.RemoveSection(nStart-1, nEnd-1)

    #---------------------------#
    #  SEARCHING AND INDEXING   #
    #---------------------------#

    def IndexOf(pPattern)
        if isList(pPattern) and len(pPattern) = 2
            return This.IndexOfXT(pPattern[1], pPattern[2])
        ok
        return This.IndexOfXT(pPattern, 0)

    def IndexOf0(pPattern)
        return This.IndexOf(pPattern)

    def IndexOf1(pPattern)
        _nResult_ = This.IndexOf(pPattern)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    def IndexOfXT(pPattern, _nStartOffset_)
        This.ValidateBuffer()
        
        if IsNull(_nStartOffset_)
            _nStartOffset_ = 0
        ok
        
        if _nStartOffset_ < 0 or _nStartOffset_ >= @nSize
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
            return _nStartOffset_
        ok
        
        _cSearchBuffer_ = right(@buffer, len(@buffer) - _nStartOffset_)
        _nPos_ = substr(_cSearchBuffer_, _cPattern_)
        
        if _nPos_ > 0
            return _nStartOffset_ + _nPos_ - 1
        else
            return -1
        ok

    def IndexOfXT0(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def IndexOfXT1(pPattern, _nStartOffset_)
        _nResult_ = This.IndexOfXT(pPattern, _nStartOffset_)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    #------------------------------#
    #  BUFFER MANAGEMENT METHODS   #
    #------------------------------#

    def Resize(nNewSize)
        This.ValidateBuffer()
        
        if nNewSize <= 0
            raise("ERROR: New size must be positive")
        ok
        
        _cNewBuffer_ = ""
        
        if nNewSize > len(@buffer)
            # Extend with null bytes
            _cNewBuffer_ = @buffer + @copy(char(0), nNewSize - len(@buffer))
        but nNewSize < len(@buffer)
            _cNewBuffer_ = left(@buffer, nNewSize)
        else
            _cNewBuffer_ = @buffer
        ok
        
        @buffer = _cNewBuffer_
        @nCapacity = nNewSize
        
        if @nSize > nNewSize
            @nSize = nNewSize
        ok

    def Clear()
        @buffer = ""
        @nSize = 0

    def Fill(nByte, nStartPos, _nLength_)
        This.ValidateBuffer()
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        if _nLength_ <= 0
            raise("ERROR: Length must be positive")
        ok
        
        # Create string of repeated byte character
        _cFillData_ = @copy(char(nByte), _nLength_)
        
        # Use existing Write() method
        This.Write(nStartPos, _cFillData_)

    def Compact()
        if @nSize < @nCapacity and @nSize > 0
            This.Resize(@nSize)
        ok

    def Copy()
	    # Create new buffer through our memory container
	    _oNewBuffer_ = @oMemory.CreateBuffer(@nSize)
	    
	    if @nSize > 0
	        _oNewBuffer_.Write(0, This.Read(0, @nSize))
	    ok
	    
	    return _oNewBuffer_

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

    def Free()
        if @bIsValid
            @oMemory.DestroyBuffer(@cId)  # Notify container
            @buffer = ""
            @nSize = 0
            @nCapacity = 0
            @bIsValid = FALSE
            @bHasWritePointer = FALSE
        ok

    def Destroy()
        This.Free()

    #-----------------------------#
    #  POINTER ACCESS CONTROL     #
    #-----------------------------#

    def GetReadPointer()
        # Always allowed - multiple read pointers OK
        return @oMemory.CreatePointer(@cId, "read")

    def GetWritePointer()
        # Only if no write pointer exists
        if @bHasWritePointer = TRUE
            raise("ERROR: Buffer already has a write pointer")
        ok
        
        @bHasWritePointer = TRUE
        return @oMemory.CreatePointer(@cId, "write")

    def ReleaseWritePointer()
        # Called when write pointer is destroyed
        @bHasWritePointer = FALSE

    def HasWritePointer()
        return @bHasWritePointer

    #-----------------------------#
    #  INFORMATION AND METADATA   #
    #-----------------------------#

	def Size()
	    return @nSize

    def SizeInBytes()
        return This.Size()

    def Capacity()
        This.ValidateBuffer()
        return @nCapacity

    def RawData()
        This.ValidateBuffer()
        return @buffer

    def Content()
        This.ValidateBuffer()
        return @buffer

    def Info()
        This.ValidateBuffer()
        return [ 
            :id = @cId,
            :size = @nSize, 
            :capacity = @nCapacity,
            :hasWritePointer = @bHasWritePointer,
            :isValid = @bIsValid
        ]

    def IsValid()
        return @bIsValid and @oMemory != NULL


    #--------------------------------------------------------#
    #  LOADING AND SAVING EXTERNAL FILES TO/FROM THE BUFFER  #
    #--------------------------------------------------------#

    def LoadFromFile(cFileName)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Replace buffer content with file content
        This.InitWithData(_cFileContent_)

    def LoadFromFileXT(cFileName, _nOffset_, _nLength_)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") not allowed")
        ok
        
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        _nFileSize_ = len(_cFileContent_)
        
        if _nOffset_ >= _nFileSize_
            raise("ERROR: Offset (" + _nOffset_ + ") beyond file size (" + _nFileSize_ + ")")
        ok
        
        if IsNull(_nLength_)
            _nLength_ = _nFileSize_ - _nOffset_
        ok
        
        if _nLength_ < 0
            raise("ERROR: Negative length (" + _nLength_ + ") not allowed")
        ok
        
        if _nOffset_ + _nLength_ > _nFileSize_
            raise("ERROR: Read request exceeds file size")
        ok
        
        # Extract requested portion
        _cData_ = ""
        if _nOffset_ = 0
            _cData_ = left(_cFileContent_, _nLength_)
        else
            _cTemp_ = right(_cFileContent_, _nFileSize_ - _nOffset_)
            _cData_ = left(_cTemp_, _nLength_)
        ok
        
        # Replace buffer content with extracted data
        This.InitWithData(_cData_)

    def AppendFromFile(cFileName)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        This.Append(_cFileContent_)

    def SaveToFile(cFileName, _nOffset_, _nLength_)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nSize - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if @nSize = 0
            raise("ERROR: Cannot save from empty buffer")
        ok
        
        if _nOffset_ >= @nSize
            raise("ERROR: Offset beyond buffer size")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("ERROR: Save request exceeds buffer size")
        ok
        
        # Read data from buffer
        _cData_ = This.Read(_nOffset_, _nLength_)
        
        # Write to file
        ring_write(cFileName, _cData_)

    def SaveToFileAll(cFileName)
        This.SaveToFile(cFileName, 0, @nSize)

    #--------------------------------#
    #  PRIVATE KITCHEN OF THE CLASS  #
    #--------------------------------#

    PRIVATE

    def ValidateBuffer()
        if not @bIsValid
            raise("ERROR: Invalid buffer - buffer was not properly initialized")
        ok
        
        if @oMemory = NULL or not @oMemory.IsValid()
            raise("ERROR: Buffer has invalid memory container reference")
        ok
        
        if @nSize < 0
            raise("ERROR: Buffer size is negative - invalid state")
        ok
        
        if @nCapacity < 0
            raise("ERROR: Buffer capacity is negative - invalid state")
        ok
        
        if @nSize > @nCapacity
            raise("ERROR: Buffer size exceeds capacity - corruption detected")
        ok
        
        if not IsString(@buffer)
            raise("ERROR: Buffer is not a string - type corruption detected")
        ok
        
        _nActualLen_ = len(@buffer)
        if _nActualLen_ != @nSize and @nSize > 0
            @nSize = _nActualLen_  # Auto-correct minor discrepancies
        ok
