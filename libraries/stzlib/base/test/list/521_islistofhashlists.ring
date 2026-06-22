# Narrative
# --------
# Recognizing and wrapping a list of hash lists (lists of name=value pairs).
#
# @IsListOfHashLists() is the global predicate that returns TRUE when every
# item of the outer list is itself a hashlist -- a list of :key = value
# entries, here three person records sharing the same schema. Once the shape
# is confirmed, new stzListOfHashLists(...) wraps it as a first-class type,
# and Show() renders each record as plain "key : value" rows separated by a
# blank line. Note the renderer prints raw values (no surrounding quotes on
# the strings) and uses " : " as the separator.
#
# Extracted from stzlisttest.ring, block #521.

load "../../stzBase.ring"

pr()

? @IsListOfHashLists([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
]) + NL
#--> TRUE

o1 = new stzListOfHashLists([
	[ :name = "mansour", :job = "programmer", :age = 45 ],
	[ :name = "selmen", :job = "manager", :age = 45 ],
	[ :name = "mahran", :job = "manager", :age = 45 ]
])

o1.Show()

#--> name : mansour
#    job : programmer
#    age : 45
#
#    name : selmen
#    job : manager
#    age : 45
#
#    name : mahran
#    job : manager
#    age : 45

pf()
# Executed in 0.02 second(s).
