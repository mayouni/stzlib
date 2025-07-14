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
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = list2str(pData)
        ok
        
        @nSize = len(cData)
        @nCapacity = @nSize
        @buffer = cData
        @bIsValid = TRUE

    #------------------------#
    #  WRITING AND UPDATING  #
    #------------------------#

    def Write(nOffset, pData) # Uses 0-index by default
        This.ValidateBuffer()
        
        if nOffset < 0
            raise("ERROR: Negative offset (" + nOffset + ") not allowed")
        ok
        
        # Convert data to string safely
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        nLenData = len(cData)
        if nLenData = 0
            ? "WARNING: Writing empty data - no changes made"
            return
        ok
        
        nRequiredSize = nOffset + nLenData
        
        # Expand capacity if needed
        if nRequiredSize > @nCapacity
            This.Resize(nRequiredSize)
        ok
        
        # FIXED: Proper buffer reconstruction
        cNewBuffer = ""
        nLenBuffer = len(@buffer)
        # Case 1: Writing at or beyond current buffer end
        if nOffset >= nLenBuffer
            # Keep existing buffer and pad with zeros if needed
            cNewBuffer = @buffer
            if nOffset > nLenBuffer
                # Pad with zeros between current end and write position
                cNewBuffer += @copy(char(0), nOffset - nLenBuffer)
            ok
            cNewBuffer += cData
        else
            # Case 2: Writing within existing buffer (overwrite/insert)
            # Copy data before write position
            cNewBuffer = left(@buffer, nOffset)
            # Add new data
            cNewBuffer += cData
            # Copy remaining data after write position (if any)
            nEndPos = nOffset + nLenData
            if nEndPos < nLenBuffer
                cNewBuffer += right(@buffer, nLenBuffer - nEndPos)
            ok
        ok
        
        @buffer = cNewBuffer
        @nSize = len(@buffer)
        @nCapacity = max([@nCapacity, @nSize])

    def Write0(nOffset, pData)
        This.Write(nOffset, pData)

    def Write1(nOffset, pData) # Ring 1-based index
        This.Write(nOffset-1, pData)

    def UpdateRange(nStart, nLength, pData)
        This.ValidateBuffer()
        
        if nStart < 0 or nLength < 0
            raise("ERROR: Negative start position or length not allowed")
        ok
        
        if nStart >= @nSize
            raise("ERROR: Start position beyond buffer size")
        ok
        
        if nStart + nLength > @nSize
            raise("ERROR: Range exceeds buffer size")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot update with null data")
        ok
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        # Replace the range with new data
        cNewBuffer = left(@buffer, nStart) + cData + right(@buffer, @nSize - (nStart + nLength))
        @buffer = cNewBuffer
        @nSize = len(@buffer)
        @nCapacity = max([@nCapacity, @nSize])

    def UpdateRange0(nStart, nLength, pData)
        This.UpdateRange(nStart, nLength, pData)

    def UpdateRange1(nStart, nLength, pData)
        This.UpdateRange(nStart-1, nLength, pData)

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
        
        nLength = nEnd - nStart + 1
        This.UpdateRange(nStart, nLength, pData)

    def UpdateSection0(nStart, nEnd, pData)
        This.UpdateSection(nStart, nEnd, pData)

    def UpdateSection1(nStart, nEnd, pData)
        This.UpdateSection(nStart-1, nEnd-1, pData)

    #-----------------------#
    #  READING AND SLICING  #
    #-----------------------#

    def Read(nOffset, nLength)
        This.ValidateBuffer()
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset (" + nOffset + ") or length (" + nLength + ") not allowed")
        ok
        
        if @nSize = 0
            raise("ERROR: Cannot read from empty buffer (size=0)")
        ok
        
        if nOffset >= @nSize
            raise("ERROR: Offset (" + nOffset + ") beyond buffer size (" + @nSize + ")")
        ok
        
        if nOffset + nLength > @nSize
            raise("ERROR: Read request (offset:" + nOffset + " + length:" + nLength + 
                  ") exceeds buffer size (" + @nSize + ")")
        ok
        
        if nLength = 0
            ? "WARNING: Reading zero bytes - returning empty string"
            return ""
        ok
        
        # SAFEGUARD: Validate buffer integrity before read
        if len(@buffer) != @nSize
            raise("CRITICAL ERROR: Buffer corruption detected - internal size mismatch")
        ok
        
        if nOffset = 0
            return left(@buffer, nLength)
        else
            cTemp = right(@buffer, @nSize - nOffset)
            return left(cTemp, nLength)
        ok

    def Read1(nOffset, nLength) # Ring 1-based index
        return This.Read(nOffset-1, nLength)

    def Slice(nOffset, nLength) # Range() in Softanza semantics, uses 0-index
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
        
        return This.Read(nOffset, nLength)

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
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        @buffer = cData + @buffer
        @nSize += len(cData)
        @nCapacity = len(@buffer)

    def Insert(nOffset, pData) # Uses low level 0-index by default
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

    def Insert0(nOffset, pData)
        This.Insert(nOffset, pData)

    def InsertAt(nPos, pData)
        This.Insert(nPos, pData)

    def Insert1(nOffset, pData) # Uses Ring 1-index
        This.Insert(nOffset-1, pData)

    def InsertAt1(nOffset, pData)
        This.Insert1(nOffset, pData)

    def Remove(nOffset, nLength) # Uses lowlevel 0-Index
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

    def Remove0(nOffset, nLength)
        This.Remove(nOffset, nLength)

    def RemoveRange(nStart, nLength)
        This.Remove(nStart, nLength)

    def RemoveRange0(nStart, nLength)
        This.Remove(nStart, nLength)

    def Remove1(nOffset, nLength) # Uses Ring highlevel 1-index
        This.Remove(nOffset-1, nLength)

    def RemoveRange1(nStart, nLength)
        This.Remove(nStart-1, nLength)

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
        
        nLength = nEnd - nStart + 1
        This.Remove(nStart, nLength)

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
        nResult = This.IndexOf(pPattern)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    def FindFirst1(pPattern) # Idem
        return This.IndexOf1(pPattern)

    def IndexOfXT(pPattern, nStartOffset) # Uses lowlevel 0-index
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

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

    def IndexOfXT1(pPattern, nStartOffset) # Uses highlevel Ring 1-index
        nResult = This.IndexOfXT(pPattern, nStartOffset)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    def FindFirstXT1(pPattern, nStartOffset) # Idem
        return This.IndexOfXT1(pPattern, nStartOffset)

    def IndexOfN(pPattern, nStartOffset)
        return This.IndexOfXT(pPattern, nStartOffset)

    def FindFirstN(pPattern, nStartOffset)
        return This.IndexOfXT(pPattern, nStartOffset)

    def IndexOfN0(pPattern, nStartOffset)
        return This.IndexOfN(pPattern, nStartOffset)

    def FindFirstN0(pPattern, nStartOffset)
        return This.IndexOfN(pPattern, nStartOffset)

    def IndexOfN1(pPattern, nStartOffset)
        nResult = This.IndexOfN(pPattern, nStartOffset)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    def FindFirstN1(pPattern, nStartOffset)
        return This.IndexOfN1(pPattern, nStartOffset)

    #------------------------------#
    #  BUFFER MANAGEMENT METHODS   #
    #------------------------------#

    def Resize(nNewSize)
        This.ValidateBuffer()
        
        if nNewSize <= 0
            raise("New size must be positive")
        ok
        
        cNewBuffer = ""
        
        if nNewSize > len(@buffer)
            # Extend with null bytes, not spaces
            cNewBuffer = @buffer + @copy(char(0), nNewSize - len(@buffer))
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

    def Clear()
        @buffer = ""  # Empty buffer, not spaces
        @nSize = 0

	def Fill(nByte, nStartPos, nLength)
		# Fill buffer with a specific byte value (0-255)
		# This method must support full byte range including null bytes (0)
		# for binary data, network packets, and C library interoperability
		
		if nByte < 0 or nByte > 255
			raise("ERROR: Byte value must be between 0 and 255")
		ok
		
		if nLength <= 0
			raise("ERROR: Length must be positive")
		ok
		
		# Create string of repeated byte character
		cFillData = @copy(char(nByte), nLength)
		
		# Use existing Write() method (now supports null bytes)
		This.Write(nStartPos, cFillData)


    def Compact()
        if @nSize < @nCapacity and @nSize > 0
            This.Resize(@nSize)
        ok

    def Copy()
        # Copies data to a new buffer
        # and return it (as a stkBuffer object), leaving the
        # current (source) buffer as is
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

    def GetPointer(nOffset) # An internal method, for better semantics, use methods that follow

		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0 or nOffset >= @nSize
            raise("Invalid offset for pointer")
        ok

        cSliceData = right(@buffer, @nSize - nOffset)
        return new stkPointer([cSliceData, "string", len(cSliceData)+1])

    def SliceToPointer(nOffset, nLength)
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        oTempBuffer = new stkBuffer(This.Slice(nOffset, nLength))
        return oTempBuffer.GetPointer(0)

    def RangeToPointer(nOffset, nLength)
        return This.SliceToPointer(nOffset, nLength)

    def SliceToPointer0(nOffset, nLength)
        return This.SliceToPointer(nOffset, nLength)

    def RangeToPointer0(nOffset, nLength)
        return This.SliceToPointer(nOffset, nLength)

    def SliceToPointer1(nOffset, nLength)
        return This.SliceToPointer(nOffset-1, nLength)

    def RangeToPointer1(nOffset, nLength)
        return This.SliceToPointer(nOffset-1, nLength)

    def SectionToPointer(nOffset, nLength)
		if This.IsValid() = FALSE
			raise("Invalid buffer - buffer was not properly initialized.")
		ok

        oTempBuffer = new stkBuffer(This.Section(nOffset, nLength))
        return oTempBuffer.GetPointer(0)

    def SectionToPointer0(nOffset, nLength)
        return This.SectionToPointer(nOffset, nLength)

    def SectionToPointer1(nOffset, nLength)
        return This.SectionToPointer(nOffset-1, nLength-1)

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
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Initialize buffer with file content
        This.InitWithData(cFileContent)
        
		# For debug (comment it)
        //? "INFO: Successfully loaded " + len(cFileContent) + " bytes from '" + cFileName + "'"

    def LoadFromFileXT(cFileName, nOffset, nLength)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0
            raise("ERROR: Negative offset (" + nOffset + ") not allowed")
        ok
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read entire file first
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        nFileSize = len(cFileContent)
        
        if nOffset >= nFileSize
            raise("ERROR: Offset (" + nOffset + ") beyond file size (" + nFileSize + ")")
        ok
        
        # Determine length to read
        if IsNull(nLength)
            nLength = nFileSize - nOffset
        ok
        
        if nLength < 0
            raise("ERROR: Negative length (" + nLength + ") not allowed")
        ok
        
        if nOffset + nLength > nFileSize
            raise("ERROR: Read request (offset:" + nOffset + " + length:" + nLength + 
                  ") exceeds file size (" + nFileSize + ")")
        ok
        
        # Extract the requested portion
        cData = ""
        if nOffset = 0
            cData = left(cFileContent, nLength)
        else
            cTemp = right(cFileContent, nFileSize - nOffset)
            cData = left(cTemp, nLength)
        ok
        
        # Initialize buffer with extracted data
        This.InitWithData(cData)
        
		# For debug (comment it)
        // ? "INFO: Successfully loaded " + len(cData) + " bytes (offset:" + nOffset + 
          ", length:" + nLength + ") from '" + cFileName + "'"

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
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Append to existing buffer
        This.Append(cFileContent)
        
		# For debug (comment it)
        // ? "INFO: Successfully appended " + len(cFileContent) + " bytes from '" + cFileName + "'"

    def AppendFromFileXT(cFileName, nOffset, nLength)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0
            raise("ERROR: Negative offset (" + nOffset + ") not allowed")
        ok
        
        # Check if file exists
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        # Read entire file first
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        nFileSize = len(cFileContent)
        
        if nOffset >= nFileSize
            raise("ERROR: Offset (" + nOffset + ") beyond file size (" + nFileSize + ")")
        ok
        
        # Determine length to read
        if IsNull(nLength)
            nLength = nFileSize - nOffset
        ok
        
        if nLength < 0
            raise("ERROR: Negative length (" + nLength + ") not allowed")
        ok
        
        if nOffset + nLength > nFileSize
            raise("ERROR: Read request (offset:" + nOffset + " + length:" + nLength + 
                  ") exceeds file size (" + nFileSize + ")")
        ok
        
        # Extract the requested portion
        cData = ""
        if nOffset = 0
            cData = left(cFileContent, nLength)
        else
            cTemp = right(cFileContent, nFileSize - nOffset)
            cData = left(cTemp, nLength)
        ok
        
        # Append to existing buffer
        This.Append(cData)

		# For debug (comment it)
        // ? "INFO: Successfully appended " + len(cData) + " bytes (offset:" + nOffset + 
          ", length:" + nLength + ") from '" + cFileName + "'"


    def SaveToFile(cFileName, nOffset, nLength)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if len(cFileName) = 0
            raise("ERROR: Empty filename not allowed")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nSize - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset (" + nOffset + ") or length (" + nLength + ") not allowed")
        ok
        
        if @nSize = 0
            raise("ERROR: Cannot save from empty buffer")
        ok
        
        if nOffset >= @nSize
            raise("ERROR: Offset (" + nOffset + ") beyond buffer size (" + @nSize + ")")
        ok
        
        if nOffset + nLength > @nSize
            raise("ERROR: Save request (offset:" + nOffset + " + length:" + nLength + 
                  ") exceeds buffer size (" + @nSize + ")")
        ok
        
        # Read data from buffer
        cData = This.Read(nOffset, nLength)
        
        # Write to file
        ring_write(cFileName, cData)

		# For debug (comment it)
         ? "INFO: Successfully saved " + len(cData) + " bytes to '" + cFileName + "'"

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
        
        nActualLen = len(@buffer)
        if nActualLen != @nSize and @nSize > 0
			# A warning for debugging
            # ? "WARNING: Buffer size mismatch - expected:" + @nSize + " actual:" + nActualLen
            @nSize = nActualLen  # Auto-correct minor discrepancies
        ok
