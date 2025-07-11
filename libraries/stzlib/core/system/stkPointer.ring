# stkPointer.ring
# Simplified pointer abstraction for Softanza library

func StkPointerQ(pParams)
    return new stkPointer(pParams)

func StkStringPointerQ(cString, nBufferSize)
    if IsNull(nBufferSize) nBufferSize = len(cString) + 1 ok
    return new stkPointer([cString, "string", nBufferSize])


class stkPointer

    @pointer = NULL
    @buffer = NULL
    @cLogicalType = ""
    @nBufferSize = 0
    @bIsValid = FALSE
    @bIsManaged = FALSE
	@oMemory = NULL


	def init(pParams)
	    @oMemory = new stkMemory()
	    
	    if IsNull(pParams)
	        This.CreateNullPointer()
	    but isList(pParams) and len(pParams) >= 2
	        This.CreateFromParams(pParams)
	    else
	        This.CreateFromValue(pParams)
	    ok
	

    def CreateNullPointer()

        @pointer = nullpointer()
        @cLogicalType = "null"
        @bIsValid = TRUE
        @bIsManaged = FALSE


    def CreateFromParams(aParams)

        pValue = aParams[1]
        cType = aParams[2]
        nSize = 0

        if len(aParams) > 2
			nSize = aParams[3]
		ok
        
        This.CreateFromValue([ pValue, cType, nSize ])


    def CreateFromValue(pParams)

        pValue = NULL
        cType = NULL
        nSize = 0
        
        if isList(pParams) and len(pParams) >= 2

            pValue = pParams[1]
            cType = pParams[2]

            if len(pParams) > 2
				nSize = pParams[3]
			ok

        else
            pValue = pParams
            cType = This.DetectType(pValue)

        ok
        
        @cLogicalType = cType
        
        switch cType

            on "string"
                This.CreateStringPointer(pValue, nSize)

            on "int"
                This.CreateIntPointer(pValue)

            on "double"
                This.CreateDoublePointer(pValue)

            on "list"
                This.CreateObjectPointer(pValue)

            on "object"
                This.CreateObjectPointer(pValue)

            other
                raise("Unsupported type: " + cType)

        off
        
        @bIsValid = TRUE
        @bIsManaged = TRUE


	def CreateStringPointer(cString, nSize)
	    if nSize = 0
	        nSize = len(cString) + 1
	    ok
	    
	    @nBufferSize = nSize
	    
	    # Use memory allocation
	    @buffer = @oMemory.Allocate(nSize)
	    @oMemory.Set(@buffer, 0, nSize)  # Initialize with zeros
	    
	    # Copy string data
	    if len(cString) > 0
	        nCopySize = min([len(cString), nSize - 1])
	        for i = 1 to nCopySize
	            @buffer[i] = cString[i]
	        next
	    ok
	    
	    @pointer = varptr("@buffer", "char")


	def CreateIntPointer(nValue)
	    @buffer = @oMemory.Allocate(4)
	    @oMemory.Set(@buffer, 0, 4)
	    
	    # Store the integer value
	    @buffer = nValue
	    @pointer = varptr("@buffer", "int")
	    @nBufferSize = 4
	
	def CreateDoublePointer(nValue)
	    @buffer = @oMemory.Allocate(8)
	    @oMemory.Set(@buffer, 0, 8)
	    
	    # Store the double value
	    @buffer = nValue
	    @pointer = varptr("@buffer", "double")
	    @nBufferSize = 8


    def CreateObjectPointer(pObject)

		#NOTE // For objects, we don't need memory allocation since
		# Ring manages object memory automatically - we just store
		# the object reference directly and use object2pointer()
		# to get the pointer

        @buffer = pObject
        @pointer = object2pointer(pObject)
        @nBufferSize = -1


    def DetectType(pValue)

        if isString(pValue)
			return "string"

        but isNumber(pValue)

            if floor(pValue) = pValue
				return "int"
            else
				return "double"
			ok

        but isList(pValue)
			return "list"

		but isObject(pValue)
			return "object"

        else
			return "string"
		ok


    # Proper CopyFrom implementation

	def CopyFrom(pSource, nSize)
	    This.ValidatePointer()
	    
	    if IsNull(nSize)
	        nSize = @nBufferSize
	    ok
	    
	    # Get source data properly
	    cSourceData = ""
	    
	    if isObject(pSource) and classname(pSource) = "stkpointer"
	        cSourceData = pSource.RingValue()
	    else
	        cSourceData = pointer2string(pSource, 0, nSize)
	    ok
	    
	    # For string pointers, merge with existing buffer
	    if @cLogicalType = "string"
	        cCurrentBuffer = @buffer
	        cNewBuffer = ""
	        
	        # Copy specified bytes from source to beginning of buffer
	        for i = 1 to nSize
	            if i <= len(cSourceData)
	                cNewBuffer += cSourceData[i]
	            else
	                cNewBuffer += char(0)
	            ok
	        next
	        
	        # Append remaining original data after the copied portion
	        if len(cCurrentBuffer) > nSize
	            cNewBuffer += right(cCurrentBuffer, len(cCurrentBuffer) - nSize)
	        ok
	        
	        @buffer = cNewBuffer
	        @pointer = varptr("@buffer", "char")
	    else
	        # For other types, use Ring's built-in memory functions
	        memcpy(@pointer, pSource, nSize)
	    ok
	
	
	def CopyTo(pDest, nSize)
	    This.ValidatePointer()
	    
	    if IsNull(nSize)
	        nSize = @nBufferSize
	    ok
	    
	    if isObject(pDest) and classname(pDest) = "stkpointer"
	        pDest.CopyFrom(This, nSize)
	    else
	        # Use memory copy for Ring types
	        if @cLogicalType = "string"
	            cData = @oMemory.Copy(@buffer, NULL, nSize)
	            memcpy(pDest, varptr("cData", "char"), nSize)
	        else
	            memcpy(pDest, @pointer, nSize)
	        ok
	    ok
	
	def Memory()
	    return @oMemory
	

    def RingValue()

        This.ValidatePointer()

        switch @cLogicalType

            on "string"
                return @buffer

            on "int"
                return @buffer

            on "double"
                return @buffer

            on "object"
                return @buffer

            on "null"
                return NULL

            other
                return @buffer

        off


    def RawPointer()

        This.ValidatePointer()
        return @pointer


    def Address()

        This.ValidatePointer()
        return getpointer(@pointer)


    def AddressHex()
        return upper(hex(This.Address()))


    def Type()
        return @cLogicalType


    def Status()

        if IsNull(@pointer)
			return -1
		ok

        if len(@pointer) >= 3
			return @pointer[3]
		ok

        return 0

 
    def IsValidPointer()
        return @bIsValid and not IsNull(@pointer)


    def IsNullPointer()
        return IsNull(@pointer) or This.Address() = 0


    def Equals(oOther)

        if isObject(oOther) and classname(oOther) = "stkpointer"
            return ptrcmp(@pointer, oOther.RawPointer()) = 1

        else
            return FALSE
        ok


    def Info()

        return [

            [ "address", This.AddressHex() ],
            [ "type", This.Type() ],
            [ "status", This.Status() ],
            [ "valid", This.IsValidPointer() ],
            [ "managed", @bIsManaged ],
            [ "buffer_size", @nBufferSize ]
        ]


    def Show()
        ? list2code(This.Info())


    def debug()

        return [
            [ "logical_type", @cLogicalType ],
            [ "isvalid", @bIsValid ],
            [ "buffer_size", @nBufferSize ],
            [ "buffer_content", @buffer ],
            [ "ring_value", This.RingValue() ]
        ]

	def Free()
	    if @bIsManaged and @oMemory != NULL
	        if @oMemory.IsAllocated(@buffer)
	            @oMemory.Deallocate(@buffer)
	        ok
	        @buffer = NULL
	        @pointer = nullpointer()
	        @bIsValid = FALSE
	        @bIsManaged = FALSE
	    ok


    	def Destroy()
        	This.Free()

	#--------------------------------#
	#  PRIVATE KITCHEN OF THE CLASS  #
	#--------------------------------#

    PRIVATE


    def ValidatePointer()
        if not @bIsValid
            raise("Invalid pointer")
        ok
