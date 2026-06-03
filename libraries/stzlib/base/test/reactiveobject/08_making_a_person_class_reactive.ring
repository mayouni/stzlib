# Narrative
# --------
# Making a Person Class Reactive
#
# Extracted from stzreactiveobjecttest.ring, block #8.

load "../../stzBase.ring"


pr()

# The class used by this example (Person) is defined at the
# end of the code after the pf() function

	# Creating an instance of the Person class

	oPerson = new Person("Youssef", 28)

	# Initialize a Softanza reactive system (Rs)
	Rs = new stzReactiveSystem()

	# Making the Person object reactive
	oXPerson = Rs.ReactivateObject(oPerson)

	# Defining the attributes we want to watch and what
	# would happen when they are changed

	oXPerson.Watch(:name, func(oSelf, attr, oldval, newval) {
		? "✓ Name updated: " + oldval + " → " + newval
	})

	oXPerson.Watch(:age, func(oSelf, attr, oldval, newval) {
		? "✓ Age updated: " + oldval + " → " + newval
	})

	oXPerson.Watch(:email, func(oSelf, attr, oldval, newval) {
		? "✓ Email set: " + newval
	})

	# Changing the attributes and expecting the reactive system
	# to watch the change and fire the functions we definded above

	Rs.RunAfter(100, func {

		oXPerson {
			@(:name = "John Doe")
			@(:age = 26)
			@(:email = "john@test.com")
		}
		
		Rs.RunAfter(500, func {
			? ""
			? "Current person info:"
			oXPerson {
				? "  Name: " + name
				? "  Age: " + age
				? "  Email: " + email
			}
		})
	})

	Rs.Start()
	? NL + "✔ Sample completed."

pf()

class Person
	name = ""
	age = 0
	email = ""
	
	def init(pcName, pnAge)
		name = pcName
		age = pnAge

#-->
# ✓ Name updated: Youssef → John Doe
# ✓ Age updated: 28 → 26
# ✓ Email set: john@test.com
#
# Current person info:
#   Name: John Doe
#   Age: 26
#   Email: john@test.com

# ✔ Sample completed.

# Executed in 1.48 second(s) in Ring 1.23
