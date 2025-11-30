load "../stzbase.ring"

#---------------------
# stzUuid Class Tests
#--------------------
	
/*--- Basic generation

pr()

# Quick function style

? Uuid()
# CC02DAFB-674E-40AF-A909-10F47F8C62C9

# Or in object-oriented

o1 = new stzUuid()
? o1.Content()
#--> EB2D8987-C83B-4DE8-B3D8-20B058A7201B

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 1.00 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

/*--- Format variations

pr()

o1 = new stzUuid()

? o1.Content()
#--> F78F5731-1E62-4394-AC20-4AB5AF780653

? o1.WithoutHyphens()
#--> F78F57311E624394AC204AB5AF780653

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

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
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

/*--- Null Uuid

pr()

? NullUuid()
#--> 00000000-0000-0000-0000-000000000000

? ""
o1 = new stzUuid()

? o1.IsNull()
#--> FALSE

? o1.Content()
#--> 3D7543C0-E5B4-43B2-B3D6-75A2AF5131D4

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

/*--- Hash

pr()

o1 = new stzUuid()
? o1.Hashed()
#--> 1484387222

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.35 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

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
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.99 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)

/*===
*/
pr()

o1 = new stzString("Ring")
? o1.HasUuid()
#--> FALSE

o1.SetUuid()
? o1.Uuid()
#--> "E1C2A3B4-D74E-459E-99CE-1380D59B6DEC"

? o1.HashedUuid()
#--> "1944623326"

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.37 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)


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
