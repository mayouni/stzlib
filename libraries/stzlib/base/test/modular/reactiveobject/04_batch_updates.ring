# Narrative
# --------
# Batch Updates
#
# Extracted from stzreactiveobjecttest.ring, block #4.

load "../../../stzBase.ring"


pr()

	# Create reactive system
	Rs = new stzReactiveSystem()
	
	# Create reactive object
	oXProduct = Rs.ReactiveObject()
	oXProduct.SetAttribute(:@Name, "")
	oXProduct.SetAttribute(:@Price, 0)
	oXProduct.SetAttribute(:@Category, "")
	oXProduct.SetAttribute(:@InStock, false)
	
	# Watch all attributes to see update order

	oXProduct.Watch(:@Name, func(oSelf, attr, oldval, newval) {
	    ? "  Name updated: " + newval
	})
	
	oXProduct.Watch(:@Price, func(oSelf, attr, oldval, newval) {
	    ? "  Price updated: $" + string(newval)
	})
	
	oXProduct.Watch(:@Category, func(oSelf, attr, oldval, newval) {
	    ? "  Category updated: " + newval
	})
	
	oXProduct.Watch(:@InStock, func(oSelf, attr, oldval, newval) {
	    ? "  Stock status: " + string(newval)
	})
	
	# The three attributes are now under the magic eyies of
	# our reactive system: each change could be captured!

	# Let's change them and check how the change is captured,
	# both when the changes are made indivisually or in bacth!

	Rs.RunAfter(100, func {
		? "Individual updates (watch each change):"

		oXProduct.SetAttribute(:@Name, "Laptop")
		sleep(0.1)

		oXProduct.SetAttribute(:@Price, 999.99)
		sleep(0.1)

		oXProduct.SetAttribute(:@Category, "Electronics")
		sleep(0.1)

		oXProduct.SetAttribute(:@InStock, true)
		
		Rs.RunAfter(1000, func {
			? ""
			? "Batch updates (all changes processed together):"

			oXProduct.Batch(func {
				oXProduct.SetAttribute(:@Name, "Gaming Laptop")
				oXProduct.SetAttribute(:@Price, 1299.99)
				oXProduct.SetAttribute(:@Category, "Gaming")
				oXProduct.SetAttribute(:@InStock, false)
			})
		})
	})
	
	Rs.Start()
	? NL + "✔ Sample completed."

#-->
# Individual updates (watch each change):
#   Name updated: Laptop
#   Price updated: $999.99
#   Category updated: Electronics
#   Stock status: 1
#
# Batch updates (all changes processed together):
#   Name updated: Gaming Laptop
#   Price updated: $1299.99
#   Category updated: Gaming
#   Stock status: 0

# ✔ Sample completed.

pf()
# Executed in 2.32 second(s) in Ring 1.23
