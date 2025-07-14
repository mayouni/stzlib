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
? filledBlock
#--> "AAAAAAAAAA"

# Copy operation
sourceData = "Test data to copy"
copiedData = mem.Copy(sourceData, NULL, len(sourceData))
? copiedData
#--> "Test data to copy"

# Compare memory blocks
result = mem.Compare("Hello", "Hello", 5)
? result
#--> 0 (equal)

# Deallocate memory
mem.Deallocate(block1)
mem.Deallocate(block2)

? mem.IsAllocated(block1) #--> FALSE
? mem.IsAllocated(block2) #--> FALSE

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

# 7. Display final buffer content
? newBuf.RawData()
#--> "Original content here XXXXXXXXXXXXXXXXXXXX"

# 8. Show buffer information
? newBuf.Info()
#--> [
#	[ "size", 42 ],
#	[ "capacity", 50 ]
# ]

# 9. Cleanup
memMgr.Deallocate(extraBlock)
? memMgr.IsAllocated(extraBlock)
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 6: Pointer Operations and Type Handling

pr()

# Create different types of pointers
intPtr = new stkPointer([42, "int"])
doublePtr = new stkPointer([3.14159, "double"])
stringPtr = new stkPointer(["Test string", "string"])

# Display pointer information
? intPtr.RingValue() 		#--> 42
? doublePtr.RingValue() 	#--> 31.4
? stringPtr.RingValue() 	#--> Test string

# Show pointer details
? list2code(intPtr.Info())
#-->
'
[
	[
		"address",
		"222B546DBC0"
	],
	[
		"type",
		"int"
	],
	[
		"status",
		0
	],
	[
		"valid",
		1
	],
	[
		"managed",
		1
	],
	[
		"buffer_size",
		4
	]
]
'

# Copy between pointers

stringPtr2 = new stkPointer(["", "string", 20])
stringPtr2.CopyFrom(stringPtr, 11)

# Copied string
? stringPtr2.RingValue()
#--> Test string

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 7: Error Handling and Validation

pr()

# Demonstrate proper error handling
try
    # This will raise an error - negative size
    badBuf = new stkBuffer(-10)
catch
    ? "Caught error: Invalid buffer size"
done
#--> Caught error: Invalid buffer size


try
    # This will work fine
    goodBuf = new stkBuffer(10)
    goodBuf.Write(0, "Test")
    
    # This will raise an error - reading beyond buffer
    data = goodBuf.Read(5, 20)
catch
    ? "Caught error: Buffer overflow prevented"
done
#--> Caught error: Buffer overflow prevented


# Check buffer validity
if goodBuf.IsValid()
    ? "Buffer is valid and ready to use"
    ? "Buffer size: " + goodBuf.Size()
else
    ? "Buffer is invalid"
ok
#--> Buffer is valid and ready to use
# Buffer size: 4

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=================================================================#
# MEMORY MANAGEMENT TUTORIAL IN SOFTANZA                          #
# Learning Low-Level Concepts Through High-Level Softanza Classes #
#=================================================================#

/*---

# CONCEPT 1: Memory is like hotel rooms - you request, use, then return them
# Ring automatically manages most memory, but we simulate low-level control


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
? "=== STEP 9: DEALLOCATION (CHECKING OUT OF HOTEL) ==="
# Free memory resources (like returning hotel rooms)
? "Before deallocation:"
? "  Buffer1 valid: " + buffer1.IsValid()        # TRUE
? "  Pointer valid: " + ptr.IsValidPointer()     # TRUE

# Free pointer first (return room key card)
ptr.Free()
? "After pointer free:"
? "  Pointer valid: " + ptr.IsValidPointer()     # FALSE

# Free buffers (return hotel rooms)
buffer1.Free()

? "After buffer free:"
? "  Buffer1 valid: " + buffer1.IsValid()        # FALSE

# LOW-LEVEL CONCEPT: Always free in reverse order of allocation
# RING BEHAVIOR: Automatic garbage collection as backup safety

? ""
? "=== STEP 10: MEMORY LEAK PREVENTION ==="
# Good practice: Always free allocated resources
? "All resources freed - no memory leaks!"
? "Memory manager still valid: " + mem.IsValid()  # TRUE - system still works

# KEY TAKEAWAY: Ring prevents crashes, but explicit management gives control
# BEST PRACTICE: Always pair allocation with deallocation

pf()
# Executed in 0.01 second(s) in Ring 1.22

#============================================#
#  SAMPLES OF THE SOFTANZA LOWLEVEL ARTICLE  #
#============================================#

/*---

pr()

# Create a buffer - like a box that holds 50 bytes
oBuffer = new stkBuffer(50)

# It's empty at first
? oBuffer.Size()        #--> 0 (nothing in it yet)
? oBuffer.Capacity()    #--> 50 (but it can hold 50 bytes)

# Put some data in it
oBuffer.Write(0, "Hello")
? oBuffer.Size()        #--> 5 (now it has 5 bytes)

# Read it back
? oBuffer.Read(0, 5)    #--> "Hello"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

oBuffer = new stkBuffer("Hello World")

# 0-based indexing (systems programming style)
? oBuffer.Read(0, 5)    #--> "Hello"
? oBuffer.Read(6, 5)    #--> "World"
? ""

# 1-based indexing (Ring style)
? oBuffer.Read1(1, 5)   #--> "Hello"
? oBuffer.Read1(7, 5)   #--> "World"
? ""

# Alternative semantic methods
? oBuffer.Range(0, 5)   # --> "Hello"
? oBuffer.Section(6, 10) # --> "World"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Create a pointer to some data
oPointer = new stkPointer("Secret Data")

# See where it "points" (simulated address)
? oPointer.AddressHex()  #--> "1B70A91DC24"

# Access the data through the pointer
? oPointer.RingValue()   #--> "Secret Data"

# Create from buffer range
oBuffer = new stkBuffer("Hello World")
oPointer = oBuffer.RangeToPointer(6, 5)
? oPointer.RingValue()   #--> "World"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

oMemory = new stkMemory()
block1 = oMemory.Allocate(100)  # "Give me 100 bytes"
block2 = oMemory.Allocate(200)  # "Give me 200 bytes"

# Use the memory - Fill returns the modified buffer
block1 = oMemory.Fill(block1, 65, 100)    # Fill with 'A' characters
data = oMemory.Read(block1, 10)  # Read first 10 bytes
? data
#--> AAAAAAAAAA

pf()
# Executed in almost 0 second(s) in Ring 1.22


/*--- Example 1: Building a Simple Text Buffer

pr()

# Create a text editor's internal buffer
textBuffer = new stkBuffer(200)

# Add text piece by piece
textBuffer.Write(0, "Hello ")
textBuffer.Write(6, "World!")

# Read the whole thing
? textBuffer.Read(0, 12)  # --> "Hello World!"
#--> Hello World!

# Insert text in the middle (real text editors do this)
textBuffer.Insert(6, "Beautiful ")
? textBuffer.RawData()    # --> "Hello Beautiful World!"
#--> Hello Beautiful World!

# Remove text
textBuffer.Remove(6, 10)  # Remove "Beautiful "
? textBuffer.RawData()    # --> "Hello World!"
#--> Hello World!

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 2: Safe Buffer Operations with Error Handling

pr()

# The framework protects you from dangerous operations
oBuffer = new stkBuffer("Hello")

try
    # Try to read beyond the buffer
    oBuffer.Read(10, 5)  # Reading beyond buffer size
catch
    ? "Buffer overflow caught safely!"
    ? "Error: " + CatchError()
    # --> ERROR: Offset (10) beyond buffer size (5)
done
#--> Buffer overflow caught safely!
# Error: ERROR: Offset (10) beyond buffer size (5)

? ""
# Safe way to check bounds
if oBuffer.Size() >= 15
    data = oBuffer.Read(10, 5)
else
    ? "Not enough data - buffer only has " + oBuffer.Size() + " bytes"
ok
#--> Not enough data - buffer only has 5 bytes

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 3: File Operations - Loading and Saving

pr()

# Create a test file
write("test.txt", "Hello from file!")

# Load entire file into buffer
oBuffer = new stkBuffer(1) # A buffer must contain at least one memory position
oBuffer.LoadFromFile("test.txt")
? oBuffer.RawData()
#--> "Hello from file!"

# Partial loading
? ""
oBuffer2 = new stkBuffer(1)
oBuffer2.LoadFromFileXT("test.txt", 6, 4)  # Load "from"
? oBuffer2.RawData()
#--> "from"

# Save buffer to file
oBuffer.SaveToFileAll("output.txt")
# INFO: Successfully saved 16 bytes to 'output.txt'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Example 4: Network Packet Construction

pr()

# Practical example: building network packets

# Using the packet builder
packet = new NetworkPacket()
headerSize = packet.AddHeader(6, "192.168.1.1", "192.168.1.2")
packet.AddPayload(headerSize, "Hello Network!")
? packet.GetPacket()  # --> Complete packet data
#--> 192.192.Hello Network!

pf()
# Executed in almost 0 second(s) in Ring 1.22

class NetworkPacket
    buffer = new stkBuffer(1500)  # Standard Ethernet MTU

	def init()

    def AddHeader(protocol, source, dest)
        # Protocol header (simplified)
        buffer.Write(0, char(protocol))
        buffer.Write(1, source)
        buffer.Write(5, dest)
        return 9  # Header size
    
    def AddPayload(headerSize, data)
        buffer.Write(headerSize, data)
        
    def GetPacket()
        return buffer.RawData()

/*--- Example 5: Understanding Memory Layout

pr()

# Demonstrate how arrays work under the hood
oBuffer = new stkBuffer(20)

# Manually store integers as bytes (simplified)
oBuffer.Write(0, char(42))     # array[0] = 42
oBuffer.Write(1, char(17))     # array[1] = 17  
oBuffer.Write(2, char(99))     # array[2] = 99

# Read them back
? ascii(oBuffer.Read(0, 1))  #--> 42
? ascii(oBuffer.Read(1, 1))  #--> 17
? ascii(oBuffer.Read(2, 1))  #--> 99

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Search and Pattern Matching

pr()

oBuffer = new stkBuffer("Hello World Hello")

# 0-based search (systems programming style)
? oBuffer.IndexOf("Hello")      #--> 0
? oBuffer.IndexOfXT("Hello", 5) #--> 12
? oBuffer.IndexOf("xyz")        #--> -1
? ""

# 1-based search (Ring style)
? oBuffer.IndexOf1("Hello")     #--> 1
? oBuffer.IndexOf1("xyz")       #--> 0

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Buffer Manipulation

pr()

oBuffer = new stkBuffer("World")

# Prepend and append
oBuffer.Prepend("Hello ")
oBuffer.Append("!")
? oBuffer.RawData()
#--> "Hello World!"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Fill operations

pr()

oBuffer2 = new stkBuffer(10)
oBuffer2.Fill(65, 0, 5)  # Fill with 'A' (ASCII 65)
oBuffer2.Fill(66, 5, 5)  # Fill with 'B' (ASCII 66)
? oBuffer2.RawData()
#--> "AAAAABBBBB"

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Memory Management

pr()

oBuffer = new stkBuffer(10)
oBuffer.Write(0, "Hello")

? oBuffer.Capacity()  #--> 10
? oBuffer.Size()      #--> 5

# Resize buffer
oBuffer.Resize(20)
? oBuffer.Capacity()  #--> 20

# Compact to minimum size
oBuffer.Compact()
? oBuffer.Capacity()  #--> 5 (fits exactly)

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---
*/
pr()

# Why Pointers Are Powerful and Dangerous.
# Pointers let you have multiple "names" for the same data

original = new stkPointer("Shared Data")
alias = original  # Now both point to the same memory

# Change through one pointer
original.Update("Modified!")

# See the change through the other
? alias.RingValue()  # --> "Modified!"

pf()
