load "stzlib.ring"


/*----

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
#--> 20

obj = new TempObject
? SizeInBytes(obj) 
#--> 20

proff()
# Executed in 0.02 second(s).

class TempObject
	Language = "Ring"
	Version = 20
	InArabic = "رينغ"

/*=========
*/

pron()

? 54_687.58 / 1024 + NL

? SizeInBytes(12)
#--> 56

? SizeInBytes([12])
#--> 136

? SizeInBytes(1:100)
#--> 5680

? SizeInBytes(1:1_000_000)
#--> 56_000_080

	? SizeInMegaBytes(1:1_000_000)
	#--> 54_687.58

	? SizeInGigaBytes(1:1_000_000) + NL
	#--> 53.41


? SizeInGigaBytes(1:100_000_000)
#--> 5340.58

	? SizeInTeraBytes(1:100_000_000)
	#--> 0.01

proff()
# Executed in 13.61 second(s).
