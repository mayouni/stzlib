load "../stklib.ring"

# Comprehensive Test Suite for stkPointer Class
# Covers all use cases including C/C++ library integration scenarios

/*--- TestSuite 1: Basic Pointer Operations

pr()
    
	# Integer pointers
    o1 = new stkPointer(42)
    ? o1.toRingValue()				#--> 42
	? o1.getType() + NL				#--> int

    # Double pointers  
    o2 = new stkPointer(3.14)
    ? o2.toRingValue()				#--> 3.14
	? o2.getType() + NL				#--> double

    # String pointers
    o3 = new stkPointer("Hello Ring")
    ? o3.toRingValue()				#--> "Hello Ring"
	? o3.detectStringLength() + NL	#--> 10

    # Null pointers
    o4 = new stkPointer(NULL)
    ? o4.isValidPointer()			#--> FALSE
	? o4.isNullPointer()			#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- TestSuite 2: Advanced String Buffer Management

pr()
    # Fixed-size buffer
    o1 = StkStringPointerQ("Hello", 20)
    # Buffer size:
	? o1.@metadata[1]			#--> 20
	? o1.toRingValue() + NL		#--> Hello
    
    # Multi-byte character handling
    o2 = new stkPointer(["こんにちは", "char", [20, true, "utf8"]])
    ? o2.toRingValue() + NL		#--> こんにちは	(Hello in Japaneese)
    
    # Buffer with no null terminator
    o3 = new stkPointer(["TEST", "char", [4, false]])
    ? o3.pointerToString(0, 4)	#--> TEST

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- TestSuite 3: Object and List Pointers

#NOTE This sample use the peerson class defined at the end of the file
#~> Ensure it is not commented for the sample to work

pr()

    # List pointer
    o1 = new stkPointer(["apple", "banana", "cherry"])

	# Retrieved list:
    	? o1.toRingValue()
	#--> [ "apple", "banana", "cherry" ]

	? o1.getType() + NL
	#--> list


    # Object pointer

    oObj = new Person("John", 30)
    o2 = new stkPointer(oObj)

    # Original object
	? classname(oObj) #--> person
	? o2.getType() #--> object

    # Retrieved object
	? classname(o2.toRingValue()) + NL
    	#--> person

    # Nested structure

    aComplex = [
        "data" = ["x" = 10, "y" = 20],
        "config" = ["debug" = true, "version" = "1.0"]
    ]

    # Ensuring that complex structure ismaintained
    o3 = new stkPointer(aComplex)
    ? (list2str(aComplex) = list2str(o3.toRingValue()))
    #--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- TestSuite 4: Pointer Arithmetic and Memory Operations
*/
pr()
    # String traversal
    o1 = new stkPointer("ABCDEFGH")
    ? "Original: " + o1.getAddressHex() + " -> '" + o1.pointerToString(0, 8) + "'"
    
    # Create offset pointers
    o2 = o1.copy()
    o2.offsetBy(2)
    ? "Offset +2: " + o2.getAddressHex() + " -> '" + o2.pointerToString(0, 6) + "'"
    
    o3 = o1.copy()  
    o3.offsetBy(4)
    ? "Offset +4: " + o3.getAddressHex() + " -> '" + o3.pointerToString(0, 4) + "'"
    
    # Pointer comparison
    ? "Pointers equal: " + o1.equals(o2)
    ? "Address difference: " + (o2.getAddress() - o1.getAddress())

pf()

/*--- TestSuite 5: Memory Copy Operations (Didactic)

pr()
    # Create source and destination buffers
    o1 = new stkPointer("SOURCE_DATA")
    o2 = StkStringPointerQ("", 20)  # Empty destination buffer
    
    ? "Before memcpy:"
    ? "Source: '" + o1.toRingValue() + "'"
    ? "Destination: '" + o2.toRingValue() + "'"
    
    # Perform memory copy
    o2.copyFrom(o1, 6)  # Copy first 6 bytes
    
    ? "After copying 6 bytes:"
    ? "Source: '" + o1.toRingValue() + "'"
    ? "Destination: '" + o2.toRingValue() + "'" + NL
    
    # Demonstrate copyTo method
    o3 = StkStringPointerQ("", 15)
    o1.copyTo(o3, 11)  # Copy all 11 bytes
    
    ? "Using copyTo method:"
    ? "Source copied to new buffer: '" + o3.toRingValue() + "'"
    
    # Show memory addresses during copy
    ? "Memory addresses:"
    ? "Source: " + o1.getAddressHex()
    ? "Dest1: " + o2.getAddressHex()
    ? "Dest2: " + o3.getAddressHex()

pf()

/*--- TestSuite 6: Debug Method Testing

pr()
    # Integer pointer debug
    o1 = new stkPointer(42)
    ? "Integer pointer debug:"
    o1.debug()
    
    # String pointer debug
    o2 = new stkPointer("Hello Ring")
    ? "String pointer debug:"
    o2.debug()
    
    # Object pointer debug
    o3 = new stkPointer(["a", "b", "c"])
    ? "List pointer debug:"
    o3.debug()
    
    # Null pointer debug
    o4 = new stkPointer(NULL)
    ? "Null pointer debug:"
    o4.debug()

pf()

/*--- TestSuite 7: C Library Integration Simulation

pr()
    # Simulate passing string to C function
    o1 = new stkPointer("test.txt")
    ? "C function parameter: " + o1.getAddressHex()
    ? "Would pass to C: char* filename = " + o1.toRingValue() + NL
    
    # Simulate C function that fills a buffer
    o2 = StkStringPointerQ("", 256)  # Empty buffer
    ? "C buffer allocated: " + o2.@metadata[1] + " bytes at " + o2.getAddressHex() + NL
    
    # Simulate array of integers for C function
    o3 = new stkPointer([1, 2, 3, 4, 5])
    ? "Integer array pointer: " + o3.getAddressHex() + NL
    
    # Simulate struct-like object for C
    aStruct = [
        "id" = 1001,
        "name" = "Component A",
        "active" = true
    ]
    o4 = new stkPointer(aStruct)
    ? "Struct pointer: " + o4.getAddressHex()

pf()

/*--- TestSuite 8: Qt QVariant Integration

pr()
    # Simulate QVariant scenarios
    testValues = [
        42,              # QVariant(int)
        3.14,           # QVariant(double)  
        "Hello Qt",     # QVariant(QString)
        true,           # QVariant(bool)
        ["a", "b", "c"] # QVariant(QStringList)
    ]
    
    for i = 1 to len(testValues)
        o1 = new stkPointer(testValues[i])
        ? "QVariant #" + i + ": " + o1.getType() + " at " + o1.getAddressHex()
        ? "  Value: " + o1.toRingValue()
    next

pf()

/*--- TestSuite 9: Error Handling and Edge Cases

pr()
    # Test null operations
    o1 = new stkPointer(NULL)
    
    try
        cResult = o1.toRingValue()
        ? "Null conversion: " + cResult
    catch cError
        ? "Expected error caught: " + cError
    done
    
    # Test pointer invalidation
    o2 = new stkPointer("temporary")
    o2.free()
    
    try
        nAddr = o2.getAddress()
        ? "Address after free: " + nAddr
    catch cError
        ? "Expected error after free: " + cError
    done + NL
    
    # Test type mismatch
    o3 = new stkPointer(42)
    try
        cStr = o3.pointerToString()
        ? "String from int: " + cStr
    catch cError
        ? "Expected type error: " + cError
    done

pf()

/*--- TestSuite 10: Memory Management

pr()
    # Test large buffer allocation
    o1 = StkStringPointerQ("", 1024)
    ? "Large buffer: " + o1.@metadata[1] + " bytes" + NL
    
    # Test multiple pointers to same data
    cSharedData = "Shared String"
    o2 = new stkPointer(cSharedData)
    o3 = new stkPointer(cSharedData)
    
    ? "Pointer 1: " + o2.getAddressHex()
    ? "Pointer 2: " + o3.getAddressHex()
    ? "Same data: " + (o2.toRingValue() = o3.toRingValue()) + NL
    
    # Test managed vs unmanaged
    o4 = new stkPointer("managed")
    o5 = o4.copy()
    
    ? "Managed status - Original: " + o4.@isManaged + ", Copy: " + o5.@isManaged()
    
    # Cleanup
    o1.free()
    o4.free()

pf()

/*--- TestSuite 11: Real-world Scenarios

pr()
    # Scenario 1: File I/O with C library
    ? "Scenario 1: File I/O"
    o1 = new stkPointer("rb")
    ? "File mode pointer: " + o1.getAddressHex() + NL
    
    # Scenario 2: Network buffer
    ? "Scenario 2: Network Buffer"
    o2 = StkStringPointerQ("", 4096)
    ? "Network buffer: " + o2.@metadata[1] + " bytes ready" + NL
    
    # Scenario 3: Graphics pixel data
    ? "Scenario 3: Graphics Data"
    aPixelData = []
    for i = 1 to 100
        aPixelData + random(255)
    next
    o3 = new stkPointer(aPixelData)
    ? "Pixel data: " + len(o3.toRingValue()) + " pixels" + NL
    
    # Scenario 4: Configuration data
    ? "Scenario 4: Configuration"
    aConfig = [
        "database" = [
            "host" = "localhost",
            "port" = 5432,
            "name" = "mydb"
        ],
        "cache" = [
            "enabled" = true,
            "ttl" = 3600
        ]
    ]
    o4 = new stkPointer(aConfig)
    ? "Config pointer: " + o4.getAddressHex()
    aRetrievedConfig = o4.toRingValue()
    ? "Config preserved: " + (aRetrievedConfig["database"]["host"] = "localhost")

pf()

/*--- TestSuite 12: Number Type Detection and C/C++ Interop

pr()

   # Auto-detection: Ring-like simplicity
   # Ring automatically chooses optimal storage type
   o1 = new stkPointer(42)
   ? o1.getType()              #--> number (high-level Ring semantics)
   ? o1.@logicalType           #--> int (actual storage: 4-byte int)
   ? o1.toRingValue() + NL     #--> 42
  
   # Floating point auto-detected as double
   o2 = new stkPointer(3.14159)
   ? o2.getType()              #--> number (Ring semantics)
   ? o2.@logicalType           #--> double (actual storage: 8-byte double)
   ? o2.toRingValue() + NL     #--> 3.14159
 
   # Explicit C/C++ interop: override auto-detection
   # Force 32-bit int for C functions expecting int*
   o3 = new stkPointer([42, "int"])
   ? o3.getType()              #--> int (explicit type)
   ? o3.@metadata[1]  + NL     #--> 4 (memory footprint in bytes)
 
   # Force 64-bit double for C functions expecting double*
   o4 = new stkPointer([42.0, "double"])  
   ? o4.getType()              #--> double (explicit type)
   ? o4.@metadata[1] + NL      #--> 8 (memory footprint in bytes)
  
   # Memory efficiency: int vs double storage
   oInt = new stkPointer([1000, "int"])      # Compact: 4 bytes
   oDouble = new stkPointer([1000, "double"]) # Larger: 8 bytes
   ? ''+ oInt.@metadata[1] + " vs " + oDouble.@metadata[1]  #--> 4 vs 8

pf()
# Executed in almost 0 second(s) in Ring 1.22


pr()
   # Auto-detection: Ring-like string semantics
   o1 = new stkPointer("Hello World")
   ? o1.getType()              #--> string (Ring semantics)
   ? o1.@logicalType           #--> string (actual storage type)
   ? o1.toRingValue() + NL         #--> Hello World
   
   # Explicit C interop: char* for C functions
   o2 = new stkPointer(["Hello", "char"])
   ? o2.getType()              #--> char (C-style char* pointer)
   ? o2.toRingValue() + NL     #--> Hello
   
   # Buffer management: Ring string vs C char array
   o3 = new stkPointer(["Text", "string", [10, true]])  # Ring semantics
   ? o3.@metadata[1] + NL      #--> 10 (buffer size)
   
   o4 = new stkPointer(["Text", "char", [10, true]])    # C semantics  
   ? o4.@metadata[1] + NL      #--> 10 (C-style buffer)
   
   # Both work with string operations
   ? o3.pointerToString(0, 4)  	#--> Text
   ? o4.pointerToString(0, 4) + NL #--> Text
   
   # Encoding support (both types)
   o5 = new stkPointer(["こんにちは", "string", [20, true, "utf8"]])
   ? o5.getType()              #--> string
   ? o5.toRingValue()          #--> こんにちは

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- TestSuite 14: Educational Examples

pr()
    # Example 1: Understanding pointer structure
    ? "Example 1: Pointer Structure"
    o1 = new stkPointer("Learning")
    aRawPointer = o1.getRawPointer()
    ? "Raw pointer structure: " + @@(aRawPointer)
    ? "Address: " + aRawPointer[1] + " (hex: " + upper(hex(aRawPointer[1])) + ")"
    ? "Type: " + aRawPointer[2]
    ? "Status: " + aRawPointer[3] + NL
    
    # Example 2: Memory layout visualization
    ? "Example 2: Memory Layout"
    o2 = new stkPointer("ABCD")
    ? "String 'ABCD' in memory:"
    for i = 0 to 3
        cByte = o2.pointerToString(i, 1)
        ? "  Offset " + i + ": '" + cByte + "' (ASCII " + ascii(cByte) + ")"
    next
    
    # Example 3: Pointer lifecycle
    ? "Example 3: Pointer Lifecycle"
    o3 = new stkPointer("lifecycle")
    ? "Created: " + o3.@createdFrom
    ? "Valid: " + o3.isValidPointer()
    ? "Managed: " + o3.@isManaged
    o3.free()
    ? "After free - Valid: " + o3.isValidPointer()

pf()
/*---
*/
# Helper class for testing
class Person
    @name @age
    func init(cName, nAge)
        @name = cName
        @age = nAge
