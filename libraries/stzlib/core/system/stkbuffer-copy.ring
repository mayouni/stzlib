class stkBuffer

    @buffer = NULL
    @nSize = 0 # In bytes
    @nCapacity = 0
    @bIsValid = FALSE
    @oMemory = NULL

    #-------------------------------#
    #  INITIALIZATION AND CREATION  #
    #-------------------------------#

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
        @buffer = ""  # Start with empty buffer, not spaces
        @bIsValid = TRUE

    def InitWithData(pData)
        if IsNull(pData)
            raise("Cannot initialize buffer with null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = list2str(pData)
        ok
        
        @nSize = len(_cData_)
        @nCapacity = @nSize
        @buffer = _cData_
        @bIsValid = TRUE

    #------------------------#
    #  WRITING AND UPDATING  #
    #------------------------#

    def Write(_nOffset_, pData) # Uses 0-index by default
        This.ValidateBuffer()
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") not allowed")
        ok
        
        # Convert data to string safely
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        _nLenData_ = len(_cData_)
        if _nLenData_ = 0
            ? "WARNING: Writing empty data - no changes made"
            return
        ok
        
        _nRequiredSize_ = _nOffset_ + _nLenData_
        
        # Expand capacity if needed
        if _nRequiredSize_ > @nCapacity
            This.Resize(_nRequiredSize_)
        ok
        
        # FIXED: Proper buffer reconstruction
        _cNewBuffer_ = ""
        _nLenBuffer_ = len(@buffer)
        # Case 1: Writing at or beyond current buffer end
        if _nOffset_ >= _nLenBuffer_
            # Keep existing buffer and pad with zeros if needed
            _cNewBuffer_ = @buffer
            if _nOffset_ > _nLenBuffer_
                # Pad with zeros between current end and write position
                _cNewBuffer_ += @copy(char(0), _nOffset_ - _nLenBuffer_)
            ok
            _cNewBuffer_ += _cData_
        else
            # Case 2: Writing within existing buffer (overwrite/insert)
            # Copy data before write position
            _cNewBuffer_ = left(@buffer, _nOffset_)
            # Add new data
            _cNewBuffer_ += _cData_
            # Copy remaining data after write position (if any)
            _nEndPos_ = _nOffset_ + _nLenData_
            if _nEndPos_ < _nLenBuffer_
                _cNewBuffer_ += right(@buffer, _nLenBuffer_ - _nEndPos_)
            ok
        ok
        
        @buffer = _cNewBuffer_
        @nSize = len(@buffer)
        @nCapacity = max([@nCapacity, @nSize])

    def Write0(_nOffset_, pData)
        This.Write(_nOffset_, pData)

    def Write1(_nOffset_, pData) # Ring 1-based index
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
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") or length (" + _nLength_ + ") not allowed")
        ok
        
        if @nSize = 0
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
        
        # SAFEGUARD: Validate buffer integrity before read
        if len(@buffer) != @nSize
            raise("CRITICAL ERROR: Buffer corruption detected - internal size mismatch")
        ok
        
        if _nOffset_ = 0
            return left(@buffer, _nLength_)
        else
            _cTemp_ = right(@buffer, @nSize - _nOffset_)
            return left(_cTemp_, _nLength_)
        ok

    def Read1(_nOffset_, _nLength_) # Ring 1-based index
        return This.Read(_nOffset_-1, _nLength_)

    def Slice(_nOffset_, _nLength_) # Range() in Softanza semantics, uses 0-index
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nSize - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("Slice beyond buffer size")
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

    def Section(n1, n2) # Uses lowlevel 0-index
        return This.Range(n1, n2 - n1 + 1)

    def Section0(n1, n2)
        return This.Section(n1, n2)

    def Section1(n1, n2) # Uses highlevel Ring 1-index
        return This.Section(n1-1, n2-1)

    #----------------------------------#
    #  INSERTING, APPENDING, REMOVING  #
    #----------------------------------#

    def Append(pData)
        if IsNull(pData)
            raise("Cannot append null data")
        ok
        
        This.Write(@nSize, pData)

    def Prepend(pData)
        if IsNull(pData)
            raise("Cannot prepend null data")
        ok
        
        _cData_ = ""
        if IsString(pData)
            _cData_ = pData
        else
            _cData_ = string(pData)
        ok
        
        @buffer = _cData_ + @buffer
        @nSize += len(_cData_)
        @nCapacity = len(@buffer)

    def Insert(_nOffset_, pData) # Uses low level 0-index by default
        if _nOffset_ < 0 or _nOffset_ > @nSize
            raise("Invalid offset for insertion")
        ok
        
        if IsNull(pData)
            raise("Cannot insert null data")
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
        @nCapacity = len(@buffer)

    def Insert0(_nOffset_, pData)
        This.Insert(_nOffset_, pData)

    def InsertAt(_nPos_, pData)
        This.Insert(_nPos_, pData)

    def Insert1(_nOffset_, pData) # Uses Ring 1-index
        This.Insert(_nOffset_-1, pData)

    def InsertAt1(_nOffset_, pData)
        This.Insert1(_nOffset_, pData)

    def Remove(_nOffset_, _nLength_) # Uses lowlevel 0-Index
        if _nOffset_ < 0 or _nLength_ < 0
            raise("Negative offset or length not allowed")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("Cannot remove beyond buffer size")
        ok
        
        if _nLength_ = 0
            return
        ok
        
        @buffer = left(@buffer, _nOffset_) + right(@buffer, len(@buffer) - (_nOffset_ + _nLength_))
        @nSize -= _nLength_
        @nCapacity = len(@buffer)

    def Remove0(_nOffset_, _nLength_)
        This.Remove(_nOffset_, _nLength_)

    def RemoveRange(nStart, _nLength_)
        This.Remove(nStart, _nLength_)

    def RemoveRange0(nStart, _nLength_)
        This.Remove(nStart, _nLength_)

    def Remove1(_nOffset_, _nLength_) # Uses Ring highlevel 1-index
        This.Remove(_nOffset_-1, _nLength_)

    def RemoveRange1(nStart, _nLength_)
        This.Remove(nStart-1, _nLength_)

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

    def IndexOf(pPattern) # Uses lowlevel 0-index
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

    def IndexOf1(pPattern) # Uses highlevel Ring 1-index
        _nResult_ = This.IndexOf(pPattern)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    def FindFirst1(pPattern) # Idem
        return This.IndexOf1(pPattern)

    def IndexOfXT(pPattern, _nStartOffset_) # Uses lowlevel 0-index
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

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

    def FindFirstXT(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def IndexOfXT0(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def FindFirstXT0(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def IndexOfXT1(pPattern, _nStartOffset_) # Uses highlevel Ring 1-index
        _nResult_ = This.IndexOfXT(pPattern, _nStartOffset_)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    def FindFirstXT1(pPattern, _nStartOffset_) # Idem
        return This.IndexOfXT1(pPattern, _nStartOffset_)

    def IndexOfN(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def FindFirstN(pPattern, _nStartOffset_)
        return This.IndexOfXT(pPattern, _nStartOffset_)

    def IndexOfN0(pPattern, _nStartOffset_)
        return This.IndexOfN(pPattern, _nStartOffset_)

    def FindFirstN0(pPattern, _nStartOffset_)
        return This.IndexOfN(pPattern, _nStartOffset_)

    def IndexOfN1(pPattern, _nStartOffset_)
        _nResult_ = This.IndexOfN(pPattern, _nStartOffset_)
        if _nResult_ = -1
            return 0  # Ring convention: 0 means not found
        else
            return _nResult_ + 1
        ok

    def FindFirstN1(pPattern, _nStartOffset_)
        return This.IndexOfN1(pPattern, _nStartOffset_)

    #------------------------------#
    #  BUFFER MANAGEMENT METHODS   #
    #------------------------------#

    def Resize(nNewSize)
        This.ValidateBuffer()
        
        if nNewSize <= 0
            raise("New size must be positive")
        ok
        
        _cNewBuffer_ = ""
        
        if nNewSize > len(@buffer)
            # Extend with null bytes, not spaces
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
        @buffer = ""  # Empty buffer, not spaces
        @nSize = 0

	def Fill(nByte, nStartPos, _nLength_)
		# Fill buffer with a specific byte value (0-255)
		# This method must support full byte range including null bytes (0)
		# for binary data, network packets, and C library interoperability
		
		if nByte < 0 or nByte > 255
			raise("ERROR: Byte value must be between 0 and 255")
		ok
		
		if _nLength_ <= 0
			raise("ERROR: Length must be positive")
		ok
		
		# Create string of repeated byte character
		_cFillData_ = @copy(char(nByte), _nLength_)
		
		# Use existing Write() method (now supports null bytes)
		This.Write(nStartPos, _cFillData_)


    def Compact()
        if @nSize < @nCapacity and @nSize > 0
            This.Resize(@nSize)
        ok

    def Copy()
        # Copies data to a new buffer
        # and return it (as a stkBuffer object), leaving the
        # current (source) buffer as is
        _oNewBuffer_ = new stkBuffer(@nSize)
        _oNewBuffer_.Write(0, This.Read(0, @nSize))
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
	        if @oMemory != NULL
	            @oMemory.Deallocate(@buffer)
	        ok
	        @buffer = NULL
	        @nSize = 0
	        @nCapacity = 0
	        @bIsValid = FALSE
	    ok

    def Destroy()
        This.Free()

    #-----------------------------#
    #  INFORMATION AND METADATA   #
    #-----------------------------#

    def Size()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return @nSize

    def SizeInBytes()
        return This.Size()

    def Capacity()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return @nCapacity

    def RawData()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return @buffer

    def Content()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return @buffer

    def Info()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return [ :size = @nSize, :capacity = @nCapacity ]

    def IsValid()
        return @bIsValid

    def Memory()
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        return @oMemory

    #------------------------------------------------#
    #  CREATING A POINTER FOR A SLICE OF THE BUFFER  #
    #------------------------------------------------#

    def GetPointer(_nOffset_) # An internal method, for better semantics, use methods that follow

		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0 or _nOffset_ >= @nSize
            raise("Invalid offset for pointer")
        ok

        _cSliceData_ = right(@buffer, @nSize - _nOffset_)
        return new stkPointer([_cSliceData_, "string", len(_cSliceData_)+1])

    def SliceToPointer(_nOffset_, _nLength_)
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        _oTempBuffer_ = new stkBuffer(This.Slice(_nOffset_, _nLength_))
        return _oTempBuffer_.GetPointer(0)

    def RangeToPointer(_nOffset_, _nLength_)
        return This.SliceToPointer(_nOffset_, _nLength_)

    def SliceToPointer0(_nOffset_, _nLength_)
        return This.SliceToPointer(_nOffset_, _nLength_)

    def RangeToPointer0(_nOffset_, _nLength_)
        return This.SliceToPointer(_nOffset_, _nLength_)

    def SliceToPointer1(_nOffset_, _nLength_)
        return This.SliceToPointer(_nOffset_-1, _nLength_)

    def RangeToPointer1(_nOffset_, _nLength_)
        return This.SliceToPointer(_nOffset_-1, _nLength_)

    def SectionToPointer(_nOffset_, _nLength_)
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        _oTempBuffer_ = new stkBuffer(This.Section(_nOffset_, _nLength_))
        return _oTempBuffer_.GetPointer(0)

    def SectionToPointer0(_nOffset_, _nLength_)
        return This.SectionToPointer(_nOffset_, _nLength_)

    def SectionToPointer1(_nOffset_, _nLength_)
        return This.SectionToPointer(_nOffset_-1, _nLength_-1)

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
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read file content (works for both text and binary)
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Initialize buffer with file content
        This.InitWithData(_cFileContent_)
        
		# For debug (comment it)
        //? "INFO: Successfully loaded " + len(cFileContent) + " bytes from '" + cFileName + "'"

    def LoadFromFileXT(cFileName, _nOffset_, _nLength_)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") not allowed")
        ok
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read entire file first
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        _nFileSize_ = len(_cFileContent_)
        
        if _nOffset_ >= _nFileSize_
            raise("ERROR: Offset (" + _nOffset_ + ") beyond file size (" + _nFileSize_ + ")")
        ok
        
        # Determine length to read
        if IsNull(_nLength_)
            _nLength_ = _nFileSize_ - _nOffset_
        ok
        
        if _nLength_ < 0
            raise("ERROR: Negative length (" + _nLength_ + ") not allowed")
        ok
        
        if _nOffset_ + _nLength_ > _nFileSize_
            raise("ERROR: Read request (offset:" + _nOffset_ + " + length:" + _nLength_ + 
                  ") exceeds file size (" + _nFileSize_ + ")")
        ok
        
        # Extract the requested portion
        _cData_ = ""
        if _nOffset_ = 0
            _cData_ = left(_cFileContent_, _nLength_)
        else
            _cTemp_ = right(_cFileContent_, _nFileSize_ - _nOffset_)
            _cData_ = left(_cTemp_, _nLength_)
        ok
        
        # Initialize buffer with extracted data
        This.InitWithData(_cData_)
        
		# For debug (comment it)
        // ? "INFO: Successfully loaded " + len(cData) + " bytes (offset:" + nOffset + 
          ", length:" + _nLength_ + ") from '" + cFileName + "'"

    def AppendFromFile(cFileName)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read file content
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Append to existing buffer
        This.Append(_cFileContent_)
        
		# For debug (comment it)
        // ? "INFO: Successfully appended " + len(cFileContent) + " bytes from '" + cFileName + "'"

    def AppendFromFileXT(cFileName, _nOffset_, _nLength_)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if _nOffset_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") not allowed")
        ok
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read entire file first
        _cFileContent_ = ring_read(cFileName)
        
        if IsNull(_cFileContent_)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        _nFileSize_ = len(_cFileContent_)
        
        if _nOffset_ >= _nFileSize_
            raise("ERROR: Offset (" + _nOffset_ + ") beyond file size (" + _nFileSize_ + ")")
        ok
        
        # Determine length to read
        if IsNull(_nLength_)
            _nLength_ = _nFileSize_ - _nOffset_
        ok
        
        if _nLength_ < 0
            raise("ERROR: Negative length (" + _nLength_ + ") not allowed")
        ok
        
        if _nOffset_ + _nLength_ > _nFileSize_
            raise("ERROR: Read request (offset:" + _nOffset_ + " + length:" + _nLength_ + 
                  ") exceeds file size (" + _nFileSize_ + ")")
        ok
        
        # Extract the requested portion
        _cData_ = ""
        if _nOffset_ = 0
            _cData_ = left(_cFileContent_, _nLength_)
        else
            _cTemp_ = right(_cFileContent_, _nFileSize_ - _nOffset_)
            _cData_ = left(_cTemp_, _nLength_)
        ok
        
        # Append to existing buffer
        This.Append(_cData_)

		# For debug (comment it)
        // ? "INFO: Successfully appended " + len(cData) + " bytes (offset:" + nOffset + 
          ", length:" + _nLength_ + ") from '" + cFileName + "'"


    def SaveToFile(cFileName, _nOffset_, _nLength_)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(_nOffset_)
            _nOffset_ = 0
        ok
        
        if IsNull(_nLength_)
            _nLength_ = @nSize - _nOffset_
        ok
        
        if _nOffset_ < 0 or _nLength_ < 0
            raise("ERROR: Negative offset (" + _nOffset_ + ") or length (" + _nLength_ + ") not allowed")
        ok
        
        if @nSize = 0
            raise("ERROR: Cannot save from empty buffer")
        ok
        
        if _nOffset_ >= @nSize
            raise("ERROR: Offset (" + _nOffset_ + ") beyond buffer size (" + @nSize + ")")
        ok
        
        if _nOffset_ + _nLength_ > @nSize
            raise("ERROR: Save request (offset:" + _nOffset_ + " + length:" + _nLength_ + 
                  ") exceeds buffer size (" + @nSize + ")")
        ok
        
        # Read data from buffer
        _cData_ = This.Read(_nOffset_, _nLength_)
        
        # Write to file
        ring_write(cFileName, _cData_)

		# For debug (comment it)
         ? "INFO: Successfully saved " + len(_cData_) + " bytes to '" + cFileName + "'"

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
        
        if @nSize < 0
            raise("ERROR: Buffer size is negative (" + @nSize + ") - invalid state")
        ok
        
        if @nCapacity < 0
            raise("ERROR: Buffer capacity is negative (" + @nCapacity + ") - invalid state")
        ok
        
        if @nSize > @nCapacity
            raise("ERROR: Buffer size (" + @nSize + ") exceeds capacity (" + @nCapacity + ") - corruption detected")
        ok
        
        # Additional integrity check
        if not IsString(@buffer)
            raise("ERROR: Buffer is not a string - type corruption detected")
        ok
        
        _nActualLen_ = len(@buffer)
        if _nActualLen_ != @nSize and @nSize > 0
			# A warning for debugging
            # ? "WARNING: Buffer size mismatch - expected:" + @nSize + " actual:" + nActualLen
            @nSize = _nActualLen_  # Auto-correct minor discrepancies
        ok
