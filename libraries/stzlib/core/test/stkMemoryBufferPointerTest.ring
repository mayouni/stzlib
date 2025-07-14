load "../stklib.ring"

#=========================================#
#  BASIC BUFFER CREATION AND MANAGEMENT   #
#=========================================#

/*--- Creating buffers and basic operations

pr()

oMem = new stkMemory()
oMem {
	
	# Create a buffer with 100 bytes capacity

	oBuff1 = CreateBuffer(100)
	
	? oBuff1.Size() + NL
	#--> 0
	
	# Write some data to the buffer

	oBuff1.Write(0, "Hello Softanza!")
	? oBuff1.Size()
	#--> 15
	
	# Read data back from buffer (first 5 bytes)
	? oBuff1.Read(0, 5)
	#--> "Hello"
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Multiple buffer management

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create multiple buffers for different purposes
	oConfigBuffer = CreateBuffer(256)    # Configuration data
	oDataBuffer = CreateBuffer(1024)     # Main data storage
	oLogBuffer = CreateBuffer(512)       # Log messages
	
	# Checking the number of buffers in memory
	? NumberOfBuffers()
	#--> 3
	
	# Write configuration data
	oConfigBuffer.Write(0, "app_version=1.0;debug=true")
	
	# Write main data
	oDataBuffer.Write(0, "user_data={name:'John',age:30}")
	
	# Write log entry
	oLogBuffer.Write(0, "[INFO] System initialized")
	
	# Read and display all data
	? "Config: " + oConfigBuffer.RawData()
	#--> "Config: app_version=1.0;debug=true"
	
	? "Data: " + oDataBuffer.RawData()
	#--> "Data: user_data={name:'John',age:30}"
	
	? "Log: " + oLogBuffer.RawData()
	#--> "Log: [INFO] System initialized"
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=================================#
#  POINTER-BASED ACCESS PATTERNS  #
#=================================#

/*--- Creating and using read pointers
*/
pr()

oMem = new stkMemory()
oMem {

oBuff = CreateBuffer(200)

	# Create a buffer with sample text
	oBuff = CreateBuffer(200)
	oBuff.Write(0, "The quick brown fox jumps over the lazy dog")
	
	# Create multiple read pointers to different parts
	oReadPtr1 = CreatePointer(oBuff.Id(), "read")
	oReadPtr2 = CreatePointer(oBuff.Id(), "read")
	
	? "Created " + len(@aPointers) + " pointers"
	#--> "Created 2 pointers"
	
	# Use pointers to read different segments
	cWord1 = oReadPtr1.Read(0, 3)    # "The"
	cWord2 = oReadPtr1.Read(10, 5)   # "brown"
	cWord3 = oReadPtr2.Read(16, 3)   # "fox"
	
	? "Words extracted: " + cWord1 + ", " + cWord2 + ", " + cWord3
	#--> "Words extracted: The, brown, fox"

}

pf()

/*--- Write pointer exclusivity and data modification

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create buffer for document editing
	oDocBuffer = CreateBuffer(500)
	WriteToBuffer(oDocBuffer.Id(), 0, "Original document content")
	
	# Create a write pointer (only one allowed per buffer)
	oWritePtr = CreatePointer(oDocBuffer.Id(), "write")
	
	? "Write pointer created successfully"
	#--> "Write pointer created successfully"
	
	# Try to create another write pointer (should fail)
	try {
		oWritePtr2 = CreatePointer(oDocBuffer.Id(), "write")
	}
	catch {
		? "Expected error: Cannot create second write pointer"
		#--> "Expected error: Cannot create second write pointer"
	}
	
	# Use write pointer to modify content
	oWritePtr.Write(0, "Modified document content")
	
	# Verify modification with read pointer
	oReadPtr = CreatePointer(oDocBuffer.Id(), "read")
	cNewContent = oReadPtr.Read(0, 25)
	? "Modified content: " + cNewContent
	#--> "Modified content: Modified document content"
}

pf()

#===============================#
#  MEMORY LIFECYCLE MANAGEMENT  #
#===============================#

/*--- Buffer destruction and pointer invalidation

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create buffer and pointers
	oBuff = CreateBuffer(100)
	WriteToBuffer(oBuff.Id(), 0, "Test data")
	
	oPtr1 = CreatePointer(oBuff.Id(), "read")
	oPtr2 = CreatePointer(oBuff.Id(), "read")
	
	? "Before destruction - Pointer 1 valid: " + oPtr1.IsValid()
	#--> "Before destruction - Pointer 1 valid: true"
	
	? "Before destruction - Pointer 2 valid: " + oPtr2.IsValid()
	#--> "Before destruction - Pointer 2 valid: true"
	
	# Destroy the buffer
	DestroyBuffer(oBuff.Id())
	
	? "After destruction - Pointer 1 valid: " + oPtr1.IsValid()
	#--> "After destruction - Pointer 1 valid: false"
	
	? "After destruction - Pointer 2 valid: " + oPtr2.IsValid()
	#--> "After destruction - Pointer 2 valid: false"
	
	? "Remaining buffers: " + len(@aBuffers)
	#--> "Remaining buffers: 0"
}

pf()

/*--- Pointer destruction and write pointer release

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create buffer and write pointer
	oBuff = CreateBuffer(100)
	oWritePtr = CreatePointer(oBuff.Id(), "write")
	
	? "Buffer has write pointer: " + oBuff.@bHasWritePointer
	#--> "Buffer has write pointer: true"
	
	# Destroy the write pointer
	DestroyPointer(oWritePtr.@nPointerId)
	
	? "After pointer destruction - Buffer has write pointer: " + oBuff.@bHasWritePointer
	#--> "After pointer destruction - Buffer has write pointer: false"
	
	# Now we can create a new write pointer
	oNewWritePtr = CreatePointer(oBuff.Id(), "write")
	? "New write pointer created successfully"
	#--> "New write pointer created successfully"
}

pf()

#================================#
#  PRACTICAL USAGE SCENARIOS     #
#================================#

/*--- Text processing with multiple views

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create a text buffer with paragraph data
	oTextBuffer = CreateBuffer(1000)
	cText = "Softanza is a programming language designed for natural programming. " +
	        "It combines the power of Ring with intuitive syntax. " +
	        "The memory management system provides safe and efficient data handling."
	
	WriteToBuffer(oTextBuffer.Id(), 0, cText)
	
	# Create specialized pointers for different text operations
	oReaderPtr = CreatePointer(oTextBuffer.Id(), "read")    # For reading operations
	oParserPtr = CreatePointer(oTextBuffer.Id(), "read")    # For parsing operations
	
	# Extract sentences using different pointers
	cSentence1 = oReaderPtr.Read(0, 67)   # First sentence
	cSentence2 = oParserPtr.Read(67, 51)  # Second sentence
	
	? "Sentence 1: " + cSentence1
	#--> "Sentence 1: Softanza is a programming language designed for natural programming."
	
	? "Sentence 2: " + cSentence2
	#--> "Sentence 2: It combines the power of Ring with intuitive syntax."
}

pf()

/*--- Data serialization and deserialization

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create buffers for serialization process
	oSourceBuffer = CreateBuffer(500)   # Original data
	oSerialBuffer = CreateBuffer(1000)  # Serialized data
	oTargetBuffer = CreateBuffer(500)   # Deserialized data
	
	# Original data structure (simulated)
	cOriginalData = "user_id:123|name:John Doe|email:john@example.com"
	WriteToBuffer(oSourceBuffer.Id(), 0, cOriginalData)
	
	# Serialization process (add header)
	cHeader = "DATA_V1.0|LENGTH:" + len(cOriginalData) + "|"
	cSerialized = cHeader + cOriginalData
	WriteToBuffer(oSerialBuffer.Id(), 0, cSerialized)
	
	? "Serialized data: " + ReadFromBuffer(oSerialBuffer.Id(), 0, oSerialBuffer.Size())
	#--> "Serialized data: DATA_V1.0|LENGTH:45|user_id:123|name:John Doe|email:john@example.com"
	
	# Deserialization process (extract original data)
	cFullSerialized = ReadFromBuffer(oSerialBuffer.Id(), 0, oSerialBuffer.Size())
	nDataStart = find(cFullSerialized, "user_id:")
	cDeserialized = substr(cFullSerialized, nDataStart, len(cOriginalData))
	WriteToBuffer(oTargetBuffer.Id(), 0, cDeserialized)
	
	? "Deserialized data: " + ReadFromBuffer(oTargetBuffer.Id(), 0, oTargetBuffer.Size())
	#--> "Deserialized data: user_id:123|name:John Doe|email:john@example.com"
}

pf()

#=================================#
#  ERROR HANDLING AND ROBUSTNESS  #
#=================================#

/*--- Boundary condition testing

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create small buffer for boundary testing
	oBuff = CreateBuffer(10)
	WriteToBuffer(oBuff.Id(), 0, "1234567890")
	
	oPtr = CreatePointer(oBuff.Id(), "read")
	
	# Test normal read
	cData = oPtr.Read(0, 5)
	? "Normal read (0,5): " + cData
	#--> "Normal read (0,5): 12345"
	
	# Test boundary read
	cData = oPtr.Read(5, 5)
	? "Boundary read (5,5): " + cData
	#--> "Boundary read (5,5): 67890"
	
	# Test error conditions
	try {
		cData = oPtr.Read(8, 5)  # Should fail - out of bounds
	}
	catch {
		? "Expected error: Read out of bounds"
		#--> "Expected error: Read out of bounds"
	}
	
	try {
		cData = oPtr.Read(-1, 5)  # Should fail - negative offset
	}
	catch {
		? "Expected error: Invalid offset"
		#--> "Expected error: Invalid offset"
	}
}

pf()

/*--- Invalid operations and safety checks

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create buffer and pointers
	oBuff = CreateBuffer(50)
	WriteToBuffer(oBuff.Id(), 0, "Test data for safety checks")
	
	oReadPtr = CreatePointer(oBuff.Id(), "read")
	oWritePtr = CreatePointer(oBuff.Id(), "write")
	
	# Test write with read-only pointer
	try {
		oReadPtr.Write(0, "Should fail")
	}
	catch {
		? "Expected error: Read-only pointer cannot write"
		#--> "Expected error: Read-only pointer cannot write"
	}
	
	# Test operations on invalid buffer
	try {
		cData = ReadFromBuffer(999, 0, 10)  # Non-existent buffer
	}
	catch {
		? "Expected error: Buffer not found"
		#--> "Expected error: Buffer not found"
	}
	
	# Test write beyond capacity
	try {
		WriteToBuffer(oBuff.Id(), 0, copy("X", 100))  # Exceeds capacity
	}
	catch {
		? "Expected error: Write beyond capacity"
		#--> "Expected error: Write beyond capacity"
	}
}

pf()

#============================#
#  ADVANCED USAGE PATTERNS   #
#============================#

/*--- Multi-buffer data processing pipeline

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create processing pipeline buffers
	oInputBuffer = CreateBuffer(200)    # Raw input
	oProcessBuffer = CreateBuffer(300)  # Processing stage
	oOutputBuffer = CreateBuffer(250)   # Final output
	
	# Input data
	cRawData = "hello world from softanza system"
	WriteToBuffer(oInputBuffer.Id(), 0, cRawData)
	
	# Stage 1: Read and uppercase
	cInput = ReadFromBuffer(oInputBuffer.Id(), 0, oInputBuffer.Size())
	cProcessed = upper(cInput)
	WriteToBuffer(oProcessBuffer.Id(), 0, cProcessed)
	
	# Stage 2: Add formatting
	cFormatted = "[PROCESSED] " + ReadFromBuffer(oProcessBuffer.Id(), 0, oProcessBuffer.Size()) + " [END]"
	WriteToBuffer(oOutputBuffer.Id(), 0, cFormatted)
	
	# Final result
	cResult = ReadFromBuffer(oOutputBuffer.Id(), 0, oOutputBuffer.Size())
	? "Pipeline result: " + cResult
	#--> "Pipeline result: [PROCESSED] HELLO WORLD FROM SOFTANZA SYSTEM [END]"
	
	? "Pipeline uses " + len(@aBuffers) + " buffers and " + len(@aPointers) + " pointers"
	#--> "Pipeline uses 3 buffers and 0 pointers"
}

pf()

/*--- Dynamic buffer management with cleanup

pr()

oMem = new stkMemory()
oMem {
	init()
	
	# Create temporary buffers for batch processing
	aTempBuffers = []
	for i = 1 to 5 {
		oBuff = CreateBuffer(100)
		WriteToBuffer(oBuff.Id(), 0, "Batch item " + i)
		aTempBuffers + oBuff
	}
	
	? "Created " + len(aTempBuffers) + " temporary buffers"
	#--> "Created 5 temporary buffers"
	
	# Process all buffers
	for oBuff in aTempBuffers {
		cData = ReadFromBuffer(oBuff.Id(), 0, oBuff.Size())
		? "Processing: " + cData
		#--> "Processing: Batch item 1"
		#--> "Processing: Batch item 2"
		#--> "Processing: Batch item 3"
		#--> "Processing: Batch item 4"
		#--> "Processing: Batch item 5"
	}
	
	# Cleanup temporary buffers
	for oBuff in aTempBuffers {
		DestroyBuffer(oBuff.Id())
	}
	
	? "Cleanup complete. Remaining buffers: " + len(@aBuffers)
	#--> "Cleanup complete. Remaining buffers: 0"
}

pf()
