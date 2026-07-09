
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
	    
	    _cBufferId_ = "buf" + @nNextBufferId
	    @nNextBufferId++
	    
	    _oBuffer_ = new stkBuffer(This, _cBufferId_, nSize)
//	    ? "DEBUG CreateBuffer: Created buffer with ID " + cBufferId + " and size " + oBuffer.Size()
	    
	    @aBuffers + [_cBufferId_, _oBuffer_]
//	    ? "DEBUG CreateBuffer: Buffer stored in hashlist with size " + @aBuffers[cBufferId].Size()
	    
	    return TRUE


	def NumberOfBuffers()
		return len(@aBuffers)
	
	def CreatePointer(_cBufferId_, cAccessMode)

		_oBuffer_ = @aBuffers[_cBufferId_]
		if IsNull(_oBuffer_)
	        raise("Invalid buffer ID (" + _cBufferId_ + ")")
	    ok

	    if NoT ( cAccessMode = "read" or cAccessMode = "write" )
	        raise("Access mode must be 'read' or 'write'")
	    ok

	    if cAccessMode = "write" and _oBuffer_.HasWritePointer()
	        raise("Buffer already has a write pointer")
	    ok
	    
	    # Add the pointer to the @aPointers container

	    _cPointerId_ = "ptr" + @nNextPointerId
	    @nNextPointerId++
	    _oPointer_ = new stkPointer(This, _cBufferId_, cAccessMode, 0, _oBuffer_.Capacity(), _cPointerId_)
	    @aPointers + [ _cPointerId_, _oPointer_]

	    return TRUE
  

    def CreatePointerView(_cBufferId_, cAccessMode, nOffset, nLength)

	_oBuffer_ = @aBuffers[_cBufferId_]
	if IsNull(_oBuffer_)
            raise("Invalid buffer ID: " + _cBufferId_)
        ok
        
        # Validate view bounds
        if nOffset < 0 or nLength <= 0
            raise("Invalid view bounds")
        ok
        
        if (nOffset + nLength) > _oBuffer_.Size()
            raise("View extends beyond buffer bounds")
        ok
        
        # Check write access restrictions
        if cAccessMode = "write" and _oBuffer_.HasWritePointer()
            raise("Buffer already has a write pointer")
        ok
        
        # Create new stkPointer instance with view

	_cPointerId_ = "ptr" + @nNextPointerId
        _oPointer_ = new stkPointer(This, _cBufferId_, cAccessMode, nOffset, nLength, _cPointerId_)
        
        # Add to managed pointers
        @aPointers + [ _cPointerId_, _oPointer_ ]
        
        # Update buffer's write pointer status
        if cAccessMode = "write"
            _oBuffer_.ReleaseWritePointer()  # This will be called when pointer is destroyed
        ok
        
        # Increment ID for next pointer
        @nNextPointerId++
        
        return TRUE
 

	def ReadFromBuffer(_cBufferId_, nOffset, nLength)

	    _oBuffer_ = @aBuffers[_cBufferId_]
	    if IsNull(_oBuffer_)
	        raise("Buffer not found: " + _cBufferId_)
	    ok

	    return _oBuffer_.Read(nOffset, nLength)


    def GetBuffer(_cBufferId_)
        _oBuffer_ = @aBufferId[_cBufferId_]
		if IsNull(_oBuffer_)
			raise("Invalid buffer ID: " + _cBufferId_)
		ok

		return _oBuffer_
    

	def DestroyBuffer(_cBufferId_)
		_oBuffer_ = @aBuffers[_cBufferId_]
	    if IsNull(_oBuffer_)
	        return FALSE
	    ok
	    
	    # Invalidate all pointers to this buffer
		_nLenPtr_ = len(@aPointers)

	    for i = 1 to _nLenPtr_
	        if @aPointers[i].BufferId() = _cBufferId_
	            @aPointers[i].@bIsValid = FALSE  # Direct access to invalidate
	        ok
	    next
	    
	    # Remove buffer from hashlist
	    del(@aBuffers, This.FindBuffer(_cBufferId_))
	    
	    return TRUE

    def FindBuffer(_cBufferId_)
		_nLen_ = len(@aBuffers)
		for i = 1 to _nLen_
			if @aBuffers[i][1] = _cBufferId_
				return i
			ok
		next

		return 0

    def DestroyPointer(_cPointerId_)
		_oPointer_ = @aPointers[_cPointerId_]
        if IsNull(_oPointer_)
			return FALSE
		ok
         
        # If it is a write pointer, release the buffer's write lock
        if _oPointer_.AccessMode() = "write"
			_oBuffers_ = @aBuffers[_oPointer_.BufferId()]
            if not IsNull(_oBuffer_)
                _oBuffer_.ReleaseWritePointer()
            ok
        ok
        
        # Remove pointer from list
        del(@aPointers, This.FindPointer(_cPointerId_))

        return TRUE
    
    def FindPointer(_cPointerId_)
		_nLen_ = len(@aPointers)
		for i = 1 to _nLen_
			if @aPointers[i][1] = _cPointerId_
				return i
			ok
		next

		return 0

    def ValidatePointer(_cPointerId_)
		_oPointer_ = @aPointers[_cPointerId_]
        if IsNull(_oPointer_)
            return FALSE
        ok

        # Check if referenced buffer still exists
        return IsValidBufferId(_oPointer_.BufferId())


	def BufferInfo(_cBufferId_)
		_oBuffer_ = @aBuffers[_cBufferId_]
		if IsNull(_oBuffer_)
			return []
		ok
	    
	    return [
	        :id = _oBuffer_.Id(),
	        :size = _oBuffer_.Size(),
	        :capacity = _oBuffer_.Capacity(),
	        :hasWritePointer = _oBuffer_.HasWritePointer(),
	        :isValid = _oBuffer_.IsValid()
	    ]
    
    def PointerInfo(nPointerId)

        # Find pointer in list

	_nLen_ = len(@aPointers)

        for i = 1 to _nLen_
            _oPointer_ = @aPointers[i]
            if _oPointer_.PointerId() = nPointerId
                return _oPointer_.Info()
            ok
        next
        
        return NULL
    

	def Stats()

	    _aStats_ = [
	        :totalBuffers = _nLenBuf_,
	        :totalPointers = _nLenPtr_,
	        :validPointers = 0,
	        :readPointers = 0,
	        :writePointers = 0,
	        :totalMemory = 0
	    ]

		_nLenBuf_ = len(@aBuffers)
		_nLenPtr_ = len(@aPointers)
	    
	    # Count valid pointers (unchanged)
	    for i = 1 to _nLenPtr_
	        _oPointer_ = @aPointers[i]
	        if _oPointer_.IsValid()
	            _aStats_[:validPointers]++
	            if _oPointer_.AccessMode() = "read"
	                _aStats_[:readPointers]++
	            else
	                _aStats_[:writePointers]++
	            ok
	        ok
	    next
	    
	    # Calculate total memory using hashlist
	    for i = 1 to _nLenBuf_
	        _oBuffer_ = @aBuffers[i][2]  # Get buffer object from hashlist pair
	        _aStats_[:totalMemory] += _oBuffer_.Size()
	    next
	    
	    return _aStats_
    

    def IsValid()
        return @bIsValid
    
    def Show()

	_nLenBuf_ = len(@aBuffers)
	_nLenPtr_ = len(@aPointers)

  	  ? "stkMemory Container:"
	    ? "  Valid: " + @bIsValid
	    ? "  Buffers: " + _nLenBuf_
	    ? "  Pointers: " + _nLenPtr_
	    ? "  Next Buffer ID: " + @nNextBufferId
	    ? "  Next Pointer ID: " + @nNextPointerId
	    
	    if _nLenBuf_ > 0
	        ? "  Buffer Details:"
	        for i = 1 to _nLenBuf_
	            _cBufferId_ = @aBuffers[i][1]
	            _oBuffer_ = @aBuffers[i][2]
	            ? "    ID:" + _cBufferId_ + " Size:" + _oBuffer_.Size() + " WritePtr:" + _oBuffer_.HasWritePointer()
	        next
	    ok
        
        if _nLenPtr_ > 0
            ? "  Pointer Details:"
            for i = 1 to _nLenPtr_
                _oPointer_ = @aPointers[i]
                ? "    ID:" + _oPointer_.PointerId() + " Buffer:" + _oPointer_.BufferId() + " Mode:" + _oPointer_.AccessMode() + " Valid:" + _oPointer_.IsValid()
            next
        ok
    
    def CleanupInvalidPointers()

        # Remove invalid pointers from array

	_nLenPtr_ = len(@aPointers)
        _aValidPointers_ = []

        for i = 1 to _nLenPtr_
            if @aPointers[i].IsValid()
                _aValidPointers_ + @aPointers[i]
            ok
        next

        @aPointers = _aValidPointers_


	def DestroyAllBuffers()

	    # Destroy all buffers (will invalidate all pointers)

	    _nLenBuf_ = len(@aBuffers)

	    for i = 1 to nLenBuff
	        _cBufferId_ = @aBuffers[i][1]
	       This.DestroyBuffer(_cBufferId_)
	    next

	    @aBuffers = []
    

    def DestroyAllPointers()

        # Destroy all pointers

	_nLenPtr_ = len(@aPointers)

        for i = 1 to _nLenPtr_
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
    
	def IsValidBuffer(_oBuffer_)
		if NOT (isObject(_oBuffer_) and classname(_oBuffer_) = "stkbuffer")
			return  FALSE
		ok

		return This.IsValidBufferId(_oBuffer_.Id())

	def IsValidBufferId(_cBufferId_)
	    return HasKey(@aBuffers[_cBufferId_]) #TODO #WARNING // HasKey() belongs to the base layer!
    
