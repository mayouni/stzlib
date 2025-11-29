load "../stzbase.ring"
load "uuid.ring"

/*---

pr()

? uuid_generate()
#--> ce89386e-61a9-4de3-98f2-9189f0cb76c3

pf()
# Executed in almost 0 second(s) in Ring

/*---

pr()

for n = 1 to 5
	? uuid_generate()
next
#-->
'
5ba2398e-944b-47fb-b6d7-7d05951d11b3
e569cbf7-3139-471d-9655-8ed7a65ec825
555d69d3-259c-45c0-8944-8160d8e69522
589120c5-1332-4b66-82a3-4e37059b13c9
f7ab4434-1095-490d-aff5-7197b7c5207f
'

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*---

pr()

cUUID = "550e8400-e29b-41d4-a716-446655440000"
? uuid_isvalid(cUUID)

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--
*/
pr()

? uuid_nil()

pf()

#---------------------
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
# Executed in 1.00 second(s) in Ring 1.24

/*--- Format variations

pr()

o1 = new stzUuid()

# From string
? o1.Content()
#--> 550E8400-E29B-41D4-A716-446655440000

? o1.WithoutHyphens()
#--> 550E8400E29B41D4A716446655440000

pf()
# Executed in 0.36 second(s) in Ring 1.24

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
# Executed in 0.36 second(s) in Ring 1.24

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
# Executed in 0.36 second(s) in Ring 1.24

/*--- Hash

pr()

o1 = new stzUuid()
? o1.Hashed()
#--> 2146197897

pf()
# Executed in 0.35 second(s) in Ring 1.24

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
# Executed in 0.99 second(s) in Ring 1.24

/*===
*/
pr()

o1 = new stzString("Ring")
? o1.HasUuid()
#--> FALSE

o1.SetUuid()
? o1.Uuid()
#--> "076A1822-F061-4943-A67C-9DD569115B84"

? o1.HashedUuid()
#--> "738121558"

pf()
# Executed in 0.37 second(s) in Ring 1.24


/*=== #ring #ref

pr()

oMyPoint = new Point
aInnerList = [1, 2, 3]

aList = [ 22, ref(oMyPoint), "B", ref(aInnerList) ]

? find(aList, 22) 		#--> 1
? find(aList, "B")		#--> 3
? find(aList, aInnerList) 	#--> 2
? find(aList, oMyPoint)		#--> 4

pf()
# Executed in almost 0 second(s) in Ring 1.24

class Point { x=10 y=10 z=10 }

/*--- #ring

pr()

myList1 = [new Company {position=3 name="Mahmoud" symbol="MHD"},
           new Company {position=2 name="Bert" symbol="BRT"},
           new Company {position=1 name="Ring" symbol="RNG"}
          ]

see find(mylist1,"Bert", 1, "name") #--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.24

class company position name symbol
