# Narrative
# --------
# ok!
#
# Extracted from stzchainoftruthtest.ring, block #9.

load "../../stzBase.ring"


? _([]).IsA(:List)._	#--> TRUE
? _(12).IsA(:Number)._	#--> TRUE

? _("g").IsA(:Letter)._	#--> TRUE
? _([ :name = "mio", :age = 12 ]).IsA(:HashList)._	#--> TRUE
? _([ "Tunis", "Cairo", "Prag" ]).IsA(:ListOfStrings)._	#--> TRUE

o1 = new person { name = "ali" }
? _(:o1).IsAn(:Object)._ #--> ERRO: should return 1

class Person
	name
