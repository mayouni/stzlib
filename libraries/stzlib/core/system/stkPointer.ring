# stkPointer.ring - Softanza Pointer Class
# Universal abstraction for Ring pointer operations with C/C++ libraries
# Handles all Ring pointer types with safety and educational clarity

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
            # Extract parameters from list
            pValue = pParams[1]
            if len(pParams) > 1 cType = pParams[2] ok
            if len(pParams) > 2 nOptions = pParams[3] ok
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
        @isValid = true
        @isManaged = false
        @createdFrom = "null"
    
    # Create pointer from Ring value
    def createFromValue(pValue, cType, nOptions)
		if isNull(cType)
			cType = :auto
		ok
		if isNull(nOptions)
			noptions = []
		ok

        # Auto-detect type if needed
        if cType = :auto
            cType = this.detectOptimalType(pValue)
        ok
        
        try
            switch cType
            on "int"
                @originalValue = pValue
                @pointer = varptr("@originalValue", "int")
                @metadata[1] = 4  # int size
                
            on "double" 
                @originalValue = pValue
                @pointer = varptr("@originalValue", "double")
                @metadata[1] = 8  # double size
                
            on "char"
                this.createStringPointer(pValue, nOptions)
                
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
            raise("Pointer creation failed: " + CatchError())
        done
    
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
        @originalValue = space(nBufferSize)
        if nBufferSize > 0
            for i = 1 to len(cString)
                @originalValue[i] = cString[i]
            next
            if lNullTerminate and len(cString) < nBufferSize
                @originalValue[len(cString) + 1] = char(0)
            ok
        ok
        
        @pointer = varptr("@originalValue", "char")
        @metadata = [nBufferSize, cEncoding, true]
    
    # Smart type detection based on Ring value
    def detectOptimalType(pValue)
        if isNumber(pValue)
            if floor(pValue) = pValue and pValue >= -2147483648 and pValue <= 2147483647
                return "int"
            else
                return "double"
            ok
        but isString(pValue)
            return "char"
        but isList(pValue) or isObject(pValue)
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
        
        cType = this.getType()
        switch cType
        on "char"
            return this.pointerToString()
        on "object" on "OBJECTPOINTER"
            return pointer2object(@pointer)
        on "int" on "double"
            # For numeric pointers, we need the original value
            if not isNull(@originalValue)
                return @originalValue
            else
                raise("Cannot convert numeric pointer without original value reference")
            ok
        on "NULLPOINTER"
            return NULL
        other
            raise("Unsupported pointer type for conversion: " + cType)
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
        if this.getType() != "char"
            raise("pointerToString() only works with char pointers")
        ok
        
        if nCount = -1
            nCount = this.detectStringLength()
        ok
        
        if nCount = 0 return "" ok
        
        return pointer2string(@pointer, nStart, nCount)
    
    # Detect string length for char pointers
    def detectStringLength()
        if this.getType() != "char" return 0 ok
        
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
        oNew = new stkPointer()
        oNew.@pointer = @pointer
        oNew.@originalValue = @originalValue
        oNew.@metadata = @metadata
        oNew.@isValid = @isValid
        oNew.@isManaged = false  # Copy is not managed
        oNew.@createdFrom = @createdFrom + "_copy"
        return oNew
    
    # Get detailed pointer information
    def getInfo()
        aInfo = []
        aInfo + ["Address", this.getAddressHex()]
        aInfo + ["Type", this.getType()]
        aInfo + ["Status", this.getStatus()]
        aInfo + ["Valid", this.isValidPointer()]
        aInfo + ["Managed", @isManaged]
        aInfo + ["Created From", @createdFrom]
        aInfo + ["Size", @metadata[1]]
        aInfo + ["Encoding", @metadata[2]]
        return aInfo
    
    # Display pointer information
    def show()
        aInfo = this.getInfo()
        ? "=== stzPointer Info ==="
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
            @pointer = nullpointer()
            @isValid = false
            @isManaged = false
        ok
    
    # Destructor
    def destroy()
        this.free()


