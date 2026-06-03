# Narrative
# --------
# pr()
#
# Extracted from stzreactiveobjecttest.ring, block #7.

load "../../../stzBase.ring"


# Create a regular object instance
oPerson = new Person("John", 25)

# Initialize reactive system
Rs = new stzReactiveSystem()

# Make the existing object reactive
oXPerson = Rs.Reactivate(oPerson)
oXPerson {

	# Add watchers
	Watch(:name, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Name changed: " + oldval + " → " + newval
	})

	Watch(:age, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Age chnaged: " + oldval + " → " + newval
	})

	Watch(:email, func(oSelf, attr, oldval, newval) {
		? CheckMark() + " Email set: " + newval
	})

	? "Starting property changes..."

	@(:name = "Karim")
	@(:age = 30)
	@(:email = "karim@example.com")

}

Rs.Start()
? NL + "✔ Attribute changes completed."

pf()

# Define a regular class
class Person
	name = ""
	age = 0
	email = ""
	
	def Init(cName, nAge)
		name = cName
		age = nAge

#-->
# Starting property changes...
# ✓ Name changed: John → Karim
# ✓ Age chnaged: 25 → 30
# ✓ Email set: karim@example.com
# 
# ✔ Attribute changes completed.

# Executed in 0.96 second(s) in Ring 1.23
