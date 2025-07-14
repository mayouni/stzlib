
class stkMemory
    @bIsValid = TRUE
    @aBuffers = []           # Hashlist format: [["id1", oBuffer1], ["id2", oBuffer2], ...]
    @aPointers = []          # Array of all active pointers
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
	    
	    return oBuffer


	def NumberOfBuffers()
		return len(@aBuffers)
	
	def CreatePointer(cBufferId, cAccessMode)

		oBuffer = @aBuffers[cBufferId]
		if IsNull(oBuffer)
	        raise("Invalid buffer ID (" + cBufferId + ")")
	    ok

	    if cAccessMode != "read" and cAccessMode != "write"
	        raise("Access mode must be 'read' or 'write'")
	    ok

	    if cAccessMode = "write" and oBuffer.HasWritePointer()
	        raise("Buffer already has a write pointer")
	    ok
	    
	    # Add placeholder to array first to reserve the ID
	    cPointerId = "ptr" + @nNextPointerId
	    @nNextPointerId++
	    oPointer = new stkPointer(This, cBufferId, cAccessMode, 0, oBuffer.Capacity(), cPointerId)
	    @aPointers + [ cPointerId, oPointer]  # Simply append, don't add NULL first
	    return oPointer
  

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
        
        return oPointer
 

	def ReadFromBuffer(cBufferId, nOffset, nLength)

	    oBuffer = @aBuffers[cBufferId]
	    if IsNull(oBuffer)
	        raise("Buffer not found: " + cBufferId)
	    ok

	    return oBuffer.Read(nOffset, nLength)


    def GetBuffer(cBufferId)
        return GetBufferById(cBufferId)
    

	def DestroyBuffer(cBufferId)
		oBuffer = @aBuffers[cBufferId]
	    if IsNull(oBuffer)
	        return FALSE
	    ok
	    
	    # Invalidate all pointers to this buffer
	    for i = 1 to len(@aPointers)
	        oPointer = @aPointers[i]
	        if oPointer.BufferId() = cBufferId
	            oPointer.@bIsValid = FALSE  # Direct access to invalidate
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
         
        # If it's a write pointer, release the buffer's write lock
        if oPointer.AccessMode() = "write"
            oBuffer = GetBufferById(oPointer.BufferId())
            if not IsNull(oBuffer)
                oBuffer.ReleaseWritePointer()
            ok
        ok
        
        # Remove pointer from array
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


	def GetBufferInfo(cBufferId)
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
    
    def GetPointerInfo(nPointerId)
        # Find pointer in array
        for i = 1 to len(@aPointers)
            oPointer = @aPointers[i]
            if IsObject(oPointer) and oPointer.PointerId() = nPointerId
                return oPointer.Info()
            ok
        next
        
        return NULL
    

	def GetStats()
	    aStats = [
	        :totalBuffers = len(@aBuffers),
	        :totalPointers = len(@aPointers),
	        :validPointers = 0,
	        :readPointers = 0,
	        :writePointers = 0,
	        :totalMemory = 0
	    ]
	    
	    # Count valid pointers (unchanged)
	    for i = 1 to len(@aPointers)
	        oPointer = @aPointers[i]
	        if IsObject(oPointer) and oPointer.IsValid()
	            aStats[:validPointers]++
	            if oPointer.AccessMode() = "read"
	                aStats[:readPointers]++
	            else
	                aStats[:writePointers]++
	            ok
	        ok
	    next
	    
	    # Calculate total memory using hashlist
	    for i = 1 to len(@aBuffers)
	        oBuffer = @aBuffers[i][2]  # Get buffer object from hashlist pair
	        if IsObject(oBuffer)
	            aStats[:totalMemory] += oBuffer.Size()
	        ok
	    next
	    
	    return aStats
    
    def IsValid()
        return @bIsValid
    
    def Show()
  	  ? "stkMemory Container:"
	    ? "  Valid: " + @bIsValid
	    ? "  Buffers: " + len(@aBuffers)
	    ? "  Pointers: " + len(@aPointers)
	    ? "  Next Buffer ID: " + @nNextBufferId
	    ? "  Next Pointer ID: " + @nNextPointerId
	    
	    if len(@aBuffers) > 0
	        ? "  Buffer Details:"
	        for i = 1 to len(@aBuffers)
	            cBufferId = @aBuffers[i][1]
	            oBuffer = @aBuffers[i][2]
	            if IsObject(oBuffer)
	                ? "    ID:" + cBufferId + " Size:" + oBuffer.Size() + " WritePtr:" + oBuffer.HasWritePointer()
	            ok
	        next
	    ok
        
        if len(@aPointers) > 0
            ? "  Pointer Details:"
            for i = 1 to len(@aPointers)
                oPointer = @aPointers[i]
                if IsObject(oPointer)
                    ? "    ID:" + oPointer.PointerId() + " Buffer:" + oPointer.BufferId() + " Mode:" + oPointer.AccessMode() + " Valid:" + oPointer.IsValid()
                ok
            next
        ok
    
    def CleanupInvalidPointers()
        # Remove invalid pointers from array
        aValidPointers = []
        for i = 1 to len(@aPointers)
            oPointer = @aPointers[i]
            if IsObject(oPointer) and oPointer.IsValid()
                aValidPointers + oPointer
            ok
        next
        @aPointers = aValidPointers
    

	def DestroyAllBuffers()
	    # Destroy all buffers (will invalidate all pointers)
	    for i = 1 to len(@aBuffers)
	        cBufferId = @aBuffers[i][1]
	        oBuffer = @aBuffers[i][2]
	        if IsObject(oBuffer)
	            This.DestroyBuffer(cBufferId)
	        ok
	    next
	    @aBuffers = []
    

    def DestroyAllPointers()
        # Destroy all pointers
        for i = 1 to len(@aPointers)
            oPointer = @aPointers[i]
            if IsObject(oPointer)
                This.DestroyPointer(oPointer.PointerId())
            ok
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
		if NOT (isObject(obuffer) and classname(oBuffer) = "stkbuffer")
			return  FALSE
		ok

		return This.IsValidBufferId(oBuffer.Id())

	def IsValidBufferId(cBufferId)
	    return @aBuffers[cBufferId] != ""
    

	def GetBufferById(cBufferId)
//	    ? "Looking for buffer ID: " + cBufferId
	    oBuffer = @aBuffers[cBufferId]
	    
	    if oBuffer = ""
//	        ? "Buffer not found"
	        raise("ERROR: Buffer ID not found (" + cBufferId + ")")
	    ok
	    
//	    ? "Found buffer with size: " + oBuffer.Size()
//	    ? "DEBUG: Retrieved buffer size = " + oBuffer.Size() + ", content = '" + oBuffer.@buffer + "'"
	    return oBuffer
