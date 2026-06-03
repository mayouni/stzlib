# Narrative
# --------
# Basic Attribute Watching
#
# Extracted from stzreactiveobjecttest.ring, block #1.
#ERR Error (R54) : Object attribute redefinition, attribute is already defined!

load "../../stzBase.ring"


pr()

	# Create reactive system
	Rs = new stzReactiveSystem()

	# Create reactive object
	oXUser = Rs.ReactiveObject()
	oXUser.SetAttribute(:@Name, "")
	oXUser.SetAttribute(:@Age, 0)

	# Watch name changes
	oXUser.Watch(:@Name, func(oSelf, attr, oldval, newval) {
		? "╰─> Name changed from (" + @@(oldval) + ") to (" + @@(newval) + ")"
	})

	# Watch age changes
	oXUser.Watch(:@Age, func(oSelf, attr, oldval, newval) {
		? "╰─> Age changed from " + @@(oldval) + " to " + @@(newval)
	})

	# Test Attribute changes
	Rs.RunAfter(100, func {
		? "Setting name to 'John'..."
		oXUser.SetAttribute(:@Name, "John")
		? ""

		Rs.RunAfter(500, func {
			? "Setting age to 25..."
			oXUser.SetAttribute(:@Age, 25)
			? ""

			Rs.RunAfter(500, func {
				? "Changing name to 'John Doe'..."
				oXUser.SetAttribute(:@Name, "John Doe")
			})
		})
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#-->
# Setting name to 'John'...
# ╰─> Name changed from ("") to ("John")
#
# Setting age to 25...
# ╰─> Age changed from 0 to 25
#
# Changing name to 'John Doe'...
# ╰─> Name changed from ("John") to ("John Doe")

# ✔ Sample completed.

pf()
# Executed in 1.98 second(s) in Ring 1.23
