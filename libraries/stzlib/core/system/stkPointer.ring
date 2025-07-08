# stkPointer.ring - Softanza Pointer Class
# Universal abstraction for Ring pointer operations with C/C++ libraries
# Handles all Ring pointer types with safety and educational clarity

#NOTE Class made in collaboration with Claude and Grock AIs

# Utility functions for common pointer operations
func StkPointerQ(pParams)
    return new stkPointer(pParams)

func StkNullPointerQ()
    return new stkPointer(NULL)

func StkStringPointerQ(cString, nBufferSize)
	if IsNull(nBufferSize)
		nBufferSize = 0
	ok
    return new stkPointer([cString, "char", [nBufferSize, true, "utf8"]])

func StkObjectPointerQ(pObject)
    return new stkPointer([pObject, "object"])


class stkPointer
    # Core pointer data - Ring pointers are lists: [address, type, status]
    @pointer = NULL      	# The actual Ring pointer object (list of 3 items)
    @originalValue = NULL 	# Keep reference to prevent garbage collection
    @buffer = NULL          # Buffer for memory management (separate from originalValue)
    @logicalType = ""       # The logical type we created (int, double, char, object)
    @metadata = []       	# Additional info: [size, encoding, allocated_by_us]
    
    # Safety and state tracking
    @isValid = false     	# Current validity state
    @isManaged = false   	# Whether we allocated the memory
    @createdFrom = ""    	# Track creation source for debugging
    
    # Constructor - unified interface for all pointer creation scenarios
	def init(pParams)
	    @metadata = [0, "utf8", false]  # [size, encoding, allocated_by_us]
	    @createdFrom = "init"
	    
	    # Handle parameter variations
	    pValue = NULL
	    cType = :auto
	    nOptions = []
	    
	    if isList(pParams)
	        # Check if this looks like a parameter specification or data
	        # Parameter spec: [value, type_string, options]
	        # Data: any other list structure
	        bIsParamSpec = false
	        
	        if len(pParams) >= 2 and len(pParams) <= 3
	            # Could be param spec - check if second element is a type string
	            cSecondElement = pParams[2]
	            if isString(cSecondElement)
	                aValidTypes = ["int", "double", "number", "char", "string", "list", "object", "auto"]
	                if find(aValidTypes, cSecondElement) > 0
	                    bIsParamSpec = true
	                ok
	            ok
	        ok
	        
	        if bIsParamSpec
	            # Extract parameters from list
	            pValue = pParams[1]
	            cType = pParams[2]
	            if len(pParams) > 2 nOptions = pParams[3] ok
	        else
	            # Treat entire list as data value
	            pValue = pParams
	            cType = :auto
	        ok
	    else
	        # Single parameter - treat as pValue
	        pValue = pParams
	    ok
	    
	    if isNull(pValue)
	        this.createNullPointer()
	    else
	        this.createFromValue(pValue, cType, nOptions)
	    ok
    
    # Create a null pointer
    def createNullPointer()
        @pointer = nullpointer()
        @logicalType = "null"
        @isValid = true
        @isManaged = false
        @createdFrom = "null"
    
    # Create pointer from Ring value
    def createFromValue(pValue, cType, nOptions)
		if isNull(cType)
			cType = :auto
		ok
		if isNull(nOptions)
			nOptions = []
		ok

        # Auto-detect type if needed
        if cType = :auto
            cType = this.detectOptimalType(pValue)
        ok

        # Store the logical type
        @logicalType = cType

        try
            switch cType
		on "number"
		    if floor(pValue) = pValue and pValue >= -2147483648 and pValue <= 2147483647
		        @logicalType = "int"
		        @originalValue = pValue
		        @pointer = this.createNumericPointer(pValue, "int")
		        @metadata[1] = 4
		    else
		        @logicalType = "double" 
		        @originalValue = pValue
		        @pointer = this.createNumericPointer(pValue, "double")
		        @metadata[1] = 8
		    ok

		on "int"
		    @originalValue = pValue
		    @pointer = this.createNumericPointer(pValue, "int")
		    @metadata[1] = 4

		on "double"
		    @originalValue = pValue
		    @pointer = this.createNumericPointer(pValue, "double")
		    @metadata[1] = 8

		on "string"
		    this.createStringPointer(pValue, nOptions)

		on "char"
		    this.createStringPointer(pValue, nOptions)  # Keep for C compatibility

		on "list"
		    @originalValue = pValue
		    @pointer = object2pointer(pValue)
		    @metadata[1] = -1  # variable size
		    @logicalType = "list"  # Keep list type distinct from object
                
		on "object"
		    @originalValue = pValue
		    @pointer = object2pointer(pValue)
		    @metadata[1] = -1  # variable size
                
            other
                raise("Unsupported pointer type: " + cType)
            off
            
            @isValid = true
            @isManaged = true
            @createdFrom = "value:" + cType
            
        catch
            @isValid = false
            @pointer = nullpointer()
            raise("Pointer creation failed: " + cCatchError)
        done
    
    # Create numeric pointer using space() and direct assignment
    def createNumericPointer(nValue, cType)
        if cType = "int"
            # Create 4-byte buffer for int
            @buffer = space(4)
            # Convert int to bytes manually (little-endian)
            nVal = nValue
            @buffer[1] = char(nVal % 256)
            nVal = floor(nVal / 256)
            @buffer[2] = char(nVal % 256)
            nVal = floor(nVal / 256)
            @buffer[3] = char(nVal % 256)
            nVal = floor(nVal / 256)
            @buffer[4] = char(nVal % 256)
            
            return varptr("@buffer", "char")
            
        but cType = "double"
            # For double, store as string representation in buffer
            @buffer = space(32)  # Enough space for double representation
            cDoubleStr = "" + nValue
            for i = 1 to len(cDoubleStr)
                @buffer[i] = cDoubleStr[i]
            next
            
            return varptr("@buffer", "char")
        ok
    
    # Specialized string pointer creation with buffer management
    def createStringPointer(cString, nOptions)
		if isNull(nOptions)
			nOptions = []
		ok

        # Options: buffer_size, null_terminate, encoding
        nBufferSize = 0
        lNullTerminate = true
        cEncoding = "utf8"
        
        if len(nOptions) > 0
            if isNumber(nOptions[1]) nBufferSize = nOptions[1] ok
            if len(nOptions) > 1 and isNumber(nOptions[2]) lNullTerminate = nOptions[2] ok
            if len(nOptions) > 2 and isString(nOptions[3]) cEncoding = nOptions[3] ok
        ok
        
        # Calculate buffer size
        nNeededSize = len(cString)
        if lNullTerminate nNeededSize++ ok
        if nBufferSize = 0 nBufferSize = nNeededSize ok
        if nBufferSize < nNeededSize nBufferSize = nNeededSize ok
        
        # Allocate buffer and copy string
        @buffer = space(nBufferSize)
        if nBufferSize > 0
            for i = 1 to len(cString)
                @buffer[i] = cString[i]
            next
            if lNullTerminate and len(cString) < nBufferSize
                @buffer[len(cString) + 1] = char(0)
            ok
        ok
        
        @originalValue = cString
        @logicalType = "char"
        @pointer = varptr("@buffer", "char")
        @metadata = [nBufferSize, cEncoding, true]
    
    # Smart type detection based on Ring value
	def detectOptimalType(pValue)
	    if isNumber(pValue)
	        return "number"
	    but isString(pValue)
	        return "string"
	    but isList(pValue)
	        return "list"
	    but isObject(pValue)
	        return "object"
	    else
	        raise("Cannot detect appropriate pointer type")
	    ok
    
    # Get the raw Ring pointer (list of 3 items)
    def getRawPointer()
        this.validatePointer()
        return @pointer
    
    # Get pointer address as number
    def getAddress()
        this.validatePointer()
        return getpointer(@pointer)
    
    # Get pointer address as hex string
    def getAddressHex()
        return upper(hex(this.getAddress()))
    
    # Get pointer type
    def getType()
        this.validatePointer()
        if not isNull(@logicalType) and @logicalType != ""
            # Return high-level Ring semantics
            if @logicalType = "int" or @logicalType = "double"
                return "number"
            but @logicalType = "char"
                return "string"
            else
                return @logicalType
            ok
        ok
        
        # Fallback to Ring pointer type
        if isNull(@pointer) return "null" ok
        if len(@pointer) >= 2 return @pointer[2] ok
        return "unknown"
    
    # Get pointer status
    def getStatus()
        this.validatePointer()
        if isNull(@pointer) return -1 ok
        if len(@pointer) >= 3 return @pointer[3] ok
        return -1
    
    # Check if pointer is valid
    def isValidPointer()
        return @isValid and not isNull(@pointer) and this.getStatus() = 0
    
    # Check if pointer is null
    def isNullPointer()
        return isNull(@pointer) or this.getAddress() = 0
    

    # Convert pointer back to Ring value
    def toRingValue()
        this.validatePointer()
        
        # Use logical type directly
        switch @logicalType
	   	on "string"
    			return this.pointerToString(0, -1)
	   	on "char"
    			return this.pointerToString(0, -1)

		on "list"
		    if not isNull(@originalValue)
		        return @originalValue
		    else
		        return pointer2object(@pointer)
		    ok

		on "object"
		    if not isNull(@originalValue)
		        return @originalValue
		    else
		        return pointer2object(@pointer)
		    ok

        	on "int"
            	# Read integer from buffer
            	if not isNull(@buffer) and len(@buffer) >= 4
                	# Convert bytes back to integer (little-endian)
                	nVal = 0
               	 nVal += ascii(@buffer[4]) * 256 * 256 * 256
               	 nVal += ascii(@buffer[3]) * 256 * 256
               	 nVal += ascii(@buffer[2]) * 256
               	 nVal += ascii(@buffer[1])
                	return nVal
           	 else
                	return @originalValue
            	ok

        	on "double"
            	# For double, return original value (complex byte conversion not implemented)
            	return @originalValue

       	on "null"
            	return NULL

        	other
            	raise("Unsupported pointer type for conversion: " + @logicalType)
       	 off

    # Convert char pointer to string with options
    def pointerToString(nStart, nCount)
		if isNull(nStart)
			nStart = 0
		ok
		if isNull(nCount)
			nCount = -1
		ok

        this.validatePointer()
		cType = This.getType()

	    if not (cType = "string" or cType = "char")
	        raise("pointerToString() only works with string/char pointers")
	    ok
        
        if nCount = -1
            nCount = this.detectStringLength()
        ok
        
        if nCount = 0 return "" ok
        
        return pointer2string(@pointer, nStart, nCount)
    
    # Detect string length for char pointers
    def detectStringLength()
        if @logicalType != "char" return 0 ok
        
        nMaxScan = 1024
        if @metadata[1] > 0 and @metadata[1] < nMaxScan
            nMaxScan = @metadata[1]
        ok
        
        # Scan for null terminator
        for i = 0 to nMaxScan - 1
            try
                cByte = pointer2string(@pointer, i, 1)
                if cByte = char(0) return i ok
            catch
                return i
            done
        next
        
        return nMaxScan
    
    # Memory copy operation
    def memcpy(pDestPointer, cSourceString, nSize)
        this.validatePointer()
        if isObject(pDestPointer) and classname(pDestPointer) = "stkpointer"
            pDestPointer = pDestPointer.getRawPointer()
        ok
        memcpy(pDestPointer, cSourceString, nSize)
    
    # Copy from this pointer to another
    def copyTo(pDestPointer, nSize)
        this.validatePointer()
        if isNull(nSize) nSize = @metadata[1] ok
        if nSize > 0
            cData = pointer2string(@pointer, 0, nSize)
            if isObject(pDestPointer) and classname(pDestPointer) = "stkpointer"
                pDestPointer = pDestPointer.getRawPointer()
            ok
            memcpy(pDestPointer, cData, nSize)
        ok
    
    # Copy from another pointer to this one
    def copyFrom(pSourcePointer, nSize)
        this.validatePointer()
        if isNull(nSize) nSize = @metadata[1] ok
        if nSize > 0
            if isObject(pSourcePointer) and classname(pSourcePointer) = "stkpointer"
                cData = pSourcePointer.pointerToString(0, nSize)
            else
                cData = pointer2string(pSourcePointer, 0, nSize)
            ok
            memcpy(@pointer, cData, nSize)
        ok
    
    # Compare two pointers
    def equals(oOther)
        if isObject(oOther) and classname(oOther) = "stkpointer"
            return ptrcmp(@pointer, oOther.getRawPointer()) = 1
        but isPointer(oOther)
            return ptrcmp(@pointer, oOther) = 1
        else
            return false
        ok
    
    # Change pointer address (advanced operation)
    def setAddress(nNewAddress)
        this.validatePointer()
        setpointer(@pointer, nNewAddress)
    
    # Offset pointer by bytes (for array traversal)
    def offsetBy(nBytes)
        nCurrentAddr = this.getAddress()
        this.setAddress(nCurrentAddr + nBytes)
    
    # Create a copy of this pointer
    def copy()
        oNew = new stkPointer([])
        oNew.@pointer = @pointer
        oNew.@originalValue = @originalValue
        oNew.@buffer = @buffer
        oNew.@logicalType = @logicalType
        oNew.@metadata = @metadata
        oNew.@isValid = @isValid
        oNew.@isManaged = false  # Copy is not managed
        oNew.@createdFrom = @createdFrom + "_copy"
        return oNew
    
    # Get detailed pointer information
    def getInfo()
        aInfo = []
        aInfo + ["Address", this.getAddressHex()]
        aInfo + ["Ring Type", this.getType()]
	   aInfo + ["Internal Type", this.@logicalType]
        aInfo + ["Status", this.getStatus()]
        aInfo + ["Valid", this.isValidPointer()]
        aInfo + ["Managed", @isManaged]
        aInfo + ["Created From", @createdFrom]
        aInfo + ["Size", @metadata[1]]
        aInfo + ["Encoding", @metadata[2]]
        return aInfo
    
    # Debug method to see internal state
	def debug()
	    ? "=== DEBUG INFO ==="
	    ? "logicalType: " + @logicalType
	    if isList(@originalValue) or isObject(@originalValue)
	        ? "originalValue: [complex object/list]"
	    else
	        ? "originalValue: " + @originalValue
	    ok
	    ? "getType(): " + this.getType()
	    ? "isValid: " + @isValid
	    ? "=================="
    
    # Display pointer information
    def show()
        aInfo = this.getInfo()
        ? "=== stkPointer Info ==="
        for i = 1 to len(aInfo) step 2
            ? aInfo[i] + ": " + aInfo[i+1]
        next
        ? "======================="
    
    # Validate pointer state
    private

	def validatePointer()
        if not @isValid
            raise("Invalid pointer - cannot perform operation")
        ok
    
    # Free managed memory
    def free()
        if @isManaged and @isValid
            @originalValue = NULL  # Let Ring GC handle it
            @buffer = NULL
            @pointer = nullpointer()
            @isValid = false
            @isManaged = false
        ok
    
    # Destructor
    def destroy()
        this.free()
