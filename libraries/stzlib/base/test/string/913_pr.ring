# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #913.
#ERR panic: @memcpy arguments alias

load "../../stzBase.ring"

pr()

Q("Softanza is awosme!") {

	Replace("awosme", :with = "wonderful")
	? content()
	#--> Softanza is wonderful!

	Undo()
	? Content()
	#--> Softanza is awosme!

	Redo()
	? Content()
	#--> Softanza is wonderful!

	InsertXT("really ", :Before = "wonderful")
	? Content()
	#--> Softanza is really wonderful!

	Undo()
	? Content()
	#--> Softanza is wonderful!
}

pf()
# Executed in 0.03 second(s).
