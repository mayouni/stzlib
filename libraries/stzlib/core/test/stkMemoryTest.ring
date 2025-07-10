load "../stklib.ring"

# Enhanced Examples of Use - stkBuffer, stkMemory, and stkPointer Synergy

/*--- Example 1: Basic Buffer Operations
*/
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
# Create a buffer with initial data
buf = new stkBuffer("Initial data for testing")

# Get a pointer to a specific position in the buffer
ptr = buf.GetPointer(8)  // Points to "data for testing"

# Access data through the pointer
data = ptr.RingValue()
? data  // Outputs: "data for testing"

# Create another pointer from string data
strPtr = new stkPointer(["Hello from pointer", "string"])
? strPtr.RingValue()  // Outputs: "Hello from pointer"

/*--- Example 3: Memory Management and Copying
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

/*--- Example 4: Advanced Buffer Operations with Search
# Create buffer with sample data
buf = new stkBuffer("The quick brown fox jumps over the lazy dog")

# Search for patterns
pos = buf.IndexOf("brown")
? "Found 'brown' at position: " + pos  // 0-based index

# Search with offset
pos = buf.IndexOfXT("the", 10)
? "Found 'the' after position 10: " + pos

# Create a slice of the buffer
slice = buf.Slice(10, 9)  // Extract "brown fox"
? slice.RawData()  // Outputs: "brown fox"

/*--- Example 5: Complete Workflow - All Classes Together
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

/*--- Example 6: Pointer Operations and Type Handling
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

/*--- Example 7: Error Handling and Validation
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
