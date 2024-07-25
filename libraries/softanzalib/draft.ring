load "stzlib.ring"

decimals(3)

pron()

? Q(20).SizeInBytes()
#--> 8

? Q("両").SizeInBytes()
#--> 3

? Q([ 20, "両" ]).SizeInBytes()
#--> 11

? Q([ "Ring", 20, "رينغ" ]).SizeInBytes()
#--> 20

? Q(new TempObject).SizeInBytes() # 7 more bytes taken by internal stzObject attributes
#--> 27

proff()

class TempObject
	Language = "Ring"
	Version = 20
	InArabic = "رينغ"

/*----

pron()

? SizeInBytes("Ring")
#--> 4

? SizeInBytes(20)
#--> 8

? SizeInBytes("رينغ")
#--> 8

? SizeInBytes([ "Ring", 20, "رينغ" ])
#--> 44

obj = new TempObject
? SizeInBytes(obj) 
#--> 20

proff()
# Executed in 0.02 second(s).

class TempObject
	Language = "Ring"
	Version = 20
	InArabic = "رينغ"
