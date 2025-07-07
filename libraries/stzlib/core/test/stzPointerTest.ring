load "../stklib.ring"

# Comprehensive Test Suite for stkPointer Class
# Covers all use cases including C/C++ library integration scenarios

/*--- TestSuite 1: Basic Pointer Operations
*/
pr()
    
    # Integer pointers
    oInt = new stkPointer(42)
    ? oInt.toRingValue()
	? oInt.getType()
 /*   
    # Double pointers  
    oDouble = new stkPointer(3.14159)
    ? "Double: " + oDouble.toRingValue() + " | Type: " + oDouble.getType()
    
    # String pointers
    oString = new stkPointer("Hello World")
    ? "String: '" + oString.toRingValue() + "' | Length: " + oString.detectStringLength()
    
    # Null pointers
    oNull = new stkPointer(NULL)
    ? "Null valid: " + oNull.isValidPointer() + " | Is null: " + oNull.isNullPointer()
*/
pf()

/*--- TestSuite 2: Advanced String Buffer Management
func testStringBuffers()
    ? "=== STRING BUFFER MANAGEMENT ==="
    
    # Fixed-size buffer
    oBuffer = stzStringPointer("Hello", 20)
    ? "Buffer size: " + oBuffer.@metadata[1] + " | Content: '" + oBuffer.toRingValue() + "'"
    
    # Multi-byte character handling
    oUtf8 = new stkPointer("こんにちは", "char", [20, true, "utf8"])
    ? "UTF-8 string: '" + oUtf8.toRingValue() + "'"
    
    # Buffer with no null terminator
    oNoNull = new stkPointer("TEST", "char", [4, false])
    ? "No null terminator: '" + oNoNull.pointerToString(0, 4) + "'"
    
    ? ""

/*--- TestSuite 3: Object and List Pointers
func testObjectPointers()
    ? "=== OBJECT AND LIST POINTERS ==="
    
    # List pointer
    aList = ["apple", "banana", "cherry"]
    oListPtr = new stkPointer(aList)
    aRetrieved = oListPtr.toRingValue()
    ? "Original list: " + @@(aList)
    ? "Retrieved list: " + @@(aRetrieved)
    
    # Object pointer
    oObj = new Person("John", 30)
    oObjPtr = new stkPointer(oObj)
    oRetrieved = oObjPtr.toRingValue()
    ? "Original object: " + classname(oObj)
    ? "Retrieved object: " + classname(oRetrieved)
    
    # Nested structure
    aComplex = [
        "data" = ["x" = 10, "y" = 20],
        "config" = ["debug" = true, "version" = "1.0"]
    ]
    oComplexPtr = new stkPointer(aComplex)
    aComplexRetrieved = oComplexPtr.toRingValue()
    ? "Complex structure maintained: " + (@@(aComplex) = @@(aComplexRetrieved))
    
    ? ""

/*--- TestSuite 4: Pointer Arithmetic and Memory Operations
func testPointerArithmetic()
    ? "=== POINTER ARITHMETIC ==="
    
    # String traversal
    oStr = new stkPointer("ABCDEFGH")
    ? "Original: " + oStr.getAddressHex() + " -> '" + oStr.pointerToString(0, 8) + "'"
    
    # Create offset pointers
    oOffset2 = oStr.copy()
    oOffset2.offsetBy(2)
    ? "Offset +2: " + oOffset2.getAddressHex() + " -> '" + oOffset2.pointerToString(0, 6) + "'"
    
    oOffset4 = oStr.copy()  
    oOffset4.offsetBy(4)
    ? "Offset +4: " + oOffset4.getAddressHex() + " -> '" + oOffset4.pointerToString(0, 4) + "'"
    
    # Pointer comparison
    ? "Pointers equal: " + oStr.equals(oOffset2)
    ? "Address difference: " + (oOffset2.getAddress() - oStr.getAddress())
    
    ? ""

/*--- TestSuite 5: C Library Integration Simulation
func testCLibraryIntegration()
    ? "=== C LIBRARY INTEGRATION SIMULATION ==="
    
    # Simulate passing string to C function
    cFilename = "test.txt"
    oFilenamePtr = new stkPointer(cFilename)
    ? "C function parameter: " + oFilenamePtr.getAddressHex()
    ? "Would pass to C: char* filename = " + oFilenamePtr.toRingValue()
    
    # Simulate C function that fills a buffer
    oBuffer = stzStringPointer("", 256)  # Empty buffer
    ? "C buffer allocated: " + oBuffer.@metadata[1] + " bytes at " + oBuffer.getAddressHex()
    
    # Simulate array of integers for C function
    aNumbers = [1, 2, 3, 4, 5]
    oArrayPtr = new stkPointer(aNumbers)
    ? "Integer array pointer: " + oArrayPtr.getAddressHex()
    
    # Simulate struct-like object for C
    aStruct = [
        "id" = 1001,
        "name" = "Component A",
        "active" = true
    ]
    oStructPtr = new stkPointer(aStruct)
    ? "Struct pointer: " + oStructPtr.getAddressHex()
    
    ? ""

/*--- TestSuite 6: Qt QVariant Integration
func testQtIntegration()
    ? "=== QT QVARIANT INTEGRATION ==="
    
    # Simulate QVariant scenarios
    testValues = [
        42,              # QVariant(int)
        3.14,           # QVariant(double)  
        "Hello Qt",     # QVariant(QString)
        true,           # QVariant(bool)
        ["a", "b", "c"] # QVariant(QStringList)
    ]
    
    for i = 1 to len(testValues)
        oQtPtr = new stkPointer(testValues[i])
        ? "QVariant #" + i + ": " + oQtPtr.getType() + " at " + oQtPtr.getAddressHex()
        ? "  Value: " + oQtPtr.toRingValue()
    next
    
    ? ""

/*--- TestSuite 7: Error Handling and Edge Cases
func testErrorHandling()
    ? "=== ERROR HANDLING ==="
    
    /*--- Testinvalid operations
    oNull = new stkPointer(NULL)
    
    try
        cResult = oNull.toRingValue()
        ? "Null conversion: " + cResult
    catch cError
        ? "Expected error caught: " + cError
    done
    
    /*--- Testpointer invalidation
    oTemp = new stkPointer("temporary")
    oTemp.free()
    
    try
        nAddr = oTemp.getAddress()
        ? "Address after free: " + nAddr
    catch cError
        ? "Expected error after free: " + cError
    done
    
    /*--- Testtype mismatch
    oInt = new stkPointer(42)
    try
        cStr = oInt.pointerToString()
        ? "String from int: " + cStr
    catch cError
        ? "Expected type error: " + cError
    done
    
    ? ""

/*--- TestSuite 8: Performance and Memory Management
func testMemoryManagement()
    ? "=== MEMORY MANAGEMENT ==="
    
    /*--- Testlarge buffer allocation
    oLargeBuffer = stzStringPointer("", 1024)
    ? "Large buffer: " + oLargeBuffer.@metadata[1] + " bytes"
    
    /*--- Testmultiple pointers to same data
    cSharedData = "Shared String"
    oPtr1 = new stkPointer(cSharedData)
    oPtr2 = new stkPointer(cSharedData)
    
    ? "Pointer 1: " + oPtr1.getAddressHex()
    ? "Pointer 2: " + oPtr2.getAddressHex()
    ? "Same data: " + (oPtr1.toRingValue() = oPtr2.toRingValue())
    
    /*--- Testmanaged vs unmanaged
    oManaged = new stkPointer("managed")
    oUnmanaged = oManaged.copy()
    
    ? "Managed status - Original: " + oManaged.@isManaged + ", Copy: " + oUnmanaged.@isManaged
    
    # Cleanup
    oLargeBuffer.free()
    oManaged.free()
    
    ? ""

/*--- TestSuite 9: Real-world Scenarios
func testRealWorldScenarios()
    ? "=== REAL-WORLD SCENARIOS ==="
    
    # Scenario 1: File I/O with C library
    ? "Scenario 1: File I/O"
    cMode = "rb"
    oModePtr = new stkPointer(cMode)
    ? "File mode pointer: " + oModePtr.getAddressHex()
    
    # Scenario 2: Network buffer
    ? "Scenario 2: Network Buffer"
    oNetBuffer = stzStringPointer("", 4096)
    ? "Network buffer: " + oNetBuffer.@metadata[1] + " bytes ready"
    
    # Scenario 3: Graphics pixel data
    ? "Scenario 3: Graphics Data"
    aPixelData = []
    for i = 1 to 100
        aPixelData + random(255)
    next
    oPixelPtr = new stkPointer(aPixelData)
    ? "Pixel data: " + len(oPixelPtr.toRingValue()) + " pixels"
    
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
    oConfigPtr = new stkPointer(aConfig)
    ? "Config pointer: " + oConfigPtr.getAddressHex()
    aRetrievedConfig = oConfigPtr.toRingValue()
    ? "Config preserved: " + (aRetrievedConfig["database"]["host"] = "localhost")
    
    ? ""

/*--- TestSuite 10: Educational Examples
func testEducationalExamples()
    ? "=== EDUCATIONAL EXAMPLES ==="
    
    # Example 1: Understanding pointer structure
    ? "Example 1: Pointer Structure"
    oExample = new stkPointer("Learning")
    aRawPointer = oExample.getRawPointer()
    ? "Raw pointer structure: " + @@(aRawPointer)
    ? "Address: " + aRawPointer[1] + " (hex: " + upper(hex(aRawPointer[1])) + ")"
    ? "Type: " + aRawPointer[2]
    ? "Status: " + aRawPointer[3]
    
    # Example 2: Memory layout visualization
    ? "Example 2: Memory Layout"
    cData = "ABCD"
    oDataPtr = new stkPointer(cData)
    ? "String '" + cData + "' in memory:"
    for i = 0 to len(cData) - 1
        cByte = oDataPtr.pointerToString(i, 1)
        ? "  Offset " + i + ": '" + cByte + "' (ASCII " + ascii(cByte) + ")"
    next
    
    # Example 3: Pointer lifecycle
    ? "Example 3: Pointer Lifecycle"
    oLife = new stkPointer("lifecycle")
    ? "Created: " + oLife.@createdFrom
    ? "Valid: " + oLife.isValidPointer()
    ? "Managed: " + oLife.@isManaged
    oLife.free()
    ? "After free - Valid: " + oLife.isValidPointer()
    
    ? ""

# Helper class for testing
class Person
    @name @age
    func init(cName, nAge)
        @name = cName
        @age = nAge

