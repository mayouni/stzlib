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
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        @buffer = cData
        @nSize = len(cData)
        @nCapacity = max([@nCapacity, @nSize])

    #------------------------#
    #  WRITING AND UPDATING  #
    #------------------------#

	def Write(nOffset, pData)
	    if nOffset < 0
	        raise("ERROR: Negative offset not allowed")
	    ok
	    cData = ""
	    if IsString(pData)
	        cData = pData
	    else
	        cData = string(pData)
	    ok
	    nLenData = len(cData)
//	    ? "DEBUG: nLenData = " + nLenData
	    if nLenData = 0
//	        ? "WARNING: Writing empty data - no changes made"
	        return
	    ok
//	    ? "DEBUG: About to write data, current buffer size: " + @nSize
	    nRequiredSize = nOffset + nLenData
//	    ? "DEBUG: nRequiredSize = " + nRequiredSize + ", capacity = " + @nCapacity
	    if nRequiredSize > @nCapacity
	        @nCapacity = nRequiredSize
	    ok
	    cNewBuffer = ""
	    nLenBuffer = len(@buffer)
//	    ? "DEBUG: nLenBuffer = " + nLenBuffer + ", nOffset = " + nOffset
	    if nOffset >= nLenBuffer
//	        ? "DEBUG: Taking first branch (nOffset >= nLenBuffer)"
	        cNewBuffer = @buffer
	        if nOffset > nLenBuffer
//	            ? "DEBUG: Adding padding of " + (nOffset - nLenBuffer) + " bytes"
	            cNewBuffer += @copy(char(0), nOffset - nLenBuffer)
	        ok
	        cNewBuffer += cData
//	        ? "DEBUG: After adding data, cNewBuffer length = " + len(cNewBuffer)
	    else
//	        ? "DEBUG: Taking second branch (nOffset < nLenBuffer)"
	        cNewBuffer = left(@buffer, nOffset) + cData
	        nEndPos = nOffset + nLenData
	        if nEndPos < nLenBuffer
	            cNewBuffer += right(@buffer, nLenBuffer - nEndPos)
	        ok
//	        ? "DEBUG: After building, cNewBuffer length = " + len(cNewBuffer)
	    ok
	    @buffer = cNewBuffer
	    @nSize = len(@buffer)
//	    ? "DEBUG: Final buffer size: " + @nSize + ", buffer content: '" + @buffer + "'"
	

    def Write0(nOffset, pData)
        This.Write(nOffset, pData)

    def Write1(nOffset, pData)
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
 ? "DEBUG Read: @nSize = " + @nSize + ", nOffset = " + nOffset + ", nLength = " + nLength

        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset (" + nOffset + ") or length (" + nLength + ") not allowed")
        ok
        
        if @nSize = 0
       ? "DEBUG: Buffer is empty, @buffer = '" + @buffer + "'"
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
        
        # Buffer integrity check
        if len(@buffer) != @nSize
            raise("CRITICAL ERROR: Buffer corruption detected - internal size mismatch")
        ok
        
        if nOffset = 0
            return left(@buffer, nLength)
        else
            cTemp = right(@buffer, @nSize - nOffset)
            return left(cTemp, nLength)
        ok

    def Read1(nOffset, nLength)
        return This.Read(nOffset-1, nLength)

    def Slice(nOffset, nLength)
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nSize - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nSize
            raise("ERROR: Slice beyond buffer size")
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
        
        cData = ""
        if IsString(pData)
            cData = pData
        else
            cData = string(pData)
        ok
        
        @buffer = cData + @buffer
        @nSize += len(cData)
        @nCapacity = max([@nCapacity, @nSize])

    def Insert(nOffset, pData)
        if nOffset < 0 or nOffset > @nSize
            raise("ERROR: Invalid offset for insertion")
        ok
        
        if IsNull(pData)
            raise("ERROR: Cannot insert null data")
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
        @nCapacity = max([@nCapacity, @nSize])

    def Insert0(nOffset, pData)
        This.Insert(nOffset, pData)

    def Insert1(nOffset, pData)
        This.Insert(nOffset-1, pData)

    def Remove(nOffset, nLength)
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if nOffset + nLength > @nSize
            raise("ERROR: Cannot remove beyond buffer size")
        ok
        
        if nLength = 0
            return
        ok
        
        @buffer = left(@buffer, nOffset) + right(@buffer, len(@buffer) - (nOffset + nLength))
        @nSize -= nLength
        @nCapacity = max([@nCapacity, @nSize])

    def Remove0(nOffset, nLength)
        This.Remove(nOffset, nLength)

    def Remove1(nOffset, nLength)
        This.Remove(nOffset-1, nLength)

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

    def IndexOf(pPattern)
        if isList(pPattern) and len(pPattern) = 2
            return This.IndexOfXT(pPattern[1], pPattern[2])
        ok
        return This.IndexOfXT(pPattern, 0)

    def IndexOf0(pPattern)
        return This.IndexOf(pPattern)

    def IndexOf1(pPattern)
        nResult = This.IndexOf(pPattern)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    def IndexOfXT(pPattern, nStartOffset)
        This.ValidateBuffer()
        
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

    def IndexOfXT0(pPattern, nStartOffset)
        return This.IndexOfXT(pPattern, nStartOffset)

    def IndexOfXT1(pPattern, nStartOffset)
        nResult = This.IndexOfXT(pPattern, nStartOffset)
        if nResult = -1
            return 0  # Ring convention: 0 means not found
        else
            return nResult + 1
        ok

    #------------------------------#
    #  BUFFER MANAGEMENT METHODS   #
    #------------------------------#

    def Resize(nNewSize)
        This.ValidateBuffer()
        
        if nNewSize <= 0
            raise("ERROR: New size must be positive")
        ok
        
        cNewBuffer = ""
        
        if nNewSize > len(@buffer)
            # Extend with null bytes
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
        @buffer = ""
        @nSize = 0

    def Fill(nByte, nStartPos, nLength)
        This.ValidateBuffer()
        
        if nByte < 0 or nByte > 255
            raise("ERROR: Byte value must be between 0 and 255")
        ok
        
        if nLength <= 0
            raise("ERROR: Length must be positive")
        ok
        
        # Create string of repeated byte character
        cFillData = @copy(char(nByte), nLength)
        
        # Use existing Write() method
        This.Write(nStartPos, cFillData)

    def Compact()
        if @nSize < @nCapacity and @nSize > 0
            This.Resize(@nSize)
        ok

    def Copy()
	    # Create new buffer through our memory container
	    oNewBuffer = @oMemory.CreateBuffer(@nSize)
	    
	    if @nSize > 0
	        oNewBuffer.Write(0, This.Read(0, @nSize))
	    ok
	    
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
        
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        # Replace buffer content with file content
        This.InitWithData(cFileContent)

    def LoadFromFileXT(cFileName, nOffset, nLength)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if nOffset < 0
            raise("ERROR: Negative offset (" + nOffset + ") not allowed")
        ok
        
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        nFileSize = len(cFileContent)
        
        if nOffset >= nFileSize
            raise("ERROR: Offset (" + nOffset + ") beyond file size (" + nFileSize + ")")
        ok
        
        if IsNull(nLength)
            nLength = nFileSize - nOffset
        ok
        
        if nLength < 0
            raise("ERROR: Negative length (" + nLength + ") not allowed")
        ok
        
        if nOffset + nLength > nFileSize
            raise("ERROR: Read request exceeds file size")
        ok
        
        # Extract requested portion
        cData = ""
        if nOffset = 0
            cData = left(cFileContent, nLength)
        else
            cTemp = right(cFileContent, nFileSize - nOffset)
            cData = left(cTemp, nLength)
        ok
        
        # Replace buffer content with extracted data
        This.InitWithData(cData)

    def AppendFromFile(cFileName)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if not fexists(cFileName)
            raise("ERROR: File '" + cFileName + "' does not exist")
        ok
        
        cFileContent = ring_read(cFileName)
        
        if IsNull(cFileContent)
            raise("ERROR: Failed to read file '" + cFileName + "'")
        ok
        
        This.Append(cFileContent)

    def SaveToFile(cFileName, nOffset, nLength)
        This.ValidateBuffer()
        
        if IsNull(cFileName) or not IsString(cFileName)
            raise("ERROR: Invalid filename - must be a non-null string")
        ok
        
        if IsNull(nOffset)
            nOffset = 0
        ok
        
        if IsNull(nLength)
            nLength = @nSize - nOffset
        ok
        
        if nOffset < 0 or nLength < 0
            raise("ERROR: Negative offset or length not allowed")
        ok
        
        if @nSize = 0
            raise("ERROR: Cannot save from empty buffer")
        ok
        
        if nOffset >= @nSize
            raise("ERROR: Offset beyond buffer size")
        ok
        
        if nOffset + nLength > @nSize
            raise("ERROR: Save request exceeds buffer size")
        ok
        
        # Read data from buffer
        cData = This.Read(nOffset, nLength)
        
        # Write to file
        ring_write(cFileName, cData)

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
        
        nActualLen = len(@buffer)
        if nActualLen != @nSize and @nSize > 0
            @nSize = nActualLen  # Auto-correct minor discrepancies
        ok
