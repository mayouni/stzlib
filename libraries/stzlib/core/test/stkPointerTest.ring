load "../stklib.ring"

/*--- Test file for the FIXED stkPointer class
# This demonstrates that all the synchronization issues have been resolved

/*--- Test 1: Basic string pointer creation and conversion

pr()

o1 = new stkPointer("Hello World")

? o1.RingValue()
#--> Hello World

? o1.Type()
#--> string

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 2: The original failing case - copyFrom operation

pr()

oSource = new stkPointer("SOURCE_DATA")
oDest = StkStringPointerQ("", 20)  # Empty destination buffer

# Before copy

? oSource.RingValue() 	#--> SOURCE_DATA
? oDest.RingValue()		#--> ""


# Perform memory copy

oDest.CopyFrom(oSource, 6)  # Copy first 6 bytes

# After copy

? oSource.RingValue()		#--> SOURCE_DATA
? oDest.RingValue()			#--> SOURCE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 3: Integer pointer operations

pr()

oInt = new stkPointer([ 42, "int" ])

? oInt.RingValue()	#--> 42
? oInt.Type()		#--> int

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 4: Double pointer operations

pr()

decimals(5)

oDouble = new stkPointer([3.14159, "double"])

? oDouble.RingValue()	#--> 3.14159
? oDouble.Type()		#--> double

decimals(2)

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 5: Buffer modifications and synchronization

pr()

oBuffer = StkStringPointerQ("ORIGINAL", 20)
? oBuffer.RingValue()
#--> ORIGINAL

# Modify through CopyFrom

oNew = new stkPointer("MODIFIED")
oBuffer.CopyFrom(oNew, 8)

# After copyFrom 'MODIFIED'

? oBuffer.RingValue()
#--> MODIFIED

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test with partial copy

pr()

oBuffer = new stkPointer("SUNDAY")
oPartial = new stkPointer("MON")

oBuffer.CopyFrom(oPartial, 3)

# After CopyFrom 'MON' (3 bytes)

? oBuffer.RingValue()
#--> MONDAY

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 6: Copy chain operations

pr()

o1 = new stkPointer("STEP1")
o2 = StkStringPointerQ("", 10)
o3 = StkStringPointerQ("", 10)

? o1.RingValue()	#--> STEP1

o2.CopyFrom(o1, 5)
? o2.RingValue()	#--> STEP1

o3.CopyFrom(o2, 5)
? o3.RingValue()	#--> STEP1

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 7: Object pointer operations

pr()

aList = [1, 2, 3, "test"]
oObj = new stkPointer([aList, "list"])

? oObj.RingValue()
#--> [1, 2, 3, "test"]

? oObj.Type()
#--> list

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 8: Bounds checking

pr()

oSmall = StkStringPointerQ("", 5)  # Small buffer
oLarge = new stkPointer("VERYLONGSTRING")

? oLarge.RingValue()
#--> VERYLONGSTRING

oSmall.CopyFrom(oLarge, 10)  # Try to copy more than buffer size

# After copying 10 bytes to 5-byte buffer

? oSmall.RingValue()
#--> VERYLONGST

? len(oSmall.RingValue())
#--> 10

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 9: Null termination (#TODO Explain null-termination)

pr()

oNullTerm = StkStringPointerQ("TEST", 10)
value = oNullTerm.RingValue()

? value			#--> TEST
? len(value)	#--> 4

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Test 10: Debug information

pr()

oDebug = new stkPointer("DEBUG_TEST")
? list2code(oDebug.debug()) + NL
#-->
'
[
	[
		"logical_type",
		"string"
	],
	[
		"isvalid",
		1
	],
	[
		"buffer_size",
		11
	],
	[
		"buffer_content",
		"DEBUG_TEST"
	],
	[
		"ring_value",
		"DEBUG_TEST"
	]
]
'

? oDebug.show()
#-->
'
[
	[
		"address",
		"293D588CC24"
	],
	[
		"type",
		"string"
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
		11
	]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.22
