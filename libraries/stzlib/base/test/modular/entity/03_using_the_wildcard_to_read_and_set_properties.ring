# Narrative
# --------
# Using the @() wildcard to read and set properties
#
# Extracted from stzentitytest.ring, block #3.

load "../../../stzBase.ring"


pr()

o1 = new stzEntity([
	:name = "customer",
	:value = "sonibank"
])

o1 {
	# Checking a property

	? @(:name)
	#--> customer

	? @(:value)
	#--> sonibank

	# Setting a property

	@(:value = "cousbox")
	? @(:value)
	#--> cousbox

	# Setting many properties at once
	@([ :name = "partner", :value = "nigercom", :country = "niger" ])

	? @(:name)
	#--> partner

	? @(:value)
	#--> nigercom

	? @(:country)
	#--> niger
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
