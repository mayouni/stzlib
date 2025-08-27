
class stkMemory
    @bIsValid = TRUE
    @aBuffers = []           # Hashlist format: [["buf1", oBuffer1], ["buf2", oBuffer2], ...]
    @aPointers = []          # Hashlist format: [["ptr1", oPointer1], ["ptr2", oPointer2], ...]
    @nNextBufferId = 1       # Unique ID generator
    @nNextPointerId = 1      # Unique pointer ID generator
    
    def init()
        # Initialize container
        @aBuffers = []
        @aPointers = []
        @nNextBufferId = 1
        @nNextPointerId = 1
        @bIsValid = TRUE


	def CreateBuffer(nSize)

	    if nSize <= 0
	        raise("Buffer size must be positive")
	    ok
	    
	    cBufferId = "buf" + @nNextBufferId
	    @nNextBufferId++
	    
	    oBuffer = new stkBuffer(This, cBufferId, nSize)
//	    ? "DEBUG CreateBuffer: Created buffer with ID " + cBufferId + " and size " + oBuffer.Size()
	    
	    @aBuffers + [cBufferId, oBuffer]
//	    ? "DEBUG CreateBuffer: Buffer stored in hashlist with size " + @aBuffers[cBufferId].Size()
	    
	    return TRUE


	def NumberOfBuffers()
		return len(@aBuffers)
	
	def CreatePointer(cBufferId, cAccessMode)

		oBuffer = @aBuffers[cBufferId]
		if IsNull(oBuffer)
	        raise("Invalid buffer ID (" + cBufferId + ")")
	    ok

	    if NoT ( cAccessMode = "read" or cAccessMode = "write" )
	        raise("Access mode must be 'read' or 'write'")
	    ok

	    if cAccessMode = "write" and oBuffer.HasWritePointer()
	        raise("Buffer already has a write pointer")
	    ok
	    
	    # Add the pointer to the @aPointers container

	    cPointerId = "ptr" + @nNextPointerId
	    @nNextPointerId++
	    oPointer = new stkPointer(This, cBufferId, cAccessMode, 0, oBuffer.Capacity(), cPointerId)
	    @aPointers + [ cPointerId, oPointer]

	    return TRUE
  

    def CreatePointerView(cBufferId, cAccessMode, nOffset, nLength)

	oBuffer = @aBuffers[cBufferId]
	if IsNull(oBuffer)
            raise("Invalid buffer ID: " + cBufferId)
        ok
        
        # Validate view bounds
        if nOffset < 0 or nLength <= 0
            raise("Invalid view bounds")
        ok
        
        if (nOffset + nLength) > oBuffer.Size()
            raise("View extends beyond buffer bounds")
        ok
        
        # Check write access restrictions
        if cAccessMode = "write" and oBuffer.HasWritePointer()
            raise("Buffer already has a write pointer")
        ok
        
        # Create new stkPointer instance with view

	cPointerId = "ptr" + @nNextPointerId
        oPointer = new stkPointer(This, cBufferId, cAccessMode, nOffset, nLength, cPointerId)
        
        # Add to managed pointers
        @aPointers + [ cPointerId, oPointer ]
        
        # Update buffer's write pointer status
        if cAccessMode = "write"
            oBuffer.ReleaseWritePointer()  # This will be called when pointer is destroyed
        ok
        
        # Increment ID for next pointer
        @nNextPointerId++
        
        return TRUE
 

	def ReadFromBuffer(cBufferId, nOffset, nLength)

	    oBuffer = @aBuffers[cBufferId]
	    if IsNull(oBuffer)
	        raise("Buffer not found: " + cBufferId)
	    ok

	    return oBuffer.Read(nOffset, nLength)


    def GetBuffer(cBufferId)
        oBuffer = @aBufferId[cBufferId]
		if IsNull(oBuffer)
			raise("Invalid buffer ID: " + cBufferId)
		ok

		return oBuffer
    

	def DestroyBuffer(cBufferId)
		oBuffer = @aBuffers[cBufferId]
	    if IsNull(oBuffer)
	        return FALSE
	    ok
	    
	    # Invalidate all pointers to this buffer
		nLenPtr = len(@aPointers)

	    for i = 1 to nLenPtr
	        if @aPointers[i].BufferId() = cBufferId
	            @aPointers[i].@bIsValid = FALSE  # Direct access to invalidate
	        ok
	    next
	    
	    # Remove buffer from hashlist
	    del(@aBuffers, This.FindBuffer(cBufferId))
	    
	    return TRUE

    def FindBuffer(cBufferId)
		nLen = len(@aBuffers)
		for i = 1 to nLen
			if @aBuffers[i][1] = cBufferId
				return i
			ok
		next

		return 0

    def DestroyPointer(cPointerId)
		oPointer = @aPointers[cPointerId]
        if IsNull(oPointer)
			return FALSE
		ok
         
        # If it is a write pointer, release the buffer's write lock
        if oPointer.AccessMode() = "write"
			oBuffers = @aBuffers[oPointer.BufferId()]
            if not IsNull(oBuffer)
                oBuffer.ReleaseWritePointer()
            ok
        ok
        
        # Remove pointer from list
        del(@aPointers, This.FindPointer(cPointerId))

        return TRUE
    
    def FindPointer(cPointerId)
		nLen = len(@aPointers)
		for i = 1 to nLen
			if @aPointers[i][1] = cPointerId
				return i
			ok
		next

		return 0

    def ValidatePointer(cPointerId)
		oPointer = @aPointers[cPointerId]
        if IsNull(oPointer)
            return FALSE
        ok

        # Check if referenced buffer still exists
        return IsValidBufferId(oPointer.BufferId())


	def BufferInfo(cBufferId)
		oBuffer = @aBuffers[cBufferId]
		if IsNull(obuffer)
			return []
		ok
	    
	    return [
	        :id = oBuffer.Id(),
	        :size = oBuffer.Size(),
	        :capacity = oBuffer.Capacity(),
	        :hasWritePointer = oBuffer.HasWritePointer(),
	        :isValid = oBuffer.IsValid()
	    ]
    
    def PointerInfo(nPointerId)

        # Find pointer in list

	nLen = len(@aPointers)

        for i = 1 to nLen
            oPointer = @aPointers[i]
            if oPointer.PointerId() = nPointerId
                return oPointer.Info()
            ok
        next
        
        return NULL
    

	def Stats()

	    aStats = [
	        :totalBuffers = nLenBuf,
	        :totalPointers = nLenPtr,
	        :validPointers = 0,
	        :readPointers = 0,
	        :writePointers = 0,
	        :totalMemory = 0
	    ]

		nLenBuf = len(@aBuffers)
		nLenPtr = len(@aPointers)
	    
	    # Count valid pointers (unchanged)
	    for i = 1 to nLenPtr
	        oPointer = @aPointers[i]
	        if oPointer.IsValid()
	            aStats[:validPointers]++
	            if oPointer.AccessMode() = "read"
	                aStats[:readPointers]++
	            else
	                aStats[:writePointers]++
	            ok
	        ok
	    next
	    
	    # Calculate total memory using hashlist
	    for i = 1 to nLenBuf
	        oBuffer = @aBuffers[i][2]  # Get buffer object from hashlist pair
	        aStats[:totalMemory] += oBuffer.Size()
	    next
	    
	    return aStats
    

    def IsValid()
        return @bIsValid
    
    def Show()

	nLenBuf = len(@aBuffers)
	nLenPtr = len(@aPointers)

  	  ? "stkMemory Container:"
	    ? "  Valid: " + @bIsValid
	    ? "  Buffers: " + nLenBuf
	    ? "  Pointers: " + nLenPtr
	    ? "  Next Buffer ID: " + @nNextBufferId
	    ? "  Next Pointer ID: " + @nNextPointerId
	    
	    if nLenBuf > 0
	        ? "  Buffer Details:"
	        for i = 1 to nLenBuf
	            cBufferId = @aBuffers[i][1]
	            oBuffer = @aBuffers[i][2]
	            ? "    ID:" + cBufferId + " Size:" + oBuffer.Size() + " WritePtr:" + oBuffer.HasWritePointer()
	        next
	    ok
        
        if nLenPtr > 0
            ? "  Pointer Details:"
            for i = 1 to nLenPtr
                oPointer = @aPointers[i]
                ? "    ID:" + oPointer.PointerId() + " Buffer:" + oPointer.BufferId() + " Mode:" + oPointer.AccessMode() + " Valid:" + oPointer.IsValid()
            next
        ok
    
    def CleanupInvalidPointers()

        # Remove invalid pointers from array

	nLenPtr = len(@aPointers)
        aValidPointers = []

        for i = 1 to nLenPtr
            if @aPointers[i].IsValid()
                aValidPointers + @aPointers[i]
            ok
        next

        @aPointers = aValidPointers


	def DestroyAllBuffers()

	    # Destroy all buffers (will invalidate all pointers)

	    nLenBuf = len(@aBuffers)

	    for i = 1 to nLenBuff
	        cBufferId = @aBuffers[i][1]
	       This.DestroyBuffer(cBufferId)
	    next

	    @aBuffers = []
    

    def DestroyAllPointers()

        # Destroy all pointers

	nLenPtr = len(@aPointers)

        for i = 1 to nLenPtr
            This.DestroyPointer(@aPointers[i].PointerId())
        next

        @aPointers = []
    
    def Free()
        This.DestroyAllPointers()
        This.DestroyAllBuffers()
        @bIsValid = FALSE
    
    		def Destroy()
       		 This.Free()
    
	#----
    
	def IsValidBuffer(oBuffer)
		if NOT (isObject(oBuffer) and classname(oBuffer) = "stkbuffer")
			return  FALSE
		ok

		return This.IsValidBufferId(oBuffer.Id())

	def IsValidBufferId(cBufferId)
	    return @aBuffers[cBufferId] != ""
    
