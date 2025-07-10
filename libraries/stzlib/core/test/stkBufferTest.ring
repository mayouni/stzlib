load "../stklib.ring"

# Test file for the stkBuffer class
# This demonstrates buffer operations and integration with stkPointer

/*--- Test 1: Basic buffer creation with size

pr()

oBuffer1 = new stkBuffer(20)

? oBuffer1.Size() # Size starts at 0 since the buffer is still empty
#--> 0

? oBuffer1.Capacity()
#--> 20

? oBuffer1.IsValid()
#--> TRUE

#NOTE // Size represents actual data written, while capacity represents
# total allocated space.

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 2: Buffer creation with initial data

pr()

oBuffer2 = new stkBuffer("Hello World")

? oBuffer2.Size()
#--> 11

? oBuffer2.RawData()
#--> Hello World

? oBuffer2.Read(0, 5)
#--> Hello

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 3: Write operations and buffer growth

pr()

oBuffer3 = new stkBuffer(10)
oBuffer3.Write(0, "Hello")	# writes 5 characters at position 0
oBuffer3.Write(5, " World")	# writes 6 characters at position 5

? oBuffer3.Size()	# Total length: 5 + 6 = 11 characters
#--> 11

? oBuffer3.RawData()
#--> Hello World

? oBuffer3.Capacity()
#--> 11

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 4: Append and prepend operations

pr()

oBuffer4 = new stkBuffer("World")
oBuffer4.Prepend("Hello ")
oBuffer4.Append("!")

? oBuffer4.RawData()
#--> Hello World!

? oBuffer4.Size()
#--> 12

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 5: Insert and remove operations

pr()

oBuffer5 = new stkBuffer("Hello World")
oBuffer5.Insert(5, " Beautiful")
oBuffer5.Remove(5, 10)

? oBuffer5.RawData()
#--> Hello World

? oBuffer5.Size()
#--> 11

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 6: Search operations

pr()

oBuffer6 = new stkBuffer("Hello World Hello")

? oBuffer6.IndexOf("Hello")
#--> 0

? oBuffer6.IndexOf([ "Hello", 1 ])
#--> 12

? oBuffer6.IndexOf("Missing") + NL
#--> -1

# By default, these methods use the lower level 0-index positions.
# If you prefere staying at the high level and use Ring 1-index instead,
# just add 1 at the end of these methods (and any other position method):

? oBuffer6.IndexOf1("Hello")
#--> 1

? oBuffer6.IndexOf1([ "Hello", 1 ])
#--> 13

? oBuffer6.IndexOf1("Missing")
#--> 0

#NOTE that you can use IndexOf0() as an alternative to IndexOf(), and you
# can use FindFirst() instead of IndexOf() to cope with Softanza semantics
pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 7: Slice and copy operations
*/
pr()

oBuffer7 = new stkBuffer("Hello World")
oSlice = oBuffer7.Slice(6, 5)
oCopy = oBuffer7.Copy()

? oSlice.RawData()
#--> World

? oCopy.RawData()
#--> Hello World

? oCopy.Equals(oBuffer7) + NL
#--> TRUE

#NOTE To cope with Softanza semanctics, you can use Range() instead of Slice

? oBuffer7.Range(6, 5).RawData()
#--> World

# Also, you can use Section(nStart, nEnd)

? oBuffer7.Section(6, 10).RawData() + NL
#--> World

# By default, Slice(), Range() and Section(), and other position methods
# like IndexOf() / FindFirst(), all use 0-index positioning bu=y default.
# Which is what we should expect when working with sutch a low level construct.
# But you can easily chnage this by opting for the higher level Ring 1-index
# positiong, by just adding 1 to the end of the methods, like this:

? oBuffer7.Range1(7, 5).RawData() # Note 7 instead of 6
#--> World

? oBuffer7.Section1(7, 11).RawData() + NL
#--> World

# Of course, you can add 0 to the methods and still get the default behavoir:

? oBuffer7.Range0(6, 5).RawData() # Note how we switched back to 0-index with 6
#--> World

? oBuffer7.Section0(6, 10).RawData()
#--> World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 8: Fill operations

pr()

oBuffer8 = new stkBuffer(10)
oBuffer8.Fill(65, 0, 5)  # ASCII 'A'
oBuffer8.Fill(66, 5, 5)  # ASCII 'B'

? oBuffer8.RawData()
#--> AAAAABBBBB

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 9: Pointer integration

pr()

oBuffer9 = new stkBuffer("Hello World")
oPointer = oBuffer9.GetPointer(6)

? oPointer.Type()
#--> string

? oPointer.RingValue()
#--> World

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 10: Error handling

pr()

try
    oBuffer10 = new stkBuffer(-5)
catch
    ? "Expected error: " + cCatchError
    #--> Expected error: Buffer size must be positive
done

try
    oBuffer11 = new stkBuffer(10)
    oBuffer11.Read(5, 10)
catch
    ? "Expected error: " + cCatchError
    #--> Expected error: Buffer overflow prevented!
done

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 11: Memory management

pr()

oBuffer12 = new stkBuffer("Test Data")
oBuffer12.Clear()

? oBuffer12.Size()
#--> 0 (buffer was cleared)

? len(oBuffer12.RawData())
#--> 9 (capacity maintained)

oBuffer12.Compact() # (compact didn't run since size is 0)

? oBuffer12.Capacity()
#--> 0

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 12: Performance with large buffers
*/
pr()


nStart = clock()
oLargeBuffer = new stkBuffer(10000)
oLargeBuffer.Fill(88, 0, 10000)  # Fill with 'X'

# Large buffer size

? oLargeBuffer.Size()
#--> 10000

# Time taken

? clock() - nStart
#--> 1 (second)

pf()
# Executed in almost 0 second(s) in Ring 1.22
