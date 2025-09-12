load "../stzbase.ring"

# stzUuid Class Tests
#--------------------
	
/*--- Basic generation

pr()

# Quick function style

? Uuid()
# ED8FD5F3-9FA8-4055-884D-CD8FEBD62D61

# Or in object-oriented

o1 = new stzUuid()
? o1.Content()
#--> CEA2F100-0E5E-4851-A516-F4A5FF4D56E5

pf()
# Executed in 0.27 second(s) in Ring 1.23

/*--- Format variations

pr()

o1 = new stzUuid()

# From string
? o1.Content()
#--> 550E8400-E29B-41D4-A716-446655440000

? o1.WithoutHyphens()
#--> 550E8400E29B41D4A716446655440000

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Version and variant

pr()

o1 = new stzUuid()

? o1.Content()
# 9450E590-8628-4428-AC76-B46CBDBC1CFC

? o1.Version()
#--> 4

? o1.Variant()
#--> RFC 4122

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Null Uuid

pr()

? NullUuid()
#--> 00000000-0000-0000-0000-000000000000

? ""
o1 = new stzUuid()

? o1.IsNull()
#--> FALSE

? o1.Content()
#--> 32AB6BFF-07C7-4CAC-92C6-D4A775194D42

pf()
# Executed in 0.28 second(s) in Ring 1.23

/*--- Hash

pr()

o1 = new stzUuid()
? o1.Hashed()
#--> 2146197897

pf()

/*--- Multiple generations

pr()

for i = 1 to 3
	? Uuid()
next
#-->
# A3948468-EDE8-49C8-BF5D-C0F33DF8CD37
# 3DF8AA84-A3BB-4CFC-AA23-5AC163AF0FF7
# 08C8B293-4B36-4AF1-86B9-715CDC6494DC

pf()
# Executed in 0.78 second(s) in Ring 1.23

/*===
*/
pr()

o1 = new stzString("Ring")
? o1.HasUuid()
#--> FALSE

o1.SetUuid()
? o1.Uuid()
#--> 076A1822-F061-4943-A67C-9DD569115B84

? o1.HashedUuid()
#--> 738121558

pf()
# Executed in 0.51 second(s) in Ring 1.23
