# Narrative
# --------
# Modifying entity properties
#
# Extracted from stzentitytest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

o1 {
	SetProperty("price", 25000) # Or Set@() or @Set() or @(:price = 2500)
	? Property("price") # Or @(:price)
	#--> 25000

	SetName("honda") # Or @(:name = "honda")
	? Name() # Or @(:name)
	#--> honda

	RemoveProperty("color") # or @Remove("color") or Remove@("color")
	? ContainsProperty("color")
	#--> FALSE

	? ContainsValue("camry")
	#--> TRUE

	? ContainsProperty("year") # or ContainsPropOrVal("car") or @Contains() or Contains@()
	#--> TRUE
}

pf()
# Executed in 0.03 second(s) in Ring 1.24
