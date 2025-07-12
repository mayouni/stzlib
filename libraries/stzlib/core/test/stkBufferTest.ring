load "../stklib.ring"

# Comprehensive test suite for stkBuffer class
# Demonstrates all major operations and design patterns

/*--- Test 1: Basic buffer creation and properties

pr()

o1 = new stkBuffer(20)

? o1.Size() # Size starts at 0 since the buffer is still empty
#--> 0

? o1.Capacity()
#--> 20

? o1.IsValid()
#--> TRUE

#NOTE Size represents actual data written, while capacity represents
# total allocated space.

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 2: Buffer creation with initial data

pr()

o1 = new stkBuffer("Hello World")

? o1.Size()
#--> 11

? o1.Capacity()
#--> 11

? o1.RawData()		# Or o1.Content() in Softanza semantics
#--> Hello World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 3: Writing data to buffer

pr()

o1 = new stkBuffer(50)
o1.Write(0, "Hello")	# By default, lowlevel 0-index is used
o1.Write(5, " World")

? o1.Size()
#--> 11

? o1.RawData()
#--> Hello World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 4: Reading data with dual indexing system

pr()

o1 = new stkBuffer("Hello World")

# 0-based indexing (default - low level)
? o1.Read(0, 5)
#--> Hello

? o1.Read(6, 5) + NL
#--> World

# 1-based indexing (high level Ring semantics)
? o1.Read1(1, 5)
#--> Hello

? o1.Read1(7, 5) + NL
#--> World

# Alternative semantic methods
? o1.Range(0, 5)
#--> Hello

? o1.Range1(1, 5)
#--> Hello

? o1.Section(6, 10)
#--> World

? o1.Section1(7, 11)
#--> World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 5: Append and prepend operations

pr()

o1 = new stkBuffer("World")
o1.Prepend("Hello ")
o1.Append("!")

? o1.RawData()
#--> Hello World!

? o1.Size()
#--> 12

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 6: Insert and remove operations

pr()

o1 = new stkBuffer("Hello World")

o1.Insert(5, " Beautiful") # Or InsertAt()
? o1.RawData()
#--> Hello Beautiful World

o1.Remove(5, 10)
? o1.RawData()
#--> Hello World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 7: Search operations with dual indexing

pr()

o1 = new stkBuffer("Hello World Hello")

# 0-based search (default)

? o1.IndexOf("Hello")
#--> 0

? o1.IndexOfXT("Hello", 5)
#--> 12

? o1.IndexOf("xyz") + NL
#--> -1

# 1-based search (Ring semantics)

? o1.IndexOf1("Hello")
#--> 1

? o1.IndexOf1("xyz")
#--> 0

#NOTE You can use FindFirst() instead of IndexOf() for Softanza semantics

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 8: Slice and copy operations

pr()

oBuffer = new stkBuffer("Hello World")
? oBuffer.Slice(6, 5)

oCopy = oBuffer.Copy()
? oCopy.RawData()
#--> Hello World

? oCopy.Equals(oBuffer) + NL
#--> TRUE

# Alternative semantic methods

? oBuffer.Range(6, 5)
#--> World

? oBuffer.Section(6, 10)
#--> World

# 1-based variants
? oBuffer.Range1(7, 5)
#--> World

? oBuffer.Section1(7, 11)
#--> World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 9: Fill operations

pr()

o1 = new stkBuffer(10)
o1.Fill(65, 0, 5)  # Fill with 'A' (ASCII 65)
o1.Fill(66, 5, 5)  # Fill with 'B' (ASCII 66)

? o1.RawData()
#--> AAAAABBBBB

? o1.Size()
#--> 10

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 10: Buffer comparison and copying

pr()

o1 = new stkBuffer("Hello")
o2 = new stkBuffer("Hello")
o3 = o1.Copy()

? o1.Equals(o2)
#--> TRUE

? o1.Equals(o3)
#--> TRUE

o2.Append(" World")
? o1.Equals(o2)
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 11: Buffer resizing and capacity management

pr()

o1 = new stkBuffer(10)
o1.Write(0, "Hello")

? o1.Size()
#--> 5

? o1.Capacity()
#--> 10

o1.Resize(20)

? o1.Capacity()
#--> 20

o1.Compact()
? o1.Capacity()
#--> 5

pf()
# Buffer size mismatch

/*--- Test 12: Clear operation

pr()

o1 = new stkBuffer("Hello World")

? o1.Size()
#--> 11

o1.Clear()

? o1.Size()
#--> 0

? o1.RawData()
#--> (empty string)

pf()
# Buffer size mismatch

/*--- Test 13: File operations - Loading

pr()

# Create a test file
write("test.txt", "Hello from file!")

o1 = new stkBuffer(" ")
o1.LoadFromFile("test.txt")

? o1.Size()
#--> 16

? o1.RawData() + NL
#--> Hello from file!

# Partial loading
o2 = new stkBuffer(1)
o2.LoadFromFileXT("test.txt", 6, 4)  # Load "from"

? o2.RawData()
#--> from

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 14: File operations - Appending

pr()

o1 = new stkBuffer("Start: ")
o1.AppendFromFile("test.txt")

? o1.RawData()
#--> Start: Hello from file!

# Partial appending
o2 = new stkBuffer("Greeting: ")
o2.AppendFromFileXT("test.txt", 0, 5)  # Append "Hello"

? o2.RawData()
#--> Greeting: Hello

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 15: File operations - Saving

pr()

o1 = new stkBuffer("Save this content")
o1.SaveToFileAll("output.txt")

cFileContent = read("output.txt")

? cFileContent
#--> Save this content

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 16: Binary data handling

#TODO Add the capability to stkBuffer to read and save binary files

/*--- Test 17: Pointer integration

pr()

oBuffer = new stkBuffer("Hello World")

oPointer = oBuffer.RangeToPointer(6, 5)
? oPointer.Type()
#--> string

? oPointer.RingValue()
#--> World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 18: Error handling

pr()

o1 = new stkBuffer("Hello")

try
    o1.Read(10, 5)  # Read beyond buffer
    ? "Should not reach here"
catch
    ? "Caught expected error: " + cCatchError
    #--> Caught expected error: ERROR: Offset (10) beyond buffer size (5)
done
#--> Caught expected error: ERROR: Offset (10) beyond buffer size (5)

? ""

try
    o2 = new stkBuffer(-5)
catch
    ? "Expected error: " + CatchError()
    #--> Expected error: Buffer size must be positive
done
#--> Expected error: Buffer size must be positive

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 19: Memory management and cleanup

pr()

o1 = new stkBuffer("Test data")

? o1.IsValid()
#--> TRUE

o1.Free()

? o1.IsValid()
#--> FALSE



try
    o1.Size()  # Should fail on invalid buffer
    ? "Should not reach here"
catch
    ? "Caught expected error: " + CatchError()
    #--> Caught expected error: ERROR: Invalid buffer - buffer was not properly initialized
done
#--> Caught expected error: Invalid buffer - buffer was not properly initialized.

pf()

/*--- Test 20: Performance with large buffers

pr()

nStart = clock()
oLargeBuffer = new stkBuffer(10000)
oLargeBuffer.Fill(88, 0, 10000)  # Fill with 'X'

? oLargeBuffer.Size()
#--> 10000

? clock() - nStart
#--> 1 (second)

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 21: Network packet example (practical use case)

pr()

# This sample use tje NetworkPacket class fellowing this code

packet = new NetworkPacket()
headerSize = packet.addHeader(6, "192.168.1.1", "192.168.1.2")
packet.addPayload(headerSize, "Hello Network!")

? packet.getPacket()  # Binary packet data
#--> 192.192.Hello Network!

pf()
# Executed in almost 0 second(s) in Ring 1.22

	# Simulating network packet construction
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
	
/*--- Test 22: Safe memory alternative example

pr()

# Instead of malloc() and potential crashes

oBuffer = new stkBuffer(100)
oBuffer.Write(0, "Hello, World!")
data = oBuffer.Read(0, 13)

? data
#--> Hello, World!

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 23: Arabic text handling (UTF-8 demonstration)
*/
pr()

# Note how buffers deal with bytes and not chars, and how one arabic char
# is actually stored on multiple bytes

o1 = new stkBuffer(50)
o1.Write(0, "رمضان")
o1.Write(10, " كريم")

? o1.Size()
#--> 20

? o1.RawData()
#--> رمضان كريم

pf()
# Executed in almost 0 second(s) in Ring 1.22
