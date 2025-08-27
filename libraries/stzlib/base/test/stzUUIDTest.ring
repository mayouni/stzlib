load "../stzbase.ring"


/*--- SOFTANZA TRUTH, EMPTINESS, and NULLINESS

# Only empty strings and the NullObject() are considered null,
# everything else is not null

? IsNull("") #--> TRUE
? IsNull([]) #--> FALSE
? IsNull(0) #--> FALSE
? IsNull(NullObject()) #--> TRUE
? IsNull(TrueObject()) #--> FALSE
? IsNull(FalseObject()) #--> FALSE

? ""
# Emptiness applies to "" for strings, [] for lists, and NullObject() for objects

? IsEmpty("") #--> TRUE
? IsEmpty([]) #--> TRUE
? IsEmpty(0) #--> FALSE
? IsEmpty(NullObject()) #--> TRUE
? IsEmpty(FalseObject()) #--> FALSE


#TODO Everything is true except 0, "", FalseObject(), and NullObject()
# Make a simular article to this:
# https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/base/doc/narrations/stzstring-emptiness-narration.md

? ""

? IsTrue("") #--> FALSE
? IsTrue(0) #--> FALSE
? IsTrue(NullObject()) #--> FALSE
? IsTrue(FalseObject()) #--> FALSE

? IsTrue(123) #--> TRUE
? IsTrue(-23) #--> TRUE

? IsTrue("text") #--> TRUE
? IsTrue([1, 2, 3]) #--> TRUE
? IsTrue([]) #--> TRUE

? ""

? IsFalse("") #--> TRUE
? IsFalse(0) #--> TRUE
? IsFalse(NullObject()) #--> TRUE
? IsFalse(FalseObject()) #--> TRUE

? IsFalse(123) #--> FALSE
? IsFalse(-23) #--> FALSE

? IsFalse("text") #--> FALSE
? IsFalse([1, 2, 3]) #--> FALSE
? IsFalse([]) #--> False

*/

# stzUUID Class Tests
#--------------------
	
/*--- Basic generation

pr()

oUUID1 = new stzUUID(NULL)
?  oUUID1.UUID()
#--> 67FF86AE-5CBD-4FC5-95A9-A455E75B8D7C

pf()
	
/*--- Create from string

pr()

oUUID2 = new stzUUID("550e8400-e29b-41d4-a716-446655440000")
? oUUID2.UUID()
#--> 550E8400-E29B-41D4-A716-446655440000

pf()

/*--- Format variations

pr()

oUUID2 = new stzUUID("550e8400-e29b-41d4-a716-446655440000")

# From string
? oUUID2.UUID()
#--> 550E8400-E29B-41D4-A716-446655440000

? oUUID2.WithoutHyphens()
#--> 550E8400E29B41D4A716446655440000

? oUUID2.ToLower()
#--> 550e8400-e29b-41d4-a716-446655440000

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Version and variant

pr()

oUUID2 = new stzUUID("550e8400-e29b-41d4-a716-446655440000")

? oUUID2.UUID()

? oUUID2.Version()
#--> 4

? oUUID2.Variant()
#--> RFC 4122

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Comparison

pr()

oUUID1 = new stzUUID(NULL)
? oUUID1.UUID()

oUUID3 = new stzUUID(NULL)
? oUUID3.UUID()

? oUUID1.Equals(oUUID3)

pf()

/*--- Nil UUID

pr()

oUUID = new stzUUID(NULL)

oNilUUID = oUUID.Nil()
? oNilUUID.UUID()
#--> 00000000-0000-0000-0000-000000000000

? oNilUUID.IsNil()
#--> TRUE

pf()
# Executed in 0.28 second(s) in Ring 1.23

/*--- Byte conversion

pr()

stzUUID = new stzUUID(NULL)
oUUID2 = new stzUUID("550e8400-e29b-41d4-a716-446655440000")

	aBytes = oUUID2.ToBytes()

	? "Byte array length: " + len(aBytes)
	oFromBytes = stzUUID.FromBytes(aBytes)
	? "Reconstructed: " + oFromBytes.UUID()
	? "Equal to original: " + oUUID2.Equals(oFromBytes)

pf()

/*--- Hash

pr()

oUUID2 = new stzUUID("550e8400-e29b-41d4-a716-446655440000")
? oUUID2.Hash()
#--> 513707056

pf()

/*--- Multiple generations
*/
pr()

for i = 1 to 3
	oTemp = new stzUUID(NULL)
	? "  " + oTemp.UUID()
next
#-->
# A3948468-EDE8-49C8-BF5D-C0F33DF8CD37
# 3DF8AA84-A3BB-4CFC-AA23-5AC163AF0FF7
# 08C8B293-4B36-4AF1-86B9-715CDC6494DC

pf()
