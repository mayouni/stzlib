# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #521.

load "../../stzBase.ring"


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

#-->
#   name: "mansour"
#   job: "programmer"
#   age: 45
#   
#   name: "selmen"
#   job: "manager"
#   age: 45
#   
#   name: "mahran"
#   job: "manager"
#   age: 45

pf()
# Executed in 0.02 second(s).
