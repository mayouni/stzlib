# Narrative
# --------
# Computed Attributes
#
# Extracted from stzreactiveobjecttest.ring, block #2.

load "../../stzBase.ring"


pr()
	
	# Create a reactive system
	Rs = new stzReactiveSystem()
	
	# From inside the reactive system, we create a reactive object

	oXUser = Rs.ReactiveObject()
	oXUser { # Here we craft the object's attributes

		@(:@FirstName = "")	# Or SetAttribute(name, val)
		@(:@LastName = "")
		@(:@FullName = "")
		@(:@Email = "")
		@(:@Age = 0)
		@(:@IsAdult = false)
	}
	
	# Computed Attribute: @fullName depends on @firstName and lastName

	oXUser.Computed(:@FullName,

		func oSelf {
		        cResult = trim(oSelf.GetAttribute(:@FirstName) + " " + oSelf.GetAttribute(:@LastName))
		        return cResult
		},

		[ :@FirstName, :@LastName ]
	)

	
	# Computed Attribute: isAdult depends on age

	oXUser.Computed(:@IsAdult,

		func oSelf {
			return oContext.GetAttribute(:@Age) >= 18
		},

		[ :@Age ]
	)
	
	# Watch computed attributes to see auto-updates

	oXUser.Watch(:@FullName,
		func(oSelf, attr, oldval, newval) {
			? "Full name computed: (" + newval + ")"
		}
	)

	oXUser.Watch(:@IsAdult,
		func(oSelf, attr, oldval, newval) {
			? "Adult status: " + newval
		}
	)
	
	# Test computed attributes
	# SetTimeout is used to givethe reactive loop time to
	# start and perfom subsequent tasks

	Rs.RunAfter(100, func {
		? "Setting firstName to 'Jane'..."
		oXUser.SetAttribute(:@FirstName, "Jane")
		? ""

			Rs.SetTimeout(500, func {
				? "Setting lastName to 'Smith'..."
				oXUser.SetAttribute(:@LastName, "Smith")
				? ""

				Rs.SetTimeout(500, func {
					? "Setting age to 17..."
					oXUser.SetAttribute(:@Age, 17)
					? ""

					Rs.SetTimeout(500, func {
						? "Setting age to 21..."
						oXUser.SetAttribute(:@Age, 21)
					})
				})
			})
		})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#-->
# Setting firstName to 'Jane'...
# Full name computed: (Jane)
#
# Setting lastName to 'Smith'...
# Full name computed: (Jane Smith)
#
# Setting age to 17...
#
# Setting age to 21...
#
# Adult status: 1

# ✔ Sample completed.

pf()
# Executed in 2.52 second(s) in Ring 1.23
