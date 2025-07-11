load "../stklib.ring"

#-----------------------------------------------------#
# Comined Use of stkBuffer, stkMemory, and stkPointer #
#-----------------------------------------------------#

/*--- Example 1: Basic Buffer Operations

pr()

# Create a buffer of size 100

oBuffer = new stkBuffer(100)

oBuffer {

	# Write data to the buffer

	Write(0, "Hello, World!")

	# Read data from the buffer

	data = Read(0, 13)
	? data
	#--> Hello, World!

	# Append more data

	Append(" How are you?")

	# Get buffer size and capacity

	? Size() # Current data size
	#--> 26
	
	? Capacity() + NL # Total allocated capacity
	#--> 100

	# Resize the buffer to 200 bytes

	Resize(200)
	? Size() # Still containing the same data
	#--> 26

	? Capacity() + NL # Extended
	#--> 200

	# Clear the buffer

	Clear()

	? Size() # Data is cleansed
	#--> 0

	? Capacity() # But the same capacity is maintained
	#--> 200
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 2: Buffer with Pointer Integration

pr()

# Create a buffer with initial data
buf = new stkBuffer("Initial data for testing")

# Get a pointer to a specific position in the buffer
ptr = buf.GetPointer(8)  # Points to "data for testing"

# Access data through the pointer
data = ptr.RingValue()
? data
#--> "data for testing"

# Create another pointer from string data
strPtr = new stkPointer(["Hello from pointer", "string"])
? strPtr.RingValue()
#--> "Hello from pointer"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 3: Memory Management and Copying

pr()

# Create memory manager instance
mem = new stkMemory()

# Allocate memory blocks
block1 = mem.Allocate(50)
block2 = mem.Allocate(50)

# Set memory content
filledBlock = mem.Set(NULL, 65, 10)  // Fill with 'A' characters
? filledBlock  // Outputs: "AAAAAAAAAA"

# Copy operation
sourceData = "Test data to copy"
copiedData = mem.Copy(sourceData, NULL, len(sourceData))
? copiedData  // Outputs: "Test data to copy"

# Compare memory blocks
result = mem.Compare("Hello", "Hello", 5)
? result  // Outputs: 0 (equal)

# Deallocate memory
mem.Deallocate(block1)
mem.Deallocate(block2)

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 4: Advanced Buffer Operations with Search

pr()

# Create buffer with sample data
buf = new stkBuffer("The quick brown fox jumps over the lazy dog")

# Search for patterns
pos = buf.IndexOf("brown")
? "Found 'brown' at position: " + pos  // 0-based index, use Indexof1() for 1-based index
#--> 10

# Search with offset
pos = buf.IndexOfXT("the", 10)
? "Found 'the' after position 10: " + pos
#--> 31

# Create a slice of the buffer
slice = buf.Slice(10, 9)  // Extract "brown fox"
? slice.RawData()
#--> "brown fox"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 5: Complete Workflow - All Classes Together

pr()

# 1. Create buffer with data
mainBuf = new stkBuffer("Original content here")

# 2. Get memory manager from buffer
memMgr = mainBuf.Memory()

# 3. Create additional memory block
extraBlock = memMgr.Allocate(20)
extraBlock = memMgr.Set(NULL, 88, 20)  // Fill with 'X'

# 4. Create pointer to buffer data
bufPtr = mainBuf.GetPointer(0)

# 5. Copy buffer data to new location
newBuf = new stkBuffer(50)
newBuf.Write(0, bufPtr.RingValue())

# 6. Append the extra block
newBuf.Append(extraBlock)

# 7. Display final result
? "Final buffer content: " + newBuf.RawData()

# 8. Show buffer information
newBuf.Show()

# 9. Cleanup
memMgr.Deallocate(extraBlock)

pf()

/*--- Example 6: Pointer Operations and Type Handling

pr()

# Create different types of pointers
intPtr = new stkPointer([42, "int"])
doublePtr = new stkPointer([3.14159, "double"])
stringPtr = new stkPointer(["Test string", "string"])

# Display pointer information
? "Integer pointer value: " + intPtr.RingValue()
? "Double pointer value: " + doublePtr.RingValue()
? "String pointer value: " + stringPtr.RingValue()

# Show pointer details
intPtr.Show()

# Copy between pointers
stringPtr2 = new stkPointer(["", "string", 20])
stringPtr2.CopyFrom(stringPtr, 11)
? "Copied string: " + stringPtr2.RingValue()

pf()

/*--- Example 7: Error Handling and Validation

pr()

# Demonstrate proper error handling
try
    # This will raise an error - negative size
    badBuf = new stkBuffer(-10)
catch
    ? "Caught error: Invalid buffer size"
done

try
    # This will work fine
    goodBuf = new stkBuffer(10)
    goodBuf.Write(0, "Test")
    
    # This will raise an error - reading beyond buffer
    data = goodBuf.Read(5, 20)
catch
    ? "Caught error: Buffer overflow prevented"
done

# Check buffer validity
if goodBuf.IsValid()
    ? "Buffer is valid and ready to use"
    ? "Buffer size: " + goodBuf.Size()
else
    ? "Buffer is invalid"
ok

pf()

#=================================================================#
# MEMORY MANAGEMENT TUTORIAL IN SOFTANZA                          #
# Learning Low-Level Concepts Through High-Level Softanza Classes #
#=================================================================#

/*---

# CONCEPT 1: Memory is like hotel rooms - you request, use, then return them
# Ring automatically manages most memory, but we simulate low-level control

*/
pr()

# CONCEPT 1: Memory is like hotel rooms - you request, use, then return them
# Ring automatically manages most memory, but we simulate low-level control

? "=== STEP 1: BASIC ALLOCATION ==="
# Create a buffer (like booking a hotel room for 50 guests)
buffer1 = new stkBuffer(50)
? "Created buffer with capacity: " + buffer1.Capacity()  # 50 bytes reserved
? "Current size (occupied): " + buffer1.Size()          # 0 bytes used

# RING BEHAVIOR: Ring allocated actual string space automatically
# OUR SIMULATION: We track allocation state and provide low-level interface

? ""
? "=== STEP 2: WRITING DATA (OCCUPYING THE ROOM) ==="
# Write data to buffer (like guests checking into hotel rooms)
buffer1.Write(0, "Hello World")
? "After writing data, size: " + buffer1.Size()         # 11 bytes now used
? "Capacity unchanged: " + buffer1.Capacity()           # Still 50 bytes reserved

# RING BEHAVIOR: String concatenation handled automatically
# LOW-LEVEL CONCEPT: We specify exact byte position and length

? ""
? "=== STEP 3: READING DATA (CHECKING ROOM OCCUPANCY) ==="
# Read specific portions (like checking specific room numbers)
data = buffer1.Read(0, 5)  # Read first 5 bytes
? "Read first 5 bytes: '" + data + "'"                  # "Hello"

data = buffer1.Read(6, 5)  # Read next 5 bytes  
? "Read bytes 6-10: '" + data + "'"                     # "World"

# LOW-LEVEL CONCEPT: Memory is accessed by exact byte positions
# RING BEHAVIOR: String slicing handled automatically behind scenes

? ""
? "=== STEP 4: BUFFER EXPANSION (HOTEL ADDING ROOMS) ==="
# Write beyond current capacity triggers automatic resize
buffer1.Write(60, "Extended")  # Writing at position 60 (beyond capacity 50)
? "After expansion, capacity: " + buffer1.Capacity()    # Automatically grew
? "New size: " + buffer1.Size()                         # Size increased too

# RING BEHAVIOR: Automatic string buffer expansion
# LOW-LEVEL CONCEPT: In C, this would cause buffer overflow crash!

? ""
? "=== STEP 5: POINTER CREATION (ROOM ADDRESS CARDS) ==="
# Create pointer to buffer position (like getting room key card)
ptr = buffer1.GetPointer(0)  # Pointer to start of buffer
? "Pointer type: " + ptr.Type()                         # "string"
? "Pointer address: " + ptr.AddressHex()                # Memory address (simulated)

# LOW-LEVEL CONCEPT: Pointers are memory addresses
# RING BEHAVIOR: We simulate addresses since Ring abstracts this

? ""
? "=== STEP 6: MEMORY COPYING (MOVING BETWEEN ROOMS) ==="
# Create second buffer with direct data
buffer2 = new stkBuffer("Target: Hello World")

? "Source buffer contains: Hello World"
? "Target buffer: '" + buffer2.RawData() + "'"

# LOW-LEVEL CONCEPT: Memory copying moves bytes between locations
# RING BEHAVIOR: String operations handled automatically

? ""
? "=== STEP 7: MEMORY STATES AND VALIDATION ==="
# Check memory states (like hotel occupancy reports)
? "Buffer1 valid: " + buffer1.IsValid()          # TRUE - buffer is usable
? "Buffer1 size: " + buffer1.Size()              # Current data size
? "Buffer1 capacity: " + buffer1.Capacity()      # Total reserved space

# Show memory object state
mem = buffer1.Memory()
? "Memory manager valid: " + mem.IsValid()       # TRUE - memory system working

# LOW-LEVEL CONCEPT: Always validate memory before use
# RING BEHAVIOR: Automatic validation prevents crashes

? ""
? "=== STEP 8: DEALLOCATION (CHECKING OUT OF HOTEL) ==="
# Free memory resources (like returning hotel rooms)
? "Before deallocation:"
? "  Buffer1 valid: " + buffer1.IsValid()        # TRUE
? "  Pointer valid: " + ptr.IsValidPointer()     # TRUE

# Free pointer first (return room key card)
ptr.Free()
? "After pointer free:"
? "  Pointer valid: " + ptr.IsValidPointer()     # FALSE

# Free buffer (return hotel room)
buffer1.Free()
? "After buffer free:"
? "  Buffer1 valid: " + buffer1.IsValid()        # FALSE

# LOW-LEVEL CONCEPT: Always free in reverse order of allocation
# RING BEHAVIOR: Automatic garbage collection as backup safety

? ""
? "=== STEP 9: MEMORY LEAK PREVENTION ==="
# Good practice: Always free allocated resources
buffer2.Free()  # Clean up second buffer too

? "All resources freed - no memory leaks!"
? "Memory manager still valid: " + mem.IsValid()  # TRUE - system still works

# KEY TAKEAWAY: Ring prevents crashes, but explicit management gives control
# BEST PRACTICE: Always pair allocation with deallocation

? ""
? "=== SUMMARY ==="
? "1. ALLOCATION: Reserve memory space (like booking hotel rooms)"
? "2. USAGE: Read/write data at specific positions" 
? "3. VALIDATION: Check memory state before operations"
? "4. DEALLOCATION: Free resources in reverse order"
? "5. RING SAFETY: Automatic garbage collection prevents crashes"
? "6. SOFTANZA POWER: Low-level control with high-level safety"

pf()
