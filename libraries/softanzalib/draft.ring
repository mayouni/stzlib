load "stzlib.ring"

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
